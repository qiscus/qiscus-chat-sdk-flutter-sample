import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_flutter_sample/providers/chat_provider.dart';
import 'package:qiscus_chat_flutter_sample/providers/feature_gallery_provider.dart';

class FeatureGalleryScreen extends StatelessWidget {
  const FeatureGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeatureGalleryProvider(),
      child: const _FeatureGalleryView(),
    );
  }
}

class _FeatureGalleryView extends StatefulWidget {
  const _FeatureGalleryView();

  @override
  State<_FeatureGalleryView> createState() => _FeatureGalleryViewState();
}

class _FeatureGalleryViewState extends State<_FeatureGalleryView> {
  final _userId = TextEditingController();
  final _roomId = TextEditingController();
  final _roomName = TextEditingController();
  final _customType = TextEditingController(text: 'sample_card');
  final _customValue = TextEditingController(text: 'Hello from the gallery');

  int? get roomId => int.tryParse(_roomId.text.trim());

  @override
  void dispose() {
    _userId.dispose();
    _roomId.dispose();
    _roomName.dispose();
    _customType.dispose();
    _customValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gallery = context.watch<FeatureGalleryProvider>();
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('SDK Feature Gallery')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.sensors),
              title: Text('Realtime: ${chat.connectionState}'),
              subtitle: chat.realtimeError == null
                  ? const Text('No realtime error reported')
                  : Text(chat.realtimeError!),
            ),
          ),
          TextField(
            controller: _userId,
            decoration: const InputDecoration(
              labelText: 'User ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => gallery.blockUser(_userId.text.trim()),
                child: const Text('Block'),
              ),
              OutlinedButton(
                onPressed: () => gallery.unblockUser(_userId.text.trim()),
                child: const Text('Unblock'),
              ),
              OutlinedButton(
                onPressed: gallery.listBlockedUsers,
                child: const Text('Blocked users'),
              ),
              OutlinedButton(
                onPressed: gallery.getJwtNonce,
                child: const Text('JWT nonce'),
              ),
            ],
          ),
          const Divider(height: 32),
          TextField(
            controller: _roomId,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Room ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _roomName,
            decoration: const InputDecoration(labelText: 'New room name'),
          ),
          TextField(
            controller: _customType,
            decoration: const InputDecoration(labelText: 'Custom type'),
          ),
          TextField(
            controller: _customValue,
            decoration: const InputDecoration(labelText: 'Custom value'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: roomId == null
                    ? null
                    : () => gallery.updateRoom(
                          roomId: roomId!,
                          name: _roomName.text.trim(),
                        ),
                child: const Text('Update room'),
              ),
              OutlinedButton(
                onPressed: roomId == null
                    ? null
                    : () => gallery.sendCustomMessage(
                          roomId: roomId!,
                          type: _customType.text.trim(),
                          text: _customValue.text,
                        ),
                child: const Text('Custom message'),
              ),
              OutlinedButton(
                onPressed: roomId == null
                    ? null
                    : () => gallery.publishCustomEvent(
                          roomId: roomId!,
                          value: _customValue.text,
                        ),
                child: const Text('Publish event'),
              ),
              OutlinedButton(
                onPressed: roomId == null
                    ? null
                    : () => gallery.subscribeCustomEvents(roomId!),
                child: const Text('Listen events'),
              ),
              OutlinedButton(
                onPressed:
                    roomId == null ? null : () => gallery.listFiles(roomId!),
                child: const Text('List files'),
              ),
            ],
          ),
          const Divider(height: 32),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: gallery.synchronize,
                child: const Text('Force sync'),
              ),
              OutlinedButton(
                onPressed: () => gallery.setRealtimeConnection(open: false),
                child: const Text('Close realtime'),
              ),
              OutlinedButton(
                onPressed: () => gallery.setRealtimeConnection(open: true),
                child: const Text('Open realtime'),
              ),
            ],
          ),
          if (gallery.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (gallery.error != null)
            SelectableText(
              gallery.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (gallery.result != null) SelectableText(gallery.result!),
        ],
      ),
    );
  }
}
