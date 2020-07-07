import 'dart:async';
import 'dart:collection';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qiscus_chat_sample/constants.dart';
import 'package:qiscus_chat_sample/user_list_page.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'avatar_widget.dart';
import 'extensions.dart';

import 'chat_page.dart';
import 'login_page.dart';
import 'profile_page.dart';

class RoomListPage extends StatefulWidget {
  RoomListPage({
    @required this.qiscus,
    @required this.account,
  });
  final QiscusSDK qiscus;
  final QAccount account;

  @override
  _RoomListPageState createState() => _RoomListPageState();
}

enum MenuItems {
  profile,
  logout,
}

class _RoomListPageState extends State<RoomListPage> {
  QAccount account;
  QiscusSDK qiscus;
  var rooms = HashMap<int, QChatRoom>();
  StreamSubscription<QMessage> _onMessageReceivedSubscription;
  StreamSubscription<int> _onChatRoomCleared;

  @override
  void initState() {
    super.initState();
    qiscus = widget.qiscus;
    account = widget.account;
    scheduleMicrotask(() async {
      var rooms = await qiscus.getAllChatRooms$();
      setState(() {
        this.rooms.addEntries(rooms.map((r) => MapEntry(r.id, r)));
      });

      _onChatRoomCleared = qiscus.onChatRoomCleared$().listen((roomId) {
        setState(() {
          this.rooms.removeWhere((key, room) => key == roomId);
        });
      });

      _onMessageReceivedSubscription =
          qiscus.onMessageReceived$().listen(_onMessageReceived);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _onMessageReceivedSubscription?.cancel();
    _onChatRoomCleared?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Hero(
            tag: HeroTags.accountAvatar,
            child: Avatar(url: account.avatarUrl),
          ),
        ),
        title: Text(account.name),
        actions: <Widget>[
          PopupMenuButton<MenuItems>(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: MenuItems.profile,
                  child: Text('Profile'),
                ),
                PopupMenuItem(
                  value: MenuItems.logout,
                  child: Text('Logout'),
                ),
              ];
            },
            onSelected: (item) async {
              switch (item) {
                case MenuItems.logout:
                  {
                    await qiscus.clearUser$();
                    context.pushReplacement(LoginPage(
                      qiscus: qiscus,
                    ));

                    break;
                  }

                case MenuItems.profile:
                  var _account = await context.push(
                    ProfilePage(
                      qiscus: qiscus,
                      account: account,
                    ),
                  );
                  setState(() {
                    this.account = _account;
                  });
                  break;
              }
            },
          ),
        ],
      ),
      body: Container(
        child: ListView.separated(
          itemBuilder: (context, index) {
            var rooms = this.rooms.values.toList()
              ..sort((r1, r2) {
                return r2.lastMessage.timestamp
                    .compareTo(r1.lastMessage.timestamp);
              });
            var room = rooms.elementAt(index);
            var lastMessage = _getLastMessage(room.lastMessage);
            return ListTile(
              leading: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Hero(
                    tag: HeroTags.roomAvatar(roomId: room.id),
                    child: Avatar(url: room.avatarUrl),
                  ),
                  if (room.unreadCount > 0)
                    Positioned(
                      bottom: -3,
                      right: -3,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: Colors.redAccent,
                          border: Border.fromBorderSide(BorderSide(
                            color: Colors.white,
                            width: 1,
                          )),
                        ),
                        child: Center(
                          child: Text(
                            room.unreadCount > 9
                                ? '9+'
                                : room.unreadCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(room.name),
              subtitle: room.type == QRoomType.single
                  ? Text(
                      lastMessage,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : Row(
                      children: <Widget>[
                        Expanded(
                          flex: 0,
                          child: Text(
                            '${room.lastMessage.sender.name}: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            lastMessage,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
              trailing: room.lastMessage != null
                  ? Text(
                      formatDate(
                        room.lastMessage?.timestamp,
                        [HH, ':', mm],
                      ),
                    )
                  : Container(),
              onTap: () async {
                var _room = await context.push(
                  ChatPage(
                    qiscus: qiscus,
                    account: account,
                    room: room,
                  ),
                );
                if (_room != null) {
                  setState(() {
                    this.rooms.update(room.id, (r) {
                      return _room;
                    });
                  });
                }
              },
            );
          },
          itemCount: this.rooms.length,
          separatorBuilder: (context, index) {
            return Divider(
              color: Colors.black38,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          context.push(UserListPage(
            qiscus: qiscus,
            account: account,
          ));
        },
      ),
    );
  }

  String _getLastMessage(QMessage lastMessage) {
    if (lastMessage == null) return 'No messages';
    if (lastMessage.text.contains('[file]')) return 'File attachment';
    return lastMessage.text;
  }

  void _onMessageReceived(QMessage message) async {
    var roomId = message.chatRoomId;
    var hasRoom = this.rooms.containsKey(roomId);

    QChatRoom room;
    if (!hasRoom) {
      var rooms = await qiscus.getChatRooms$(roomIds: [roomId]);
      room = rooms.first;
    }

    setState(() {
      this.rooms.update(roomId, (room) {
        room.lastMessage = message;
        room.unreadCount++;
        return room;
      }, ifAbsent: () {
        return room;
      });
    });
  }
}
