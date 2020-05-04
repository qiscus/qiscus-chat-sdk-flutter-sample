// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'room_detail_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$RoomDetailBlocEventTearOff {
  const _$RoomDetailBlocEventTearOff();

  _EventInitialize initialize() {
    return const _EventInitialize();
  }

  _EventLoad load(int roomId) {
    return _EventLoad(
      roomId,
    );
  }
}

// ignore: unused_element
const $RoomDetailBlocEvent = _$RoomDetailBlocEventTearOff();

mixin _$RoomDetailBlocEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result initialize(),
    @required Result load(int roomId),
  });

  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result initialize(),
    Result load(int roomId),
    @required Result orElse(),
  });

  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result initialize(_EventInitialize value),
    @required Result load(_EventLoad value),
  });

  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result initialize(_EventInitialize value),
    Result load(_EventLoad value),
    @required Result orElse(),
  });
}

abstract class $RoomDetailBlocEventCopyWith<$Res> {
  factory $RoomDetailBlocEventCopyWith(
          RoomDetailBlocEvent value, $Res Function(RoomDetailBlocEvent) then) =
      _$RoomDetailBlocEventCopyWithImpl<$Res>;
}

class _$RoomDetailBlocEventCopyWithImpl<$Res>
    implements $RoomDetailBlocEventCopyWith<$Res> {
  _$RoomDetailBlocEventCopyWithImpl(this._value, this._then);

  final RoomDetailBlocEvent _value;

  // ignore: unused_field
  final $Res Function(RoomDetailBlocEvent) _then;
}

abstract class _$EventInitializeCopyWith<$Res> {
  factory _$EventInitializeCopyWith(
          _EventInitialize value, $Res Function(_EventInitialize) then) =
      __$EventInitializeCopyWithImpl<$Res>;
}

class __$EventInitializeCopyWithImpl<$Res>
    extends _$RoomDetailBlocEventCopyWithImpl<$Res>
    implements _$EventInitializeCopyWith<$Res> {
  __$EventInitializeCopyWithImpl(
      _EventInitialize _value, $Res Function(_EventInitialize) _then)
      : super(_value, (v) => _then(v as _EventInitialize));

  @override
  _EventInitialize get _value => super._value as _EventInitialize;
}

class _$_EventInitialize implements _EventInitialize {
  const _$_EventInitialize();

  @override
  String toString() {
    return 'RoomDetailBlocEvent.initialize()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _EventInitialize);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result initialize(),
    @required Result load(int roomId),
  }) {
    assert(initialize != null);
    assert(load != null);
    return initialize();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result initialize(),
    Result load(int roomId),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (initialize != null) {
      return initialize();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result initialize(_EventInitialize value),
    @required Result load(_EventLoad value),
  }) {
    assert(initialize != null);
    assert(load != null);
    return initialize(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result initialize(_EventInitialize value),
    Result load(_EventLoad value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (initialize != null) {
      return initialize(this);
    }
    return orElse();
  }
}

abstract class _EventInitialize implements RoomDetailBlocEvent {
  const factory _EventInitialize() = _$_EventInitialize;
}

abstract class _$EventLoadCopyWith<$Res> {
  factory _$EventLoadCopyWith(
          _EventLoad value, $Res Function(_EventLoad) then) =
      __$EventLoadCopyWithImpl<$Res>;

  $Res call({int roomId});
}

class __$EventLoadCopyWithImpl<$Res>
    extends _$RoomDetailBlocEventCopyWithImpl<$Res>
    implements _$EventLoadCopyWith<$Res> {
  __$EventLoadCopyWithImpl(_EventLoad _value, $Res Function(_EventLoad) _then)
      : super(_value, (v) => _then(v as _EventLoad));

  @override
  _EventLoad get _value => super._value as _EventLoad;

  @override
  $Res call({
    Object roomId = freezed,
  }) {
    return _then(_EventLoad(
      roomId == freezed ? _value.roomId : roomId as int,
    ));
  }
}

class _$_EventLoad implements _EventLoad {
  const _$_EventLoad(this.roomId) : assert(roomId != null);

  @override
  final int roomId;

  @override
  String toString() {
    return 'RoomDetailBlocEvent.load(roomId: $roomId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _EventLoad &&
            (identical(other.roomId, roomId) ||
                const DeepCollectionEquality().equals(other.roomId, roomId)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(roomId);

  @override
  _$EventLoadCopyWith<_EventLoad> get copyWith =>
      __$EventLoadCopyWithImpl<_EventLoad>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result initialize(),
    @required Result load(int roomId),
  }) {
    assert(initialize != null);
    assert(load != null);
    return load(roomId);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result initialize(),
    Result load(int roomId),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (load != null) {
      return load(roomId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result initialize(_EventInitialize value),
    @required Result load(_EventLoad value),
  }) {
    assert(initialize != null);
    assert(load != null);
    return load(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result initialize(_EventInitialize value),
    Result load(_EventLoad value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (load != null) {
      return load(this);
    }
    return orElse();
  }
}

abstract class _EventLoad implements RoomDetailBlocEvent {
  const factory _EventLoad(int roomId) = _$_EventLoad;

  int get roomId;

  _$EventLoadCopyWith<_EventLoad> get copyWith;
}

class _$RoomDetailBlocStateTearOff {
  const _$RoomDetailBlocStateTearOff();

  _StateLoading loading() {
    return const _StateLoading();
  }

  _StateReady ready(QChatRoom room) {
    return _StateReady(
      room,
    );
  }
}

// ignore: unused_element
const $RoomDetailBlocState = _$RoomDetailBlocStateTearOff();

mixin _$RoomDetailBlocState {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result loading(),
    @required Result ready(QChatRoom room),
  });

  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result loading(),
    Result ready(QChatRoom room),
    @required Result orElse(),
  });

  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result loading(_StateLoading value),
    @required Result ready(_StateReady value),
  });

  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result loading(_StateLoading value),
    Result ready(_StateReady value),
    @required Result orElse(),
  });
}

