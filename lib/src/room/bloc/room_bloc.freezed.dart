// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'room_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$RoomBlocEventTearOff {
  const _$RoomBlocEventTearOff();

  _$GetRoomInfoEvent getRoomInfo(int roomId) {
    return _$GetRoomInfoEvent(
      roomId,
    );
  }

  _$GetRoomList getRoomList() {
    return const _$GetRoomList();
  }
}

// ignore: unused_element
const $RoomBlocEvent = _$RoomBlocEventTearOff();

mixin _$RoomBlocEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result getRoomInfo(int roomId),
    @required Result getRoomList(),
  });

  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result getRoomInfo(int roomId),
    Result getRoomList(),
    @required Result orElse(),
  });

  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result getRoomInfo(_$GetRoomInfoEvent value),
    @required Result getRoomList(_$GetRoomList value),
  });

  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result getRoomInfo(_$GetRoomInfoEvent value),
    Result getRoomList(_$GetRoomList value),
    @required Result orElse(),
  });
}

abstract class $RoomBlocEventCopyWith<$Res> {
  factory $RoomBlocEventCopyWith(
          RoomBlocEvent value, $Res Function(RoomBlocEvent) then) =
      _$RoomBlocEventCopyWithImpl<$Res>;
}

class _$RoomBlocEventCopyWithImpl<$Res>
    implements $RoomBlocEventCopyWith<$Res> {
  _$RoomBlocEventCopyWithImpl(this._value, this._then);

  final RoomBlocEvent _value;

  // ignore: unused_field
  final $Res Function(RoomBlocEvent) _then;
}

abstract class _$$GetRoomInfoEventCopyWith<$Res> {
  factory _$$GetRoomInfoEventCopyWith(
          _$GetRoomInfoEvent value, $Res Function(_$GetRoomInfoEvent) then) =
      __$$GetRoomInfoEventCopyWithImpl<$Res>;

  $Res call({int roomId});
}

class __$$GetRoomInfoEventCopyWithImpl<$Res>
    extends _$RoomBlocEventCopyWithImpl<$Res>
    implements _$$GetRoomInfoEventCopyWith<$Res> {
  __$$GetRoomInfoEventCopyWithImpl(
      _$GetRoomInfoEvent _value, $Res Function(_$GetRoomInfoEvent) _then)
      : super(_value, (v) => _then(v as _$GetRoomInfoEvent));

  @override
  _$GetRoomInfoEvent get _value => super._value as _$GetRoomInfoEvent;

  @override
  $Res call({
    Object roomId = freezed,
  }) {
    return _then(_$GetRoomInfoEvent(
      roomId == freezed ? _value.roomId : roomId as int,
    ));
  }
}

class _$_$GetRoomInfoEvent implements _$GetRoomInfoEvent {
  const _$_$GetRoomInfoEvent(this.roomId) : assert(roomId != null);

  @override
  final int roomId;

