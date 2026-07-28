import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_flutter_sample/providers/chat_provider.dart';
import 'package:qiscus_chat_flutter_sample/screens/chat_list_screen.dart';
import 'package:qiscus_chat_flutter_sample/screens/profile_screen.dart';
import 'package:qiscus_chat_flutter_sample/screens/create_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load chat rooms on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadChatRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreateChatScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
