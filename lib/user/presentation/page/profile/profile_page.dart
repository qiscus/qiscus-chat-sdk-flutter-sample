import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'bloc/profile_page_bloc.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({
    @required this.qiscus,
    @required this.userId,
  });

  final QiscusSDK qiscus;
  final String userId;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfilePageBloc bloc;

  var editNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bloc = ProfilePageBloc(widget.qiscus);

    Future.microtask(() {
      bloc.add(ProfilePageEvent.load(widget.userId));
    });
  }

  @override
  void dispose() {
    super.dispose();
    bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfilePageBloc, ProfilePageState>(
      bloc: bloc,
      builder: (context, state) {
        state.when(
          loading: () => editNameController.text = 'Loading',
          ready: (u) => editNameController.text = u.name,
          uploading: (u, _) => editNameController.text = u.name,
          editingName: (u, name) => editNameController.text = name,
        );
        return Scaffold(
          appBar: AppBar(
            title: state.maybeWhen(
              orElse: () => Text('Profile'),
              loading: () => Text('Loading...'),
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
                        uploading: (user, _) => Image.network(user.avatarUrl),
                        ready: (user) => Image.network(
                          user.avatarUrl,
                          fit: BoxFit.scaleDown,
                        ),
                        editingName: (user, name) => Image.network(
                          user.avatarUrl,
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
                                  uploading: (u, _) => Text(
                                    u.name,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  ready: (r) => Text(
                                    r.name,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  editingName: (user, name) => Text(
                                    name,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            ...state.when(
                              loading: () => [Container()],
                              editingName: (user, name) => [Container()],
                              uploading: (user, progress) => <Widget>[
                                CircularProgressIndicator(value: progress),
                              ],
                              ready: (_) => <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.image,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    var file = await FilePicker.getFile(
                                      type: FileType.image,
                                    );
                                    if (file != null) {
                                      bloc.add(
                                        ProfilePageEvent.changeProfilePicture(
                                          file,
                                        ),
                                      );
                                    }
                                  },
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
                // color: Color.fromRGBO(250, 250, 250, 1),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'INFORMATION',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(120, 120, 120, 1),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.person, color: ICON_COLOR),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: state.when(
                                loading: () => Text('Loading...'),
                                editingName: (user, name) => TextField(
                                  controller: editNameController,
                                  onSubmitted: (value) {
                                    bloc.add(
                                      ProfilePageEvent.finishEditName(value),
                                    );
                                  },
                                ),
                                ready: (user) => Text(user.name),
                                uploading: (user, progress) => Text(user.name),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: ICON_COLOR),
                            onPressed: () {
                              bloc.add(ProfilePageEvent.startEditName());
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.credit_card, color: ICON_COLOR),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: state.when(
                                loading: () => Text('Loading...'),
                                ready: (u) => Text(u.id),
                                uploading: (u, _) => Text(u.id),
                                editingName: (u, _) => Text(u.id),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
//              Expanded(
//                child: state.when(
//                  loading: () => Center(
//                    child: CircularProgressIndicator(),
//                  ),
//                  uploading: (account, _) => renderDetail(
//                    context,
//                    account,
//                    false,
//                  ),
//                  ready: (account) => renderDetail(
//                    context,
//                    account,
//                    false,
//                  ),
//                  editingName: (account, name) => renderDetail(
//                    context,
//                    account,
//                    true,
//                    name,
//                  ),
//                ),
//              ),
            ],
          ),
        );
      },
    );
  }
}

const ICON_COLOR = Color.fromRGBO(151, 151, 151, 1);
