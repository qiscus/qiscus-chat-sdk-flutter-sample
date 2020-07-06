import 'dart:async';
import 'dart:collection';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qiscus_chat_sample/constants.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'chat_page.dart';
import 'login_page.dart';
import 'profile_page.dart';

class RoomListPage extends StatefulWidget {
  RoomListPage({
    @required this.qiscus,
    @required this.account,
  });

  static MaterialPageRoute route({
    @required QiscusSDK qiscus,
    @required QAccount account,
  }) {
    return MaterialPageRoute(
      builder: (c) => RoomListPage(qiscus: qiscus, account: account),
    );
  }

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Hero(
            tag: HeroTags.accountAvatar,
            child: CircleAvatar(
              backgroundImage: Image.network(
                account.avatarUrl,
                fit: BoxFit.cover,
              ).image,
              onBackgroundImageError: (_, __) {},
            ),
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
                    Navigator.pushReplacement(
                      context,
                      LoginPage.route(
                        qiscus: qiscus,
                      ),
                    );
                    break;
                  }

                case MenuItems.profile:
                  var _account = await Navigator.push(
                    context,
                    ProfilePage.route(
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
              leading: Hero(
                tag: HeroTags.roomAvatar(roomId: room.id),
                child: CircleAvatar(
                  backgroundImage: Image.network(room.avatarUrl).image,
                ),
              ),
              title: Text(room.name),
              subtitle: Text(lastMessage),
              trailing: room.lastMessage != null
                  ? Text(
                      formatDate(
                        room.lastMessage?.timestamp,
                        [HH, ':', mm],
                      ),
                    )
                  : Container(),
              onTap: () async {
                var _room = await Navigator.push(
                  context,
                  ChatPage.route(
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
    );
  }

  String _getLastMessage(QMessage lastMessage) {
    if (lastMessage == null) return 'No messages';
    if (lastMessage.text.contains('[file]')) return 'File attachment';
    return lastMessage.text;
  }
}
