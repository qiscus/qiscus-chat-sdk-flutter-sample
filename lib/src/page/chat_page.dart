import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sample/src/state/state.dart';
import 'package:qiscus_chat_sample/src/widget/app_bar.dart';
import 'package:qiscus_chat_sample/src/widget/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  ChatPage({this.roomId});

  final int roomId;

  @override
  State<StatefulWidget> createState() => _ChatState();
}

class _ChatState extends State<ChatPage> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      _getRoom();
      _getMessages();
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return Consumer<RoomState>(
      builder: (_, state, __) => Scaffold(
        appBar: appBar(
          room: state.currentRoom,
          onBack: () => Navigator.pushReplacementNamed(context, '/login'),
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

  Widget buildLoading() {
    return Expanded(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _form(BuildContext ctx) {
    var roomId = widget.roomId;
    final controller = TextEditingController();
    final key = GlobalKey<FormState>();
    var messageState = Provider.of<MessageState>(context, listen: false);

    final submit = (String message) {
      messageState.submit(
        roomId: roomId,
        message: message,
      );
      controller.text = '';
      _animateScrollToBottom();
    };
    return Form(
      key: key,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: () async {
              print('get file');
              var file = await FilePicker.getFile();
              if (file != null) {
                await messageState.sendFile(file);
                _animateScrollToBottom();
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

  bool isLoading = false;

  Widget _messageList(BuildContext ctx) {
    return Expanded(
      child: Consumer<MessageState>(builder: (_, state, __) {
        var reversed = state.messages.reversed;
        return ListView.separated(
          separatorBuilder: (_, __) {
            return Divider(color: Colors.grey, height: 1.0);
          },
          itemCount: state.messages.length,
          itemBuilder: (ctx, index) =>
              ChatBubble(
                message: reversed.elementAt(index),
              ),
          controller: scrollController,
          padding: EdgeInsets.symmetric(horizontal: 10),
        );
      }),
    );
  }

  Future _getMessages() async {
    var roomId = widget.roomId;
    if (roomId == null) return;
    var messageState = Provider.of<MessageState>(context, listen: false);
    await messageState.getAllMessage(roomId);
    messageState.subscribeChatRoom(messageReceivedCallback: () {
      _animateScrollToBottom();
    });
  }

  void _animateScrollToBottom() {
    Timer(const Duration(milliseconds: 400), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.ease,
      );
    });
  }

  Future _getRoom() async {
    var roomId = widget.roomId;
    if (roomId == null) return;
    var roomState = Provider.of<RoomState>(context, listen: false);
    var room = await roomState.getRoomWithId(roomId);
    roomState.subscribe(room);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
