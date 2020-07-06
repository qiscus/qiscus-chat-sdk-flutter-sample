import 'dart:async';
import 'dart:collection';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:qiscus_chat_sample/constants.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'chat_bubble_widget.dart';

class ChatPage extends StatefulWidget {
  final QiscusSDK qiscus;
  final QAccount account;
  final QChatRoom room;

  ChatPage({
    @required this.qiscus,
    @required this.account,
    @required this.room,
  });

  static MaterialPageRoute route({
    @required QiscusSDK qiscus,
    @required QAccount account,
    @required QChatRoom room,
  }) {
    return MaterialPageRoute(
      builder: (c) => ChatPage(
        qiscus: qiscus,
        account: account,
        room: room,
      ),
    );
  }

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  QiscusSDK qiscus;
  QAccount account;
  QChatRoom room;
  var messages = HashMap<String, QMessage>();

  final messageInputController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    qiscus = widget.qiscus;
    account = widget.account;
    room = widget.room;

    scheduleMicrotask(() async {
      var data = await qiscus.getChatRoomWithMessages$(roomId: room.id);
      setState(() {
        messages.addEntries(data.messages.map((msg) => MapEntry(
              msg.uniqueId,
              msg,
            )));
        room = data.room;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var messages = this.messages.values.toList()
      ..sort((m1, m2) {
        return m1.timestamp.compareTo(m2.timestamp);
      });
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop<QChatRoom>(context, room);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Row(
          children: <Widget>[
            Hero(
              tag: HeroTags.roomAvatar(roomId: room.id),
              child: CircleAvatar(
                backgroundImage: Image.network(room.avatarUrl).image,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(room.name),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GroupedListView<QMessage, String>(
              sort: false,
              controller: scrollController,
              elements: messages,
              groupBy: (QMessage message) {
                return formatDate(message.timestamp, [dd, ' ', MM, ' ', yyyy]);
              },
              groupSeparatorBuilder: (message) {
                return Center(
                  child: Container(
                    width: 150,
                    height: 25,
                    decoration: BoxDecoration(
                      border: Border.fromBorderSide(BorderSide(
                        color: Colors.black12,
                        width: 1.0,
                      )),
                      borderRadius: BorderRadius.all(Radius.elliptical(5, 1)),
                      color: Colors.white,
                    ),
                    child: Center(child: Text(message)),
                  ),
                );
              },
              itemBuilder: (context, message) {
                final sender = message.sender;
                return ChatBubble(
                  message: message,
                  flipped: sender.id == account.id,
                );
              },
            ),
          ),
          Container(
            child: TextField(
              controller: messageInputController,
              onSubmitted: (_) async {
                var newMessage = qiscus.generateMessage(
                  chatRoomId: room.id,
                  text: messageInputController.text,
                );
                messageInputController.clear();

                setState(() {
                  this.messages.addAll({
                    newMessage.uniqueId: newMessage,
                  });
                });

                var m = await qiscus.sendMessage$(message: newMessage);
                print('message: $m');
                setState(() {
                  this.messages.update(newMessage.uniqueId, (_) {
                    return m;
                  });
                  room.lastMessage = m;
                });

                scrollController.animateTo(
                  ((this.messages.length + 1) * 200.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linear,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
