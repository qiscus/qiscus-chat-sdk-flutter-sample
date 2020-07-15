import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'extensions.dart';
import 'constants.dart';
import 'room_list_page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({
    @required this.qiscus,
  });

  final QiscusSDK qiscus;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userIdController = TextEditingController(text: 'guest-1003');
  final userKeyController = TextEditingController(text: 'passkey');
  final userNameController = TextEditingController(text: 'guest-1003');
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final _formStyle = TextStyle(
    color: Colors.white,
    backgroundColor: Colors.white10.withAlpha(10),
  );
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white,
        ),
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.only(top: 100),
        color: Colors.black87,
        child: Column(
          children: <Widget>[
            Text(
              'Login',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 34,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      style: _formStyle,
                      decoration: _inputDecoration('User ID'),
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
                      style: _formStyle,
                      decoration: _inputDecoration('User Key'),
                      controller: userKeyController,
                      validator: (value) {
                        if (value.contains(RegExp(r'(\s+)'))) {
                          return 'Can not contains whitespace character';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      style: _formStyle,
                      decoration: _inputDecoration('Username'),
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

                            context.pushReplacement(RoomListPage(
                              qiscus: widget.qiscus,
                              account: account,
                            ));
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
                      textColor:
                          Theme.of(context).primaryTextTheme.button.color,
                      child: Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
