import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import '../extensions.dart';
import '../widget/avatar_widget.dart';
import 'chat_page.dart';
import 'create_room_page.dart';

class UserListPage extends StatefulWidget {
  UserListPage({
    @required this.qiscus,
    @required this.account,
  });

  final QiscusSDK qiscus;
  final QAccount account;

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  QiscusSDK qiscus;
  QAccount account;
  var users = HashMap<String, QUser>();

  @override
  void initState() {
    super.initState();
    this.qiscus = widget.qiscus;
    this.account = widget.account;

    scheduleMicrotask(() async {
      var _users = await qiscus.getUsers$(limit: 100);
      setState(() {
        users.addEntries(_users.map((u) => MapEntry(u.id, u)));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final _users = users.values.toList()
      ..sort((u1, u2) => u1.name.compareTo(u2.name));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Contacts'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushReplacement(CreateRoomPage(
            qiscus: qiscus,
            account: account,
          ));
        },
        child: Icon(Icons.add),
      ),
      body: Container(
        child: ListView.separated(
          itemCount: _users.length,
          separatorBuilder: (context, index) {
            return Divider();
          },
          itemBuilder: (context, index) {
            final user = _users.elementAt(index);

            return ListTile(
              leading: Avatar(url: user.avatarUrl),
              title: Text(user.name.isEmpty ? 'No name' : user.name),
              subtitle: Text(
                user.id,
                style: TextStyle(
                  color: Colors.black38,
                ),
              ),
              onTap: () async {
                var room = await qiscus.chatUser$(userId: user.id);
                context.pushReplacement(ChatPage(
                  qiscus: qiscus,
                  account: account,
                  room: room,
                ));
              },
            );
          },
        ),
      ),
    );
  }
}