  @override
  String toString() {
    return 'RoomBlocEvent.getRoomInfo(roomId: $roomId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _$GetRoomInfoEvent &&
            (identical(other.roomId, roomId) ||
                const DeepCollectionEquality().equals(other.roomId, roomId)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(roomId);

  @override
  _$$GetRoomInfoEventCopyWith<_$GetRoomInfoEvent> get copyWith =>
      __$$GetRoomInfoEventCopyWithImpl<_$GetRoomInfoEvent>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result getRoomInfo(int roomId),
    @required Result getRoomList(),
  }) {
    assert(getRoomInfo != null);
    assert(getRoomList != null);
    return getRoomInfo(roomId);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result getRoomInfo(int roomId),
    Result getRoomList(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (getRoomInfo != null) {
      return getRoomInfo(roomId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result getRoomInfo(_$GetRoomInfoEvent value),
    @required Result getRoomList(_$GetRoomList value),
  }) {
    assert(getRoomInfo != null);
    assert(getRoomList != null);
    return getRoomInfo(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result getRoomInfo(_$GetRoomInfoEvent value),
    Result getRoomList(_$GetRoomList value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (getRoomInfo != null) {
      return getRoomInfo(this);
    }
    return orElse();
  }
}

abstract class _$GetRoomInfoEvent implements RoomBlocEvent {
  const factory _$GetRoomInfoEvent(int roomId) = _$_$GetRoomInfoEvent;

  int get roomId;

  _$$GetRoomInfoEventCopyWith<_$GetRoomInfoEvent> get copyWith;
}

abstract class _$$GetRoomListCopyWith<$Res> {
  factory _$$GetRoomListCopyWith(
          _$GetRoomList value, $Res Function(_$GetRoomList) then) =
      __$$GetRoomListCopyWithImpl<$Res>;
}

class __$$GetRoomListCopyWithImpl<$Res>
    extends _$RoomBlocEventCopyWithImpl<$Res>
    implements _$$GetRoomListCopyWith<$Res> {
  __$$GetRoomListCopyWithImpl(
      _$GetRoomList _value, $Res Function(_$GetRoomList) _then)
      : super(_value, (v) => _then(v as _$GetRoomList));

  @override
  _$GetRoomList get _value => super._value as _$GetRoomList;
}

class _$_$GetRoomList implements _$GetRoomList {
  const _$_$GetRoomList();

  @override
  String toString() {
    return 'RoomBlocEvent.getRoomList()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _$GetRoomList);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result getRoomInfo(int roomId),
    @required Result getRoomList(),
  }) {
    assert(getRoomInfo != null);
    assert(getRoomList != null);
    return getRoomList();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result getRoomInfo(int roomId),
    Result getRoomList(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (getRoomList != null) {
      return getRoomList();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result getRoomInfo(_$GetRoomInfoEvent value),
    @required Result getRoomList(_$GetRoomList value),
  }) {
    assert(getRoomInfo != null);
    assert(getRoomList != null);
    return getRoomList(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result getRoomInfo(_$GetRoomInfoEvent value),
    Result getRoomList(_$GetRoomList value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (getRoomList != null) {
      return getRoomList(this);
    }
    return orElse();
  }
}

abstract class _$GetRoomList implements RoomBlocEvent {
  const factory _$GetRoomList() = _$_$GetRoomList;
}

class _$RoomBlocStateTearOff {
  const _$RoomBlocStateTearOff();

  _RoomBlocState call({Iterable<QChatRoom> rooms}) {
    return _RoomBlocState(
      rooms: rooms,
    );
  }
}

// ignore: unused_element
const $RoomBlocState = _$RoomBlocStateTearOff();

mixin _$RoomBlocState {
  Iterable<QChatRoom> get rooms;

  $RoomBlocStateCopyWith<RoomBlocState> get copyWith;
}

abstract class $RoomBlocStateCopyWith<$Res> {
  factory $RoomBlocStateCopyWith(
          RoomBlocState value, $Res Function(RoomBlocState) then) =
      _$RoomBlocStateCopyWithImpl<$Res>;

  $Res call({Iterable<QChatRoom> rooms});
}

class _$RoomBlocStateCopyWithImpl<$Res>
    implements $RoomBlocStateCopyWith<$Res> {
  _$RoomBlocStateCopyWithImpl(this._value, this._then);

  final RoomBlocState _value;

  // ignore: unused_field
  final $Res Function(RoomBlocState) _then;

  @override
  $Res call({
    Object rooms = freezed,
  }) {
    return _then(_value.copyWith(
      rooms: rooms == freezed ? _value.rooms : rooms as Iterable<QChatRoom>,
    ));
  }
}

abstract class _$RoomBlocStateCopyWith<$Res>
    implements $RoomBlocStateCopyWith<$Res> {
  factory _$RoomBlocStateCopyWith(
          _RoomBlocState value, $Res Function(_RoomBlocState) then) =
      __$RoomBlocStateCopyWithImpl<$Res>;

  @override
  $Res call({Iterable<QChatRoom> rooms});
}

class __$RoomBlocStateCopyWithImpl<$Res>
    extends _$RoomBlocStateCopyWithImpl<$Res>
    implements _$RoomBlocStateCopyWith<$Res> {
  __$RoomBlocStateCopyWithImpl(
      _RoomBlocState _value, $Res Function(_RoomBlocState) _then)
      : super(_value, (v) => _then(v as _RoomBlocState));

  @override
  _RoomBlocState get _value => super._value as _RoomBlocState;

  @override
  $Res call({
    Object rooms = freezed,
  }) {
    return _then(_RoomBlocState(
      rooms: rooms == freezed ? _value.rooms : rooms as Iterable<QChatRoom>,
    ));
  }
}

class _$_RoomBlocState implements _RoomBlocState {
  const _$_RoomBlocState({this.rooms});

  @override
  final Iterable<QChatRoom> rooms;

  @override
  String toString() {
    return 'RoomBlocState(rooms: $rooms)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _RoomBlocState &&
            (identical(other.rooms, rooms) ||
                const DeepCollectionEquality().equals(other.rooms, rooms)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(rooms);

  @override
  _$RoomBlocStateCopyWith<_RoomBlocState> get copyWith =>
      __$RoomBlocStateCopyWithImpl<_RoomBlocState>(this, _$identity);
}

abstract class _RoomBlocState implements RoomBlocState {
  const factory _RoomBlocState({Iterable<QChatRoom> rooms}) = _$_RoomBlocState;

  @override
  Iterable<QChatRoom> get rooms;

  @override
  _$RoomBlocStateCopyWith<_RoomBlocState> get copyWith;
}
