import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'bloc/room_detail_bloc.dart';

class RoomDetail extends StatefulWidget {
  RoomDetail({
    @required this.qiscus,
    @required this.roomId,
  });

  final QiscusSDK qiscus;
  final int roomId;

  @override
  _RoomDetailState createState() => _RoomDetailState();
}

class _RoomDetailState extends State<RoomDetail> {
  RoomDetailBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = RoomDetailBloc(widget.qiscus);

    Future.microtask(() {
      bloc.add(RoomDetailBlocEvent.load(widget.roomId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomDetailBloc, RoomDetailBlocState>(
      bloc: bloc,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: state.map(
              loading: (state) => Text('Loading...'),
              ready: (state) => Text(state.room.name),
            ),
            leading: IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: <Widget>[
              Container(
                child: state.when(
                  loading: () =>
                      Image.asset('assets/ic-default-room-avatar.png'),
                  ready: (room) => Image.network(room.avatarUrl),
                ),
              ),
              state.map(
                loading: (state) => CircularProgressIndicator(),
                ready: (state) => ListView.builder(
                  itemCount: state.room.participants.length,
                  itemBuilder: (context, index) {
                    final participant = state.room.participants[index];
                    final avatar = Image.network(participant.avatarUrl);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: avatar.image,
                      ),
                      title: Text(participant.name),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
