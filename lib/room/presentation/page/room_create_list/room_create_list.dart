import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sample/state/state.dart';
import 'package:qiscus_chat_sample/widget/user_list.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

class RoomCreateListPage extends StatefulWidget {
  RoomCreateListPage({
    @required this.qiscus,
    @required this.roomState,
  });

  final QiscusSDK qiscus;
  final RoomState roomState;

  @override
  State<StatefulWidget> createState() => _State(qiscus, roomState);
}

class _State extends State {
  _State(this.qiscus, this.roomState);

  final QiscusSDK qiscus;
  final RoomState roomState;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await roomState.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Container(
        child: Consumer<RoomState>(
          builder: (context, state, _) {
            return UserList(qiscus, onTap: (user) async {
              var room = await state.getRoomWithUser(userId: user.id);
              Navigator.pushReplacementNamed(context, '/room/${room.id}');
            });
          },
        ),
      ),
    );
  }
}
