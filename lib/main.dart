import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'screen/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  await FlutterDownloader.initialize();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final qiscus = QiscusSDK();
  final firebase = FirebaseMessaging.instance;
  StreamSubscription<bool>? _subs;
  final _port = ReceivePort('DOWNLOADED');

  @override
  void initState() {
    super.initState();
    qiscus.enableDebugMode(enable: false);

    _subs = Stream.periodic(
      const Duration(seconds: 3),
      (_) => qiscus.isLogin && this.mounted,
    ).where((it) => it).listen((_) {
      qiscus.publishOnlinePresence(isOnline: true);
    });
    // FirebaseMessaging.onMessage.listen((message) {});

    _port.listen((dynamic data) {
      String taskId = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      print('@LISTEN taskId($taskId) progress($progress) status($status)');
      if (progress == 100 && status == DownloadTaskStatus.complete) {
        FlutterDownloader.open(taskId: taskId);
      }
    });
    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );
    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(
      String taskId, DownloadTaskStatus status, int progress) {
    var send = IsolateNameServer.lookupPortByName('downloader_send_port');
    print('@CB taskId($taskId) progress($progress) status($status)');

    if (send != null) {
      send.send([taskId, status, progress]);
    } else {
      print('`send` are null');
    }
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _subs?.cancel();

    super.dispose();
  }

  Future<void> _initializeApp() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onMessage.listen((message) {
      var data = message.data;
      print('@got-fcm-message');
      print('title: ${message.notification?.title}');
      print('body: ${message.notification?.body}');
      print('data: $data');
    });
  }

  @override
  Widget build(BuildContext context) {
    var stream = _initializeApp().asStream();
    var builder = StreamBuilder(
      builder: _child,
      stream: stream,
    );

    return builder;
  }

  Widget _child(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      // if (snapshot.hasData) {
      return MultiProvider(
        providers: [
          Provider<QiscusSDK>.value(value: qiscus),
          Provider<FirebaseMessaging>.value(value: firebase),
          ProxyProvider<QiscusSDK, QAccount?>(
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
    } else {
      return CircularProgressIndicator();
    }
  }
}

Future<void> _onBackgroundMessage(RemoteMessage message) async {
  print('@bg-message');
  print('title: ${message.notification?.title}');
  print('body: ${message.notification?.body}');
}
