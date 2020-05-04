// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'room_list_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$RoomListBlocEventTearOff {
  const _$RoomListBlocEventTearOff();

  _EventInitialize initialize() {
    return const _EventInitialize();
  }

  _EventLoad load([int page, int limit]) {
    return _EventLoad(
      page,
      limit,
    );
  }
}

// ignore: unused_element
const $RoomListBlocEvent = _$RoomListBlocEventTearOff();

mixin _$RoomListBlocEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result initialize(),
    @required Result load(int page, int limit),
  });

  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result initialize(),
    Result load(int page, int limit),
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

abstract class $RoomListBlocEventCopyWith<$Res> {
  factory $RoomListBlocEventCopyWith(
          RoomListBlocEvent value, $Res Function(RoomListBlocEvent) then) =
      _$RoomListBlocEventCopyWithImpl<$Res>;
}

class _$RoomListBlocEventCopyWithImpl<$Res>
    implements $RoomListBlocEventCopyWith<$Res> {
  _$RoomListBlocEventCopyWithImpl(this._value, this._then);

  final RoomListBlocEvent _value;

  // ignore: unused_field
  final $Res Function(RoomListBlocEvent) _then;
}

abstract class _$EventInitializeCopyWith<$Res> {
  factory _$EventInitializeCopyWith(
          _EventInitialize value, $Res Function(_EventInitialize) then) =
      __$EventInitializeCopyWithImpl<$Res>;
}

class __$EventInitializeCopyWithImpl<$Res>
    extends _$RoomListBlocEventCopyWithImpl<$Res>
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
    return 'RoomListBlocEvent.initialize()';
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
    @required Result load(int page, int limit),
  }) {
    assert(initialize != null);
    assert(load != null);
    return initialize();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result initialize(),
    Result load(int page, int limit),
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

abstract class _EventInitialize implements RoomListBlocEvent {
  const factory _EventInitialize() = _$_EventInitialize;
}

abstract class _$EventLoadCopyWith<$Res> {
  factory _$EventLoadCopyWith(
          _EventLoad value, $Res Function(_EventLoad) then) =
      __$EventLoadCopyWithImpl<$Res>;

  $Res call({int page, int limit});
}

class __$EventLoadCopyWithImpl<$Res>
    extends _$RoomListBlocEventCopyWithImpl<$Res>
    implements _$EventLoadCopyWith<$Res> {
  __$EventLoadCopyWithImpl(_EventLoad _value, $Res Function(_EventLoad) _then)
      : super(_value, (v) => _then(v as _EventLoad));

  @override
  _EventLoad get _value => super._value as _EventLoad;

  @override
  $Res call({
    Object page = freezed,
    Object limit = freezed,
  }) {
    return _then(_EventLoad(
      page == freezed ? _value.page : page as int,
      limit == freezed ? _value.limit : limit as int,
    ));
  }
}

class _$_EventLoad implements _EventLoad {
  const _$_EventLoad([this.page, this.limit]);

  @override
  final int page;
  @override
  final int limit;

  @override
  String toString() {
    return 'RoomListBlocEvent.load(page: $page, limit: $limit)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _EventLoad &&
            (identical(other.page, page) ||
                const DeepCollectionEquality().equals(other.page, page)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(page) ^
      const DeepCollectionEquality().hash(limit);

  @override
  _$EventLoadCopyWith<_EventLoad> get copyWith =>
      __$EventLoadCopyWithImpl<_EventLoad>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result initialize(),
    @required Result load(int page, int limit),
  }) {
    assert(initialize != null);
    assert(load != null);
    return load(page, limit);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result initialize(),
    Result load(int page, int limit),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (load != null) {
      return load(page, limit);
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

abstract class _EventLoad implements RoomListBlocEvent {
  const factory _EventLoad([int page, int limit]) = _$_EventLoad;

  int get page;

  int get limit;

  _$EventLoadCopyWith<_EventLoad> get copyWith;
}

class _$RoomListBlocStateTearOff {
  const _$RoomListBlocStateTearOff();

  _RoomListBlocStateReady ready(List<QChatRoom> rooms) {
    return _RoomListBlocStateReady(
      rooms,
    );
  }

  _RoomListBlocStateLoading loading(List<QChatRoom> rooms) {
    return _RoomListBlocStateLoading(
      rooms,
    );
  }
}

// ignore: unused_element
const $RoomListBlocState = _$RoomListBlocStateTearOff();

mixin _$RoomListBlocState {
  List<QChatRoom> get rooms;

  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result ready(List<QChatRoom> rooms),
    @required Result loading(List<QChatRoom> rooms),
  });

  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result ready(List<QChatRoom> rooms),
    Result loading(List<QChatRoom> rooms),
    @required Result orElse(),
  });

  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result ready(_RoomListBlocStateReady value),
    @required Result loading(_RoomListBlocStateLoading value),
  });

  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result ready(_RoomListBlocStateReady value),
    Result loading(_RoomListBlocStateLoading value),
    @required Result orElse(),
  });

  $RoomListBlocStateCopyWith<RoomListBlocState> get copyWith;
}

