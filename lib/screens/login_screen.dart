import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_flutter_sample/providers/auth_provider.dart';
import 'package:qiscus_chat_flutter_sample/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController(text: 'guest-2001');
  final _userKeyController = TextEditingController(text: 'passkey');
  final _usernameController = TextEditingController(text: 'guest-2001');
  final _avatarUrlController =
      TextEditingController(text: 'https://placehold.co/200');
  final _identityTokenController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _userKeyController.dispose();
    _usernameController.dispose();
    _avatarUrlController.dispose();
    _identityTokenController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      userId: _userIdController.text.trim(),
      userKey: _userKeyController.text.trim(),
      username: _usernameController.text.trim().isEmpty
          ? null
          : _usernameController.text.trim(),
      avatarUrl: _avatarUrlController.text.trim().isEmpty
          ? null
          : _avatarUrlController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _fillDemoCredentials() {
    _userIdController.text =
        'demo-user-${DateTime.now().millisecondsSinceEpoch}';
    _userKeyController.text = 'demo-password';
    _usernameController.text = 'Demo User';
  }

  Future<void> _handleIdentityTokenLogin() async {
    final token = _identityTokenController.text.trim();
    if (token.isEmpty) return;
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithToken(token: token);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Token login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Icon(
                  Icons.chat_bubble_rounded,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to Qiscus Chat',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _userIdController,
                  decoration: const InputDecoration(
                    labelText: 'User ID',
                    hintText: 'Enter your user ID',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter user ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _userKeyController,
                  decoration: const InputDecoration(
                    labelText: 'User Key',
                    hintText: 'Enter your user key',
                    prefixIcon: Icon(Icons.key),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter user key';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name (Optional)',
                    hintText: 'Enter your display name',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _avatarUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Avatar URL (Optional)',
                    hintText: 'Enter avatar URL',
                    prefixIcon: Icon(Icons.image),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 16),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _fillDemoCredentials,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Use Demo Credentials',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text('Login with identity token'),
                  children: [
                    TextField(
                      controller: _identityTokenController,
                      decoration: const InputDecoration(
                        labelText: 'JWT / identity token',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _handleIdentityTokenLogin,
                      child: const Text('Login with token'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'The App ID is supplied with --dart-define=QISCUS_APP_ID.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
