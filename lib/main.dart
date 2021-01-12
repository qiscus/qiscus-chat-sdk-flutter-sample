import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'screen/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final qiscus = QiscusSDK();
  final firebase = FirebaseMessaging();
  StreamSubscription<bool> _subs;

  @override
  void initState() {
    super.initState();
    qiscus.enableDebugMode(enable: true);

    scheduleMicrotask(() {
      _subs = Stream.periodic(const Duration(seconds: 3), (_) => qiscus.isLogin)
          .where((isLogin) => isLogin)
          .listen((isLogin) {
        if (isLogin) {
          qiscus.publishOnlinePresence(
              isOnline: isLogin,
              callback: (error) {
                print('error while publishing online presence: $error');
              });
        }
      });
      firebase.configure(
        onMessage: (Map<String, dynamic> message) async {
          // print('got message');
        },
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subs?.cancel();
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
        // theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
