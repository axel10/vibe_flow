// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'music_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MusicFile {

 String get path; String get name; String? get title; String? get artist; String? get albumArtist; String? get album; int? get trackNumber; int? get id;// System Media Library ID
 String? get mediaUri; String? get thumbnailPath; String? get artworkPath; int? get artworkWidth; int? get artworkHeight; int? get durationMillis; Uint8List? get themeColorsBlob; Uint8List? get waveformBlob; Uint8List? get artworkBytes; int? get lastModifiedTime; MusicLyric? get lyrics; bool get isMissing;
/// Create a copy of MusicFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MusicFileCopyWith<MusicFile> get copyWith => _$MusicFileCopyWithImpl<MusicFile>(this as MusicFile, _$identity);





@override
String toString() {
  return 'MusicFile(path: $path, name: $name, title: $title, artist: $artist, albumArtist: $albumArtist, album: $album, trackNumber: $trackNumber, id: $id, mediaUri: $mediaUri, thumbnailPath: $thumbnailPath, artworkPath: $artworkPath, artworkWidth: $artworkWidth, artworkHeight: $artworkHeight, durationMillis: $durationMillis, themeColorsBlob: $themeColorsBlob, waveformBlob: $waveformBlob, artworkBytes: $artworkBytes, lastModifiedTime: $lastModifiedTime, lyrics: $lyrics, isMissing: $isMissing)';
}


}

/// @nodoc
abstract mixin class $MusicFileCopyWith<$Res>  {
  factory $MusicFileCopyWith(MusicFile value, $Res Function(MusicFile) _then) = _$MusicFileCopyWithImpl;
@useResult
$Res call({
 String path, String name, String? title, String? artist, String? albumArtist, String? album, int? trackNumber, int? id, String? mediaUri, String? thumbnailPath, String? artworkPath, int? artworkWidth, int? artworkHeight, int? durationMillis, Uint8List? themeColorsBlob, Uint8List? waveformBlob, Uint8List? artworkBytes, int? lastModifiedTime, MusicLyric? lyrics, bool isMissing
});


$MusicLyricCopyWith<$Res>? get lyrics;

}
/// @nodoc
class _$MusicFileCopyWithImpl<$Res>
    implements $MusicFileCopyWith<$Res> {
  _$MusicFileCopyWithImpl(this._self, this._then);

  final MusicFile _self;
  final $Res Function(MusicFile) _then;

/// Create a copy of MusicFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? name = null,Object? title = freezed,Object? artist = freezed,Object? albumArtist = freezed,Object? album = freezed,Object? trackNumber = freezed,Object? id = freezed,Object? mediaUri = freezed,Object? thumbnailPath = freezed,Object? artworkPath = freezed,Object? artworkWidth = freezed,Object? artworkHeight = freezed,Object? durationMillis = freezed,Object? themeColorsBlob = freezed,Object? waveformBlob = freezed,Object? artworkBytes = freezed,Object? lastModifiedTime = freezed,Object? lyrics = freezed,Object? isMissing = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,albumArtist: freezed == albumArtist ? _self.albumArtist : albumArtist // ignore: cast_nullable_to_non_nullable
as String?,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String?,trackNumber: freezed == trackNumber ? _self.trackNumber : trackNumber // ignore: cast_nullable_to_non_nullable
as int?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,mediaUri: freezed == mediaUri ? _self.mediaUri : mediaUri // ignore: cast_nullable_to_non_nullable
as String?,thumbnailPath: freezed == thumbnailPath ? _self.thumbnailPath : thumbnailPath // ignore: cast_nullable_to_non_nullable
as String?,artworkPath: freezed == artworkPath ? _self.artworkPath : artworkPath // ignore: cast_nullable_to_non_nullable
as String?,artworkWidth: freezed == artworkWidth ? _self.artworkWidth : artworkWidth // ignore: cast_nullable_to_non_nullable
as int?,artworkHeight: freezed == artworkHeight ? _self.artworkHeight : artworkHeight // ignore: cast_nullable_to_non_nullable
as int?,durationMillis: freezed == durationMillis ? _self.durationMillis : durationMillis // ignore: cast_nullable_to_non_nullable
as int?,themeColorsBlob: freezed == themeColorsBlob ? _self.themeColorsBlob : themeColorsBlob // ignore: cast_nullable_to_non_nullable
as Uint8List?,waveformBlob: freezed == waveformBlob ? _self.waveformBlob : waveformBlob // ignore: cast_nullable_to_non_nullable
as Uint8List?,artworkBytes: freezed == artworkBytes ? _self.artworkBytes : artworkBytes // ignore: cast_nullable_to_non_nullable
as Uint8List?,lastModifiedTime: freezed == lastModifiedTime ? _self.lastModifiedTime : lastModifiedTime // ignore: cast_nullable_to_non_nullable
as int?,lyrics: freezed == lyrics ? _self.lyrics : lyrics // ignore: cast_nullable_to_non_nullable
as MusicLyric?,isMissing: null == isMissing ? _self.isMissing : isMissing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of MusicFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MusicLyricCopyWith<$Res>? get lyrics {
    if (_self.lyrics == null) {
    return null;
  }

  return $MusicLyricCopyWith<$Res>(_self.lyrics!, (value) {
    return _then(_self.copyWith(lyrics: value));
  });
}
}


