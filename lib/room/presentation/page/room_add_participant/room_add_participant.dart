import 'package:flutter/material.dart';
import 'package:qiscus_chat_sample/widget/user_list.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

class RoomAddParticipant extends StatefulWidget {
  RoomAddParticipant({
    @required this.qiscus,
    @required this.roomId,
  });

  final QiscusSDK qiscus;
  final int roomId;

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RoomAddParticipant> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add participant'),
        leading: Navigator.canPop(context)
            ? IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.chevron_left),
              )
            : null,
      ),
      body: UserList(
        widget.qiscus,
        onTap: (user) async {
          await widget.qiscus.addParticipants$(
            roomId: widget.roomId,
            userIds: [user.id],
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}
