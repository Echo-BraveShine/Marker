// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OpenDocument {

 String get id; String? get path; String get text; String get saved; int get lastEdited;
/// Create a copy of OpenDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenDocumentCopyWith<OpenDocument> get copyWith => _$OpenDocumentCopyWithImpl<OpenDocument>(this as OpenDocument, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.text, text) || other.text == text)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.lastEdited, lastEdited) || other.lastEdited == lastEdited));
}


@override
int get hashCode => Object.hash(runtimeType,id,path,text,saved,lastEdited);

@override
String toString() {
  return 'OpenDocument(id: $id, path: $path, text: $text, saved: $saved, lastEdited: $lastEdited)';
}


}

/// @nodoc
abstract mixin class $OpenDocumentCopyWith<$Res>  {
  factory $OpenDocumentCopyWith(OpenDocument value, $Res Function(OpenDocument) _then) = _$OpenDocumentCopyWithImpl;
@useResult
$Res call({
 String id, String? path, String text, String saved, int lastEdited
});




}
/// @nodoc
class _$OpenDocumentCopyWithImpl<$Res>
    implements $OpenDocumentCopyWith<$Res> {
  _$OpenDocumentCopyWithImpl(this._self, this._then);

  final OpenDocument _self;
  final $Res Function(OpenDocument) _then;

/// Create a copy of OpenDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? path = freezed,Object? text = null,Object? saved = null,Object? lastEdited = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as String,lastEdited: null == lastEdited ? _self.lastEdited : lastEdited // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OpenDocument].
extension OpenDocumentPatterns on OpenDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenDocument value)  $default,){
final _that = this;
switch (_that) {
case _OpenDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenDocument value)?  $default,){
final _that = this;
switch (_that) {
case _OpenDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? path,  String text,  String saved,  int lastEdited)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenDocument() when $default != null:
return $default(_that.id,_that.path,_that.text,_that.saved,_that.lastEdited);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? path,  String text,  String saved,  int lastEdited)  $default,) {final _that = this;
switch (_that) {
case _OpenDocument():
return $default(_that.id,_that.path,_that.text,_that.saved,_that.lastEdited);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? path,  String text,  String saved,  int lastEdited)?  $default,) {final _that = this;
switch (_that) {
case _OpenDocument() when $default != null:
return $default(_that.id,_that.path,_that.text,_that.saved,_that.lastEdited);case _:
  return null;

}
}

}

/// @nodoc


class _OpenDocument extends OpenDocument {
  const _OpenDocument({required this.id, this.path, required this.text, required this.saved, this.lastEdited = 0}): super._();
  

@override final  String id;
@override final  String? path;
@override final  String text;
@override final  String saved;
@override@JsonKey() final  int lastEdited;

/// Create a copy of OpenDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenDocumentCopyWith<_OpenDocument> get copyWith => __$OpenDocumentCopyWithImpl<_OpenDocument>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.text, text) || other.text == text)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.lastEdited, lastEdited) || other.lastEdited == lastEdited));
}


@override
int get hashCode => Object.hash(runtimeType,id,path,text,saved,lastEdited);

@override
String toString() {
  return 'OpenDocument(id: $id, path: $path, text: $text, saved: $saved, lastEdited: $lastEdited)';
}


}

/// @nodoc
abstract mixin class _$OpenDocumentCopyWith<$Res> implements $OpenDocumentCopyWith<$Res> {
  factory _$OpenDocumentCopyWith(_OpenDocument value, $Res Function(_OpenDocument) _then) = __$OpenDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String? path, String text, String saved, int lastEdited
});




}
/// @nodoc
class __$OpenDocumentCopyWithImpl<$Res>
    implements _$OpenDocumentCopyWith<$Res> {
  __$OpenDocumentCopyWithImpl(this._self, this._then);

  final _OpenDocument _self;
  final $Res Function(_OpenDocument) _then;

/// Create a copy of OpenDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? path = freezed,Object? text = null,Object? saved = null,Object? lastEdited = null,}) {
  return _then(_OpenDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as String,lastEdited: null == lastEdited ? _self.lastEdited : lastEdited // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$WorkspaceState {

 List<OpenDocument> get documents; String? get activeId;
/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceStateCopyWith<WorkspaceState> get copyWith => _$WorkspaceStateCopyWithImpl<WorkspaceState>(this as WorkspaceState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceState&&const DeepCollectionEquality().equals(other.documents, documents)&&(identical(other.activeId, activeId) || other.activeId == activeId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(documents),activeId);

@override
String toString() {
  return 'WorkspaceState(documents: $documents, activeId: $activeId)';
}


}

/// @nodoc
abstract mixin class $WorkspaceStateCopyWith<$Res>  {
  factory $WorkspaceStateCopyWith(WorkspaceState value, $Res Function(WorkspaceState) _then) = _$WorkspaceStateCopyWithImpl;
@useResult
$Res call({
 List<OpenDocument> documents, String? activeId
});




}
/// @nodoc
class _$WorkspaceStateCopyWithImpl<$Res>
    implements $WorkspaceStateCopyWith<$Res> {
  _$WorkspaceStateCopyWithImpl(this._self, this._then);

  final WorkspaceState _self;
  final $Res Function(WorkspaceState) _then;

/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documents = null,Object? activeId = freezed,}) {
  return _then(_self.copyWith(
documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<OpenDocument>,activeId: freezed == activeId ? _self.activeId : activeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkspaceState].
extension WorkspaceStatePatterns on WorkspaceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceState value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceState value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OpenDocument> documents,  String? activeId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
return $default(_that.documents,_that.activeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OpenDocument> documents,  String? activeId)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceState():
return $default(_that.documents,_that.activeId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OpenDocument> documents,  String? activeId)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
return $default(_that.documents,_that.activeId);case _:
  return null;

}
}

}

/// @nodoc


class _WorkspaceState implements WorkspaceState {
  const _WorkspaceState({final  List<OpenDocument> documents = const [], this.activeId}): _documents = documents;
  

 final  List<OpenDocument> _documents;
@override@JsonKey() List<OpenDocument> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}

@override final  String? activeId;

/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceStateCopyWith<_WorkspaceState> get copyWith => __$WorkspaceStateCopyWithImpl<_WorkspaceState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceState&&const DeepCollectionEquality().equals(other._documents, _documents)&&(identical(other.activeId, activeId) || other.activeId == activeId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_documents),activeId);

@override
String toString() {
  return 'WorkspaceState(documents: $documents, activeId: $activeId)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceStateCopyWith<$Res> implements $WorkspaceStateCopyWith<$Res> {
  factory _$WorkspaceStateCopyWith(_WorkspaceState value, $Res Function(_WorkspaceState) _then) = __$WorkspaceStateCopyWithImpl;
@override @useResult
$Res call({
 List<OpenDocument> documents, String? activeId
});




}
/// @nodoc
class __$WorkspaceStateCopyWithImpl<$Res>
    implements _$WorkspaceStateCopyWith<$Res> {
  __$WorkspaceStateCopyWithImpl(this._self, this._then);

  final _WorkspaceState _self;
  final $Res Function(_WorkspaceState) _then;

/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documents = null,Object? activeId = freezed,}) {
  return _then(_WorkspaceState(
documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<OpenDocument>,activeId: freezed == activeId ? _self.activeId : activeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
