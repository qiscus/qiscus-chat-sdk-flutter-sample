import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sample/src/state/app_state.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  var _loginFormKey = GlobalKey<FormState>();
  var _appIdController = TextEditingController(text: 'sdksample');
  var _userIdController = TextEditingController(text: 'guest-1002');
  var _userKeyController = TextEditingController(text: 'passkey');

  var isLoggingIn = false;

  String _noWhitespaceValidator(String text) {
    if (text.contains(RegExp(r'\s'))) return 'Can not contain whitespace';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.asset('assets/login-background.png').image,
              fit: BoxFit.cover,
            ),
          ),
          child: Form(
            key: _loginFormKey,
            child: buildContainer(),
          ),
        ),
      ),
    );
  }

  Widget buildContainer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/logo.png'),
          TextFormField(
            controller: _appIdController,
            autovalidate: true,
            validator: (text) => _noWhitespaceValidator(text),
            decoration: InputDecoration(labelText: 'App ID'),
          ),
          TextFormField(
            autovalidate: true,
            validator: (text) => _noWhitespaceValidator(text),
            controller: _userIdController,
            decoration: InputDecoration(labelText: 'User ID'),
          ),
          TextFormField(
            autovalidate: true,
            controller: _userKeyController,
            decoration: InputDecoration(labelText: 'User Key'),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: RaisedButton(
              onPressed: _doLogin,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (!isLoggingIn) Text('START') else Text('Loading...'),
                  if (!isLoggingIn) Icon(Icons.chevron_right),
                ],
              ),
              textColor: Colors.white,
              color: Colors.teal,
            ),
          )
        ],
      ),
    );
  }

  _doLogin() async {
    var appState = Provider.of<AppState>(context, listen: false);
    if (_loginFormKey.currentState.validate()) {
      var appId = _appIdController.text;
      var userId = _userIdController.text;
      var userKey = _userKeyController.text;

      setState(() {
        isLoggingIn = true;
      });

      await appState.setup(appId);
      await appState.setUser(userId, userKey);

      setState(() {
        isLoggingIn = false;
      });
      Navigator.pushReplacementNamed(context, '/room');
    }
  }
}
