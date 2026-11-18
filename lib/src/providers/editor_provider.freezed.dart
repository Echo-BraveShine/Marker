// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editor_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditorState {

 String get markdown; String get saved; String? get path; bool get restoring; bool get sidebar; bool get busy; double get fontSize; bool get serif; int get mode; bool get searchVisible; bool get replaceVisible; String get searchQuery; String get replacement; bool get searchCaseSensitive; bool get toolbarExpanded; int get settingsPage; double get ratio; int get cursorLine; int get cursorColumn;
/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorStateCopyWith<EditorState> get copyWith => _$EditorStateCopyWithImpl<EditorState>(this as EditorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorState&&(identical(other.markdown, markdown) || other.markdown == markdown)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.path, path) || other.path == path)&&(identical(other.restoring, restoring) || other.restoring == restoring)&&(identical(other.sidebar, sidebar) || other.sidebar == sidebar)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.serif, serif) || other.serif == serif)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.searchVisible, searchVisible) || other.searchVisible == searchVisible)&&(identical(other.replaceVisible, replaceVisible) || other.replaceVisible == replaceVisible)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.replacement, replacement) || other.replacement == replacement)&&(identical(other.searchCaseSensitive, searchCaseSensitive) || other.searchCaseSensitive == searchCaseSensitive)&&(identical(other.toolbarExpanded, toolbarExpanded) || other.toolbarExpanded == toolbarExpanded)&&(identical(other.settingsPage, settingsPage) || other.settingsPage == settingsPage)&&(identical(other.ratio, ratio) || other.ratio == ratio)&&(identical(other.cursorLine, cursorLine) || other.cursorLine == cursorLine)&&(identical(other.cursorColumn, cursorColumn) || other.cursorColumn == cursorColumn));
}


@override
int get hashCode => Object.hashAll([runtimeType,markdown,saved,path,restoring,sidebar,busy,fontSize,serif,mode,searchVisible,replaceVisible,searchQuery,replacement,searchCaseSensitive,toolbarExpanded,settingsPage,ratio,cursorLine,cursorColumn]);

@override
String toString() {
  return 'EditorState(markdown: $markdown, saved: $saved, path: $path, restoring: $restoring, sidebar: $sidebar, busy: $busy, fontSize: $fontSize, serif: $serif, mode: $mode, searchVisible: $searchVisible, replaceVisible: $replaceVisible, searchQuery: $searchQuery, replacement: $replacement, searchCaseSensitive: $searchCaseSensitive, toolbarExpanded: $toolbarExpanded, settingsPage: $settingsPage, ratio: $ratio, cursorLine: $cursorLine, cursorColumn: $cursorColumn)';
}


}

