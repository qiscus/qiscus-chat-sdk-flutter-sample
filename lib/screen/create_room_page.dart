import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import '../extensions.dart';
import '../qiscus_util.dart';
import '../widget/avatar_widget.dart';
import 'chat_page.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  CreateRoomPageState createState() => CreateRoomPageState();
}

class CreateRoomPageState extends State<CreateRoomPage> {
  File? selectedImage;
  String? setectedName;
  List<QUser> selectedUser = [];
  final selectedNameController = TextEditingController(text: '');

  var scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _initializePage(BuildContext context) async {
    await context.read<QiscusUtil>().getUsers();
  }

  @override
  Widget build(BuildContext context) {
    var users = context.select<QiscusUtil, List<QUser>>(
      (it) => it.users.toList(),
    );

    return FutureBuilder(
      future: _initializePage(context),
      builder: (context, snapshot) {
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('Create room'),
            actions: <Widget>[
              TextButton(
                onPressed: () => _onCreateRoom(context),
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                child: const Text('Create'),
              ),
            ],
          ),
          body: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        height: 64,
                        width: 64,
                        child: GestureDetector(
                          child: CircleAvatar(
                            backgroundImage: selectedImage == null
                                ? Image.asset(
                                    'assets/ic-default-avatar.png',
                                  ).image
                                : Image.file(selectedImage!).image,
                          ),
                          onTap: () async {
                            var file = await FilePicker.platform.getFile(
                              type: FileType.image,
                            );
                            setState(() {
                              selectedImage = file;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: SizedBox(
                            height: 64,
                            child: TextField(
                              controller: selectedNameController,
                              decoration: const InputDecoration(
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
                      var user = users[index];
                      var selected = selectedUser.any((u) => u.id == user.id);

                      return ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.id),
                        leading: Avatar(url: user.avatarUrl!),
                        trailing: selected
                            ? const Icon(Icons.check_circle_outline)
                            : null,
                        selected: selected,
                        onTap: () {
                          setState(() {
                            if (selectedUser.contains(user)) {
                              selectedUser.removeWhere((u) => u.id == user.id);
                            } else {
                              selectedUser.add(user);
                            }
                          });
                        },
                      );
                    },
                    itemCount: users.length,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onCreateRoom(BuildContext context) async {
    var name = selectedNameController.text;
    var avatar = selectedImage;
    var userIds = selectedUser.map((e) => e.id).toList();

    var snackbar = const SnackBar(content: Text(''));

    String? avatarUrl;

    if (name.isEmpty) {
      snackbar = const SnackBar(
        content: Text('Room name cannot be empty'),
        duration: Duration(seconds: 1),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      return;
    }
    if (userIds.isEmpty) {
      snackbar = const SnackBar(
        content: Text('Participant can not be empty'),
        duration: Duration(seconds: 1),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      return;
    }

    if (avatar != null) {
      avatarUrl = await context
          .read<QiscusSDK>()
          .upload(avatar)
          .firstWhere((r) => r.data != null)
          .then((r) => r.data!);
    }

    snackbar = const SnackBar(
      content: Text('Creating room'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);

    var room = await context.read<QiscusUtil>().createGroupChat(
          name: name,
          userIds: userIds,
          avatarUrl: avatarUrl,
        );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    context.pushReplacement(ChatPage(chatRoomId: room.id));
  }
}
