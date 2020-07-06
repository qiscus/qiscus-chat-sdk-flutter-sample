import 'package:flutter/material.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'constants.dart';
import 'room_list_page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({
    @required this.qiscus,
  });

  static MaterialPageRoute route({
    @required QiscusSDK qiscus,
  }) {
    return MaterialPageRoute(
      builder: (c) => LoginPage(qiscus: qiscus),
    );
  }

  final QiscusSDK qiscus;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userIdController = TextEditingController(text: 'guest-1001');
  final userKeyController = TextEditingController(text: 'passkey');
  final userNameController = TextEditingController(text: 'guest-1001');
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'UserID'),
                controller: userIdController,
                onChanged: (value) {
                  userNameController.text = value;
                },
                validator: (value) {
                  if (value.contains(RegExp(r'(\s+)'))) {
                    return 'Can not contains whitespace character';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'UserKey'),
                controller: userKeyController,
                validator: (value) {
                  if (value.contains(RegExp(r'(\s+)'))) {
                    return 'Can not contains whitespace character';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                controller: userNameController,
              ),
              RaisedButton(
                onPressed: () async {
                  if (formKey.currentState.validate()) {
                    try {
                      final snackbar = SnackBar(
                        content: Text('Loading...'),
                      );
                      scaffoldKey.currentState.showSnackBar(snackbar);
                      await widget.qiscus.setup$(APP_ID);
                      final account = await widget.qiscus.setUser$(
                        userId: userIdController.text,
                        userKey: userKeyController.text,
                        username: userNameController.text,
                      );
                      scaffoldKey.currentState.hideCurrentSnackBar();
                      Navigator.pushReplacement(
                        context,
                        RoomListPage.route(
                          qiscus: widget.qiscus,
                          account: account,
                        ),
                      );
                    } on QError catch (error) {
                      final snackbar = SnackBar(
                        content: Text(error.message),
                        duration: const Duration(seconds: 2),
                      );
                      scaffoldKey.currentState.showSnackBar(snackbar);
                    }
                  }
                },
                color: Theme.of(context).primaryColor,
                textColor: Theme.of(context).primaryTextTheme.button.color,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