abstract class $RoomListBlocStateCopyWith<$Res> {
  factory $RoomListBlocStateCopyWith(
          RoomListBlocState value, $Res Function(RoomListBlocState) then) =
      _$RoomListBlocStateCopyWithImpl<$Res>;

  $Res call({List<QChatRoom> rooms});
}

class _$RoomListBlocStateCopyWithImpl<$Res>
    implements $RoomListBlocStateCopyWith<$Res> {
  _$RoomListBlocStateCopyWithImpl(this._value, this._then);

  final RoomListBlocState _value;

  // ignore: unused_field
  final $Res Function(RoomListBlocState) _then;

  @override
  $Res call({
    Object rooms = freezed,
  }) {
    return _then(_value.copyWith(
      rooms: rooms == freezed ? _value.rooms : rooms as List<QChatRoom>,
    ));
  }
}

abstract class _$RoomListBlocStateReadyCopyWith<$Res>
    implements $RoomListBlocStateCopyWith<$Res> {
  factory _$RoomListBlocStateReadyCopyWith(_RoomListBlocStateReady value,
          $Res Function(_RoomListBlocStateReady) then) =
      __$RoomListBlocStateReadyCopyWithImpl<$Res>;

  @override
  $Res call({List<QChatRoom> rooms});
}

class __$RoomListBlocStateReadyCopyWithImpl<$Res>
    extends _$RoomListBlocStateCopyWithImpl<$Res>
    implements _$RoomListBlocStateReadyCopyWith<$Res> {
  __$RoomListBlocStateReadyCopyWithImpl(_RoomListBlocStateReady _value,
      $Res Function(_RoomListBlocStateReady) _then)
      : super(_value, (v) => _then(v as _RoomListBlocStateReady));

  @override
  _RoomListBlocStateReady get _value => super._value as _RoomListBlocStateReady;

  @override
  $Res call({
    Object rooms = freezed,
  }) {
    return _then(_RoomListBlocStateReady(
      rooms == freezed ? _value.rooms : rooms as List<QChatRoom>,
    ));
  }
}

class _$_RoomListBlocStateReady implements _RoomListBlocStateReady {
  const _$_RoomListBlocStateReady(this.rooms) : assert(rooms != null);

  @override
  final List<QChatRoom> rooms;

