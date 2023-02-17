import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_flutter_sample/qiscus_util.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:logger/logger.dart';
import 'firebase_options.dart';

import 'screen/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  await FlutterDownloader.initialize();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
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
      (_) => qiscus.isLogin && mounted,
    ).where((it) => it).listen((_) {
      qiscus.publishOnlinePresence(isOnline: true);
    });

    _setupDownloader();
  }

  void _setupDownloader() {
    _port.listen((dynamic data) {
      String taskId = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      logger.d('@LISTEN taskId($taskId) progress($progress) status($status)');
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
    logger.d('@CB taskId($taskId) progress($progress) status($status)');

    if (send != null) {
      send.send([taskId, status, progress]);
    } else {
      logger.d('`send` are null');
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
      logger.d('@got-fcm-message');
      logger.d('title: ${message.notification?.title}');
      logger.d('body: ${message.notification?.body}');
      logger.d('data: $data');
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
      return MultiProvider(
        providers: [
          Provider<Logger>.value(value: logger),
          qiscusProvider,
          Provider<FirebaseMessaging>.value(value: firebase),
          qiscusUtilProvider,
          qiscusAccountProvider,
        ],
        child: const MaterialApp(
          home: LoginPage(),
          debugShowCheckedModeBanner: false,
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }
}

final logger = Logger();

final qiscusProvider = Provider<QiscusSDK>(
  create: (_) => QiscusSDK(),
);
final qiscusAccountProvider = ProxyProvider<QiscusUtil, QAccount?>(
  update: (context, QiscusUtil qiscus, QAccount? user) {
    return user ?? qiscus.account;
  },
);
final qiscusUtilProvider = ChangeNotifierProxyProvider<QiscusSDK, QiscusUtil>(
  create: (context) => QiscusUtil(
    context.read<QiscusSDK>(),
    logger: context.read<Logger>(),
  ),
  update: (context, qiscus, util) => QiscusUtil.update(
    qiscus,
    dis: util,
    logger: context.read<Logger>(),
  ),
);

// ignore: unused_element
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  logger.d('@bg-message');
  logger.d('title: ${message.notification?.title}');
  logger.d('body: ${message.notification?.body}');
}
