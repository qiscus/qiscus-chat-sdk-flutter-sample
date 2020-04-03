import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sample/src/state/state.dart';

class RoomDetailPage extends StatefulWidget {
  const RoomDetailPage({Key key, @required this.roomId}) : super(key: key);
  final int roomId;

  @override
  _RoomDetailPageState createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: <Widget>[
          Consumer<RoomState>(
            builder: (_, state, __) {
              var participants = state.currentRoom?.participants;
              return ListView.separated(
                itemBuilder: (_, index) {
                  var participant = participants.elementAt(index);
                  return ListTile(
                    leading: Padding(
                      padding: EdgeInsets.all(10),
                      child: CircleAvatar(
                        backgroundImage:
                            Image.network(participant.avatarUrl).image,
                      ),
                    ),
                    title: Text(participant.name),
                  );
                },
                separatorBuilder: (_, __) => Divider(
                  height: 2,
                  thickness: 1,
                ),
                itemCount: participants.length,
              );
            },
          )
        ],
      ),
    );
  }
}