/// @nodoc
abstract mixin class $EditorStateCopyWith<$Res>  {
  factory $EditorStateCopyWith(EditorState value, $Res Function(EditorState) _then) = _$EditorStateCopyWithImpl;
@useResult
$Res call({
 String markdown, String saved, String? path, bool restoring, bool sidebar, bool busy, double fontSize, bool serif, int mode, bool searchVisible, bool replaceVisible, String searchQuery, String replacement, bool searchCaseSensitive, bool toolbarExpanded, int settingsPage, double ratio, int cursorLine, int cursorColumn
});




}
/// @nodoc
class _$EditorStateCopyWithImpl<$Res>
    implements $EditorStateCopyWith<$Res> {
  _$EditorStateCopyWithImpl(this._self, this._then);

  final EditorState _self;
  final $Res Function(EditorState) _then;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? markdown = null,Object? saved = null,Object? path = freezed,Object? restoring = null,Object? sidebar = null,Object? busy = null,Object? fontSize = null,Object? serif = null,Object? mode = null,Object? searchVisible = null,Object? replaceVisible = null,Object? searchQuery = null,Object? replacement = null,Object? searchCaseSensitive = null,Object? toolbarExpanded = null,Object? settingsPage = null,Object? ratio = null,Object? cursorLine = null,Object? cursorColumn = null,}) {
  return _then(_self.copyWith(
markdown: null == markdown ? _self.markdown : markdown // ignore: cast_nullable_to_non_nullable
as String,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as String,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,restoring: null == restoring ? _self.restoring : restoring // ignore: cast_nullable_to_non_nullable
as bool,sidebar: null == sidebar ? _self.sidebar : sidebar // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,serif: null == serif ? _self.serif : serif // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as int,searchVisible: null == searchVisible ? _self.searchVisible : searchVisible // ignore: cast_nullable_to_non_nullable
as bool,replaceVisible: null == replaceVisible ? _self.replaceVisible : replaceVisible // ignore: cast_nullable_to_non_nullable
as bool,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,replacement: null == replacement ? _self.replacement : replacement // ignore: cast_nullable_to_non_nullable
as String,searchCaseSensitive: null == searchCaseSensitive ? _self.searchCaseSensitive : searchCaseSensitive // ignore: cast_nullable_to_non_nullable
as bool,toolbarExpanded: null == toolbarExpanded ? _self.toolbarExpanded : toolbarExpanded // ignore: cast_nullable_to_non_nullable
as bool,settingsPage: null == settingsPage ? _self.settingsPage : settingsPage // ignore: cast_nullable_to_non_nullable
as int,ratio: null == ratio ? _self.ratio : ratio // ignore: cast_nullable_to_non_nullable
as double,cursorLine: null == cursorLine ? _self.cursorLine : cursorLine // ignore: cast_nullable_to_non_nullable
as int,cursorColumn: null == cursorColumn ? _self.cursorColumn : cursorColumn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [EditorState].
extension EditorStatePatterns on EditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditorState value)  $default,){
final _that = this;
switch (_that) {
case _EditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditorState value)?  $default,){
final _that = this;
switch (_that) {
case _EditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String markdown,  String saved,  String? path,  bool restoring,  bool sidebar,  bool busy,  double fontSize,  bool serif,  int mode,  bool searchVisible,  bool replaceVisible,  String searchQuery,  String replacement,  bool searchCaseSensitive,  bool toolbarExpanded,  int settingsPage,  double ratio,  int cursorLine,  int cursorColumn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditorState() when $default != null:
return $default(_that.markdown,_that.saved,_that.path,_that.restoring,_that.sidebar,_that.busy,_that.fontSize,_that.serif,_that.mode,_that.searchVisible,_that.replaceVisible,_that.searchQuery,_that.replacement,_that.searchCaseSensitive,_that.toolbarExpanded,_that.settingsPage,_that.ratio,_that.cursorLine,_that.cursorColumn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String markdown,  String saved,  String? path,  bool restoring,  bool sidebar,  bool busy,  double fontSize,  bool serif,  int mode,  bool searchVisible,  bool replaceVisible,  String searchQuery,  String replacement,  bool searchCaseSensitive,  bool toolbarExpanded,  int settingsPage,  double ratio,  int cursorLine,  int cursorColumn)  $default,) {final _that = this;
switch (_that) {
case _EditorState():
return $default(_that.markdown,_that.saved,_that.path,_that.restoring,_that.sidebar,_that.busy,_that.fontSize,_that.serif,_that.mode,_that.searchVisible,_that.replaceVisible,_that.searchQuery,_that.replacement,_that.searchCaseSensitive,_that.toolbarExpanded,_that.settingsPage,_that.ratio,_that.cursorLine,_that.cursorColumn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String markdown,  String saved,  String? path,  bool restoring,  bool sidebar,  bool busy,  double fontSize,  bool serif,  int mode,  bool searchVisible,  bool replaceVisible,  String searchQuery,  String replacement,  bool searchCaseSensitive,  bool toolbarExpanded,  int settingsPage,  double ratio,  int cursorLine,  int cursorColumn)?  $default,) {final _that = this;
switch (_that) {
case _EditorState() when $default != null:
return $default(_that.markdown,_that.saved,_that.path,_that.restoring,_that.sidebar,_that.busy,_that.fontSize,_that.serif,_that.mode,_that.searchVisible,_that.replaceVisible,_that.searchQuery,_that.replacement,_that.searchCaseSensitive,_that.toolbarExpanded,_that.settingsPage,_that.ratio,_that.cursorLine,_that.cursorColumn);case _:
  return null;

}
}

}

/// @nodoc


class _EditorState extends EditorState {
  const _EditorState({this.markdown = defaultMarkdown, this.saved = defaultMarkdown, this.path, this.restoring = true, this.sidebar = true, this.busy = false, this.fontSize = 14, this.serif = false, this.mode = 1, this.searchVisible = false, this.replaceVisible = false, this.searchQuery = '', this.replacement = '', this.searchCaseSensitive = false, this.toolbarExpanded = false, this.settingsPage = 0, this.ratio = .5, this.cursorLine = 1, this.cursorColumn = 1}): super._();
  

@override@JsonKey() final  String markdown;
@override@JsonKey() final  String saved;
@override final  String? path;
@override@JsonKey() final  bool restoring;
@override@JsonKey() final  bool sidebar;
@override@JsonKey() final  bool busy;
@override@JsonKey() final  double fontSize;
@override@JsonKey() final  bool serif;
@override@JsonKey() final  int mode;
@override@JsonKey() final  bool searchVisible;
@override@JsonKey() final  bool replaceVisible;
@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  String replacement;
@override@JsonKey() final  bool searchCaseSensitive;
@override@JsonKey() final  bool toolbarExpanded;
@override@JsonKey() final  int settingsPage;
@override@JsonKey() final  double ratio;
@override@JsonKey() final  int cursorLine;
@override@JsonKey() final  int cursorColumn;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditorStateCopyWith<_EditorState> get copyWith => __$EditorStateCopyWithImpl<_EditorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditorState&&(identical(other.markdown, markdown) || other.markdown == markdown)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.path, path) || other.path == path)&&(identical(other.restoring, restoring) || other.restoring == restoring)&&(identical(other.sidebar, sidebar) || other.sidebar == sidebar)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.serif, serif) || other.serif == serif)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.searchVisible, searchVisible) || other.searchVisible == searchVisible)&&(identical(other.replaceVisible, replaceVisible) || other.replaceVisible == replaceVisible)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.replacement, replacement) || other.replacement == replacement)&&(identical(other.searchCaseSensitive, searchCaseSensitive) || other.searchCaseSensitive == searchCaseSensitive)&&(identical(other.toolbarExpanded, toolbarExpanded) || other.toolbarExpanded == toolbarExpanded)&&(identical(other.settingsPage, settingsPage) || other.settingsPage == settingsPage)&&(identical(other.ratio, ratio) || other.ratio == ratio)&&(identical(other.cursorLine, cursorLine) || other.cursorLine == cursorLine)&&(identical(other.cursorColumn, cursorColumn) || other.cursorColumn == cursorColumn));
}


