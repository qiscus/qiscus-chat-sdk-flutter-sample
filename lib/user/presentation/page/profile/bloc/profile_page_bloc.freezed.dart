// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'profile_page_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$ProfilePageEventTearOff {
  const _$ProfilePageEventTearOff();

  _EventInitialize initialize() {
    return const _EventInitialize();
  }

  _EventLoad load(String userId) {
    return _EventLoad(
      userId,
    );
  }

  _EventChangePicture changeProfilePicture(File file) {
    return _EventChangePicture(
      file,
    );
  }

  _EventStartEditName startEditName() {
    return const _EventStartEditName();
  }

  _EventEditName editName(String name) {
    return _EventEditName(
      name,
    );
  }

  _EventFinishEditName finishEditName(String name) {
    return _EventFinishEditName(
      name,
    );
  }
}

// ignore: unused_element
const $ProfilePageEvent = _$ProfilePageEventTearOff();

mixin _$ProfilePageEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result initialize(),
    @required Result load(String userId),
    @required Result changeProfilePicture(File file),
    @required Result startEditName(),
    @required Result editName(String name),
    @required Result finishEditName(String name),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result initialize(),
    Result load(String userId),
    Result changeProfilePicture(File file),
    Result startEditName(),
    Result editName(String name),
    Result finishEditName(String name),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result initialize(_EventInitialize value),
    @required Result load(_EventLoad value),
    @required Result changeProfilePicture(_EventChangePicture value),
    @required Result startEditName(_EventStartEditName value),
    @required Result editName(_EventEditName value),
    @required Result finishEditName(_EventFinishEditName value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result initialize(_EventInitialize value),
    Result load(_EventLoad value),
    Result changeProfilePicture(_EventChangePicture value),
    Result startEditName(_EventStartEditName value),
    Result editName(_EventEditName value),
    Result finishEditName(_EventFinishEditName value),
    @required Result orElse(),
  });
}

abstract class $ProfilePageEventCopyWith<$Res> {
  factory $ProfilePageEventCopyWith(
          ProfilePageEvent value, $Res Function(ProfilePageEvent) then) =
      _$ProfilePageEventCopyWithImpl<$Res>;
}

class _$ProfilePageEventCopyWithImpl<$Res>
    implements $ProfilePageEventCopyWith<$Res> {
  _$ProfilePageEventCopyWithImpl(this._value, this._then);

  final ProfilePageEvent _value;
  // ignore: unused_field
  final $Res Function(ProfilePageEvent) _then;
}

abstract class _$EventInitializeCopyWith<$Res> {
  factory _$EventInitializeCopyWith(
          _EventInitialize value, $Res Function(_EventInitialize) then) =
      __$EventInitializeCopyWithImpl<$Res>;
}

