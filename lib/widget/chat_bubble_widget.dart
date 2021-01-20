import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import '../widget/avatar_widget.dart';

class ChatBubble extends StatelessWidget {
  ChatBubble({
    @required this.message,
    this.onPress,
    this.flipped = false,
  });

  final bool flipped;
  final QMessage message;
  final void Function() onPress;

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
          Avatar(url: sender.avatarUrl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment:
                  flipped ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                _buildSender(sender),
                Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[
                    GestureDetector(
                      onLongPress: () => this.onPress?.call(),
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
    return BoxDecoration(
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
          style: TextStyle(
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
              style: TextStyle(
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
              style: TextStyle(
                fontSize: 12,
              )),
        ),
    ];
  }

  Text _buildSender(QUser sender) {
    return Text(
      sender.name,
      style: TextStyle(
        fontSize: 12,
      ),
    );
  }

  Widget _buildChild() {
    if (message.payload == null || message.payload?.isEmpty == true)
      return Text(message.text);
    String url = message.payload['url'];
    var uri = Uri.parse(url);
    var isImage = uri.toString().contains(RegExp(r'(jpe?g|png|gif)$'));
    var progress = message.payload['progress'] ?? 0.0;
    progress = progress / 100;

    if (message.type == QMessageType.attachment && isImage) {
      return Container(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (message.payload['progress'] != null) ...[
              // Image.file(File(message.payload['url'])),
              LinearProgressIndicator(value: progress),
            ],
            if ((message.payload['url'] as String).startsWith('http'))
              Image.network(message.payload['url']),
            Positioned(
              bottom: 0,
              left: 0,
              child: FlatButton(
                onPressed: () => _download(),
                shape: CircleBorder(),
                color: Colors.white.withAlpha(0x55),
                minWidth: 14,
                child: Icon(Icons.file_download, size: 18),
              ),
            ),
          ],
        ),
      );
    }
    if (message.type == QMessageType.attachment && !isImage) {
      return Container(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (message.payload['progress'] != null) ...[
              // Image.file(File(message.payload['url'])),
              LinearProgressIndicator(value: progress),
            ],
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: Row(
                children: [
                  FlatButton(
                    onPressed: _download,
                    color: Colors.grey.withAlpha(60),
                    minWidth: 18,
                    child: Icon(Icons.file_download, size: 20),
                    shape: CircleBorder(),
                  ),
                  Text(message.payload['file_name']),
                ],
              ),
            ),
            if ((message.payload['caption'] as String).isNotEmpty)
              Text(message.payload['caption']),
          ],
        ),
      );
    }
    return Text(message.text);
  }

  void _download() async {
    var status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      var downloadFolder =
          await getExternalStorageDirectory().then((d) => d.path);
      await FlutterDownloader.enqueue(
        url: message.payload['url'],
        savedDir: downloadFolder,
        showNotification: true,
        openFileFromNotification: true,
        fileName: message.payload['file_name'],
      );
    }
  }

  List<Widget> _buildStatus() {
    if (flipped)
      return [
        Positioned(
          top: 0,
          left: flipped ? -14 : null,
          right: !flipped ? -14 : null,
          child: Icon(
            Icons.done_all,
            size: 12,
            color: message.status == QMessageStatus.read
                ? Colors.lightGreen
                : Colors.grey,
          ),
        )
      ];
    else
      return [];
  }
}
