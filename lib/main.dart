import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:qiscus_chat_flutter_sample/providers/auth_provider.dart';
import 'package:qiscus_chat_flutter_sample/providers/chat_provider.dart';
import 'package:qiscus_chat_flutter_sample/screens/splash_screen.dart';
import 'package:qiscus_chat_flutter_sample/services/push_service.dart';
import 'package:qiscus_chat_flutter_sample/services/qiscus_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final pushService = PushService();
  Object? bootstrapError;
  try {
    await QiscusService.instance.initialize();
    await pushService.initialize();
  } catch (error) {
    bootstrapError = error;
  }

  runApp(MyApp(
    pushService: pushService,
    bootstrapError: bootstrapError,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.pushService,
    this.bootstrapError,
  });

  final PushService pushService;
  final Object? bootstrapError;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final ChatProvider _chatProvider;
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = ChatProvider();
    _authProvider = AuthProvider(pushService: widget.pushService);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chatProvider.dispose();
    _authProvider.dispose();
    unawaited(widget.pushService.dispose());
    super.dispose();
  }

  DateTime? _backgroundedAt;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final now = DateTime.now();
    debugPrint('📱 [${now.toIso8601String()}] Lifecycle state -> $state');

    if (state != AppLifecycleState.resumed) {
      _backgroundedAt ??= now;
      unawaited(
        QiscusService.instance.publishOnlinePresence(isOnline: false),
      );
      return;
    }

    final bgDuration =
        _backgroundedAt != null ? now.difference(_backgroundedAt!) : null;
    _backgroundedAt = null;
    debugPrint(
        '📱 App resumed${bgDuration != null ? ' after ${bgDuration.inSeconds}s in background' : ''} — forcing resync');
    QiscusService.instance.forceSynchronize();
    unawaited(
      QiscusService.instance.publishOnlinePresence(isOnline: true),
    );

    final currentRoom = _chatProvider.currentRoom;
    if (currentRoom != null) {
      debugPrint('🔁 Resubscribing room ${currentRoom.id} on resume');
      QiscusService.instance.subscribeChatRoom(currentRoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bootstrapError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _BootstrapErrorScreen(error: widget.bootstrapError!),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _chatProvider),
      ],
      child: MaterialApp(
        title: 'Qiscus Chat SDK Example',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class _BootstrapErrorScreen extends StatelessWidget {
  const _BootstrapErrorScreen({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.settings_suggest, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Qiscus configuration is incomplete',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const SelectableText(
                  'Run with:\n'
                  'flutter run --dart-define=QISCUS_APP_ID=<your-app-id>',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
