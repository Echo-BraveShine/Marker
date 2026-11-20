// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resource_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ResourceUiState {

 bool get showResources; bool get busy; bool get dropHover; String get operation; int get done; int get total; int get revision;
/// Create a copy of ResourceUiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResourceUiStateCopyWith<ResourceUiState> get copyWith => _$ResourceUiStateCopyWithImpl<ResourceUiState>(this as ResourceUiState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResourceUiState&&(identical(other.showResources, showResources) || other.showResources == showResources)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.dropHover, dropHover) || other.dropHover == dropHover)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.done, done) || other.done == done)&&(identical(other.total, total) || other.total == total)&&(identical(other.revision, revision) || other.revision == revision));
}


@override
int get hashCode => Object.hash(runtimeType,showResources,busy,dropHover,operation,done,total,revision);

@override
String toString() {
  return 'ResourceUiState(showResources: $showResources, busy: $busy, dropHover: $dropHover, operation: $operation, done: $done, total: $total, revision: $revision)';
}


}

/// @nodoc
abstract mixin class $ResourceUiStateCopyWith<$Res>  {
  factory $ResourceUiStateCopyWith(ResourceUiState value, $Res Function(ResourceUiState) _then) = _$ResourceUiStateCopyWithImpl;
@useResult
$Res call({
 bool showResources, bool busy, bool dropHover, String operation, int done, int total, int revision
});




}
/// @nodoc
class _$ResourceUiStateCopyWithImpl<$Res>
    implements $ResourceUiStateCopyWith<$Res> {
  _$ResourceUiStateCopyWithImpl(this._self, this._then);

  final ResourceUiState _self;
  final $Res Function(ResourceUiState) _then;

/// Create a copy of ResourceUiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? showResources = null,Object? busy = null,Object? dropHover = null,Object? operation = null,Object? done = null,Object? total = null,Object? revision = null,}) {
  return _then(_self.copyWith(
showResources: null == showResources ? _self.showResources : showResources // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,dropHover: null == dropHover ? _self.dropHover : dropHover // ignore: cast_nullable_to_non_nullable
as bool,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ResourceUiState].
extension ResourceUiStatePatterns on ResourceUiState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResourceUiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResourceUiState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResourceUiState value)  $default,){
final _that = this;
switch (_that) {
case _ResourceUiState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResourceUiState value)?  $default,){
final _that = this;
switch (_that) {
case _ResourceUiState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool showResources,  bool busy,  bool dropHover,  String operation,  int done,  int total,  int revision)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResourceUiState() when $default != null:
return $default(_that.showResources,_that.busy,_that.dropHover,_that.operation,_that.done,_that.total,_that.revision);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool showResources,  bool busy,  bool dropHover,  String operation,  int done,  int total,  int revision)  $default,) {final _that = this;
switch (_that) {
case _ResourceUiState():
return $default(_that.showResources,_that.busy,_that.dropHover,_that.operation,_that.done,_that.total,_that.revision);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool showResources,  bool busy,  bool dropHover,  String operation,  int done,  int total,  int revision)?  $default,) {final _that = this;
switch (_that) {
case _ResourceUiState() when $default != null:
return $default(_that.showResources,_that.busy,_that.dropHover,_that.operation,_that.done,_that.total,_that.revision);case _:
  return null;

}
}

}

/// @nodoc


class _ResourceUiState implements ResourceUiState {
  const _ResourceUiState({this.showResources = false, this.busy = false, this.dropHover = false, this.operation = '', this.done = 0, this.total = 0, this.revision = 0});
  

@override@JsonKey() final  bool showResources;
@override@JsonKey() final  bool busy;
@override@JsonKey() final  bool dropHover;
@override@JsonKey() final  String operation;
@override@JsonKey() final  int done;
@override@JsonKey() final  int total;
@override@JsonKey() final  int revision;

/// Create a copy of ResourceUiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResourceUiStateCopyWith<_ResourceUiState> get copyWith => __$ResourceUiStateCopyWithImpl<_ResourceUiState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResourceUiState&&(identical(other.showResources, showResources) || other.showResources == showResources)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.dropHover, dropHover) || other.dropHover == dropHover)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.done, done) || other.done == done)&&(identical(other.total, total) || other.total == total)&&(identical(other.revision, revision) || other.revision == revision));
}


@override
int get hashCode => Object.hash(runtimeType,showResources,busy,dropHover,operation,done,total,revision);

@override
String toString() {
  return 'ResourceUiState(showResources: $showResources, busy: $busy, dropHover: $dropHover, operation: $operation, done: $done, total: $total, revision: $revision)';
}


}

/// @nodoc
abstract mixin class _$ResourceUiStateCopyWith<$Res> implements $ResourceUiStateCopyWith<$Res> {
  factory _$ResourceUiStateCopyWith(_ResourceUiState value, $Res Function(_ResourceUiState) _then) = __$ResourceUiStateCopyWithImpl;
@override @useResult
$Res call({
 bool showResources, bool busy, bool dropHover, String operation, int done, int total, int revision
});




}
/// @nodoc
class __$ResourceUiStateCopyWithImpl<$Res>
    implements _$ResourceUiStateCopyWith<$Res> {
  __$ResourceUiStateCopyWithImpl(this._self, this._then);

  final _ResourceUiState _self;
  final $Res Function(_ResourceUiState) _then;

/// Create a copy of ResourceUiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? showResources = null,Object? busy = null,Object? dropHover = null,Object? operation = null,Object? done = null,Object? total = null,Object? revision = null,}) {
  return _then(_ResourceUiState(
showResources: null == showResources ? _self.showResources : showResources // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,dropHover: null == dropHover ? _self.dropHover : dropHover // ignore: cast_nullable_to_non_nullable
as bool,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
