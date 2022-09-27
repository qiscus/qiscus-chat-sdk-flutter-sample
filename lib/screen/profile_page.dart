import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import '../constants.dart';
import '../extensions.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({
    required this.qiscus,
    required this.account,
  });

  final QiscusSDK qiscus;
  final QAccount account;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late QiscusSDK qiscus = widget.qiscus;
  late QAccount account = widget.account;

  late TextEditingController accountIdController =
      TextEditingController(text: account.id);
  late TextEditingController accountNameController =
      TextEditingController(text: account.name);

  bool isEditing = false;

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    qiscus = widget.qiscus;
    account = widget.account;

    scheduleMicrotask(() async {
      await qiscus.getUserData().then((account) {
        if (this.mounted) {
          setState(() {
            this.account = account;
            accountNameController.text = account.name;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop<QAccount>(context, account),
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Profile'),
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
                    child: Image.network(
                      account.avatarUrl!,
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
                        var snackbar =
                            SnackBar(content: Text('Updating user avatar...'));
                        ScaffoldMessenger.of(context).showSnackBar(snackbar);

                        var account = await Future.microtask(() async {
                          var url = await qiscus
                              .upload(file)
                              .firstWhere((r) => r.data != null)
                              .then((r) => r.data!);
                          return await qiscus.updateUser(avatarUrl: url);
                        });
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();

                        if (this.mounted) {
                          setState(() {
                            this.account = account;
                          });
                        }
                      }
                    },
                    icon: Icon(Icons.image),
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
                decoration: InputDecoration(
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
                    decoration: InputDecoration(
                      labelText: 'Username',
                    ),
                    onSubmitted: (name) async {
                      var snackbar =
                          SnackBar(content: Text('Updating user...'));
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);

                      qiscus.updateUser(name: name).then((r) {
                        print('sukses update account: $account');
                        setState(() {
                          isEditing = false;
                          this.account = account;
                        });

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
                            icon: Icon(Icons.edit),
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
  }
}
