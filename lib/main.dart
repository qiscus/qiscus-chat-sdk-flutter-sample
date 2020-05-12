import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sample/src/page/login_page.dart';
import 'package:qiscus_chat_sample/src/page/page.dart';
import 'package:qiscus_chat_sample/src/room/presentation/page/room_detail/room_detail.dart';
import 'package:qiscus_chat_sample/src/state/app_state.dart';
import 'package:qiscus_chat_sample/src/state/room_state.dart';

import 'src/page/chat_page.dart';
import 'src/state/message_state.dart';
import 'src/user/presentation/page/profile/profile_page.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(MyApp());
}

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print('bloc: $bloc');
    print('error: $error');
    print('stack: $stacktrace');
  }
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

extension on Router {
  handle(
    String path, {
    Widget Function(BuildContext, Map<String, List<String>>) handler,
  }) {
    define(
      path,
      handler: Handler(handlerFunc: (ctx, args) => handler(ctx, args)),
    );
  }
}

class _MyAppState extends State<MyApp> {
  final router = Router();

  _MyAppState() {
    router
          ..handle('/login', handler: (_, __) => LoginPage()) //
          ..handle('/room/:roomId',
              handler: (_, args) => ChatPage(
                    roomId: int.parse(args['roomId'][0]),
                  )) //
          ..handle('/room/:roomId/detail',
              handler: (_, args) => RoomDetail(
                    roomId: int.parse(args['roomId'][0]),
                    qiscus: appState.qiscus,
                  ))
          ..handle('/room', handler: (_, __) => RoomListPage())
          ..handle('/profile/:userId',
              handler: (_, args) => ProfilePage(
                    userId: args['userId'][0],
                    qiscus: appState.qiscus,
                  ))
        // to prevent semicolon get formatted into the end of statement
        // .. so if we need to add a new route, we do not have
        // .. to move the semicolon.
        ;
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
          initialRoute: '/login',
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }

  @override
  void deactivate() {
    messageState.dispose();
    roomState.dispose();
    appState.dispose();
    super.deactivate();
  }
}
