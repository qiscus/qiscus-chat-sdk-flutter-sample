import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import '../constants.dart';
import '../extensions.dart';
import '../qiscus_util.dart';
import '../widget/avatar_widget.dart';
import 'add_participant_page.dart';

class ChatRoomDetailPage extends StatefulWidget {
  const ChatRoomDetailPage({
    super.key,
    required this.chatRoomId,
  });

  final int chatRoomId;

  @override
  ChatRoomDetailPageState createState() => ChatRoomDetailPageState();
}

class ChatRoomDetailPageState extends State<ChatRoomDetailPage> {
  late int chatRoomId = widget.chatRoomId;

  Future<void> _initializePage(BuildContext context) async {
    await context.read<QiscusUtil>().getRoomWithId(chatRoomId);
  }

  @override
  Widget build(BuildContext context) {
    var qiscus = context.watch<QiscusUtil>();
    var room = context.select<QiscusUtil, QChatRoom>(
        (it) => it.rooms.firstWhere((r) => r.id == chatRoomId));
    final isSingle = room.type == QRoomType.single;
    // final isChannel = room.type == QRoomType.channel;

    return FutureBuilder(
      future: _initializePage(context),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text(room.name!),
          ),
          floatingActionButton: !isSingle
              ? FloatingActionButton(
                  onPressed: () async {
                    context.push(AddParticipantPage(chatRoomId: chatRoomId));
                  },
                  child: const Icon(Icons.add),
                )
              : null,
          body: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Hero(
                      tag: HeroTags.roomAvatar(roomId: room.id),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: Image.network(
                          room.avatarUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (!isSingle)
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: IconButton(
                          onPressed: () async {
                            var file = await FilePicker.platform
                                .getFile(type: FileType.image);
                            if (file != null) {
                              Future.microtask(() async {
                                var stream =
                                    context.read<QiscusSDK>().upload(file);
                                var completer = Completer<QChatRoom>();
                                var progress = await stream.last;
                                var url = progress.data!;
                                await qiscus.updateChatRoom(
                                  roomId: chatRoomId,
                                  avatarUrl: url,
                                );
                                return completer.future;
                              });
                            }
                          },
                          icon: const Icon(Icons.image),
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: room.participants.length,
                    itemBuilder: (context, index) {
                      var user = room.participants[index];
                      return ListTile(
                        title: Text(user.name),
                        leading: Avatar(url: user.avatarUrl!),
                        trailing: IconButton(
                          onPressed: () async {
                            await qiscus.removeParticipants(
                              roomId: room.id,
                              userIds: [user.id],
                            );
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
