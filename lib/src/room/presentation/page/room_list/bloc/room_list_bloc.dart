import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

part 'room_list_bloc.freezed.dart';

@freezed
abstract class RoomListBlocEvent with _$RoomListBlocEvent {
  const factory RoomListBlocEvent.initialize() = _EventInitialize;

  const factory RoomListBlocEvent.load([int page, int limit]) = _EventLoad;
}

@freezed
abstract class RoomListBlocState with _$RoomListBlocState {
  const factory RoomListBlocState.ready(List<QChatRoom> rooms) =
      _RoomListBlocStateReady;

  const factory RoomListBlocState.loading(List<QChatRoom> rooms) =
      _RoomListBlocStateLoading;
}

class RoomListBloc extends Bloc<RoomListBlocEvent, RoomListBlocState> {
  static const LIMIT = 20;
  final QiscusSDK qiscus;

  RoomListBloc(this.qiscus);

  @override
  RoomListBlocState get initialState => RoomListBlocState.loading([]);

  @override
  Stream<RoomListBlocState> mapEventToState(event) async* {
    yield* event.when(
      initialize: () async* {
        yield RoomListBlocState.ready(<QChatRoom>[]);
      },
      load: ([int page = 1, int limit = LIMIT]) async* {
        yield RoomListBlocState.loading(<QChatRoom>[]);
        final controller = StreamController<List<QChatRoom>>();
        qiscus.getAllChatRooms(
          page: page,
          limit: limit,
          callback: (rooms, error) {
            if (error == null) {
              controller.addError(error);
            } else {
              controller.add(rooms);
            }
            controller.close();
          },
        );

        yield* controller.stream
            .asyncMap((rooms) => RoomListBlocState.ready(rooms));
      },
    );
  }
}
