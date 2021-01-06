import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
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
                Text(
                  sender.name,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
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
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          border: Border.fromBorderSide(BorderSide(
                            color: Colors.black12,
                            width: 1.0,
                          )),
                          borderRadius: BorderRadius.all(
                            Radius.elliptical(5, 5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(message.text),
                        ),
                      ),
                    ),
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
                    if (flipped)
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
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
