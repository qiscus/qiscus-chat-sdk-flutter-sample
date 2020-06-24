import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sample/state/state.dart';
import 'package:qiscus_chat_sample/widget/app_bar.dart';
import 'package:qiscus_chat_sample/widget/chat_bubble.dart';
import 'package:rxdart/rxdart.dart';

class ChatPage extends StatefulWidget {
  final int roomId;

  ChatPage({this.roomId});

  @override
  State<StatefulWidget> createState() => _ChatState();
}

class _ChatState extends State<ChatPage> {
  final scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _debounceTimer = TimerStream(true, const Duration(milliseconds: 500)) //
      .asBroadcastStream();
  final scroll$ = StreamController<ScrollNotification>();
  final typing$ = StreamController();

  bool isLoading = false;
  MessageState _state;
  RoomState _roomState;

  @override
  Widget build(BuildContext ctx) {
    return Consumer<RoomState>(
      builder: (_, state, __) => Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leading: FlatButton(
            onPressed: () => Navigator.pop(context),
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
                  backgroundImage: (state.currentRoom != null)
                      ? Image.network(
                          state.currentRoom.avatarUrl,
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
                      if (state.currentRoom != null)
                        Text(state.currentRoom.name,
                            style: TextStyle(fontSize: 18)),
                      if (state.currentRoom == null) Text('Loading...'),
                      if (state.currentRoom != null)
                        Consumer<RoomState>(
                          builder: (_, state, __) => MultiProvider(
                            providers: [
                              StreamProvider.value(value: state.onTyping),
                              StreamProvider.value(value: state.onPresence),
                            ],
                            child: AppBarStatus(room: state.currentRoom),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            PopupMenuButton<ChatPageMenu>(
              onSelected: _onSelectMenu,
              itemBuilder: (ctx) => <PopupMenuEntry<ChatPageMenu>>[
                PopupMenuItem<ChatPageMenu>(
                  value: ChatPageMenu.detail,
                  child: Text('Detail'),
                )
              ],
            )
          ],
        ),
        body: Column(
          children: [
            if (isLoading) LinearProgressIndicator(),
            _messageList(ctx),
            _form(ctx),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    _roomState.unsubscribe(_roomState.currentRoom);
    super.deactivate();
  }

  @override
  void dispose() async {
    super.dispose();
    scrollController.dispose();
    await scroll$.close();
    await typing$.close();
    _state.clear();
  }

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      _state = Provider.of<MessageState>(context, listen: false);
      _roomState = Provider.of<RoomState>(context, listen: false);
    });

    scheduleMicrotask(() {
      _getRoom();
      _getMessages();

      scroll$.stream
          .debounce((_) => _debounceTimer)
          .where((n) => n.metrics.pixels == n.metrics.maxScrollExtent)
          .listen((_) => _loadMore());

      typing$.stream
          .debounce((_) => _debounceTimer)
          .listen((_) => _roomState.publishTyping(widget.roomId));
    });
  }

  Widget _form(BuildContext ctx) {
    var roomId = widget.roomId;
    final controller = TextEditingController();
    final key = GlobalKey<FormState>();
    var messageState = Provider.of<MessageState>(context, listen: false);

    controller.addListener(() {
      typing$.sink.add(null);
    });

    final submit = (String message) {
      messageState.submit(
        roomId: roomId,
        message: message,
      );
      controller.text = '';
    };
    return Form(
      key: key,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: () async {
              var file = await FilePicker.getFile();
              if (file != null) {
                await messageState.sendFile(file);
              }
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controller,
                onFieldSubmitted: (str) {
                  if (str.isNotEmpty) {
                    submit(str);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Type your message here',
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                submit(controller.text);
              }
            },
          ),
        ],
      ),
    );
  }

  Future _getMessages() async {
    var roomId = widget.roomId;
    if (roomId == null) return;
    var messageState = Provider.of<MessageState>(context, listen: false);
    await messageState.getAllMessage(roomId);
    messageState.subscribeChatRoom();
  }

  Future _getRoom() async {
    var roomId = widget.roomId;
    if (roomId == null) return;
    var roomState = Provider.of<RoomState>(context, listen: false);
    var room = await roomState.getRoomWithId(roomId);
    roomState.subscribe(room);
  }

  Future<void> _loadMore() async {
    setState(() {
      isLoading = true;
    });
    await _state.getPreviousMessage(widget.roomId);
    setState(() {
      isLoading = false;
    });
  }

  Widget _messageList(BuildContext ctx) {
    var roomId = widget.roomId;
    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          scroll$.sink.add(notification);
          return true;
        },
        child: Consumer<MessageState>(builder: (_, state, __) {
          var reversed = state.messageForChatRoomId(roomId).reversed;
          return ListView.separated(
            separatorBuilder: (_, __) {
              return Divider(color: Colors.grey, height: 1.0);
            },
            itemCount: state.messages.length,
            itemBuilder: (ctx, index) => ChatBubble(
              message: reversed.elementAt(index),
            ),
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 10),
            reverse: true,
          );
        }),
      ),
    );
  }

  void _onSelectMenu(ChatPageMenu value) {
    var roomId = widget.roomId;
    switch (value) {
      case ChatPageMenu.detail:
        Navigator.pushNamed(context, '/room/$roomId/detail');
        break;
      default:
        break;
    }
  }
}

enum ChatPageMenu {
  detail,
}
