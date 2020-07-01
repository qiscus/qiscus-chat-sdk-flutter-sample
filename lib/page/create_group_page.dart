import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qiscus_chat_sample/page/chat_page.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:qiscus_chat_sdk/extension.dart';

class CreateGroupPage extends StatefulWidget {
  final QiscusSDK qiscus;

  CreateGroupPage({
    Key key,
    @required this.qiscus,
  });

  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  String name;
  List<QUser> selectedParticipants = [];
  List<QUser> users = [];
  File avatarFile;
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() async {
      var users = await widget.qiscus.getUsers$();
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
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          icon: Icon(Icons.chevron_left),
        ),
        title: Text('Create Group Chat'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Create',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              var participantIds =
                  selectedParticipants.map((user) => user.id).toList();

              String avatarUrl;
              if (avatarFile != null) {
                avatarUrl = await widget.qiscus.upload$(avatarFile);
              }

              var room = await widget.qiscus.createGroupChat$(
                name: nameController.text,
                userIds: participantIds,
                avatarUrl: avatarUrl,
              );
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (c) => ChatPage(
                            roomId: room.id,
                          )));
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 100,
            width: double.infinity,
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    var file = await FilePicker.getFile(
                      type: FileType.image,
                    );
                    if (file != null) {
                      setState(() {
                        avatarFile = file;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: 80,
                      child: CircleAvatar(
                        backgroundImage: avatarFile == null
                            ? Image.asset(
                                'assets/ic-avatar-group.png',
                              ).image
                            : Image.file(avatarFile).image,
                        radius: 400,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 100,
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Room name',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, id) {
                  var user = users.elementAt(id);
                  return ListTile(
                    selected: selectedParticipants
                        .any((element) => element.id == user.id),
                    leading: CircleAvatar(
                      backgroundImage: Image.network(user.avatarUrl).image,
                    ),
                    title: Text(user.name),
                    onTap: () {
                      var hasAdded = selectedParticipants
                          .any((element) => element.id == user.id);
                      if (!hasAdded) {
                        setState(() {
                          selectedParticipants.add(user);
                        });
                      } else {
                        setState(() {
                          selectedParticipants
                              .removeWhere((element) => element.id == user.id);
                        });
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateGroupProvider extends ChangeNotifier {}
