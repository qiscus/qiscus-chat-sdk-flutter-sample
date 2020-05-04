import 'package:flutter/material.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'bloc/room_list_bloc.dart';

class RoomList extends StatefulWidget {
  RoomList(this.qiscus);

  final QiscusSDK qiscus;

  @override
  _RoomListState createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  RoomListBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = RoomListBloc(widget.qiscus);

    Future.microtask(() {
      _bloc.add(RoomListBlocEvent.load());
    });
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