  @override
  String toString() {
    return 'RoomListBlocState.ready(rooms: $rooms)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _RoomListBlocStateReady &&
            (identical(other.rooms, rooms) ||
                const DeepCollectionEquality().equals(other.rooms, rooms)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(rooms);

  @override
  _$RoomListBlocStateReadyCopyWith<_RoomListBlocStateReady> get copyWith =>
      __$RoomListBlocStateReadyCopyWithImpl<_RoomListBlocStateReady>(
          this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result ready(List<QChatRoom> rooms),
    @required Result loading(List<QChatRoom> rooms),
  }) {
    assert(ready != null);
    assert(loading != null);
    return ready(rooms);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result ready(List<QChatRoom> rooms),
    Result loading(List<QChatRoom> rooms),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (ready != null) {
      return ready(rooms);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result ready(_RoomListBlocStateReady value),
    @required Result loading(_RoomListBlocStateLoading value),
  }) {
    assert(ready != null);
    assert(loading != null);
    return ready(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result ready(_RoomListBlocStateReady value),
    Result loading(_RoomListBlocStateLoading value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (ready != null) {
      return ready(this);
    }
    return orElse();
  }
}

abstract class _RoomListBlocStateReady implements RoomListBlocState {
  const factory _RoomListBlocStateReady(List<QChatRoom> rooms) =
      _$_RoomListBlocStateReady;

  @override
  List<QChatRoom> get rooms;

  @override
  _$RoomListBlocStateReadyCopyWith<_RoomListBlocStateReady> get copyWith;
}

abstract class _$RoomListBlocStateLoadingCopyWith<$Res>
    implements $RoomListBlocStateCopyWith<$Res> {
  factory _$RoomListBlocStateLoadingCopyWith(_RoomListBlocStateLoading value,
          $Res Function(_RoomListBlocStateLoading) then) =
      __$RoomListBlocStateLoadingCopyWithImpl<$Res>;

  @override
  $Res call({List<QChatRoom> rooms});
}

class __$RoomListBlocStateLoadingCopyWithImpl<$Res>
    extends _$RoomListBlocStateCopyWithImpl<$Res>
    implements _$RoomListBlocStateLoadingCopyWith<$Res> {
  __$RoomListBlocStateLoadingCopyWithImpl(_RoomListBlocStateLoading _value,
      $Res Function(_RoomListBlocStateLoading) _then)
      : super(_value, (v) => _then(v as _RoomListBlocStateLoading));

  @override
  _RoomListBlocStateLoading get _value =>
      super._value as _RoomListBlocStateLoading;

  @override
  $Res call({
    Object rooms = freezed,
  }) {
    return _then(_RoomListBlocStateLoading(
      rooms == freezed ? _value.rooms : rooms as List<QChatRoom>,
    ));
  }
}

class _$_RoomListBlocStateLoading implements _RoomListBlocStateLoading {
  const _$_RoomListBlocStateLoading(this.rooms) : assert(rooms != null);

  @override
  final List<QChatRoom> rooms;

  @override
  String toString() {
    return 'RoomListBlocState.loading(rooms: $rooms)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _RoomListBlocStateLoading &&
            (identical(other.rooms, rooms) ||
                const DeepCollectionEquality().equals(other.rooms, rooms)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(rooms);

  @override
  _$RoomListBlocStateLoadingCopyWith<_RoomListBlocStateLoading> get copyWith =>
      __$RoomListBlocStateLoadingCopyWithImpl<_RoomListBlocStateLoading>(
          this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result ready(List<QChatRoom> rooms),
    @required Result loading(List<QChatRoom> rooms),
  }) {
    assert(ready != null);
    assert(loading != null);
    return loading(rooms);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result ready(List<QChatRoom> rooms),
    Result loading(List<QChatRoom> rooms),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (loading != null) {
      return loading(rooms);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result ready(_RoomListBlocStateReady value),
    @required Result loading(_RoomListBlocStateLoading value),
  }) {
    assert(ready != null);
    assert(loading != null);
    return loading(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result ready(_RoomListBlocStateReady value),
    Result loading(_RoomListBlocStateLoading value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _RoomListBlocStateLoading implements RoomListBlocState {
  const factory _RoomListBlocStateLoading(List<QChatRoom> rooms) =
      _$_RoomListBlocStateLoading;

  @override
  List<QChatRoom> get rooms;

  @override
  _$RoomListBlocStateLoadingCopyWith<_RoomListBlocStateLoading> get copyWith;
}
