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
  void dispose() {
    super.dispose();
    bloc.close();
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
              ready: (state) => Text('Rooms info'),
            ),
            leading: IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: <Widget>[
              // Room Avatar
              Container(
                height: 200,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.black26,
                      child: state.when(
                        loading: () => Image.asset(
                          'assets/ic-default-avatar.png',
                          fit: BoxFit.scaleDown,
                        ),
                        ready: (room) => Image.network(
                          room.avatarUrl,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      height: 55,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 0.3),
                          gradient: LinearGradient(
                            colors: <Color>[
                              Color.fromRGBO(0, 0, 0, 0.9),
                              Color.fromRGBO(51, 51, 51, 0.2),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: state.when(
                                  loading: () => Text(
                                    'Loading...',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  ready: (r) => Text(
                                    r.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ...state.when(
                              loading: () => [Container()],
                              ready: (r) => <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.image,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: Color.fromRGBO(250, 250, 250, 1),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'PARTICIPANTS',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(120, 120, 120, 1),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: state.when(
                  loading: () => Container(),
                  ready: (r) {
                    return ListView.builder(
                      itemCount: r.participants.length,
                      itemBuilder: (context, index) => ListTile(
                        leading: CircleAvatar(
                          backgroundImage: Image.network(
                            r.participants[index].avatarUrl,
                          ).image,
                        ),
                        title: Text(r.participants[index].name),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {},
                        ),
                      ),
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
