// ignore_for_file: unnecessary_this

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import '../widget/avatar_widget.dart';
import '../extensions.dart';

class AddParticipantPage extends StatefulWidget {
  const AddParticipantPage({
    super.key,
    required this.qiscus,
    required this.account,
    required this.room,
  });

  final QiscusSDK qiscus;
  final QAccount account;
  final QChatRoom room;

  @override
  createState() => AddParticipantPageState();
}

class AddParticipantPageState extends State<AddParticipantPage> {
  late QiscusSDK qiscus = widget.qiscus;
  late QAccount account = widget.account;
  late QChatRoom room = widget.room;

  List<QUser> users = [];
  List<QUser> selectedUsers = [];

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      var users = await qiscus.getUsers(limit: 100);
      setState(() {
        this.users = users;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop(room);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Add participant'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              var userIds = selectedUsers.map((it) => it.id).toList();
              var participants = await qiscus.addParticipants(
                roomId: room.id,
                userIds: userIds,
              );
              participants.addAll(room.participants);

              setState(() {
                room.participants = participants;
                this.room.totalParticipants = this.room.participants.length;
              });
              await Navigator.maybePop(context, this.room);
              // context.pop(this.room);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
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
  }
}
