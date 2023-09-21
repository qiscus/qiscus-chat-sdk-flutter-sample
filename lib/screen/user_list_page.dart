import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_flutter_sample/qiscus_util.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import '../extensions.dart';
import '../widget/avatar_widget.dart';
import 'chat_page.dart';
import 'create_room_page.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({
    super.key,
  });

  @override
  UserListPageState createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage> {
  var users = HashMap<String, QUser>();

  Future<void> _initializePage(BuildContext context) async {
    await context.read<QiscusUtil>().getUsers();
  }

  @override
  void initState() {
    super.initState();
    _initializePage(context);
  }

  @override
  Widget build(BuildContext context) {
    var _users = context.select<QiscusUtil, List<QUser>>((it) {
      return it.users.toList()..sort((u1, u2) => u1.name.compareTo(u2.name));
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Contacts'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushReplacement(CreateRoomPage());
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        itemCount: _users.length,
        separatorBuilder: (context, index) {
          return const Divider();
        },
        itemBuilder: (context, index) {
          final user = _users.elementAt(index);

          return ListTile(
            leading: Avatar(url: user.avatarUrl!),
            title: Text(user.name.isEmpty ? 'No name' : user.name),
            subtitle: Text(
              user.id,
              style: const TextStyle(
                color: Colors.black38,
              ),
            ),
            onTap: () async {
              var room = await context.read<QiscusUtil>().chatUser(
                    userId: user.id,
                  );
              context.pushReplacement(ChatPage(chatRoomId: room.id));
            },
          );
        },
      ),
    );
  }
}
