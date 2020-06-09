import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

part 'profile_page_bloc.freezed.dart';

@freezed
abstract class ProfilePageEvent with _$ProfilePageEvent {
  const factory ProfilePageEvent.initialize() = _EventInitialize;
  const factory ProfilePageEvent.load(String userId) = _EventLoad;
  const factory ProfilePageEvent.changeProfilePicture(File file) =
      _EventChangePicture;

  const factory ProfilePageEvent.startEditName() = _EventStartEditName;
  const factory ProfilePageEvent.editName(String name) = _EventEditName;
  const factory ProfilePageEvent.finishEditName(String name) =
      _EventFinishEditName;
}

@freezed
abstract class ProfilePageState with _$ProfilePageState {
  const factory ProfilePageState.loading() = _StateLoading;
  const factory ProfilePageState.ready(QAccount user) = _StateReady;
  const factory ProfilePageState.uploading({
    @required QAccount user,
    double progress,
  }) = _StateUploading;
  const factory ProfilePageState.editingName(QAccount user, String name) =
      _StateEditingName;
}

class ProfilePageBloc extends Bloc<ProfilePageEvent, ProfilePageState> {
  ProfilePageBloc(this.qiscus);

  final QiscusSDK qiscus;

  @override
  ProfilePageState get initialState => ProfilePageState.loading();

  @override
  Stream<ProfilePageState> mapEventToState(event) async* {
    yield* event.when(
      load: (userId) async* {
        var user = await qiscus.getUserData$();
        yield ProfilePageState.ready(user);
      },
      initialize: () async* {
        yield ProfilePageState.loading();
      },
      changeProfilePicture: (file) async* {
        var user = state.when(
          loading: () => null,
          ready: (u) => u,
          uploading: (u, _) => u,
          editingName: (u, _) => u,
        );
        yield ProfilePageState.uploading(user: user, progress: 0);

        var controller = StreamController<_StateUploading>();
        var completer = Completer<String>();
        qiscus.upload(
          file: file,
          callback: (error, progress, url) {
            if (progress != null)
              controller.add(ProfilePageState.uploading(
                user: user,
                progress: progress,
              ));
            if (error != null) {
              completer.completeError(error);
            } else if (url != null) {
              controller.close();
              completer.complete(url);
            }
          },
        );

        yield* controller.stream;

        var url = await completer.future;
        var account = await qiscus.updateUser$(avatarUrl: url);
        yield ProfilePageState.ready(account);
      },
      startEditName: () async* {
        var user = state.when(
          loading: () => null,
          ready: (u) => u,
          editingName: (user, _) => user,
          uploading: (user, _) => user,
        );
        yield ProfilePageState.editingName(user, user.name);
      },
      editName: (name) async* {
        yield state.maybeMap(
          orElse: () => state,
          editingName: (state) => state.copyWith(name: name),
        );
      },
      finishEditName: (name) async* {
        var user = await qiscus.updateUser$(name: name);
        yield ProfilePageState.ready(user);
      },
    );
  }
}
