import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:qiscus_chat_flutter_sample/providers/chat_provider.dart';
import 'package:qiscus_chat_flutter_sample/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatRoomScreen extends StatefulWidget {
  final QChatRoom room;

  const ChatRoomScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  late ChatProvider _chatProvider;
  String? _lastMessageUniqueId;
  final ValueNotifier<bool> _showScrollToBottom = ValueNotifier(false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference to ChatProvider for safe access in dispose()
    _chatProvider = context.read<ChatProvider>();
  }

  @override
  void initState() {
    super.initState();
    // Enter chat room
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().enterChatRoom(widget.room);
    });

    // Setup scroll listener for loading more messages
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _showScrollToBottom.dispose();
    // Use saved reference instead of context.read()
    unawaited(_chatProvider.leaveChatRoom());
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels <= position.minScrollExtent + 100) {
      context.read<ChatProvider>().loadPreviousMessages();
    }

    // Only flip the notifier (and thus rebuild) when the near-bottom
    // state actually changes, not on every scroll pixel.
    final isNearBottom = position.pixels >= position.maxScrollExtent - 100;
    if (_showScrollToBottom.value == isNearBottom) {
      _showScrollToBottom.value = !isNearBottom;
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    await context.read<ChatProvider>().sendMessage(text);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null && mounted) {
      final fileName = image.path.split('/').last;
      // Use new flow: show placeholder -> upload -> update message
      await context.read<ChatProvider>().sendFileMessageWithPlaceholder(
            File(image.path),
            caption: 'Image: $fileName',
          );
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null && mounted) {
      final fileName = result.files.single.name;
      final extension = fileName.split('.').last.toUpperCase();
      // Use new flow: show placeholder -> upload -> update message
      await context.read<ChatProvider>().sendFileMessageWithPlaceholder(
            File(result.files.single.path!),
            caption: 'File attachment .$extension',
          );
    }
  }

  void _scrollToBottom({bool jump = false}) {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (jump) {
      _scrollController.jumpTo(maxExtent);
    } else {
      _scrollController.animateTo(
        maxExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('File'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.room.name ?? 'Chat'),
            Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final typingUsers = chatProvider.typingUsers.entries
                    .where((e) => e.value && e.key != currentUserId)
                    .map((e) => e.key)
                    .toList();

                if (typingUsers.isNotEmpty) {
                  return const Text(
                    'typing...',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'clear') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Messages'),
                    content: const Text(
                      'Are you sure you want to clear all messages?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  if (context.mounted) {
                    await context.read<ChatProvider>().clearMessages();
                  }
                }
              } else if (value == 'participants') {
                _showParticipants();
              }
            },
            itemBuilder: (context) => [
              if (widget.room.type == QRoomType.group)
                const PopupMenuItem(
                  value: 'participants',
                  child: Text('Participants'),
                ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear Messages'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, _) {
                    if (chatProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (chatProvider.messages.isEmpty) {
                      return const Center(
                        child: Text('No messages yet. Start the conversation!'),
                      );
                    }

                    final messages = chatProvider.messages;
                    final newestId = messages.last.uniqueId;
                    if (newestId != _lastMessageUniqueId) {
                      final isFirstLoad = _lastMessageUniqueId == null;
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _scrollToBottom(jump: isFirstLoad),
                      );
                    }
                    _lastMessageUniqueId = newestId;

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length +
                          (chatProvider.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (chatProvider.isLoadingMore && index == 0) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final messageIndex =
                            chatProvider.isLoadingMore ? index - 1 : index;
                        final message = messages[messageIndex];
                        final isMe = message.sender.id == currentUserId;

                        return MessageBubble(
                          message: message,
                          isMe: isMe,
                        );
                      },
                    );
                  },
                ),
              ),
              SafeArea(child: _buildMessageInput()),
            ],
          ),
          Positioned(
            bottom: 120,
            right: 10,
            child: ValueListenableBuilder<bool>(
              valueListenable: _showScrollToBottom,
              builder: (context, showButton, child) {
                if (!showButton) return const SizedBox.shrink();
                return child!;
              },
              child: FloatingActionButton.small(
                onPressed: _scrollToBottom,
                elevation: 2,
                child: const Icon(Icons.arrow_drop_down_sharp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _showAttachmentOptions,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              onChanged: (text) {
                // Publish typing indicator
                if (text.isNotEmpty) {
                  context.read<ChatProvider>().publishTyping(true);
                } else {
                  context.read<ChatProvider>().publishTyping(false);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _showParticipants() async {
    final participants = await context.read<ChatProvider>().getParticipants();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Participants',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final participant = participants[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: participant.avatarUrl != null
                        ? CachedNetworkImageProvider(participant.avatarUrl!)
                        : null,
                    child: participant.avatarUrl == null
                        ? Text(participant.name[0].toUpperCase())
                        : null,
                  ),
                  title: Text(participant.name),
                  subtitle: Text(participant.id),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final QMessage message;
  final bool isMe;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  IconData _getStatusIcon() {
    switch (message.status) {
      case QMessageStatus.sending:
        return Icons.access_time;
      case QMessageStatus.sent:
        return Icons.check;
      case QMessageStatus.delivered:
        return Icons.done_all;
      case QMessageStatus.read:
        return Icons.done_all;
      default:
        return Icons.error;
    }
  }

  Color _getStatusColor() {
    if (message.status == QMessageStatus.read) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: message.sender.avatarUrl != null
                  ? CachedNetworkImageProvider(message.sender.avatarUrl!)
                  : null,
              child: message.sender.avatarUrl == null
                  ? Text(
                      message.sender.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      message.sender.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isMe ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  _buildMessageContent(context),
                  const SizedBox(height: 4),
                  // Show upload progress if uploading
                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) {
                      final progress =
                          chatProvider.getUploadProgress(message.uniqueId);
                      if (progress > 0 && progress < 100) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    value: progress / 100,
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isMe ? Colors.white70 : Colors.blue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Uploading $progress%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        isMe ? Colors.white70 : Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          _getStatusIcon(),
                          size: 14,
                          color: _getStatusColor(),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    if (message.type == QMessageType.text) {
      return Text(
        message.text,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black87,
        ),
      );
    } else if (message.type == QMessageType.attachment) {
      final url = message.payload?['url'] as String?;
      if (url != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (url.contains(
                RegExp(r'\.(jpg|jpeg|png|gif|webp)$', caseSensitive: false)))
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: url,
                  width: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
            else
              Row(
                children: [
                  const Icon(Icons.attach_file, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      }
    }

    return Text(
      message.text,
      style: TextStyle(
        color: isMe ? Colors.white : Colors.black87,
      ),
    );
  }
}
