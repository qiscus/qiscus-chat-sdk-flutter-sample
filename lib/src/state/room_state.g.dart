// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_state.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$RoomState on RoomStateBase, Store {
  Computed<int> _$currentRoomIdComputed;

  @override
  int get currentRoomId =>
      (_$currentRoomIdComputed ??= Computed<int>(() => super.currentRoomId))
          .value;

  final _$currentRoomAtom = Atom(name: 'RoomStateBase.currentRoom');

  @override
  QChatRoom get currentRoom {
    _$currentRoomAtom.context.enforceReadPolicy(_$currentRoomAtom);
    _$currentRoomAtom.reportObserved();
    return super.currentRoom;
  }

  @override
  set currentRoom(QChatRoom value) {
    _$currentRoomAtom.context.conditionallyRunInAction(() {
      super.currentRoom = value;
      _$currentRoomAtom.reportChanged();
    }, _$currentRoomAtom, name: '${_$currentRoomAtom.name}_set');
  }

  final _$roomsAtom = Atom(name: 'RoomStateBase.rooms');

  @override
  List<QChatRoom> get rooms {
    _$roomsAtom.context.enforceReadPolicy(_$roomsAtom);
    _$roomsAtom.reportObserved();
    return super.rooms;
  }

  @override
  set rooms(List<QChatRoom> value) {
    _$roomsAtom.context.conditionallyRunInAction(() {
      super.rooms = value;
      _$roomsAtom.reportChanged();
    }, _$roomsAtom, name: '${_$roomsAtom.name}_set');
  }

  @override
  String toString() {
    final string =
        'currentRoom: ${currentRoom.toString()},rooms: ${rooms.toString()},currentRoomId: ${currentRoomId.toString()}';
    return '{$string}';
  }
}
