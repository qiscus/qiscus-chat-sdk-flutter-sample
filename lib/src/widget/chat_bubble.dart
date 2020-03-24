import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

class ChatBubble extends StatelessWidget {
  ChatBubble({Key key, @required this.message}) : super(key: key);

  final QMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.white),
        child: Container(
          height: 40,
          child: Row(children: <Widget>[
            Text(
              '${message.sender.name}:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(width: 10),
            Text(message.text),
            Spacer(),
            _buildStatus(message.status),
          ]),
        ),
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
        return Icon(Icons.done, size: size, color: Colors.green[400]);
      case QMessageStatus.sent:
      default:
      return Icon(Icons.done, size: size);
    }
  }
}
