import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qiscus_chat_sample/avatar_widget.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

class CreateRoomPage extends StatefulWidget {
  CreateRoomPage({
    @required this.qiscus,
    @required this.account,
  });
  final QiscusSDK qiscus;
  final QAccount account;

  @override
  _CreateRoomPageState createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  QiscusSDK qiscus;
  QAccount account;
  List<QUser> users = [];

  @override
  void initState() {
    super.initState();
    qiscus = widget.qiscus;
    account = widget.account;

    scheduleMicrotask(() async {
      this.users = await qiscus.getUsers$(limit: 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Create room'),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {},
            child: Text('Create'),
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Row(),
            ListView.builder(
              itemCount: this.users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                return ListTile(
                  leading: Avatar(url: user.avatarUrl),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