class __$EventInitializeCopyWithImpl<$Res>
    extends _$ProfilePageEventCopyWithImpl<$Res>
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
    return 'ProfilePageEvent.initialize()';
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
    @required Result load(String userId),
    @required Result changeProfilePicture(File file),
    @required Result startEditName(),
    @required Result editName(String name),
    @required Result finishEditName(String name),
  }) {
    assert(initialize != null);
    assert(load != null);
    assert(changeProfilePicture != null);
    assert(startEditName != null);
    assert(editName != null);
    assert(finishEditName != null);
    return initialize();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result initialize(),
    Result load(String userId),
    Result changeProfilePicture(File file),
    Result startEditName(),
    Result editName(String name),
    Result finishEditName(String name),
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
    @required Result changeProfilePicture(_EventChangePicture value),
    @required Result startEditName(_EventStartEditName value),
    @required Result editName(_EventEditName value),
    @required Result finishEditName(_EventFinishEditName value),
  }) {
    assert(initialize != null);
    assert(load != null);
    assert(changeProfilePicture != null);
    assert(startEditName != null);
    assert(editName != null);
    assert(finishEditName != null);
    return initialize(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result initialize(_EventInitialize value),
    Result load(_EventLoad value),
    Result changeProfilePicture(_EventChangePicture value),
    Result startEditName(_EventStartEditName value),
    Result editName(_EventEditName value),
    Result finishEditName(_EventFinishEditName value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (initialize != null) {
      return initialize(this);
    }
    return orElse();
  }
}

abstract class _EventInitialize implements ProfilePageEvent {
  const factory _EventInitialize() = _$_EventInitialize;
}

abstract class _$EventLoadCopyWith<$Res> {
  factory _$EventLoadCopyWith(
          _EventLoad value, $Res Function(_EventLoad) then) =
      __$EventLoadCopyWithImpl<$Res>;
  $Res call({String userId});
}

class __$EventLoadCopyWithImpl<$Res>
    extends _$ProfilePageEventCopyWithImpl<$Res>
    implements _$EventLoadCopyWith<$Res> {
  __$EventLoadCopyWithImpl(_EventLoad _value, $Res Function(_EventLoad) _then)
      : super(_value, (v) => _then(v as _EventLoad));

  @override
  _EventLoad get _value => super._value as _EventLoad;

  @override
  $Res call({
    Object userId = freezed,
  }) {
    return _then(_EventLoad(
      userId == freezed ? _value.userId : userId as String,
    ));
  }
}

class _$_EventLoad implements _EventLoad {
  const _$_EventLoad(this.userId) : assert(userId != null);

  @override
  final String userId;

  @override
  String toString() {
    return 'ProfilePageEvent.load(userId: $userId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _EventLoad &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(userId);

  @override
  _$EventLoadCopyWith<_EventLoad> get copyWith =>
      __$EventLoadCopyWithImpl<_EventLoad>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result initialize(),
    @required Result load(String userId),
    @required Result changeProfilePicture(File file),
    @required Result startEditName(),
    @required Result editName(String name),
    @required Result finishEditName(String name),
  }) {
    assert(initialize != null);
    assert(load != null);
    assert(changeProfilePicture != null);
    assert(startEditName != null);
    assert(editName != null);
    assert(finishEditName != null);
    return load(userId);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result initialize(),
    Result load(String userId),
    Result changeProfilePicture(File file),
    Result startEditName(),
    Result editName(String name),
    Result finishEditName(String name),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (load != null) {
      return load(userId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result initialize(_EventInitialize value),
    @required Result load(_EventLoad value),
    @required Result changeProfilePicture(_EventChangePicture value),
    @required Result startEditName(_EventStartEditName value),
    @required Result editName(_EventEditName value),
    @required Result finishEditName(_EventFinishEditName value),
  }) {
    assert(initialize != null);
    assert(load != null);
    assert(changeProfilePicture != null);
    assert(startEditName != null);
    assert(editName != null);
    assert(finishEditName != null);
    return load(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result initialize(_EventInitialize value),
    Result load(_EventLoad value),
    Result changeProfilePicture(_EventChangePicture value),
    Result startEditName(_EventStartEditName value),
    Result editName(_EventEditName value),
    Result finishEditName(_EventFinishEditName value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (load != null) {
      return load(this);
    }
    return orElse();
  }
}

abstract class _EventLoad implements ProfilePageEvent {
  const factory _EventLoad(String userId) = _$_EventLoad;

  String get userId;
  _$EventLoadCopyWith<_EventLoad> get copyWith;
}

abstract class _$EventChangePictureCopyWith<$Res> {
  factory _$EventChangePictureCopyWith(
          _EventChangePicture value, $Res Function(_EventChangePicture) then) =
      __$EventChangePictureCopyWithImpl<$Res>;
  $Res call({File file});
}

class __$EventChangePictureCopyWithImpl<$Res>
    extends _$ProfilePageEventCopyWithImpl<$Res>
    implements _$EventChangePictureCopyWith<$Res> {
  __$EventChangePictureCopyWithImpl(
      _EventChangePicture _value, $Res Function(_EventChangePicture) _then)
      : super(_value, (v) => _then(v as _EventChangePicture));

  @override
  _EventChangePicture get _value => super._value as _EventChangePicture;

  @override
  $Res call({
    Object file = freezed,
  }) {
    return _then(_EventChangePicture(
      file == freezed ? _value.file : file as File,
    ));
  }
}

class _$_EventChangePicture implements _EventChangePicture {
  const _$_EventChangePicture(this.file) : assert(file != null);

  @override
  final File file;

  @override
  String toString() {
    return 'ProfilePageEvent.changeProfilePicture(file: $file)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _EventChangePicture &&
            (identical(other.file, file) ||
                const DeepCollectionEquality().equals(other.file, file)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(file);

  @override
  _$EventChangePictureCopyWith<_EventChangePicture> get copyWith =>
      __$EventChangePictureCopyWithImpl<_EventChangePicture>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result initialize(),
    @required Result load(String userId),
    @required Result changeProfilePicture(File file),
    @required Result startEditName(),
    @required Result editName(String name),
    @required Result finishEditName(String name),
  }) {
    assert(initialize != null);
    assert(load != null);
    assert(changeProfilePicture != null);
    assert(startEditName != null);
    assert(editName != null);
    assert(finishEditName != null);
    return changeProfilePicture(file);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result initialize(),
    Result load(String userId),
    Result changeProfilePicture(File file),
    Result startEditName(),
    Result editName(String name),
    Result finishEditName(String name),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeProfilePicture != null) {
      return changeProfilePicture(file);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result initialize(_EventInitialize value),
    @required Result load(_EventLoad value),
    @required Result changeProfilePicture(_EventChangePicture value),
    @required Result startEditName(_EventStartEditName value),
    @required Result editName(_EventEditName value),
    @required Result finishEditName(_EventFinishEditName value),
  }) {
    assert(initialize != null);
    assert(load != null);
    assert(changeProfilePicture != null);
    assert(startEditName != null);
    assert(editName != null);
    assert(finishEditName != null);
    return changeProfilePicture(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result initialize(_EventInitialize value),
    Result load(_EventLoad value),
    Result changeProfilePicture(_EventChangePicture value),
    Result startEditName(_EventStartEditName value),
    Result editName(_EventEditName value),
    Result finishEditName(_EventFinishEditName value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeProfilePicture != null) {
      return changeProfilePicture(this);
    }
    return orElse();
  }
}

abstract class _EventChangePicture implements ProfilePageEvent {
  const factory _EventChangePicture(File file) = _$_EventChangePicture;

  File get file;
  _$EventChangePictureCopyWith<_EventChangePicture> get copyWith;
}

abstract class _$EventStartEditNameCopyWith<$Res> {
  factory _$EventStartEditNameCopyWith(
          _EventStartEditName value, $Res Function(_EventStartEditName) then) =
      __$EventStartEditNameCopyWithImpl<$Res>;
}

class __$EventStartEditNameCopyWithImpl<$Res>
    extends _$ProfilePageEventCopyWithImpl<$Res>
    implements _$EventStartEditNameCopyWith<$Res> {
  __$EventStartEditNameCopyWithImpl(
      _EventStartEditName _value, $Res Function(_EventStartEditName) _then)
      : super(_value, (v) => _then(v as _EventStartEditName));

  @override
  _EventStartEditName get _value => super._value as _EventStartEditName;
}

class _$_EventStartEditName implements _EventStartEditName {
  const _$_EventStartEditName();

  @override
  String toString() {
    return 'ProfilePageEvent.startEditName()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _EventStartEditName);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result initialize(),
    @required Result load(String userId),
    @required Result changeProfilePicture(File file),
    @required Result startEditName(),
    @required Result editName(String name),
    @required Result finishEditName(String name),
  }) {
    assert(initialize != null);
    assert(load != null);
    assert(changeProfilePicture != null);
    assert(startEditName != null);
    assert(editName != null);
    assert(finishEditName != null);
    return startEditName();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result initialize(),
    Result load(String userId),
    Result changeProfilePicture(File file),
    Result startEditName(),
    Result editName(String name),
    Result finishEditName(String name),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (startEditName != null) {
      return startEditName();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result initialize(_EventInitialize value),
    @required Result load(_EventLoad value),
    @required Result changeProfilePicture(_EventChangePicture value),
    @required Result startEditName(_EventStartEditName value),
    @required Result editName(_EventEditName value),
    @required Result finishEditName(_EventFinishEditName value),
  }) {
    assert(initialize != null);
    assert(load != null);
    assert(changeProfilePicture != null);
    assert(startEditName != null);
    assert(editName != null);
    assert(finishEditName != null);
    return startEditName(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result initialize(_EventInitialize value),
    Result load(_EventLoad value),
    Result changeProfilePicture(_EventChangePicture value),
    Result startEditName(_EventStartEditName value),
    Result editName(_EventEditName value),
    Result finishEditName(_EventFinishEditName value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (startEditName != null) {
      return startEditName(this);
    }
    return orElse();
  }
}

abstract class _EventStartEditName implements ProfilePageEvent {
  const factory _EventStartEditName() = _$_EventStartEditName;
}

abstract class _$EventEditNameCopyWith<$Res> {
  factory _$EventEditNameCopyWith(
          _EventEditName value, $Res Function(_EventEditName) then) =
      __$EventEditNameCopyWithImpl<$Res>;
  $Res call({String name});
}

class __$EventEditNameCopyWithImpl<$Res>
    extends _$ProfilePageEventCopyWithImpl<$Res>
    implements _$EventEditNameCopyWith<$Res> {
  __$EventEditNameCopyWithImpl(
      _EventEditName _value, $Res Function(_EventEditName) _then)
      : super(_value, (v) => _then(v as _EventEditName));

  @override
  _EventEditName get _value => super._value as _EventEditName;

  @override
  $Res call({
    Object name = freezed,
  }) {
    return _then(_EventEditName(
      name == freezed ? _value.name : name as String,
    ));
  }
}

class _$_EventEditName implements _EventEditName {
  const _$_EventEditName(this.name) : assert(name != null);

  @override
  final String name;

  @override
  String toString() {
    return 'ProfilePageEvent.editName(name: $name)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _EventEditName &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(name);

  @override
  _$EventEditNameCopyWith<_EventEditName> get copyWith =>
      __$EventEditNameCopyWithImpl<_EventEditName>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result initialize(),
    @required Result load(String userId),
    @required Result changeProfilePicture(File file),
    @required Result startEditName(),
    @required Result editName(String name),
    @required Result finishEditName(String name),
  }) {
    assert(initialize != null);
    assert(load != null);
    assert(changeProfilePicture != null);
    assert(startEditName != null);
    assert(editName != null);
    assert(finishEditName != null);
    return editName(name);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result initialize(),
    Result load(String userId),
    Result changeProfilePicture(File file),
    Result startEditName(),
    Result editName(String name),
    Result finishEditName(String name),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (editName != null) {
      return editName(name);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result initialize(_EventInitialize value),
    @required Result load(_EventLoad value),
    @required Result changeProfilePicture(_EventChangePicture value),
    @required Result startEditName(_EventStartEditName value),
    @required Result editName(_EventEditName value),
    @required Result finishEditName(_EventFinishEditName value),
  }) {
    assert(initialize != null);
    assert(load != null);
    assert(changeProfilePicture != null);
    assert(startEditName != null);
    assert(editName != null);
    assert(finishEditName != null);
    return editName(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result initialize(_EventInitialize value),
    Result load(_EventLoad value),
    Result changeProfilePicture(_EventChangePicture value),
    Result startEditName(_EventStartEditName value),
    Result editName(_EventEditName value),
    Result finishEditName(_EventFinishEditName value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (editName != null) {
      return editName(this);
    }
    return orElse();
  }
}

abstract class _EventEditName implements ProfilePageEvent {
  const factory _EventEditName(String name) = _$_EventEditName;

  String get name;
  _$EventEditNameCopyWith<_EventEditName> get copyWith;
}

abstract class _$EventFinishEditNameCopyWith<$Res> {
  factory _$EventFinishEditNameCopyWith(_EventFinishEditName value,
          $Res Function(_EventFinishEditName) then) =
      __$EventFinishEditNameCopyWithImpl<$Res>;
  $Res call({String name});
}

class __$EventFinishEditNameCopyWithImpl<$Res>
    extends _$ProfilePageEventCopyWithImpl<$Res>
    implements _$EventFinishEditNameCopyWith<$Res> {
  __$EventFinishEditNameCopyWithImpl(
      _EventFinishEditName _value, $Res Function(_EventFinishEditName) _then)
      : super(_value, (v) => _then(v as _EventFinishEditName));

  @override
  _EventFinishEditName get _value => super._value as _EventFinishEditName;

  @override
  $Res call({
    Object name = freezed,
  }) {
    return _then(_EventFinishEditName(
      name == freezed ? _value.name : name as String,
    ));
  }
}

class _$_EventFinishEditName implements _EventFinishEditName {
  const _$_EventFinishEditName(this.name) : assert(name != null);

  @override
  final String name;

  @override
  String toString() {
    return 'ProfilePageEvent.finishEditName(name: $name)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _EventFinishEditName &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(name);

  @override
  _$EventFinishEditNameCopyWith<_EventFinishEditName> get copyWith =>
      __$EventFinishEditNameCopyWithImpl<_EventFinishEditName>(
          this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result initialize(),
    @required Result load(String userId),
    @required Result changeProfilePicture(File file),
    @required Result startEditName(),
    @required Result editName(String name),
    @required Result finishEditName(String name),
  }) {
    assert(initialize != null);
    assert(load != null);
    assert(changeProfilePicture != null);
    assert(startEditName != null);
    assert(editName != null);
    assert(finishEditName != null);
    return finishEditName(name);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result initialize(),
    Result load(String userId),
    Result changeProfilePicture(File file),
    Result startEditName(),
    Result editName(String name),
    Result finishEditName(String name),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (finishEditName != null) {
      return finishEditName(name);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result initialize(_EventInitialize value),
    @required Result load(_EventLoad value),
    @required Result changeProfilePicture(_EventChangePicture value),
    @required Result startEditName(_EventStartEditName value),
    @required Result editName(_EventEditName value),
    @required Result finishEditName(_EventFinishEditName value),
  }) {
    assert(initialize != null);
    assert(load != null);
    assert(changeProfilePicture != null);
    assert(startEditName != null);
    assert(editName != null);
    assert(finishEditName != null);
    return finishEditName(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result initialize(_EventInitialize value),
    Result load(_EventLoad value),
    Result changeProfilePicture(_EventChangePicture value),
    Result startEditName(_EventStartEditName value),
    Result editName(_EventEditName value),
    Result finishEditName(_EventFinishEditName value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (finishEditName != null) {
      return finishEditName(this);
    }
    return orElse();
  }
}

abstract class _EventFinishEditName implements ProfilePageEvent {
  const factory _EventFinishEditName(String name) = _$_EventFinishEditName;

  String get name;
  _$EventFinishEditNameCopyWith<_EventFinishEditName> get copyWith;
}

class _$ProfilePageStateTearOff {
  const _$ProfilePageStateTearOff();

  _StateLoading loading() {
    return const _StateLoading();
  }

  _StateReady ready(QAccount user) {
    return _StateReady(
      user,
    );
  }

  _StateUploading uploading({@required QAccount user, double progress}) {
    return _StateUploading(
      user: user,
      progress: progress,
    );
  }

  _StateEditingName editingName(QAccount user, String name) {
    return _StateEditingName(
      user,
      name,
    );
  }
}

// ignore: unused_element
const $ProfilePageState = _$ProfilePageStateTearOff();

mixin _$ProfilePageState {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result loading(),
    @required Result ready(QAccount user),
    @required Result uploading(@required QAccount user, double progress),
    @required Result editingName(QAccount user, String name),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result loading(),
    Result ready(QAccount user),
    Result uploading(@required QAccount user, double progress),
    Result editingName(QAccount user, String name),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result loading(_StateLoading value),
    @required Result ready(_StateReady value),
    @required Result uploading(_StateUploading value),
    @required Result editingName(_StateEditingName value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result loading(_StateLoading value),
    Result ready(_StateReady value),
    Result uploading(_StateUploading value),
    Result editingName(_StateEditingName value),
    @required Result orElse(),
  });
}

abstract class $ProfilePageStateCopyWith<$Res> {
  factory $ProfilePageStateCopyWith(
          ProfilePageState value, $Res Function(ProfilePageState) then) =
      _$ProfilePageStateCopyWithImpl<$Res>;
}

class _$ProfilePageStateCopyWithImpl<$Res>
    implements $ProfilePageStateCopyWith<$Res> {
  _$ProfilePageStateCopyWithImpl(this._value, this._then);

  final ProfilePageState _value;
  // ignore: unused_field
  final $Res Function(ProfilePageState) _then;
}

abstract class _$StateLoadingCopyWith<$Res> {
  factory _$StateLoadingCopyWith(
          _StateLoading value, $Res Function(_StateLoading) then) =
      __$StateLoadingCopyWithImpl<$Res>;
}

class __$StateLoadingCopyWithImpl<$Res>
    extends _$ProfilePageStateCopyWithImpl<$Res>
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
    return 'ProfilePageState.loading()';
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
    @required Result ready(QAccount user),
    @required Result uploading(@required QAccount user, double progress),
    @required Result editingName(QAccount user, String name),
  }) {
    assert(loading != null);
    assert(ready != null);
    assert(uploading != null);
    assert(editingName != null);
    return loading();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result loading(),
    Result ready(QAccount user),
    Result uploading(@required QAccount user, double progress),
    Result editingName(QAccount user, String name),
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
    @required Result uploading(_StateUploading value),
    @required Result editingName(_StateEditingName value),
  }) {
    assert(loading != null);
    assert(ready != null);
    assert(uploading != null);
    assert(editingName != null);
    return loading(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result loading(_StateLoading value),
    Result ready(_StateReady value),
    Result uploading(_StateUploading value),
    Result editingName(_StateEditingName value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _StateLoading implements ProfilePageState {
  const factory _StateLoading() = _$_StateLoading;
}

abstract class _$StateReadyCopyWith<$Res> {
  factory _$StateReadyCopyWith(
          _StateReady value, $Res Function(_StateReady) then) =
      __$StateReadyCopyWithImpl<$Res>;
  $Res call({QAccount user});
}

class __$StateReadyCopyWithImpl<$Res>
    extends _$ProfilePageStateCopyWithImpl<$Res>
    implements _$StateReadyCopyWith<$Res> {
  __$StateReadyCopyWithImpl(
      _StateReady _value, $Res Function(_StateReady) _then)
      : super(_value, (v) => _then(v as _StateReady));

  @override
  _StateReady get _value => super._value as _StateReady;

  @override
  $Res call({
    Object user = freezed,
  }) {
    return _then(_StateReady(
      user == freezed ? _value.user : user as QAccount,
    ));
  }
}

class _$_StateReady implements _StateReady {
  const _$_StateReady(this.user) : assert(user != null);

  @override
  final QAccount user;

  @override
  String toString() {
    return 'ProfilePageState.ready(user: $user)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _StateReady &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(user);

  @override
  _$StateReadyCopyWith<_StateReady> get copyWith =>
      __$StateReadyCopyWithImpl<_StateReady>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result loading(),
    @required Result ready(QAccount user),
    @required Result uploading(@required QAccount user, double progress),
    @required Result editingName(QAccount user, String name),
  }) {
    assert(loading != null);
    assert(ready != null);
    assert(uploading != null);
    assert(editingName != null);
    return ready(user);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result loading(),
    Result ready(QAccount user),
    Result uploading(@required QAccount user, double progress),
    Result editingName(QAccount user, String name),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (ready != null) {
      return ready(user);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result loading(_StateLoading value),
    @required Result ready(_StateReady value),
    @required Result uploading(_StateUploading value),
    @required Result editingName(_StateEditingName value),
  }) {
    assert(loading != null);
    assert(ready != null);
    assert(uploading != null);
    assert(editingName != null);
    return ready(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result loading(_StateLoading value),
    Result ready(_StateReady value),
    Result uploading(_StateUploading value),
    Result editingName(_StateEditingName value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (ready != null) {
      return ready(this);
    }
    return orElse();
  }
}

abstract class _StateReady implements ProfilePageState {
  const factory _StateReady(QAccount user) = _$_StateReady;

  QAccount get user;
  _$StateReadyCopyWith<_StateReady> get copyWith;
}

abstract class _$StateUploadingCopyWith<$Res> {
  factory _$StateUploadingCopyWith(
          _StateUploading value, $Res Function(_StateUploading) then) =
      __$StateUploadingCopyWithImpl<$Res>;
  $Res call({QAccount user, double progress});
}

class __$StateUploadingCopyWithImpl<$Res>
    extends _$ProfilePageStateCopyWithImpl<$Res>
    implements _$StateUploadingCopyWith<$Res> {
  __$StateUploadingCopyWithImpl(
      _StateUploading _value, $Res Function(_StateUploading) _then)
      : super(_value, (v) => _then(v as _StateUploading));

  @override
  _StateUploading get _value => super._value as _StateUploading;

  @override
  $Res call({
    Object user = freezed,
    Object progress = freezed,
  }) {
    return _then(_StateUploading(
      user: user == freezed ? _value.user : user as QAccount,
      progress: progress == freezed ? _value.progress : progress as double,
    ));
  }
}

class _$_StateUploading implements _StateUploading {
  const _$_StateUploading({@required this.user, this.progress})
      : assert(user != null);

  @override
  final QAccount user;
  @override
  final double progress;

  @override
  String toString() {
    return 'ProfilePageState.uploading(user: $user, progress: $progress)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _StateUploading &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)) &&
            (identical(other.progress, progress) ||
                const DeepCollectionEquality()
                    .equals(other.progress, progress)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(user) ^
      const DeepCollectionEquality().hash(progress);

  @override
  _$StateUploadingCopyWith<_StateUploading> get copyWith =>
      __$StateUploadingCopyWithImpl<_StateUploading>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result loading(),
    @required Result ready(QAccount user),
    @required Result uploading(@required QAccount user, double progress),
    @required Result editingName(QAccount user, String name),
  }) {
    assert(loading != null);
    assert(ready != null);
    assert(uploading != null);
    assert(editingName != null);
    return uploading(user, progress);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result loading(),
    Result ready(QAccount user),
    Result uploading(@required QAccount user, double progress),
    Result editingName(QAccount user, String name),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (uploading != null) {
      return uploading(user, progress);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result loading(_StateLoading value),
    @required Result ready(_StateReady value),
    @required Result uploading(_StateUploading value),
    @required Result editingName(_StateEditingName value),
  }) {
    assert(loading != null);
    assert(ready != null);
    assert(uploading != null);
    assert(editingName != null);
    return uploading(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result loading(_StateLoading value),
    Result ready(_StateReady value),
    Result uploading(_StateUploading value),
    Result editingName(_StateEditingName value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (uploading != null) {
      return uploading(this);
    }
    return orElse();
  }
}

abstract class _StateUploading implements ProfilePageState {
  const factory _StateUploading({@required QAccount user, double progress}) =
      _$_StateUploading;

  QAccount get user;
  double get progress;
  _$StateUploadingCopyWith<_StateUploading> get copyWith;
}

abstract class _$StateEditingNameCopyWith<$Res> {
  factory _$StateEditingNameCopyWith(
          _StateEditingName value, $Res Function(_StateEditingName) then) =
      __$StateEditingNameCopyWithImpl<$Res>;
  $Res call({QAccount user, String name});
}

class __$StateEditingNameCopyWithImpl<$Res>
    extends _$ProfilePageStateCopyWithImpl<$Res>
    implements _$StateEditingNameCopyWith<$Res> {
  __$StateEditingNameCopyWithImpl(
      _StateEditingName _value, $Res Function(_StateEditingName) _then)
      : super(_value, (v) => _then(v as _StateEditingName));

  @override
  _StateEditingName get _value => super._value as _StateEditingName;

  @override
  $Res call({
    Object user = freezed,
    Object name = freezed,
  }) {
    return _then(_StateEditingName(
      user == freezed ? _value.user : user as QAccount,
      name == freezed ? _value.name : name as String,
    ));
  }
}

class _$_StateEditingName implements _StateEditingName {
  const _$_StateEditingName(this.user, this.name)
      : assert(user != null),
        assert(name != null);

  @override
  final QAccount user;
  @override
  final String name;

  @override
  String toString() {
    return 'ProfilePageState.editingName(user: $user, name: $name)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _StateEditingName &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(user) ^
      const DeepCollectionEquality().hash(name);

  @override
  _$StateEditingNameCopyWith<_StateEditingName> get copyWith =>
      __$StateEditingNameCopyWithImpl<_StateEditingName>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result loading(),
    @required Result ready(QAccount user),
    @required Result uploading(@required QAccount user, double progress),
    @required Result editingName(QAccount user, String name),
  }) {
    assert(loading != null);
    assert(ready != null);
    assert(uploading != null);
    assert(editingName != null);
    return editingName(user, name);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result loading(),
    Result ready(QAccount user),
    Result uploading(@required QAccount user, double progress),
    Result editingName(QAccount user, String name),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (editingName != null) {
      return editingName(user, name);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result loading(_StateLoading value),
    @required Result ready(_StateReady value),
    @required Result uploading(_StateUploading value),
    @required Result editingName(_StateEditingName value),
  }) {
    assert(loading != null);
    assert(ready != null);
    assert(uploading != null);
    assert(editingName != null);
    return editingName(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result loading(_StateLoading value),
    Result ready(_StateReady value),
    Result uploading(_StateUploading value),
    Result editingName(_StateEditingName value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (editingName != null) {
      return editingName(this);
    }
    return orElse();
  }
}

abstract class _StateEditingName implements ProfilePageState {
  const factory _StateEditingName(QAccount user, String name) =
      _$_StateEditingName;

  QAccount get user;
  String get name;
  _$StateEditingNameCopyWith<_StateEditingName> get copyWith;
}
