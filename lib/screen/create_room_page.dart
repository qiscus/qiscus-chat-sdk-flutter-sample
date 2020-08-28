import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import '../extensions.dart';
import '../widget/avatar_widget.dart';
import 'chat_page.dart';

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
  File selectedImage;
  String setectedName;
  List<QUser> selectedUser = [];
  final selectedNameController = TextEditingController(text: '');

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    qiscus = widget.qiscus;
    account = widget.account;

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
      key: scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Create room'),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              var name = this.selectedNameController.text;
              var avatar = this.selectedImage;
              var userIds = this.selectedUser.map((e) => e.id).toList();

              var snackbar = SnackBar(content: Text(''));

              String avatarUrl;

              if (name.isEmpty) {
                snackbar = SnackBar(
                  content: Text('Room name cannot be empty'),
                  duration: const Duration(seconds: 1),
                );
                scaffoldKey.currentState.showSnackBar(snackbar);
                return;
              }
              if (userIds.length == 0) {
                snackbar = SnackBar(
                  content: Text('Participant can not be empty'),
                  duration: const Duration(seconds: 1),
                );
                scaffoldKey.currentState.showSnackBar(snackbar);
                return;
              }

              if (avatar != null) {
                avatarUrl = await qiscus.upload$(avatar);
              }

              snackbar = SnackBar(
                content: Text('Creating room'),
              );
              scaffoldKey.currentState.showSnackBar(snackbar);

              var room = await qiscus.createGroupChat$(
                name: name,
                userIds: userIds,
                avatarUrl: avatarUrl,
              );

              scaffoldKey.currentState.hideCurrentSnackBar();
              context.pushReplacement(ChatPage(
                qiscus: qiscus,
                account: account,
                room: room,
              ));
            },
            textColor: Colors.white,
            child: Text('Create'),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 64,
                    width: 64,
                    child: GestureDetector(
                      child: CircleAvatar(
                        backgroundImage: this.selectedImage == null
                            ? Image.asset(
                                'assets/ic-default-avatar.png',
                              ).image
                            : Image.file(this.selectedImage).image,
                      ),
                      onTap: () async {
                        var file = await FilePicker.getFile(
                          type: FileType.image,
                        );
                        setState(() {
                          this.selectedImage = file;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        height: 64,
                        child: TextField(
                          controller: selectedNameController,
                          decoration: InputDecoration(
                            labelText: 'Room name',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  var user = this.users[index];
                  var selected = this.selectedUser.any((u) => u.id == user.id);

                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.id),
                    leading: Avatar(url: user.avatarUrl),
                    trailing:
                        selected ? Icon(Icons.check_circle_outline) : null,
                    selected: selected,
                    onTap: () {
                      setState(() {
                        if (this.selectedUser.contains(user)) {
                          this.selectedUser.removeWhere((u) => u.id == user.id);
                        } else {
                          this.selectedUser.add(user);
                        }
                      });
                    },
                  );
                },
                itemCount: this.users.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
