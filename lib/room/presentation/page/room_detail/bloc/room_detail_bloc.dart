import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

part 'room_detail_bloc.freezed.dart';

@freezed
abstract class RoomDetailBlocEvent with _$RoomDetailBlocEvent {
  const factory RoomDetailBlocEvent.initialize() = _EventInitialize;

  const factory RoomDetailBlocEvent.load(int roomId) = _EventLoad;

  const factory RoomDetailBlocEvent.removePaticipant({
    @required int roomId,
    @required String userId,
  }) = _EvenRemoveParticipant;
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
    yield* event.when(
      initialize: () async* {
        yield state;
      },
      load: (roomId) async* {
        try {
          final room = await qiscus.getChatRooms$(
            roomIds: [roomId],
            showParticipants: true,
          );
          yield RoomDetailBlocState.ready(room.first);
        } catch (error) {
          print(error);
        }
      },
      removePaticipant: (roomId, userId) async* {
        yield* state.when(
          loading: () async* {
            yield state;
          },
          ready: (room) async* {
            yield RoomDetailBlocState.loading();
            print('removing particpant: $userId');
            var participants = await qiscus.removeParticipants$(
              roomId: roomId,
              userIds: [userId],
            );
            print('done removing participant: $participants');
            room.participants = room.participants.where((p) {
              return !participants.any((id) => p.id == id);
            }).toList();
            room.totalParticipants = room.participants.length;
            yield RoomDetailBlocState.ready(room);
          },
        );
      },
    );
  }
}