abstract class $RoomDetailBlocStateCopyWith<$Res> {
  factory $RoomDetailBlocStateCopyWith(
          RoomDetailBlocState value, $Res Function(RoomDetailBlocState) then) =
      _$RoomDetailBlocStateCopyWithImpl<$Res>;
}

class _$RoomDetailBlocStateCopyWithImpl<$Res>
    implements $RoomDetailBlocStateCopyWith<$Res> {
  _$RoomDetailBlocStateCopyWithImpl(this._value, this._then);

  final RoomDetailBlocState _value;

  // ignore: unused_field
  final $Res Function(RoomDetailBlocState) _then;
}

abstract class _$StateLoadingCopyWith<$Res> {
  factory _$StateLoadingCopyWith(
          _StateLoading value, $Res Function(_StateLoading) then) =
      __$StateLoadingCopyWithImpl<$Res>;
}

class __$StateLoadingCopyWithImpl<$Res>
    extends _$RoomDetailBlocStateCopyWithImpl<$Res>
    implements _$StateLoadingCopyWith<$Res> {
  __$StateLoadingCopyWithImpl(
      _StateLoading _value, $Res Function(_StateLoading) _then)
      : super(_value, (v) => _then(v as _StateLoading));

  @override
  _StateLoading get _value => super._value as _StateLoading;
}

class _$_StateLoading implements _StateLoading {
  const _$_StateLoading();

  @override
  String toString() {
    return 'RoomDetailBlocState.loading()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _StateLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result loading(),
    @required Result ready(QChatRoom room),
  }) {
    assert(loading != null);
    assert(ready != null);
    return loading();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result loading(),
    Result ready(QChatRoom room),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result loading(_StateLoading value),
    @required Result ready(_StateReady value),
  }) {
    assert(loading != null);
    assert(ready != null);
    return loading(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result loading(_StateLoading value),
    Result ready(_StateReady value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _StateLoading implements RoomDetailBlocState {
  const factory _StateLoading() = _$_StateLoading;
}

abstract class _$StateReadyCopyWith<$Res> {
  factory _$StateReadyCopyWith(
          _StateReady value, $Res Function(_StateReady) then) =
      __$StateReadyCopyWithImpl<$Res>;

  $Res call({QChatRoom room});
}

class __$StateReadyCopyWithImpl<$Res>
    extends _$RoomDetailBlocStateCopyWithImpl<$Res>
    implements _$StateReadyCopyWith<$Res> {
  __$StateReadyCopyWithImpl(
      _StateReady _value, $Res Function(_StateReady) _then)
      : super(_value, (v) => _then(v as _StateReady));

  @override
  _StateReady get _value => super._value as _StateReady;

  @override
  $Res call({
    Object room = freezed,
  }) {
    return _then(_StateReady(
      room == freezed ? _value.room : room as QChatRoom,
    ));
  }
}

class _$_StateReady implements _StateReady {
  const _$_StateReady(this.room) : assert(room != null);

  @override
  final QChatRoom room;

  @override
  String toString() {
    return 'RoomDetailBlocState.ready(room: $room)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _StateReady &&
            (identical(other.room, room) ||
                const DeepCollectionEquality().equals(other.room, room)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(room);

  @override
  _$StateReadyCopyWith<_StateReady> get copyWith =>
      __$StateReadyCopyWithImpl<_StateReady>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result loading(),
    @required Result ready(QChatRoom room),
  }) {
    assert(loading != null);
    assert(ready != null);
    return ready(room);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result loading(),
    Result ready(QChatRoom room),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (ready != null) {
      return ready(room);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result loading(_StateLoading value),
    @required Result ready(_StateReady value),
  }) {
    assert(loading != null);
    assert(ready != null);
    return ready(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result loading(_StateLoading value),
    Result ready(_StateReady value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (ready != null) {
      return ready(this);
    }
    return orElse();
  }
}

abstract class _StateReady implements RoomDetailBlocState {
  const factory _StateReady(QChatRoom room) = _$_StateReady;

  QChatRoom get room;

  _$StateReadyCopyWith<_StateReady> get copyWith;
}
