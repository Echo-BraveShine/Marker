// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_exporter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DocumentExportOptions {

 DocumentExportFormat get format; bool get followTheme; bool get splitPng; int get width;
/// Create a copy of DocumentExportOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentExportOptionsCopyWith<DocumentExportOptions> get copyWith => _$DocumentExportOptionsCopyWithImpl<DocumentExportOptions>(this as DocumentExportOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentExportOptions&&(identical(other.format, format) || other.format == format)&&(identical(other.followTheme, followTheme) || other.followTheme == followTheme)&&(identical(other.splitPng, splitPng) || other.splitPng == splitPng)&&(identical(other.width, width) || other.width == width));
}


@override
int get hashCode => Object.hash(runtimeType,format,followTheme,splitPng,width);

@override
String toString() {
  return 'DocumentExportOptions(format: $format, followTheme: $followTheme, splitPng: $splitPng, width: $width)';
}


}

/// @nodoc
abstract mixin class $DocumentExportOptionsCopyWith<$Res>  {
  factory $DocumentExportOptionsCopyWith(DocumentExportOptions value, $Res Function(DocumentExportOptions) _then) = _$DocumentExportOptionsCopyWithImpl;
@useResult
$Res call({
 DocumentExportFormat format, bool followTheme, bool splitPng, int width
});




}
/// @nodoc
class _$DocumentExportOptionsCopyWithImpl<$Res>
    implements $DocumentExportOptionsCopyWith<$Res> {
  _$DocumentExportOptionsCopyWithImpl(this._self, this._then);

  final DocumentExportOptions _self;
  final $Res Function(DocumentExportOptions) _then;

/// Create a copy of DocumentExportOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? format = null,Object? followTheme = null,Object? splitPng = null,Object? width = null,}) {
  return _then(_self.copyWith(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as DocumentExportFormat,followTheme: null == followTheme ? _self.followTheme : followTheme // ignore: cast_nullable_to_non_nullable
as bool,splitPng: null == splitPng ? _self.splitPng : splitPng // ignore: cast_nullable_to_non_nullable
as bool,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentExportOptions].
extension DocumentExportOptionsPatterns on DocumentExportOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentExportOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentExportOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentExportOptions value)  $default,){
final _that = this;
switch (_that) {
case _DocumentExportOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentExportOptions value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentExportOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DocumentExportFormat format,  bool followTheme,  bool splitPng,  int width)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentExportOptions() when $default != null:
return $default(_that.format,_that.followTheme,_that.splitPng,_that.width);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DocumentExportFormat format,  bool followTheme,  bool splitPng,  int width)  $default,) {final _that = this;
switch (_that) {
case _DocumentExportOptions():
return $default(_that.format,_that.followTheme,_that.splitPng,_that.width);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DocumentExportFormat format,  bool followTheme,  bool splitPng,  int width)?  $default,) {final _that = this;
switch (_that) {
case _DocumentExportOptions() when $default != null:
return $default(_that.format,_that.followTheme,_that.splitPng,_that.width);case _:
  return null;

}
}

}

/// @nodoc


class _DocumentExportOptions implements DocumentExportOptions {
  const _DocumentExportOptions({this.format = DocumentExportFormat.pdf, this.followTheme = false, this.splitPng = false, this.width = 1280});
  

@override@JsonKey() final  DocumentExportFormat format;
@override@JsonKey() final  bool followTheme;
@override@JsonKey() final  bool splitPng;
@override@JsonKey() final  int width;

/// Create a copy of DocumentExportOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentExportOptionsCopyWith<_DocumentExportOptions> get copyWith => __$DocumentExportOptionsCopyWithImpl<_DocumentExportOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentExportOptions&&(identical(other.format, format) || other.format == format)&&(identical(other.followTheme, followTheme) || other.followTheme == followTheme)&&(identical(other.splitPng, splitPng) || other.splitPng == splitPng)&&(identical(other.width, width) || other.width == width));
}


@override
int get hashCode => Object.hash(runtimeType,format,followTheme,splitPng,width);

@override
String toString() {
  return 'DocumentExportOptions(format: $format, followTheme: $followTheme, splitPng: $splitPng, width: $width)';
}


}

/// @nodoc
abstract mixin class _$DocumentExportOptionsCopyWith<$Res> implements $DocumentExportOptionsCopyWith<$Res> {
  factory _$DocumentExportOptionsCopyWith(_DocumentExportOptions value, $Res Function(_DocumentExportOptions) _then) = __$DocumentExportOptionsCopyWithImpl;
@override @useResult
$Res call({
 DocumentExportFormat format, bool followTheme, bool splitPng, int width
});




}
/// @nodoc
class __$DocumentExportOptionsCopyWithImpl<$Res>
    implements _$DocumentExportOptionsCopyWith<$Res> {
  __$DocumentExportOptionsCopyWithImpl(this._self, this._then);

  final _DocumentExportOptions _self;
  final $Res Function(_DocumentExportOptions) _then;

/// Create a copy of DocumentExportOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? format = null,Object? followTheme = null,Object? splitPng = null,Object? width = null,}) {
  return _then(_DocumentExportOptions(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as DocumentExportFormat,followTheme: null == followTheme ? _self.followTheme : followTheme // ignore: cast_nullable_to_non_nullable
as bool,splitPng: null == splitPng ? _self.splitPng : splitPng // ignore: cast_nullable_to_non_nullable
as bool,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
