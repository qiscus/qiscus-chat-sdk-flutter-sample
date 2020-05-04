import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

part 'room_bloc.freezed.dart';

@freezed
abstract class RoomBlocEvent with _$RoomBlocEvent {
  const factory RoomBlocEvent.getRoomInfo(int roomId) = _$GetRoomInfoEvent;

  const factory RoomBlocEvent.getRoomList() = _$GetRoomList;
}

@freezed
abstract class RoomBlocState with _$RoomBlocState {
  const factory RoomBlocState({
    Iterable<QChatRoom> rooms,
  }) = _RoomBlocState;
}

class RoomBloc extends Bloc<RoomBlocEvent, RoomBlocState> {
  @override
  RoomBlocState get initialState => RoomBlocState(rooms: []);

  @override
  Stream<RoomBlocState> mapEventToState(RoomBlocEvent event) async* {
    //
  }
}
