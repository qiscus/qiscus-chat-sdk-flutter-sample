import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_flutter_sample/providers/auth_provider.dart';
import 'package:qiscus_chat_flutter_sample/screens/login_screen.dart';
import 'package:qiscus_chat_flutter_sample/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    final authProvider = context.read<AuthProvider>();
    await Future.wait([
      authProvider.initialized,
      Future<void>.delayed(const Duration(milliseconds: 700)),
    ]);
    if (mounted) _navigateToNextScreen(authProvider);
  }

  void _navigateToNextScreen(AuthProvider authProvider) {
    if (_hasNavigated) return;
    _hasNavigated = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            authProvider.isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade700,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_rounded,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'Qiscus Chat SDK',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Example Integration',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
