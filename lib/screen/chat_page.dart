import 'dart:async';
import 'dart:collection';

import 'package:date_format/date_format.dart';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../constants.dart';
import '../extensions.dart';
import '../widget/avatar_widget.dart';
import '../widget/chat_bubble_widget.dart';
import 'chat_room_detail_page.dart';

enum _PopupMenu {
  detail,
  clearMessages,
}

class ChatPage extends StatefulWidget {
  final QiscusSDK qiscus;
  final QAccount account;
  final QChatRoom room;

  ChatPage({
    required this.qiscus,
    required this.account,
    required this.room,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late QiscusSDK qiscus = widget.qiscus;
  late QAccount account = widget.account;
  late QChatRoom room = widget.room;

  bool isUserTyping = false;
  String? userTyping;
  DateTime? lastOnline;
  bool isOnline = false;
  bool isEmojiPickerExpanded = false;

  var messages = HashMap<String, QMessage>();

  final messageInputController = TextEditingController();
  final scrollController = ScrollController();

  StreamSubscription<QUserTyping>? _onUserTypingSubscription;
  StreamSubscription<QUserPresence>? _onUserPresenceSubscription;

  late StreamSubscription<QMessage> _onMessageReceivedSubscription = qiscus
      .onMessageReceived()
      .takeWhile((_) => this.mounted)
      .listen(_onMessageReceived);
  late StreamSubscription<QMessage> _onMessageDeliveredSubscription = qiscus
      .onMessageDelivered()
      .takeWhile((_) => this.mounted)
      .listen((it) => _onMessageDelivered(it.uniqueId));
  late StreamSubscription<QMessage> _onMessageReadSubscription = qiscus
      .onMessageRead()
      .takeWhile((_) => this.mounted)
      .listen((it) => _onMessageRead(it.uniqueId));
  late StreamSubscription<QMessage> _onMessageDeletedSubscription = qiscus
      .onMessageDeleted()
      .takeWhile((_) => this.mounted)
      .listen((it) => _onMessageDeleted(it.uniqueId));

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      var data = await qiscus.getChatRoomWithMessages(roomId: room.id);
      setState(() {
        var entries = data.messages.map((m) {
          return MapEntry(
            m.uniqueId,
            m,
          );
        });
        messages.addEntries(entries);
        room = data.room;
        data.messages.sort((m1, m2) => m1.timestamp.compareTo(m2.timestamp));
        if (data.messages.length > 0) {
          room.lastMessage = data.messages.last;
        }
      });

      qiscus.subscribeChatRoom(room);

      _onUserTyping();
      _onUserPresence();
      if (room.lastMessage != null) {
        qiscus
            .markAsRead(roomId: room.id, messageId: room.lastMessage!.id)
            .then((_) => setState(() => this.room.unreadCount = 0));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    qiscus.unsubscribeChatRoom(room);
    _onMessageReceivedSubscription.cancel();
    _onMessageDeliveredSubscription.cancel();
    _onMessageReadSubscription.cancel();
    _onMessageDeletedSubscription.cancel();
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
            setState(() {
              if (messages.isEmpty) {
                room.lastMessage = null;
              } else {
                room.lastMessage = messages.last;
              }
            });
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
                child: Avatar(url: room.avatarUrl!),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(room.name!),
                    if (room.type == QRoomType.single && !isUserTyping)
                      Text(
                        isOnline
                            ? 'Online'
                            : lastOnline != null
                                ? timeago.format(lastOnline!)
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
        actions: <Widget>[
          PopupMenuButton<_PopupMenu>(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text('Detail'),
                  value: _PopupMenu.detail,
                ),
                PopupMenuItem(
                  child: Text('Clear messages'),
                  value: _PopupMenu.clearMessages,
                ),
              ];
            },
            onSelected: (menu) async {
              switch (menu) {
                case _PopupMenu.detail:
                  await context.push<QChatRoom>(ChatRoomDetailPage(
                    qiscus: qiscus,
                    account: account,
                    room: this.room,
                  ));
                  break;
                case _PopupMenu.clearMessages:
                  qiscus.clearMessagesByChatRoomId(
                    roomUniqueIds: [this.room.uniqueId],
                  ).then((_) => setState(() => this.messages.clear()));
                  break;
                default:
                  break;
              }
            },
          ),
        ],
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
                  onPress: () {
                    print('on message pressed: $message');
                    // var snackbar = SnackBar(content: Text('Deleting message'));
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return TextButton(
                          child: const Text('Delete message'),
                          onPressed: () {
                            qiscus.deleteMessages(
                              messageUniqueIds: [message.uniqueId],
                            ).then((_) => Navigator.pop(context));
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Container(
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: _onUpload,
                  icon: Icon(Icons.attach_file),
                ),
                IconButton(
                  icon: Icon(Icons.emoji_emotions),
                  onPressed: () {
                    setState(() {
                      isEmojiPickerExpanded = !isEmojiPickerExpanded;
                    });
                  },
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
                        onChanged: (_) => _publishTyping(),
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
          // if (isEmojiPickerExpanded)
          //   Container(
          //     height: 250,
          //     color: Colors.blueGrey,
          //     child: EmojiPicker(
          //       config: Config(),
          //       onEmojiSelected: (category, emoji) {
          //         print('emoji($emoji) category($category)');
          //         messageInputController.text += emoji.emoji;
          //       },
          //     ),
          //   ),
        ],
      ),
    );
  }

  void _publishTyping() {
    qiscus.publishTyping(roomId: room.id, isTyping: true);
    Timer(const Duration(seconds: 1), () {
      qiscus.publishTyping(roomId: room.id, isTyping: false);
    });
  }

  void _onUpload() async {
    var file = await FilePicker.platform.getFile(type: FileType.image);
    if (file != null) {
      var message = qiscus.generateFileAttachmentMessage(
        chatRoomId: room.id,
        caption: file.path.split('/').last,
        url: file.uri.toString(),
        text: 'Image attachment',
        size: await file.length(),
      );
      message.payload?['progress'] = 0;
      setState(() {
        this.messages.addAll({
          message.uniqueId: message,
        });
      });

      var urlCompleter = Completer<String>();
      var stream = qiscus.upload(file);
      stream.listen((progress) {
        var _progress = progress.progress;
        var url = progress.data;
        print('@upload: progress($_progress), url($url)');
        setState(() {
          this.messages.update(message.uniqueId, (m) {
            m.payload?['progress'] = progress;
            return m;
          });
        });

        if (url != null) {
          urlCompleter.complete(url);
        }
      }, onError: (error) {
        urlCompleter.completeError(error);
      });
      var url = await urlCompleter.future;

      setState(() {
        this.messages.update(message.uniqueId, (m) {
          message.payload?['url'] = url;
          m.payload?['url'] = url;
          return m;
        });
      });

      var _message = await qiscus.sendMessage(message: message);
      setState(() {
        this.messages.update(message.uniqueId, (value) {
          return _message;
        });
      });
    }
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

    var _message = await qiscus.sendMessage(message: message);
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
    final lastMessage = room.lastMessage;
    setState(() {
      this.messages.addAll({
        message.uniqueId: message,
      });

      if (lastMessage?.timestamp.isBefore(message.timestamp) == true) {
        room.lastMessage = message;
      }
    });
    if (message.chatRoomId == room.id) {
      await qiscus.markAsRead(roomId: room.id, messageId: message.id);
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
    late Timer? timer;

    _onUserTypingSubscription = qiscus
        .onUserTyping()
        .takeWhile((_) => this.mounted)
        .where((t) => t.userId != qiscus.currentUser?.id)
        .listen((typing) {
      if (timer != null && timer?.isActive == true) timer?.cancel();

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

    try {
      var partnerId =
          room.participants.where((it) => it.id != account.id).first.id;

      qiscus.subscribeUserOnlinePresence(partnerId);
      _onUserPresenceSubscription = qiscus
          .onUserOnlinePresence()
          .where((it) => it.userId == partnerId)
          .listen((data) {
        setState(() {
          this.isOnline = data.isOnline;
          this.lastOnline = data.lastSeen;
        });
      });
    } on StateError {}
  }
}
