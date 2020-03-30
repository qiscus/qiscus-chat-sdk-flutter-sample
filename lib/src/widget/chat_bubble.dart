import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

class ChatBubble extends StatelessWidget {
  ChatBubble({Key key, @required this.message}) : super(key: key);

  final QMessage message;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: Image.network(
          message.sender.avatarUrl,
          fit: BoxFit.cover,
        ).image,
      ),
      title: Text(message.sender.name),
      subtitle: Stack(
        children: <Widget>[
          if (message.type == QMessageType.text) Text(message.text),
          if (message.type == QMessageType.attachment)
            _buildAttachment(message.payload['url']),
          Container(
            alignment: Alignment.bottomRight,
            child: _buildStatus(message.status),
          ),
        ],
      ),
    );
  }

  Icon _buildStatus(QMessageStatus status) {
    var size = 18.0;
    switch (status) {
      case QMessageStatus.sending:
        return Icon(Icons.import_export, size: size);
      case QMessageStatus.read:
        return Icon(Icons.done_all, size: size, color: Colors.green[400]);
      case QMessageStatus.delivered:
        return Icon(Icons.done_all, size: size, color: Colors.black26);
      case QMessageStatus.sent:
      default:
        return Icon(Icons.done, size: size);
    }
  }

  Widget _buildAttachment(String url) {
    return Container(
      child: Image.network(
        url,
        width: 200,
        height: 130,
      ),
    );
  }

  String _getThumbnailUrl(String url) =>
      url.replaceAll(r'/upload/', '/upload/w_30,c_scale/');
}
