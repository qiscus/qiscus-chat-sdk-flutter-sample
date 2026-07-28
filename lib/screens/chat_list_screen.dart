import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:qiscus_chat_flutter_sample/providers/chat_provider.dart';
import 'package:qiscus_chat_flutter_sample/screens/chat_room_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              if (chatProvider.unreadCount > 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${chatProvider.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          if (chatProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chatProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${chatProvider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => chatProvider.loadChatRooms(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (chatProvider.chatRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a new conversation',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => chatProvider.loadChatRooms(),
            child: ListView.separated(
              itemCount: chatProvider.chatRooms.length +
                  (chatProvider.hasMoreRooms ? 1 : 0),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == chatProvider.chatRooms.length) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => chatProvider.loadMoreChatRooms(),
                  );
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final room = chatProvider.chatRooms[index];
                return ChatRoomTile(room: room);
              },
            ),
          );
        },
      ),
    );
  }
}

class ChatRoomTile extends StatelessWidget {
  final QChatRoom room;

  const ChatRoomTile({Key? key, required this.room}) : super(key: key);

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(time);
    } else {
      return DateFormat('dd/MM/yy').format(time);
    }
  }

  String _getRoomName() {
    if (room.type == QRoomType.single) {
      return room.name ?? 'Unknown';
    } else if (room.type == QRoomType.group) {
      return room.name ?? 'Group Chat';
    } else {
      return room.name ?? 'Channel';
    }
  }

  IconData _getRoomIcon() {
    if (room.type == QRoomType.single) {
      return Icons.person;
    } else if (room.type == QRoomType.group) {
      return Icons.group;
    } else {
      return Icons.tag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        backgroundImage: room.avatarUrl != null && room.avatarUrl!.isNotEmpty
            ? CachedNetworkImageProvider(room.avatarUrl!)
            : null,
        child: room.avatarUrl == null || room.avatarUrl!.isEmpty
            ? Icon(_getRoomIcon(), color: Theme.of(context).primaryColor)
            : null,
      ),
      title: Text(
        _getRoomName(),
        style: TextStyle(
          fontWeight:
              room.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        room.lastMessage?.text ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight:
              room.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(room.lastMessage?.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: room.unreadCount > 0
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
          ),
          if (room.unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${room.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(room: room),
          ),
        );
      },
    );
  }
}
