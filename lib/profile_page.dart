import 'package:flutter/material.dart';
import 'package:qiscus_chat_sample/constants.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({
    @required this.qiscus,
    @required this.account,
  });

  final QiscusSDK qiscus;
  final QAccount account;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  QiscusSDK qiscus;
  QAccount account;

  TextEditingController accountIdController;
  TextEditingController accountNameController;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    qiscus = widget.qiscus;
    account = widget.account;
    accountIdController = TextEditingController(text: account.id);
    accountNameController = TextEditingController(text: account.name);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      account.avatarUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () {},
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
                    onSubmitted: (_) async {
                      var account = await qiscus.updateUser$(
                        name: accountNameController.text,
                      );
                      setState(() {
                        isEditing = false;
                        this.account = account;
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
