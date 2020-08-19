import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'login_page.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final qiscus = QiscusSDK();
  final firebase = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    qiscus.enableDebugMode(enable: true);

    scheduleMicrotask(() {
      firebase.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('got message');
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<QiscusSDK>.value(value: qiscus),
        Provider<FirebaseMessaging>.value(value: firebase),
        ProxyProvider<QiscusSDK, QAccount>(
          create: (_) => qiscus.currentUser,
          update: (_, qiscus, account) => qiscus.currentUser,
        ),
      ],
      child: MaterialApp(
        home: LoginPage(qiscus: qiscus),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
