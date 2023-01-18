import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import '../constants.dart';
import '../extensions.dart';
import '../qiscus_util.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late TextEditingController accountIdController = TextEditingController();
  late TextEditingController accountNameController = TextEditingController();

  bool isEditing = false;

  var scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _initializePage(BuildContext context) async {
    var account = context.read<QAccount>();
    setState(() {
      accountIdController.text = account.id;
      accountNameController.text = account.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializePage(context),
      builder: (context, snapshot) {
        var qiscus = context.watch<QiscusUtil>();
        var isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('Profile'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Hero(
                      tag: HeroTags.accountAvatar,
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : Image.network(
                                context.watch<QAccount>().avatarUrl!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: IconButton(
                        onPressed: () async {
                          var file = await FilePicker.platform
                              .getFile(type: FileType.image);
                          if (file != null) {
                            var snackbar = const SnackBar(
                                content: Text('Updating user avatar...'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackbar);

                            await Future.microtask(() async {
                              var url = await qiscus
                                  .upload(file)
                                  .firstWhere((r) => r.data != null)
                                  .then((r) => r.data!);
                              return qiscus.updateUser(avatarUrl: url);
                            });
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          }
                        },
                        icon: const Icon(Icons.image),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    enabled: false,
                    controller: accountIdController,
                    decoration: const InputDecoration(
                      labelText: 'User ID',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: <Widget>[
                      TextField(
                        enabled: isEditing,
                        autofocus: true,
                        controller: accountNameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                        onSubmitted: (name) async {
                          var snackbar =
                              const SnackBar(content: Text('Updating user...'));
                          ScaffoldMessenger.of(context).showSnackBar(snackbar);

                          qiscus.updateUser(name: name).then((r) {
                            print('sukses update account: $r');

                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          });
                        },
                        onEditingComplete: () {
                          setState(() {
                            isEditing = false;
                          });
                        },
                      ),
                      !isEditing
                          ? Positioned(
                              right: 5,
                              bottom: 0,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isEditing = true;
                                  });
                                },
                                icon: const Icon(Icons.edit),
                                color: Colors.black38,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
