import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

part 'room_detail_bloc.freezed.dart';

@freezed
abstract class RoomDetailBlocEvent with _$RoomDetailBlocEvent {
  const factory RoomDetailBlocEvent.initialize() = _EventInitialize;

  const factory RoomDetailBlocEvent.load(int roomId) = _EventLoad;
}

@freezed
abstract class RoomDetailBlocState with _$RoomDetailBlocState {
  const factory RoomDetailBlocState.loading() = _StateLoading;

  const factory RoomDetailBlocState.ready(QChatRoom room) = _StateReady;
}

class RoomDetailBloc extends Bloc<RoomDetailBlocEvent, RoomDetailBlocState> {
  final QiscusSDK qiscus;

  RoomDetailBloc(this.qiscus);

  @override
  RoomDetailBlocState get initialState => RoomDetailBlocState.loading();

  @override
  Stream<RoomDetailBlocState> mapEventToState(event) async* {
    //
    yield* event.when(
      initialize: () async* {
        yield state;
      },
      load: (roomId) async* {
        final controller = StreamController<QChatRoom>();

        qiscus.getChatRooms(
          roomIds: [roomId],
          callback: (rooms, error) {
            if (error == null && rooms.first != null) {
              controller.sink.add(rooms.first);
            } else {
              controller.sink.addError(error);
            }
            controller.close();
          },
        );

        yield* controller.stream
            .asyncMap((room) => RoomDetailBlocState.ready(room));
      },
    );
  }
}
