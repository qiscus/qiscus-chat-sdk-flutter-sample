import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import '../widget/avatar_widget.dart';
import '../extensions.dart';

class AddParticipantPage extends StatefulWidget {
  AddParticipantPage({
    @required this.qiscus,
    @required this.account,
    @required this.room,
  });

  final QiscusSDK qiscus;
  final QAccount account;
  final QChatRoom room;

  @override
  _AddParticipantPageState createState() => _AddParticipantPageState();
}

class _AddParticipantPageState extends State<AddParticipantPage> {
  QiscusSDK qiscus;
  QAccount account;
  QChatRoom room;

  List<QUser> users = [];
  List<QUser> selectedUsers = [];

  @override
  void initState() {
    super.initState();
    qiscus = widget.qiscus;
    account = widget.account;
    room = widget.room;

    scheduleMicrotask(() async {
      var users = await qiscus.getUsers$(limit: 100);
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
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Add participant'),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              var userIds = this.selectedUsers.map((it) => it.id).toList();
              var participants = await qiscus.addParticipants$(
                roomId: room.id,
                userIds: userIds,
              );
              participants.addAll(this.room.participants);

              setState(() {
                this.room.participants = participants;
                this.room.totalParticipants = this.room.participants.length;
              });
              context.pop(this.room);
            },
            child: Text('Add'),
            textColor: Colors.white,
          ),
        ],
      ),
      body: Container(
        child: ListView.builder(
          itemCount: this.users.length,
          itemBuilder: (context, index) {
            var user = this.users[index];
            var isSelected = this.selectedUsers.any((u) => u.id == user.id);

            return ListTile(
              leading: Avatar(url: user.avatarUrl),
              title: Text(user.name),
              subtitle: Text(user.id),
              trailing: isSelected ? Icon(Icons.check_circle_outline) : null,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    this.selectedUsers.removeWhere((e) => e.id == user.id);
                  } else {
                    this.selectedUsers.add(user);
                  }
                });
              },
            );
          },
        ),
      ),
    );
  }
}
