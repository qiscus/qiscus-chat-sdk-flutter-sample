import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import '../constants.dart';
import '../extensions.dart';
import '../widget/avatar_widget.dart';
import 'add_participant_page.dart';

class ChatRoomDetailPage extends StatefulWidget {
  ChatRoomDetailPage({
    @required this.qiscus,
    @required this.account,
    @required this.room,
  });

  final QiscusSDK qiscus;
  final QAccount account;
  final QChatRoom room;

  @override
  _ChatRoomDetailPageState createState() => _ChatRoomDetailPageState();
}

class _ChatRoomDetailPageState extends State<ChatRoomDetailPage> {
  QiscusSDK qiscus;
  QAccount account;
  QChatRoom room;

  @override
  void initState() {
    super.initState();

    qiscus = widget.qiscus;
    account = widget.account;
    room = widget.room;

    scheduleMicrotask(() async {
      var rooms = await qiscus.getChatRooms$(roomIds: [
        this.room.id,
      ], showParticipants: true);

      setState(() {
        this.room = rooms.first;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSingle = room.type == QRoomType.single;
    final isChannel = room.type == QRoomType.channel;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop(this.room);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(room.name),
      ),
      floatingActionButton: !isSingle
          ? FloatingActionButton(
              onPressed: () async {
                var room = await context.push<QChatRoom>(AddParticipantPage(
                  qiscus: qiscus,
                  account: account,
                  room: this.room,
                ));
                setState(() {
                  this.room = room;
                });
              },
              child: Icon(Icons.add),
            )
          : null,
      body: Container(
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
                      room.avatarUrl,
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
                        var file =
                            await FilePicker.getFile(type: FileType.image);
                        if (file != null) {
                          var room = await Future.microtask(() async {
                            var url = await qiscus.upload$(file);
                            var completer = Completer<QChatRoom>();
                            qiscus.updateChatRoom(
                              roomId: this.room.id,
                              avatarUrl: url,
                              callback: (room, error) {
                                if (error != null) {
                                  return completer.completeError(error);
                                }
                                return completer.complete(room);
                              },
                            );
                            return completer.future;
                          });
                          if (this.mounted) {
                            setState(() {
                              this.room = room;
                            });
                          }
                        }
                      },
                      icon: Icon(Icons.image),
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: this.room.participants.length,
                itemBuilder: (context, index) {
                  var user = this.room.participants[index];
                  return ListTile(
                    title: Text(user.name),
                    leading: Avatar(url: user.avatarUrl),
                    trailing: IconButton(
                      onPressed: () async {
                        await qiscus.removeParticipants$(
                            roomId: room.id, userIds: [user.id]);
                        setState(() {
                          this
                              .room
                              .participants
                              .removeWhere((u) => u.id == user.id);
                        });
                      },
                      icon: Icon(Icons.remove_circle_outline),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
