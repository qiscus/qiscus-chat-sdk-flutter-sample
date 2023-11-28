import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import '../data/payload_data.dart';
import '../widget/avatar_widget.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.onPress,
    this.flipped = false,
  });

  final bool flipped;
  final QMessage message;
  final void Function(String?) onPress;

  @override
  Widget build(BuildContext context) {
    final sender = message.sender;
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 3.0,
        horizontal: 10.0,
      ),
      child: Row(
        // textDirection: TextDirection.rtl,
        textDirection: flipped ? TextDirection.rtl : TextDirection.ltr,
        children: <Widget>[
          Avatar(url: sender.avatarUrl!),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment:
                  flipped ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                _buildSender(sender),
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    GestureDetector(
                      onLongPress: () => onPress(null),
                      child: Container(
                        width: 200,
                        alignment: flipped
                            ? AlignmentDirectional.topEnd
                            : AlignmentDirectional.topStart,
                        decoration: _containerDecoration(),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildChild(),
                        ),
                      ),
                    ),
                    ..._buildTimestamp(),
                    ..._buildStatus(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _containerDecoration() {
    return const BoxDecoration(
      color: Colors.black12,
      border: Border.fromBorderSide(BorderSide(
        color: Colors.black12,
        width: 1.0,
      )),
      borderRadius: BorderRadius.all(
        Radius.elliptical(5, 5),
      ),
    );
  }

  List<Widget> _buildTimestamp() {
    return [
      Positioned(
        top: -10,
        right: !flipped ? 0 : null,
        left: flipped ? 0 : null,
        child: Text(
          message.timestamp.millisecondsSinceEpoch.toString(),
          style: const TextStyle(
            fontSize: 8,
          ),
        ),
      ),
      if (flipped)
        Positioned(
          left: -32,
          bottom: 1,
          child: Text(
              formatDate(
                message.timestamp,
                [HH, ':', mm],
              ),
              style: const TextStyle(
                fontSize: 12,
              )),
        ),
      if (!flipped)
        Positioned(
          right: -32,
          bottom: 1,
          child: Text(
              formatDate(
                message.timestamp,
                [HH, ':', mm],
              ),
              style: const TextStyle(
                fontSize: 12,
              )),
        ),
    ];
  }

  Text _buildSender(QUser sender) {
    return Text(
      sender.name,
      style: const TextStyle(
        fontSize: 12,
      ),
    );
  }

  Widget _buildChild() {

    CrossAxisAlignment alignment;
    Color backgroundColor;
    Color buttonColor;
    List<String> buttonLabels = [];

    if (flipped) {
      alignment = CrossAxisAlignment.end;
      backgroundColor = Colors.blue;
      buttonColor = Colors.blue;
    } else {
      alignment = CrossAxisAlignment.start;
      backgroundColor = Colors.grey[300]!;
      buttonColor = Colors.grey[400]!;
    }
    if (message.payload == null || message.payload?.isEmpty == true) {
      return Text(message.text);
    }

    String? url = message.payload?['url'] as String?;
    ResponseData? responseData;
    try {
      responseData = ResponseData.fromJson(message.payload!);
    } catch (e) {
      responseData = null;
    }
    if (responseData != null  && responseData.buttons.isNotEmpty) {
      for (var button in responseData.buttons) {
        buttonLabels.add(button.label);
      }
    }
    var isImage = url?.contains(RegExp(r'(jpe?g|png|gif)$')) ?? false;
    var progress = (message.payload?['progress'] as double?) ?? 0.0;
    progress = progress / 100;

    if (message.type == QMessageType.attachment && isImage) {
      return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (message.payload?['progress'] != null) ...[
              // Image.file(File(message.payload['url'])),
              LinearProgressIndicator(value: progress.toDouble()),
            ],
            if ((message.payload?['url'] as String).startsWith('http'))
              Image.network(message.payload!['url'] as String),
            Positioned(
              bottom: 0,
              left: 0,
              child: TextButton(
                onPressed: () => _download(),
                style: TextButton.styleFrom(
                  shape: const CircleBorder(),
                  minimumSize: const Size.fromWidth(14),
                  foregroundColor: Colors.white.withAlpha(0x55),
                ),
                child: const Icon(Icons.file_download, size: 18),
              ),
            ),
          ],
      );
    }
    if (message.type == QMessageType.attachment && !isImage) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (message.payload?['progress'] != null) ...[
            // Image.file(File(message.payload['url'])),
            LinearProgressIndicator(value: progress.toDouble()),
          ],
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3.0),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: _download,
                  child: const Icon(Icons.file_download, size: 20),
                ),
                Text(message.payload!['file_name'] as String),
              ],
            ),
          ),
          if ((message.payload?['caption'] as String).isNotEmpty)
            Text(message.payload!['caption'] as String),
        ],
      );
    }
    if (message.type == QMessageType.custom && responseData?.type == "buttons") {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: backgroundColor,
            child: Column(
              children: [
                Text(
                  message.text,
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 12.0),
                Column(
                  mainAxisAlignment: alignment == CrossAxisAlignment.start
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: buttonLabels.map((label) {
                    return ElevatedButton(
                      onPressed: () => onPress(label),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                      ),
                      child: Text(label),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Text(message.text);
  }

  void _download() async {
    var status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      // var folder = await path.getExternalStorageDirectory();
      var folder = await path.getApplicationDocumentsDirectory();
      var downloadFolder = folder.path;
      var r = await FlutterDownloader.enqueue(
        url: message.payload?['url'] as String,
        savedDir: downloadFolder,
        showNotification: true,
        openFileFromNotification: true,
        fileName: message.payload?['file_name'] as String,
      );
      if (r != null) {
        print('download: $r');
      }
    }
  }

  List<Widget> _buildStatus() {
    if (flipped) {
      return [
        Positioned(
          top: 0,
          left: -14,
          child: Icon(
            Icons.done_all,
            size: 14,
            color: message.status == QMessageStatus.read
                ? Colors.lightGreen
                : Colors.grey,
          ),
        )
      ];
    } else {
      return [];
    }
  }
}
