// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_color_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TextColorState {

 double get hue; double get saturation; double get brightness;
/// Create a copy of TextColorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextColorStateCopyWith<TextColorState> get copyWith => _$TextColorStateCopyWithImpl<TextColorState>(this as TextColorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextColorState&&(identical(other.hue, hue) || other.hue == hue)&&(identical(other.saturation, saturation) || other.saturation == saturation)&&(identical(other.brightness, brightness) || other.brightness == brightness));
}


@override
int get hashCode => Object.hash(runtimeType,hue,saturation,brightness);

@override
String toString() {
  return 'TextColorState(hue: $hue, saturation: $saturation, brightness: $brightness)';
}


}

/// @nodoc
abstract mixin class $TextColorStateCopyWith<$Res>  {
  factory $TextColorStateCopyWith(TextColorState value, $Res Function(TextColorState) _then) = _$TextColorStateCopyWithImpl;
@useResult
$Res call({
 double hue, double saturation, double brightness
});




}
/// @nodoc
class _$TextColorStateCopyWithImpl<$Res>
    implements $TextColorStateCopyWith<$Res> {
  _$TextColorStateCopyWithImpl(this._self, this._then);

  final TextColorState _self;
  final $Res Function(TextColorState) _then;

/// Create a copy of TextColorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hue = null,Object? saturation = null,Object? brightness = null,}) {
  return _then(_self.copyWith(
hue: null == hue ? _self.hue : hue // ignore: cast_nullable_to_non_nullable
as double,saturation: null == saturation ? _self.saturation : saturation // ignore: cast_nullable_to_non_nullable
as double,brightness: null == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TextColorState].
extension TextColorStatePatterns on TextColorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextColorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextColorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextColorState value)  $default,){
final _that = this;
switch (_that) {
case _TextColorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextColorState value)?  $default,){
final _that = this;
switch (_that) {
case _TextColorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double hue,  double saturation,  double brightness)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextColorState() when $default != null:
return $default(_that.hue,_that.saturation,_that.brightness);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double hue,  double saturation,  double brightness)  $default,) {final _that = this;
switch (_that) {
case _TextColorState():
return $default(_that.hue,_that.saturation,_that.brightness);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double hue,  double saturation,  double brightness)?  $default,) {final _that = this;
switch (_that) {
case _TextColorState() when $default != null:
return $default(_that.hue,_that.saturation,_that.brightness);case _:
  return null;

}
}

}

/// @nodoc


class _TextColorState extends TextColorState {
  const _TextColorState({this.hue = 210, this.saturation = 1, this.brightness = .8}): super._();
  

@override@JsonKey() final  double hue;
@override@JsonKey() final  double saturation;
@override@JsonKey() final  double brightness;

/// Create a copy of TextColorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextColorStateCopyWith<_TextColorState> get copyWith => __$TextColorStateCopyWithImpl<_TextColorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextColorState&&(identical(other.hue, hue) || other.hue == hue)&&(identical(other.saturation, saturation) || other.saturation == saturation)&&(identical(other.brightness, brightness) || other.brightness == brightness));
}


@override
int get hashCode => Object.hash(runtimeType,hue,saturation,brightness);

@override
String toString() {
  return 'TextColorState(hue: $hue, saturation: $saturation, brightness: $brightness)';
}


}

/// @nodoc
abstract mixin class _$TextColorStateCopyWith<$Res> implements $TextColorStateCopyWith<$Res> {
  factory _$TextColorStateCopyWith(_TextColorState value, $Res Function(_TextColorState) _then) = __$TextColorStateCopyWithImpl;
@override @useResult
$Res call({
 double hue, double saturation, double brightness
});




}
/// @nodoc
class __$TextColorStateCopyWithImpl<$Res>
    implements _$TextColorStateCopyWith<$Res> {
  __$TextColorStateCopyWithImpl(this._self, this._then);

  final _TextColorState _self;
  final $Res Function(_TextColorState) _then;

/// Create a copy of TextColorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hue = null,Object? saturation = null,Object? brightness = null,}) {
  return _then(_TextColorState(
hue: null == hue ? _self.hue : hue // ignore: cast_nullable_to_non_nullable
as double,saturation: null == saturation ? _self.saturation : saturation // ignore: cast_nullable_to_non_nullable
as double,brightness: null == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
