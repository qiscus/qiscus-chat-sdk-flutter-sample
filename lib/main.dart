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

class _MyAppState extends State<MyApp> {
  static final _appState = AppState();
  static final _roomState = RoomState(appState: _appState);
  static final _messageState = MessageState(
    appState: _appState,
    roomState: _roomState,
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppState>(create: (_) => _appState),
        Provider<MessageState>(create: (_) => _messageState),
        Provider<RoomState>(create: (_) => _roomState),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: _appState.isLoggedIn ? '/' : '/login',
        routes: {
          '/': (_) => ChatPage(),
          '/login': (_) => LoginPage(),
        },
      ),
    );
  }
}
