import 'dart:async';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import '../constants.dart';
import '../extensions.dart';
import '../main.dart';
import '../qiscus_util.dart';
import '../widget/avatar_widget.dart';
import 'chat_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'user_list_page.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({
    super.key,
  });

  @override
  RoomListPageState createState() => RoomListPageState();
}

enum MenuItems {
  profile,
  logout,
}

class RoomListPageState extends State<RoomListPage> {
  Future<void> _initializePage(BuildContext context) async {
    await context.read<QiscusUtil>().getAllChatRooms();
  }

  @override
  void initState() {
    super.initState();
    _initializePage(context);
  }

  @override
  Widget build(BuildContext context) {
    var qiscus = context.watch<QiscusUtil>();
    var account = qiscus.getCurrentUser();
    logger.d('data: $account');
    var rooms = context.select<QiscusUtil, List<QChatRoom>>((it) {
      return it.rooms.toList().where((r) => r.lastMessage != null).toList()
        ..sort((r1, r2) {
          return r2.lastMessage!.timestamp.compareTo(r1.lastMessage!.timestamp);
        });
    });

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Hero(
            tag: HeroTags.accountAvatar,
            child: account == null
                ? const CircularProgressIndicator()
                : Avatar(url: account.avatarUrl!),
          ),
        ),
        title: Text(account?.name ?? 'Loading...'),
        actions: <Widget>[
          PopupMenuButton<MenuItems>(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: MenuItems.profile,
                  child: Text('Profile'),
                ),
                const PopupMenuItem(
                  value: MenuItems.logout,
                  child: Text('Logout'),
                ),
              ];
            },
            onSelected: (item) async {
              switch (item) {
                case MenuItems.logout:
                  {
                    context.read<QiscusUtil>().clearUser();
                    context.read<QiscusUtil>().cancelSubscriptions();
                    context.pushReplacement(const LoginPage());

                    break;
                  }

                case MenuItems.profile:
                  await context.push(const ProfilePage());
                  break;
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<QiscusUtil>().getAllChatRooms(),
        child: ListView.separated(
          itemBuilder: (context, index) {
            var room = rooms.elementAt(index);

            return Builder(builder: (context) {
              var lastMessage = _getLastMessage(QiscusUtil.getLastMessageFor(
                context,
                chatRoomId: room.id,
              ));

              return ListTile(
                leading: Stack(
                  children: <Widget>[
                    Hero(
                      tag: HeroTags.roomAvatar(roomId: room.id),
                      child: Avatar(url: room.avatarUrl!),
                    ),
                    if (room.unreadCount > 0)
                      Positioned(
                        bottom: -3,
                        right: -3,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(room.name!),
                subtitle: room.type == QRoomType.single
                    ? Text(
                        lastMessage,
                        style: const TextStyle(
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
                              '${room.lastMessage!.sender.name}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              lastMessage,
                              style: const TextStyle(
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
                          room.lastMessage!.timestamp,
                          [HH, ':', mm],
                        ),
                      )
                    : Container(),
                onTap: () async {
                  context.push(ChatPage(chatRoomId: room.id));
                },
              );
            });
          },
          itemCount: rooms.length,
          separatorBuilder: (context, index) {
            return const Divider(
              color: Colors.black38,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () {
          context.push(const UserListPage());
        },
      ),
    );
  }

  String _getLastMessage(QMessage? lastMessage) {
    if (lastMessage == null) return 'No messages';
    if (lastMessage.text.contains('[file]')) return 'File attachment';
    return lastMessage.text;
  }
}
