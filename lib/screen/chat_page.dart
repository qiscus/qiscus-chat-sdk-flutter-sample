import 'dart:async';

import 'package:date_format/date_format.dart';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../constants.dart';
import '../extensions.dart';
import '../qiscus_util.dart';
import '../widget/avatar_widget.dart';
import '../widget/chat_bubble_widget.dart';
import 'chat_room_detail_page.dart';

enum _PopupMenu {
  detail,
  clearMessages,
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.chatRoomId});

  final int chatRoomId;

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  bool isOnline = false;
  bool isEmojiPickerExpanded = false;
  late int chatRoomId = widget.chatRoomId;

  final messageInputController = TextEditingController();
  final scrollController = ScrollController();
  QChatRoom? room;
  QiscusUtil? qiscus;

  late StreamSubscription _messageReceivedSubscription;
  late StreamSubscription _roomClearedSubscription;

  Future<void> _initializePage(BuildContext context) async {
    var qiscus = context.read<QiscusUtil>();
    var room = await qiscus.getRoomWithId(chatRoomId);
    await qiscus.getInitialMessages(room);

    setState(() {
      this.room = room;
      this.qiscus = qiscus;
    });

    qiscus.subscribeRoom(room);
    qiscus.subscribePresence(room);
  }

  @override
  void initState() {
    scheduleMicrotask(() {
      _initializePage(context);
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (room != null) {
      qiscus?.unsubscribeRoom(room!);
    }
  }

  @override
  Widget build(BuildContext context) {
    var qiscus = context.watch<QiscusUtil>();
    var account = qiscus.getCurrentUser();
    var messages = QiscusUtil.getMessagesFor(context, chatRoomId: chatRoomId);

    var presence = QiscusUtil.getPresenceForRoomId(context, chatRoomId);
    var typing = QiscusUtil.getTypingForRoomId(context, chatRoomId);

    context.debugLog('room: $room');

    return WillPopScope(
      onWillPop: () async {
        // _messageReceivedSubscription.cancel();
        // _roomClearedSubscription.cancel();

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Row(
            children: <Widget>[
              Expanded(
                flex: 0,
                child: Hero(
                  tag: HeroTags.roomAvatar(roomId: chatRoomId),
                  child: room == null
                      ? const CircularProgressIndicator()
                      : Avatar(url: room!.avatarUrl!),
                ),
              ),
              _buildTitle(room, typing, presence, context),
            ],
          ),
          actions: _buildActions(context, room),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: GroupedListView<QMessage, String>(
                sort: false,
                controller: scrollController,
                elements: messages,
                groupBy: (QMessage message) {
                  return formatDate(
                      message.timestamp, [dd, ' ', MM, ' ', yyyy]);
                },
                groupSeparatorBuilder: (message) {
                  return Center(
                    child: Container(
                      width: 150,
                      height: 25,
                      decoration: const BoxDecoration(
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
                    flipped: sender.id == account?.id,
                    onPress: (data) {
                      if(data != null){
                        _sendMessagePostBack(context, data);
                        Future.delayed(const Duration(milliseconds: 300), () {
                          scrollController.jumpTo(scrollController.position.maxScrollExtent);
                        });
                      }else{
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SafeArea(
                              child: TextButton(
                                child: const Text('Delete message'),
                                onPressed: () {
                                  qiscus.deleteMessages(
                                    messageUniqueIds: [message.uniqueId],
                                  ).then((_) => Navigator.pop(context));
                                },
                              ),
                            );
                          },
                        );
                      }
                    },
                  );
                },
              ),
            ),
            SafeArea(
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => _onUpload(context),
                    icon: const Icon(Icons.attach_file),
                  ),
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions),
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
                        decoration: const BoxDecoration(
                          border: Border.fromBorderSide(BorderSide(
                            width: 1,
                            color: Colors.black12,
                          )),
                        ),
                        child: TextField(
                          controller: messageInputController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.send,
                          onChanged: (_) => _publishTyping(context),
                          onSubmitted: (_) => _sendMessage(context),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _sendMessage(context),
                    icon: const Icon(Icons.send),
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
      ),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    QChatRoom? room,
  ) {
    var qiscus = context.watch<QiscusUtil>();
    return <Widget>[
      PopupMenuButton<_PopupMenu>(
        itemBuilder: (context) {
          return [
            const PopupMenuItem(
              value: _PopupMenu.detail,
              child: Text('Detail'),
            ),
            const PopupMenuItem(
              value: _PopupMenu.clearMessages,
              child: Text('Clear messages'),
            ),
          ];
        },
        onSelected: (menu) async {
          switch (menu) {
            case _PopupMenu.detail:
              await context.push(ChatRoomDetailPage(chatRoomId: chatRoomId));
              break;
            case _PopupMenu.clearMessages:
              qiscus.clearMessagesByChatRoomId(roomUniqueIds: [room!.uniqueId]);
              break;
            default:
              break;
          }
        },
      ),
    ];
  }

  Expanded _buildTitle(QChatRoom? room, QUserTyping? typing,
      QUserPresence? presence, BuildContext context) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            room == null ? const CircularProgressIndicator() : Text(room.name!),
            if (typing == null && presence != null)
              _buildOnlinePresence(context, presence),
            if (typing != null) _buildTyping(context, typing),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlinePresence(BuildContext context, QUserPresence presence) {
    var isOnline = presence.isOnline;
    var lastSeen = presence.lastSeen;

    return Text(
      isOnline
          ? 'Online'
          // ignore: unnecessary_null_comparison
          : lastSeen != null
              ? timeago.format(lastSeen)
              : 'Offline',
      style: const TextStyle(
        fontSize: 10,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget _buildTyping(BuildContext context, QUserTyping typing) {
    var userId = typing.userId;
    return Text(
      '$userId is typing...',
      style: const TextStyle(
        fontSize: 10,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  void _publishTyping(BuildContext context) {
    var qiscus = context.read<QiscusSDK>();
    Timer? timer;

    if (timer != null && timer.isActive == true) timer.cancel();

    qiscus.publishTyping(roomId: chatRoomId, isTyping: true);
    timer = Timer(const Duration(seconds: 1), () {
      qiscus.publishTyping(roomId: chatRoomId, isTyping: false);
    });
  }

  void _onUpload(BuildContext context) async {
    var sdk = context.read<QiscusSDK>();
    var qiscus = context.read<QiscusUtil>();
    var scaffold = ScaffoldMessenger.of(context);

    try {
      var file = await FilePicker.platform.getFile(type: FileType.image);
      if (file != null) {
        var message = sdk.generateFileAttachmentMessage(
          chatRoomId: chatRoomId,
          caption: file.path.split('/').last,
          url: file.uri.toString(),
          text: 'Image attachment',
          size: await file.length(),
        );

        await qiscus.uploadMessage(message: message, file: file);
      }
    } catch (err) {
      context.debugLog(err.toString());
      scaffold.showSnackBar(SnackBar(
        content: Text("Error while reading files: ${err.runtimeType}"),
      ));
    }
  }

  Future<void> _sendMessage(BuildContext context) async {
    if (messageInputController.text.trim().isEmpty) return;

    var qiscus = context.read<QiscusUtil>();

    final text = messageInputController.text;

    var message = context
        .read<QiscusSDK>()
        .generateMessage(chatRoomId: chatRoomId, text: text);

    await qiscus.sendMessage(message: message);
    Future.delayed(const Duration(milliseconds: 300), () {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });

    messageInputController.clear();
  }

  Future<void> _sendMessagePostBack(BuildContext context, String postBackMessage) async {
    var qiscus = context.read<QiscusUtil>();

    var message = context
        .read<QiscusSDK>()
        .generateMessage(chatRoomId: chatRoomId, text: postBackMessage);

    await qiscus.sendMessage(message: message);

    messageInputController.clear();
  }
}
