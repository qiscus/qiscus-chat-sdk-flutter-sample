import 'package:flutter/cupertino.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

class AppBar extends StatelessWidget {
  AppBar({
    @required this.room,
  }) : assert(room != null);

  final QChatRoom room;

  String get name => room.name;

  QRoomType get type => room.type;

  List<QParticipant> get participants {
    if (type == QRoomType.group) return room.participants;
    return [];
  }

  String get participantText {
    var p = participants.map((p) => p.name);
    var length = p.length;
    var visibleLength = 2;

    var res = p.take(visibleLength).join(', ');
    var remainingLength = length - visibleLength;
    if (remainingLength > 0) {
      res += 'and $remainingLength others';
    } else {
      res += '.';
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
