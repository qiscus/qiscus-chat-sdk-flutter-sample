import 'package:flutter/material.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

class UserList extends StatefulWidget {
  UserList(
    this.qiscus, {
    @required this.onTap,
  });

  final Function(QUser) onTap;
  final QiscusSDK qiscus;

  @override
  State<StatefulWidget> createState() => _State(qiscus);
}

class _State extends State<UserList> {
  _State(this.qiscus);

  QiscusSDK qiscus;
  List<QUser> users = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      var users = await qiscus.getUsers$();
      setState(() {
        this.users = users;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: users.length,
      itemBuilder: (context, index) {
        var user = users.elementAt(index);
        return ListTile(
          title: Text(user.name),
          subtitle: Text(user.id),
          leading: CircleAvatar(
            backgroundImage: Image.network(
              user.avatarUrl,
            ).image,
          ),
          onTap: () => widget.onTap(user),
        );
      },
      separatorBuilder: (_, __) => Divider(thickness: 1, height: 1),
    );
  }
}
