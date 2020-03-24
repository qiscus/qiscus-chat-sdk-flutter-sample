import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sample/src/state/state.dart';
import 'package:qiscus_chat_sample/src/widget/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChatState();
}

class _ChatState extends State<ChatPage> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext ctx) {
    return FutureBuilder(
      future: Future.wait([_getRoom(), _getMessages()]),
      builder: (ctx, snapshot) => Scaffold(
        appBar: buildAppBar(ctx),
        body: Column(
          children: [
            _messageList(ctx),
            _form(ctx),
          ],
        ),
      ),
    );
  }

  Widget buildLoading() {
    return Expanded(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: false,
      elevation: 0,
      leading: FlatButton(
        child: Icon(
          Icons.chevron_left,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pushReplacementNamed('/login');
        },
      ),
      title: Consumer<RoomState>(
        builder: (_, state, __) {
          if (state.currentRoom == null) {
            return Text('Loading...');
          } else {
            return Text(state.currentRoom.name);
          }
        },
      ),
    );
  }

  Widget _form(BuildContext ctx) {
    var roomId = ModalRoute.of(ctx).settings.arguments;
    final controller = TextEditingController();
    final key = GlobalKey<FormState>();
    var messageState = Provider.of<MessageState>(context, listen: false);

    final submit = (String message) {
      messageState.submit(
        roomId: roomId,
        message: message,
      );
      controller.text = '';
      _animateScrollToBottom();
    };
    return Form(
      key: key,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controller,
                onFieldSubmitted: (str) {
                  if (str.isNotEmpty) {
                    submit(str);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Type your message here',
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                submit(controller.text);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _messageList(BuildContext ctx) {
    return Expanded(
      child: Consumer<MessageState>(
        builder: (_, state, __) {
          var reversed = state.messages.reversed;
          return ListView.builder(
            itemCount: state.messages.length,
            itemBuilder: (ctx, id) {
              var message = reversed.elementAt(id);
              return ChatBubble(message: message);
            },
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 10),
          );
        },
      ),
    );
  }

  Future _getMessages() async {
    var roomId = ModalRoute.of(context).settings.arguments;
    var messageState = Provider.of<MessageState>(context, listen: false);
    await messageState.getAllMessage(roomId);
    messageState.subscribeChatRoom(messageReceivedCallback: () {
      _animateScrollToBottom();
    });
  }

  void _animateScrollToBottom() {
    Timer(const Duration(milliseconds: 400), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.ease,
      );
    });
  }

  Future _getRoom() async {
    var roomId = ModalRoute.of(context).settings.arguments;
    await Provider.of<RoomState>(context, listen: false).getRoomWithId(roomId);
  }
}
