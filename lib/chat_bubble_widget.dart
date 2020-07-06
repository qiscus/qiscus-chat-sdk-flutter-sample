import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

class ChatBubble extends StatelessWidget {
  ChatBubble({
    @required this.message,
    this.flipped = false,
  });

  final bool flipped;
  final QMessage message;

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
          CircleAvatar(
            backgroundImage: Image.network(sender.avatarUrl).image,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment:
                  flipped ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                Text(sender.name),
                Stack(
                  children: <Widget>[
                    Container(
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
                    if (flipped)
                      Positioned(
                        left: 5,
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
                        right: 5,
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
