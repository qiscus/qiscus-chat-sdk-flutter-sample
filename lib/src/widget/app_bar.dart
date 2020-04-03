import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sample/src/state/state.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:timeago/timeago.dart' as timeago;

String getParticipantText(List<QParticipant> participants) {
  var limit = 2;
  var count = participants.length - limit;
  var _participants = participants //
      .take(limit)
      .map((p) => p.name.split(' ')?.first ?? '')
      .toList();
  if (participants.length <= limit) return _participants.join(', ');
  _participants.add('and $count others.');
  return _participants.join(', ');
}

AppBar appBar({
  @required QChatRoom room,
  @required void Function() onBack,
}) {
  return AppBar(
    leading: FlatButton(
      onPressed: onBack,
      child: Icon(
        Icons.chevron_left,
        color: Colors.white,
        size: 34,
      ),
    ),
    centerTitle: false,
    title: Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            backgroundImage: (room != null)
                ? Image.network(
                    room.avatarUrl,
                    fit: BoxFit.fill,
                    height: 34,
                    width: 34,
                  ).image
                : Image.asset(
                    'assets/ic-default-room-avatar.png',
                    fit: BoxFit.fill,
                    height: 34,
                    width: 34,
                  ).image,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (room != null)
                  Text(room.name, style: TextStyle(fontSize: 18)),
                if (room == null) Text('Loading...'),
                if (room != null)
                  Consumer<RoomState>(
                    builder: (_, state, __) {
                      return MultiProvider(providers: [
                        StreamProvider.value(value: state.onTyping),
                        StreamProvider.value(value: state.onPresence),
                      ], child: AppBarStatus(room: room));
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class AppBarStatus extends StatelessWidget {
  AppBarStatus({@required this.room});

  final QChatRoom room;

  static const fontStyle = TextStyle(fontSize: 13.0);

  @override
  Widget build(BuildContext context) {
    if (room.type == QRoomType.single) {
      return Consumer2<Typing, Online>(
        builder: (_, typing, presence, __) {
          if (typing != null && typing.isTyping && typing.roomId == room.id) {
            return Text('Typing...', style: fontStyle);
          } else if (presence != null && !presence.isOnline) {
            var lastOnline = timeago.format(presence.lastOnline);
            return Text('Last online $lastOnline', style: fontStyle);
          } else {
            return Text('Online', style: fontStyle);
          }
        },
      );
    } else {
      return Text(getParticipantText(room.participants), style: fontStyle);
    }
  }
}
