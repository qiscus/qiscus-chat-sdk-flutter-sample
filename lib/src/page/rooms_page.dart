import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sample/src/state/room_state.dart';
import 'package:qiscus_chat_sample/src/state/state.dart';

enum MenuItem {
  profile,
  signOut,
}

class RoomListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RoomListState();
}

class _RoomListState extends State<RoomListPage> {
  @override
  Widget build(BuildContext context) {
    var userId = context.select((AppState s) => s.account.id);
    return Scaffold(
      appBar: AppBar(
        leading: Consumer<AppState>(
          builder: (ctx, state, _) => Padding(
            padding: const EdgeInsets.all(10),
            child: CircleAvatar(
              backgroundImage: Image.network(
                state.account.avatarUrl,
                width: 10,
                height: 10,
                fit: BoxFit.contain,
              ).image,
            ),
          ),
        ),
        centerTitle: false,
        title: Text('Conversations'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (_item) {
              switch (_item) {
                case MenuItem.profile:
                  Navigator.pushNamed(context, '/profile/$userId');
                  break;
                case MenuItem.signOut:
                  context.read<AppState>().signOut();
                  break;
                default:
                  return;
              }
            },
            itemBuilder: (ctx) {
              return <PopupMenuEntry<MenuItem>>[
                PopupMenuItem<MenuItem>(
                  value: MenuItem.profile,
                  child: Text('Profile'),
                ),
                PopupMenuItem<MenuItem>(
                  value: MenuItem.signOut,
                  child: Text('Sign Out'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          Expanded(
            child: Consumer<RoomState>(
              builder: (_, state, __) {
                var rooms = state.rooms.toList() //
                  ..sort((r1, r2) => r1.unreadCount.compareTo(r2.unreadCount));
                return ListView.separated(
                  itemBuilder: (_, index) {
                    var room = rooms.elementAt(index);
                    return ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, '/room/${room.id}');
                      },
                      leading: CircleAvatar(
                        backgroundImage: Image.network(room.avatarUrl).image,
                      ),
                      title: Text(
                        room.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        room.lastMessage?.text ?? 'No last message',
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: (room.unreadCount > 0)
                          ? Container(
                              alignment: Alignment.center,
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.lightGreen,
                              ),
                              child: Text(
                                room.unreadCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Container(
                              width: 30,
                              height: 30,
                            ),
                    );
                  },
                  separatorBuilder: (_, __) => Divider(
                    thickness: 1.3,
                    height: 1,
                  ),
                  itemCount: rooms.length,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: IconButton(
          onPressed: () {},
          icon: Icon(Icons.add),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() async {
      var roomState = Provider.of<RoomState>(context, listen: false);
      await roomState.getRooms();
    });
  }
}
