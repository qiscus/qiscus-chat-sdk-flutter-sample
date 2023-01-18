import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_flutter_sample/qiscus_util.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import '../constants.dart';
import '../extensions.dart';
import 'room_list_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  LoginPageState createState() => LoginPageState();
}

// var userId = const Uuid().v4();
const userId = 'guest-1001';

class LoginPageState extends State<LoginPage> {
  final userIdController = TextEditingController(text: userId);
  final userKeyController = TextEditingController(text: 'passkey');
  final userNameController = TextEditingController(text: userId);
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final _formStyle = TextStyle(
    color: Colors.white,
    backgroundColor: Colors.white10.withAlpha(10),
  );
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.white,
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white,
        ),
      ),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _initializePage(BuildContext context) async {
    // var account = context.read<QAccount?>();
    // if (account != null) {
    //   context.pushReplacement(const RoomListPage());
    // }
  }

  @override
  Widget build(BuildContext context) {
    final firebase = context.watch<FirebaseMessaging>();
    final qiscus = context.watch<QiscusUtil>();

    return FutureBuilder(
      future: _initializePage(context),
      builder: (context, snapshot) {
        var isLoading = snapshot.connectionState == ConnectionState.waiting;

        if (isLoading) {
          return const CircularProgressIndicator();
        }
        return Scaffold(
          key: scaffoldKey,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.only(top: 100),
            color: Colors.black87,
            child: Column(
              children: <Widget>[
                const Text(
                  'Login',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 34,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
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
                            if (value?.contains(RegExp(r'(\s+)')) == true) {
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
                            if (value?.contains(RegExp(r'(\s+)')) == true) {
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
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState?.validate() == true) {
                              try {
                                const snackbar = SnackBar(
                                  content: Text('Loading...'),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackbar);

                                await qiscus.setup(APP_ID);
                                await qiscus.setUser(
                                  userId: userIdController.text,
                                  userKey: userKeyController.text,
                                  username: userNameController.text,
                                );
                                qiscus.subscribe();

                                final token = await firebase.getToken();
                                print('device token: $token');
                                if (token != null) {
                                  await qiscus.registerDeviceToken(
                                      token: token);
                                }

                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();

                                context.pushReplacement(const RoomListPage());
                              } on QError catch (error) {
                                final snackbar = SnackBar(
                                  content: Text(error.message),
                                  duration: const Duration(seconds: 2),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackbar);
                              }
                            }
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
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