@override
int get hashCode => Object.hashAll([runtimeType,markdown,saved,path,restoring,sidebar,busy,fontSize,serif,mode,searchVisible,replaceVisible,searchQuery,replacement,searchCaseSensitive,toolbarExpanded,settingsPage,ratio,cursorLine,cursorColumn]);

@override
String toString() {
  return 'EditorState(markdown: $markdown, saved: $saved, path: $path, restoring: $restoring, sidebar: $sidebar, busy: $busy, fontSize: $fontSize, serif: $serif, mode: $mode, searchVisible: $searchVisible, replaceVisible: $replaceVisible, searchQuery: $searchQuery, replacement: $replacement, searchCaseSensitive: $searchCaseSensitive, toolbarExpanded: $toolbarExpanded, settingsPage: $settingsPage, ratio: $ratio, cursorLine: $cursorLine, cursorColumn: $cursorColumn)';
}


}

/// @nodoc
abstract mixin class _$EditorStateCopyWith<$Res> implements $EditorStateCopyWith<$Res> {
  factory _$EditorStateCopyWith(_EditorState value, $Res Function(_EditorState) _then) = __$EditorStateCopyWithImpl;
@override @useResult
$Res call({
 String markdown, String saved, String? path, bool restoring, bool sidebar, bool busy, double fontSize, bool serif, int mode, bool searchVisible, bool replaceVisible, String searchQuery, String replacement, bool searchCaseSensitive, bool toolbarExpanded, int settingsPage, double ratio, int cursorLine, int cursorColumn
});




}
/// @nodoc
class __$EditorStateCopyWithImpl<$Res>
    implements _$EditorStateCopyWith<$Res> {
  __$EditorStateCopyWithImpl(this._self, this._then);

  final _EditorState _self;
  final $Res Function(_EditorState) _then;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? markdown = null,Object? saved = null,Object? path = freezed,Object? restoring = null,Object? sidebar = null,Object? busy = null,Object? fontSize = null,Object? serif = null,Object? mode = null,Object? searchVisible = null,Object? replaceVisible = null,Object? searchQuery = null,Object? replacement = null,Object? searchCaseSensitive = null,Object? toolbarExpanded = null,Object? settingsPage = null,Object? ratio = null,Object? cursorLine = null,Object? cursorColumn = null,}) {
  return _then(_EditorState(
markdown: null == markdown ? _self.markdown : markdown // ignore: cast_nullable_to_non_nullable
as String,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as String,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,restoring: null == restoring ? _self.restoring : restoring // ignore: cast_nullable_to_non_nullable
as bool,sidebar: null == sidebar ? _self.sidebar : sidebar // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,serif: null == serif ? _self.serif : serif // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as int,searchVisible: null == searchVisible ? _self.searchVisible : searchVisible // ignore: cast_nullable_to_non_nullable
as bool,replaceVisible: null == replaceVisible ? _self.replaceVisible : replaceVisible // ignore: cast_nullable_to_non_nullable
as bool,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,replacement: null == replacement ? _self.replacement : replacement // ignore: cast_nullable_to_non_nullable
as String,searchCaseSensitive: null == searchCaseSensitive ? _self.searchCaseSensitive : searchCaseSensitive // ignore: cast_nullable_to_non_nullable
as bool,toolbarExpanded: null == toolbarExpanded ? _self.toolbarExpanded : toolbarExpanded // ignore: cast_nullable_to_non_nullable
as bool,settingsPage: null == settingsPage ? _self.settingsPage : settingsPage // ignore: cast_nullable_to_non_nullable
as int,ratio: null == ratio ? _self.ratio : ratio // ignore: cast_nullable_to_non_nullable
as double,cursorLine: null == cursorLine ? _self.cursorLine : cursorLine // ignore: cast_nullable_to_non_nullable
as int,cursorColumn: null == cursorColumn ? _self.cursorColumn : cursorColumn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
