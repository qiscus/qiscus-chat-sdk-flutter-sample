import 'dart:async';
import 'dart:collection';

import 'package:timeago/timeago.dart' as timeago;
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:qiscus_chat_sample/avatar_widget.dart';
import 'package:qiscus_chat_sample/constants.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'chat_bubble_widget.dart';
import 'extensions.dart';

class ChatPage extends StatefulWidget {
  final QiscusSDK qiscus;
  final QAccount account;
  final QChatRoom room;

  ChatPage({
    @required this.qiscus,
    @required this.account,
    @required this.room,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  QiscusSDK qiscus;
  QAccount account;
  QChatRoom room;

  bool isUserTyping = false;
  String userTyping;
  DateTime lastOnline;
  bool isOnline = false;

  var messages = HashMap<String, QMessage>();

  StreamSubscription<QMessage> _onMessageReceivedSubscription;
  StreamSubscription<QMessage> _onMessageReadSubscription;
  StreamSubscription<QMessage> _onMessageDeliveredSubscription;

  final messageInputController = TextEditingController();
  final scrollController = ScrollController();

  StreamSubscription<QMessage> _onMessageDeletedSubscription;

  StreamSubscription<QUserTyping> _onUserTypingSubscription;

  StreamSubscription<QUserPresence> _onUserPresenceSubscription;

  @override
  void initState() {
    super.initState();
    qiscus = widget.qiscus;
    account = widget.account;
    room = widget.room;

    scheduleMicrotask(() async {
      var data = await qiscus.getChatRoomWithMessages$(roomId: room.id);
      setState(() {
        var entries = data.messages.map((m) {
          return MapEntry(
            m.uniqueId,
            m,
          );
        });
        messages.addEntries(entries);
        room = data.room;
        if (data.messages.length > 0) {
          room.lastMessage = data.messages.last;
        }
      });

      qiscus.enableDebugMode(enable: true);
      qiscus.subscribeChatRoom(room);
      _onMessageReceivedSubscription =
          qiscus.onMessageReceived$().listen(_onMessageReceived);
      _onMessageDeliveredSubscription = qiscus
          .onMessageDelivered$()
          .listen((it) => _onMessageDelivered(it.uniqueId));
      _onMessageReadSubscription =
          qiscus.onMessageRead$().listen((it) => _onMessageRead(it.uniqueId));
      _onMessageDeletedSubscription = qiscus
          .onMessageDeleted$()
          .listen((it) => _onMessageDeleted(it.uniqueId));

      _onUserTyping();
      _onUserPresence();
      await qiscus.markAsRead$(roomId: room.id, messageId: room.lastMessage.id);
    });
  }

  @override
  void dispose() {
    super.dispose();
    qiscus.unsubscribeChatRoom(room);
    _onMessageReceivedSubscription?.cancel();
    _onMessageDeliveredSubscription?.cancel();
    _onMessageReadSubscription?.cancel();
    _onMessageDeletedSubscription?.cancel();
    _onUserTypingSubscription?.cancel();
    _onUserPresenceSubscription?.cancel();
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
            room.lastMessage = messages.last;
            context.pop<QChatRoom>(room);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Row(
          children: <Widget>[
            Expanded(
              flex: 0,
              child: Hero(
                tag: HeroTags.roomAvatar(roomId: room.id),
                child: Avatar(url: room.avatarUrl),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(room.name),
                    if (room.type == QRoomType.single && !isUserTyping)
                      Text(
                        isOnline
                            ? 'Online'
                            : lastOnline != null
                                ? timeago.format(lastOnline)
                                : 'Offline',
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    if (isUserTyping)
                      Text(
                        '$userTyping is typing...',
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.attach_file),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.fromBorderSide(BorderSide(
                          width: 1,
                          color: Colors.black12,
                        )),
                      ),
                      child: TextField(
                        controller: messageInputController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _sendMessage(),
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (messageInputController.text.trim().isEmpty) return;

    final text = messageInputController.text;

    var message = qiscus.generateMessage(chatRoomId: room.id, text: text);
    setState(() {
      this.messages.update(message.uniqueId, (m) {
        return message;
      }, ifAbsent: () => message);
    });

    var _message = await qiscus.sendMessage$(message: message);
    setState(() {
      this.messages.update(_message.uniqueId, (m) {
        return _message;
      }, ifAbsent: () => _message);
      this.room.lastMessage = _message;
    });

    messageInputController.clear();

    scrollController.animateTo(
      ((this.messages.length + 1) * 200.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }

  Future<void> _onMessageReceived(QMessage message) async {
    setState(() {
      this.messages.addAll({
        message.uniqueId: message,
      });
      this.room.lastMessage = message;
    });
    if (message.chatRoomId == room.id) {
      await qiscus.markAsRead$(roomId: room.id, messageId: message.id);
    }
  }

  void _onMessageDelivered(String uniqueId) {
    var targetedMessage = this.messages[uniqueId];

    if (targetedMessage != null) {
      setState(() {
        this.messages.updateAll((key, message) {
          if (message.status == QMessageStatus.read) return message;
          if (message.timestamp.isAfter(targetedMessage.timestamp)) {
            return message;
          }

          message.status = QMessageStatus.delivered;
          return message;
        });
      });
    }
  }

  void _onMessageRead(String uniqueId) {
    var targetedMessage = this.messages[uniqueId];
    print('$uniqueId, $targetedMessage');

    if (targetedMessage != null) {
      setState(() {
        this.messages.updateAll((key, message) {
          if (message.timestamp.isAfter(targetedMessage.timestamp)) {
            return message;
          }

          message.status = QMessageStatus.read;
          return message;
        });
      });
    }
  }

  void _onMessageDeleted(String uniqueId) {
    setState(() {
      this.messages.removeWhere((key, value) => key == uniqueId);
    });
  }

  void _onUserTyping() {
    Timer timer;

    _onUserTypingSubscription = qiscus.onUserTyping$().listen((typing) {
      print('on user typing: $typing');
      if (timer != null && timer.isActive) timer.cancel();

      setState(() {
        isUserTyping = true;
        userTyping = typing.userId;
      });

      timer = Timer(const Duration(seconds: 2), () {
        setState(() {
          isUserTyping = false;
          userTyping = null;
        });
      });
    });
  }

  void _onUserPresence() {
    if (room.type != QRoomType.single) return;

    var partnerId =
        room.participants.where((it) => it.id != account.id).first?.id;
    if (partnerId == null) return;

    qiscus.subscribeUserOnlinePresence(partnerId);
    _onUserPresenceSubscription = qiscus
        .onUserOnlinePresence$()
        .where((it) => it.userId == partnerId)
        .listen((data) {
      setState(() {
        this.isOnline = data.isOnline;
        this.lastOnline = data.lastOnline;
      });
    });
  }
}
