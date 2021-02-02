import 'dart:async';
import 'dart:collection';

import 'package:date_format/date_format.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
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
        data.messages.sort((m1, m2) => m1.timestamp.compareTo(m2.timestamp));
        if (data.messages.length > 0) {
          room.lastMessage = data.messages.last;
        }
      });

      qiscus.subscribeChatRoom(room);
      _onMessageReceivedSubscription = qiscus
          .onMessageReceived$()
          .takeWhile((_) => this.mounted)
          .listen(_onMessageReceived);
      _onMessageDeliveredSubscription = qiscus
          .onMessageDelivered$()
          .takeWhile((_) => this.mounted)
          .listen((it) => _onMessageDelivered(it.uniqueId));
      _onMessageReadSubscription = qiscus
          .onMessageRead$()
          .takeWhile((_) => this.mounted)
          .listen((it) => _onMessageRead(it.uniqueId));
      _onMessageDeletedSubscription = qiscus
          .onMessageDeleted$()
          .takeWhile((_) => this.mounted)
          .listen((it) => _onMessageDeleted(it.uniqueId));

      _onUserTyping();
      _onUserPresence();
      if (room.lastMessage != null) {
        qiscus.markAsRead(
          roomId: room.id,
          messageId: room.lastMessage.id,
          callback: (err) {
            if (this.mounted) {
              setState(() {
                this.room.unreadCount = 0;
              });
            }
          },
        );
      }
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
                      callback: (error) {
                        if (error != null) {
                          print('got error while clearing room: $error');
                        } else {
                          setState(() {
                            this.messages.clear();
                          });
                        }
                      });
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
                        return FlatButton(
                          child: const Text('Delete message'),
                          onPressed: () {
                            qiscus.deleteMessages(
                                messageUniqueIds: [message.uniqueId],
                                callback: (messages, error) {
                                  Navigator.pop(context);
                                  if (error != null) {
                                    print(
                                        'got error while deleting message: $error');
                                  } else {
                                    print('messages: $messages');
                                  }
                                });
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
                    //
                    showDialog(
                      context: context,
                      builder: (context) {
                        return EmojiPicker(
                          onEmojiSelected: (emoji, category) {
                            print('emoji($emoji) category($category)');
                            messageInputController.text += emoji.emoji;
                          },
                        );
                      },
                    );
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
    var file = await FilePicker.getFile(type: FileType.image);
    if (file != null) {
      var message = qiscus.generateFileAttachmentMessage(
        chatRoomId: room.id,
        caption: file.path.split('/').last,
        url: file.uri.toString(),
        text: 'Image attachment',
        size: file.lengthSync(),
      );
      message.payload['progress'] = 0;
      setState(() {
        this.messages.addAll({
          message.uniqueId: message,
        });
      });

      var urlCompleter = Completer<String>();
      qiscus.upload(
        file: file,
        callback: (error, progress, url) {
          print('@upload: error($error), progress($progress), url($url)');
          if (progress != null) {
            setState(() {
              this.messages.update(message.uniqueId, (m) {
                m.payload['progress'] = progress;
                return m;
              });
            });
          }
          if (error != null) {
            urlCompleter.completeError(error);
          }
          if (url != null) {
            urlCompleter.complete(url);
          }
        },
      );
      var url = await urlCompleter.future;

      setState(() {
        this.messages.update(message.uniqueId, (m) {
          message.payload['url'] = url;
          m.payload['url'] = url;
          return m;
        });
      });

      var _message = await qiscus.sendMessage$(
        message: message,
      );
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
    final lastMessage = room.lastMessage;
    setState(() {
      this.messages.addAll({
        message.uniqueId: message,
      });

      if (lastMessage.timestamp.isBefore(message.timestamp)) {
        room.lastMessage = message;
      }
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

    _onUserTypingSubscription = qiscus
        .onUserTyping$()
        .takeWhile((_) => this.mounted)
        .where((t) => t.userId != qiscus.currentUser.id)
        .listen((typing) {
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
