// ignore_for_file: unnecessary_this

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import '../qiscus_util.dart';
import '../widget/avatar_widget.dart';
import '../extensions.dart';

class AddParticipantPage extends StatefulWidget {
  const AddParticipantPage({
    super.key,
    required this.chatRoomId,
  });

  final int chatRoomId;

  @override
  createState() => AddParticipantPageState();
}

class AddParticipantPageState extends State<AddParticipantPage> {
  late int chatRoomId = widget.chatRoomId;
  List<QUser> selectedUsers = [];

  Future<void> _initializePage(BuildContext context) async {
    var qiscus = context.read<QiscusUtil>();
    await qiscus.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializePage(context),
      builder: (context, snapshot) {
        var qiscus = context.watch<QiscusUtil>();
        var users = context.select<QiscusUtil, List<QUser>>(
          (it) => it.users.toList(),
        );
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('Add participant'),
            actions: _buildActions(qiscus, context),
          ),
          body: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              var isSelected = selectedUsers.any((u) => u.id == user.id);

              return ListTile(
                leading: Avatar(
                  url: user.avatarUrl ?? 'https://via.placeholder.com/200',
                ),
                title: Text(user.name),
                subtitle: Text(user.id),
                trailing:
                    isSelected ? const Icon(Icons.check_circle_outline) : null,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedUsers.removeWhere((e) => e.id == user.id);
                    } else {
                      selectedUsers.add(user);
                    }
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildActions(QiscusUtil qiscus, BuildContext context) {
    var navigator = Navigator.of(context);
    return <Widget>[
      TextButton(
        onPressed: () async {
          var userIds = selectedUsers.map((it) => it.id).toList();
          await qiscus.addParticipants(
            roomId: chatRoomId,
            userIds: userIds,
          );

          navigator.maybePop().ignore();
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
        ),
        child: const Text('Add'),
      ),
    ];
  }
}
