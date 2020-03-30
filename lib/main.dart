import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sample/src/page/login_page.dart';
import 'package:qiscus_chat_sample/src/state/app_state.dart';
import 'package:qiscus_chat_sample/src/state/room_state.dart';

import 'src/page/chat_page.dart';
import 'src/state/message_state.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

extension on Router {
  handle(
    String path, {
    Widget Function(BuildContext, Map<String, List<String>>) handler,
  }) {
    this.define(
      path,
      handler: Handler(handlerFunc: (ctx, args) => handler(ctx, args)),
    );
  }
}

class _MyAppState extends State<MyApp> {
  final router = Router();

  _MyAppState() {
    router
      ..handle('/login', handler: (_, __) => LoginPage())
      ..handle(
        '/room/:roomId',
        handler: (_, args) => ChatPage(roomId: int.parse(args['roomId'][0])),
      );
  }

  static final appState = AppState();
  static final roomState = RoomState(appState: appState);
  static final messageState = MessageState(
    appState: appState,
    roomState: roomState,
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider.value(value: roomState),
        ChangeNotifierProvider.value(value: messageState),
      ],
      child: Consumer<AppState>(
        builder: (_, state, __) => MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(primarySwatch: Colors.blue),
          onGenerateRoute: router.generator,
          initialRoute: state.isLoggedIn ? '/' : '/login',
        ),
      ),
    );
  }
}