/// Adds pattern-matching-related methods to [MusicFile].
extension MusicFilePatterns on MusicFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MusicFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MusicFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MusicFile value)  $default,){
final _that = this;
switch (_that) {
case _MusicFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MusicFile value)?  $default,){
final _that = this;
switch (_that) {
case _MusicFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  String name,  String? title,  String? artist,  String? albumArtist,  String? album,  int? trackNumber,  int? id,  String? mediaUri,  String? thumbnailPath,  String? artworkPath,  int? artworkWidth,  int? artworkHeight,  int? durationMillis,  Uint8List? themeColorsBlob,  Uint8List? waveformBlob,  Uint8List? artworkBytes,  int? lastModifiedTime,  MusicLyric? lyrics,  bool isMissing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MusicFile() when $default != null:
return $default(_that.path,_that.name,_that.title,_that.artist,_that.albumArtist,_that.album,_that.trackNumber,_that.id,_that.mediaUri,_that.thumbnailPath,_that.artworkPath,_that.artworkWidth,_that.artworkHeight,_that.durationMillis,_that.themeColorsBlob,_that.waveformBlob,_that.artworkBytes,_that.lastModifiedTime,_that.lyrics,_that.isMissing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  String name,  String? title,  String? artist,  String? albumArtist,  String? album,  int? trackNumber,  int? id,  String? mediaUri,  String? thumbnailPath,  String? artworkPath,  int? artworkWidth,  int? artworkHeight,  int? durationMillis,  Uint8List? themeColorsBlob,  Uint8List? waveformBlob,  Uint8List? artworkBytes,  int? lastModifiedTime,  MusicLyric? lyrics,  bool isMissing)  $default,) {final _that = this;
switch (_that) {
case _MusicFile():
return $default(_that.path,_that.name,_that.title,_that.artist,_that.albumArtist,_that.album,_that.trackNumber,_that.id,_that.mediaUri,_that.thumbnailPath,_that.artworkPath,_that.artworkWidth,_that.artworkHeight,_that.durationMillis,_that.themeColorsBlob,_that.waveformBlob,_that.artworkBytes,_that.lastModifiedTime,_that.lyrics,_that.isMissing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  String name,  String? title,  String? artist,  String? albumArtist,  String? album,  int? trackNumber,  int? id,  String? mediaUri,  String? thumbnailPath,  String? artworkPath,  int? artworkWidth,  int? artworkHeight,  int? durationMillis,  Uint8List? themeColorsBlob,  Uint8List? waveformBlob,  Uint8List? artworkBytes,  int? lastModifiedTime,  MusicLyric? lyrics,  bool isMissing)?  $default,) {final _that = this;
switch (_that) {
case _MusicFile() when $default != null:
return $default(_that.path,_that.name,_that.title,_that.artist,_that.albumArtist,_that.album,_that.trackNumber,_that.id,_that.mediaUri,_that.thumbnailPath,_that.artworkPath,_that.artworkWidth,_that.artworkHeight,_that.durationMillis,_that.themeColorsBlob,_that.waveformBlob,_that.artworkBytes,_that.lastModifiedTime,_that.lyrics,_that.isMissing);case _:
  return null;

}
}

}

/// @nodoc


class _MusicFile extends MusicFile {
  const _MusicFile({required this.path, required this.name, this.title, this.artist, this.albumArtist, this.album, this.trackNumber, this.id, this.mediaUri, this.thumbnailPath, this.artworkPath, this.artworkWidth, this.artworkHeight, this.durationMillis, this.themeColorsBlob, this.waveformBlob, this.artworkBytes, this.lastModifiedTime, this.lyrics, this.isMissing = false}): super._();
  

@override final  String path;
@override final  String name;
@override final  String? title;
@override final  String? artist;
@override final  String? albumArtist;
@override final  String? album;
@override final  int? trackNumber;
@override final  int? id;
// System Media Library ID
@override final  String? mediaUri;
@override final  String? thumbnailPath;
@override final  String? artworkPath;
@override final  int? artworkWidth;
@override final  int? artworkHeight;
@override final  int? durationMillis;
@override final  Uint8List? themeColorsBlob;
@override final  Uint8List? waveformBlob;
@override final  Uint8List? artworkBytes;
@override final  int? lastModifiedTime;
@override final  MusicLyric? lyrics;
@override@JsonKey() final  bool isMissing;

/// Create a copy of MusicFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MusicFileCopyWith<_MusicFile> get copyWith => __$MusicFileCopyWithImpl<_MusicFile>(this, _$identity);





@override
String toString() {
  return 'MusicFile(path: $path, name: $name, title: $title, artist: $artist, albumArtist: $albumArtist, album: $album, trackNumber: $trackNumber, id: $id, mediaUri: $mediaUri, thumbnailPath: $thumbnailPath, artworkPath: $artworkPath, artworkWidth: $artworkWidth, artworkHeight: $artworkHeight, durationMillis: $durationMillis, themeColorsBlob: $themeColorsBlob, waveformBlob: $waveformBlob, artworkBytes: $artworkBytes, lastModifiedTime: $lastModifiedTime, lyrics: $lyrics, isMissing: $isMissing)';
}


}

/// @nodoc
abstract mixin class _$MusicFileCopyWith<$Res> implements $MusicFileCopyWith<$Res> {
  factory _$MusicFileCopyWith(_MusicFile value, $Res Function(_MusicFile) _then) = __$MusicFileCopyWithImpl;
@override @useResult
$Res call({
 String path, String name, String? title, String? artist, String? albumArtist, String? album, int? trackNumber, int? id, String? mediaUri, String? thumbnailPath, String? artworkPath, int? artworkWidth, int? artworkHeight, int? durationMillis, Uint8List? themeColorsBlob, Uint8List? waveformBlob, Uint8List? artworkBytes, int? lastModifiedTime, MusicLyric? lyrics, bool isMissing
});


@override $MusicLyricCopyWith<$Res>? get lyrics;

}
/// @nodoc
class __$MusicFileCopyWithImpl<$Res>
    implements _$MusicFileCopyWith<$Res> {
  __$MusicFileCopyWithImpl(this._self, this._then);

  final _MusicFile _self;
  final $Res Function(_MusicFile) _then;

/// Create a copy of MusicFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? name = null,Object? title = freezed,Object? artist = freezed,Object? albumArtist = freezed,Object? album = freezed,Object? trackNumber = freezed,Object? id = freezed,Object? mediaUri = freezed,Object? thumbnailPath = freezed,Object? artworkPath = freezed,Object? artworkWidth = freezed,Object? artworkHeight = freezed,Object? durationMillis = freezed,Object? themeColorsBlob = freezed,Object? waveformBlob = freezed,Object? artworkBytes = freezed,Object? lastModifiedTime = freezed,Object? lyrics = freezed,Object? isMissing = null,}) {
  return _then(_MusicFile(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,albumArtist: freezed == albumArtist ? _self.albumArtist : albumArtist // ignore: cast_nullable_to_non_nullable
as String?,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String?,trackNumber: freezed == trackNumber ? _self.trackNumber : trackNumber // ignore: cast_nullable_to_non_nullable
as int?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,mediaUri: freezed == mediaUri ? _self.mediaUri : mediaUri // ignore: cast_nullable_to_non_nullable
as String?,thumbnailPath: freezed == thumbnailPath ? _self.thumbnailPath : thumbnailPath // ignore: cast_nullable_to_non_nullable
as String?,artworkPath: freezed == artworkPath ? _self.artworkPath : artworkPath // ignore: cast_nullable_to_non_nullable
as String?,artworkWidth: freezed == artworkWidth ? _self.artworkWidth : artworkWidth // ignore: cast_nullable_to_non_nullable
as int?,artworkHeight: freezed == artworkHeight ? _self.artworkHeight : artworkHeight // ignore: cast_nullable_to_non_nullable
as int?,durationMillis: freezed == durationMillis ? _self.durationMillis : durationMillis // ignore: cast_nullable_to_non_nullable
as int?,themeColorsBlob: freezed == themeColorsBlob ? _self.themeColorsBlob : themeColorsBlob // ignore: cast_nullable_to_non_nullable
as Uint8List?,waveformBlob: freezed == waveformBlob ? _self.waveformBlob : waveformBlob // ignore: cast_nullable_to_non_nullable
as Uint8List?,artworkBytes: freezed == artworkBytes ? _self.artworkBytes : artworkBytes // ignore: cast_nullable_to_non_nullable
as Uint8List?,lastModifiedTime: freezed == lastModifiedTime ? _self.lastModifiedTime : lastModifiedTime // ignore: cast_nullable_to_non_nullable
as int?,lyrics: freezed == lyrics ? _self.lyrics : lyrics // ignore: cast_nullable_to_non_nullable
as MusicLyric?,isMissing: null == isMissing ? _self.isMissing : isMissing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of MusicFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MusicLyricCopyWith<$Res>? get lyrics {
    if (_self.lyrics == null) {
    return null;
  }

  return $MusicLyricCopyWith<$Res>(_self.lyrics!, (value) {
    return _then(_self.copyWith(lyrics: value));
  });
}
}

// dart format on
