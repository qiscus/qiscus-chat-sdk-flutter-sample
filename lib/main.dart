import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

//  @override
//  void initState() {
//    super.initState();
//    qiscus.enableDebugMode(enable: true);
//  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(qiscus: qiscus),
      debugShowCheckedModeBanner: false,
    );
  }
}
