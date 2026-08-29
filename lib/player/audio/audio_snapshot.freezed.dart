// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AudioSnapshot {

 bool get isPlaying; bool get isBuffering; bool get isTransitioning; bool? get isLastActionNext; MusicFile? get currentMusic; Duration get position; Duration get duration; double get volume; bool get isMuted; List<MusicFile> get playbackQueue; int get currentIndex; bool get isRandomMode; bool get isShuffleRandomMode; AppPlaybackMode get playbackMode; EqualizerConfig get equalizerConfig; VisualizerOptimizationOptions get currentVisualizerOptions; List<MusicFile> get randomHistory; List<MusicFile> get randomQueue; int? get historyCursor; int? get deckCursor; bool get isVisualizerEnabled; Color? get dynamicStartColor; Color? get dynamicEndColor; Map<String, Color> get currentThemeColorsMap; bool get isLyricsActive; Duration? get sleepTimerRemaining; Duration? get sleepTimerDuration; double get playbackSpeed;
/// Create a copy of AudioSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudioSnapshotCopyWith<AudioSnapshot> get copyWith => _$AudioSnapshotCopyWithImpl<AudioSnapshot>(this as AudioSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudioSnapshot&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.isBuffering, isBuffering) || other.isBuffering == isBuffering)&&(identical(other.isTransitioning, isTransitioning) || other.isTransitioning == isTransitioning)&&(identical(other.isLastActionNext, isLastActionNext) || other.isLastActionNext == isLastActionNext)&&(identical(other.currentMusic, currentMusic) || other.currentMusic == currentMusic)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&const DeepCollectionEquality().equals(other.playbackQueue, playbackQueue)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.isRandomMode, isRandomMode) || other.isRandomMode == isRandomMode)&&(identical(other.isShuffleRandomMode, isShuffleRandomMode) || other.isShuffleRandomMode == isShuffleRandomMode)&&(identical(other.playbackMode, playbackMode) || other.playbackMode == playbackMode)&&(identical(other.equalizerConfig, equalizerConfig) || other.equalizerConfig == equalizerConfig)&&(identical(other.currentVisualizerOptions, currentVisualizerOptions) || other.currentVisualizerOptions == currentVisualizerOptions)&&const DeepCollectionEquality().equals(other.randomHistory, randomHistory)&&const DeepCollectionEquality().equals(other.randomQueue, randomQueue)&&(identical(other.historyCursor, historyCursor) || other.historyCursor == historyCursor)&&(identical(other.deckCursor, deckCursor) || other.deckCursor == deckCursor)&&(identical(other.isVisualizerEnabled, isVisualizerEnabled) || other.isVisualizerEnabled == isVisualizerEnabled)&&(identical(other.dynamicStartColor, dynamicStartColor) || other.dynamicStartColor == dynamicStartColor)&&(identical(other.dynamicEndColor, dynamicEndColor) || other.dynamicEndColor == dynamicEndColor)&&const DeepCollectionEquality().equals(other.currentThemeColorsMap, currentThemeColorsMap)&&(identical(other.isLyricsActive, isLyricsActive) || other.isLyricsActive == isLyricsActive)&&(identical(other.sleepTimerRemaining, sleepTimerRemaining) || other.sleepTimerRemaining == sleepTimerRemaining)&&(identical(other.sleepTimerDuration, sleepTimerDuration) || other.sleepTimerDuration == sleepTimerDuration)&&(identical(other.playbackSpeed, playbackSpeed) || other.playbackSpeed == playbackSpeed));
}


@override
int get hashCode => Object.hashAll([runtimeType,isPlaying,isBuffering,isTransitioning,isLastActionNext,currentMusic,position,duration,volume,isMuted,const DeepCollectionEquality().hash(playbackQueue),currentIndex,isRandomMode,isShuffleRandomMode,playbackMode,equalizerConfig,currentVisualizerOptions,const DeepCollectionEquality().hash(randomHistory),const DeepCollectionEquality().hash(randomQueue),historyCursor,deckCursor,isVisualizerEnabled,dynamicStartColor,dynamicEndColor,const DeepCollectionEquality().hash(currentThemeColorsMap),isLyricsActive,sleepTimerRemaining,sleepTimerDuration,playbackSpeed]);

@override
String toString() {
  return 'AudioSnapshot(isPlaying: $isPlaying, isBuffering: $isBuffering, isTransitioning: $isTransitioning, isLastActionNext: $isLastActionNext, currentMusic: $currentMusic, position: $position, duration: $duration, volume: $volume, isMuted: $isMuted, playbackQueue: $playbackQueue, currentIndex: $currentIndex, isRandomMode: $isRandomMode, isShuffleRandomMode: $isShuffleRandomMode, playbackMode: $playbackMode, equalizerConfig: $equalizerConfig, currentVisualizerOptions: $currentVisualizerOptions, randomHistory: $randomHistory, randomQueue: $randomQueue, historyCursor: $historyCursor, deckCursor: $deckCursor, isVisualizerEnabled: $isVisualizerEnabled, dynamicStartColor: $dynamicStartColor, dynamicEndColor: $dynamicEndColor, currentThemeColorsMap: $currentThemeColorsMap, isLyricsActive: $isLyricsActive, sleepTimerRemaining: $sleepTimerRemaining, sleepTimerDuration: $sleepTimerDuration, playbackSpeed: $playbackSpeed)';
}


}

/// @nodoc
abstract mixin class $AudioSnapshotCopyWith<$Res>  {
  factory $AudioSnapshotCopyWith(AudioSnapshot value, $Res Function(AudioSnapshot) _then) = _$AudioSnapshotCopyWithImpl;
@useResult
$Res call({
 bool isPlaying, bool isBuffering, bool isTransitioning, bool? isLastActionNext, MusicFile? currentMusic, Duration position, Duration duration, double volume, bool isMuted, List<MusicFile> playbackQueue, int currentIndex, bool isRandomMode, bool isShuffleRandomMode, AppPlaybackMode playbackMode, EqualizerConfig equalizerConfig, VisualizerOptimizationOptions currentVisualizerOptions, List<MusicFile> randomHistory, List<MusicFile> randomQueue, int? historyCursor, int? deckCursor, bool isVisualizerEnabled, Color? dynamicStartColor, Color? dynamicEndColor, Map<String, Color> currentThemeColorsMap, bool isLyricsActive, Duration? sleepTimerRemaining, Duration? sleepTimerDuration, double playbackSpeed
});


$MusicFileCopyWith<$Res>? get currentMusic;

}
/// @nodoc
class _$AudioSnapshotCopyWithImpl<$Res>
    implements $AudioSnapshotCopyWith<$Res> {
  _$AudioSnapshotCopyWithImpl(this._self, this._then);

  final AudioSnapshot _self;
  final $Res Function(AudioSnapshot) _then;

/// Create a copy of AudioSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isPlaying = null,Object? isBuffering = null,Object? isTransitioning = null,Object? isLastActionNext = freezed,Object? currentMusic = freezed,Object? position = null,Object? duration = null,Object? volume = null,Object? isMuted = null,Object? playbackQueue = null,Object? currentIndex = null,Object? isRandomMode = null,Object? isShuffleRandomMode = null,Object? playbackMode = null,Object? equalizerConfig = null,Object? currentVisualizerOptions = null,Object? randomHistory = null,Object? randomQueue = null,Object? historyCursor = freezed,Object? deckCursor = freezed,Object? isVisualizerEnabled = null,Object? dynamicStartColor = freezed,Object? dynamicEndColor = freezed,Object? currentThemeColorsMap = null,Object? isLyricsActive = null,Object? sleepTimerRemaining = freezed,Object? sleepTimerDuration = freezed,Object? playbackSpeed = null,}) {
  return _then(_self.copyWith(
isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,isBuffering: null == isBuffering ? _self.isBuffering : isBuffering // ignore: cast_nullable_to_non_nullable
as bool,isTransitioning: null == isTransitioning ? _self.isTransitioning : isTransitioning // ignore: cast_nullable_to_non_nullable
as bool,isLastActionNext: freezed == isLastActionNext ? _self.isLastActionNext : isLastActionNext // ignore: cast_nullable_to_non_nullable
as bool?,currentMusic: freezed == currentMusic ? _self.currentMusic : currentMusic // ignore: cast_nullable_to_non_nullable
as MusicFile?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,playbackQueue: null == playbackQueue ? _self.playbackQueue : playbackQueue // ignore: cast_nullable_to_non_nullable
as List<MusicFile>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,isRandomMode: null == isRandomMode ? _self.isRandomMode : isRandomMode // ignore: cast_nullable_to_non_nullable
as bool,isShuffleRandomMode: null == isShuffleRandomMode ? _self.isShuffleRandomMode : isShuffleRandomMode // ignore: cast_nullable_to_non_nullable
as bool,playbackMode: null == playbackMode ? _self.playbackMode : playbackMode // ignore: cast_nullable_to_non_nullable
as AppPlaybackMode,equalizerConfig: null == equalizerConfig ? _self.equalizerConfig : equalizerConfig // ignore: cast_nullable_to_non_nullable
as EqualizerConfig,currentVisualizerOptions: null == currentVisualizerOptions ? _self.currentVisualizerOptions : currentVisualizerOptions // ignore: cast_nullable_to_non_nullable
as VisualizerOptimizationOptions,randomHistory: null == randomHistory ? _self.randomHistory : randomHistory // ignore: cast_nullable_to_non_nullable
as List<MusicFile>,randomQueue: null == randomQueue ? _self.randomQueue : randomQueue // ignore: cast_nullable_to_non_nullable
as List<MusicFile>,historyCursor: freezed == historyCursor ? _self.historyCursor : historyCursor // ignore: cast_nullable_to_non_nullable
as int?,deckCursor: freezed == deckCursor ? _self.deckCursor : deckCursor // ignore: cast_nullable_to_non_nullable
as int?,isVisualizerEnabled: null == isVisualizerEnabled ? _self.isVisualizerEnabled : isVisualizerEnabled // ignore: cast_nullable_to_non_nullable
as bool,dynamicStartColor: freezed == dynamicStartColor ? _self.dynamicStartColor : dynamicStartColor // ignore: cast_nullable_to_non_nullable
as Color?,dynamicEndColor: freezed == dynamicEndColor ? _self.dynamicEndColor : dynamicEndColor // ignore: cast_nullable_to_non_nullable
as Color?,currentThemeColorsMap: null == currentThemeColorsMap ? _self.currentThemeColorsMap : currentThemeColorsMap // ignore: cast_nullable_to_non_nullable
as Map<String, Color>,isLyricsActive: null == isLyricsActive ? _self.isLyricsActive : isLyricsActive // ignore: cast_nullable_to_non_nullable
as bool,sleepTimerRemaining: freezed == sleepTimerRemaining ? _self.sleepTimerRemaining : sleepTimerRemaining // ignore: cast_nullable_to_non_nullable
as Duration?,sleepTimerDuration: freezed == sleepTimerDuration ? _self.sleepTimerDuration : sleepTimerDuration // ignore: cast_nullable_to_non_nullable
as Duration?,playbackSpeed: null == playbackSpeed ? _self.playbackSpeed : playbackSpeed // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of AudioSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MusicFileCopyWith<$Res>? get currentMusic {
    if (_self.currentMusic == null) {
    return null;
  }

  return $MusicFileCopyWith<$Res>(_self.currentMusic!, (value) {
    return _then(_self.copyWith(currentMusic: value));
  });
}
}


/// Adds pattern-matching-related methods to [AudioSnapshot].
extension AudioSnapshotPatterns on AudioSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AudioSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AudioSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AudioSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _AudioSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AudioSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _AudioSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isPlaying,  bool isBuffering,  bool isTransitioning,  bool? isLastActionNext,  MusicFile? currentMusic,  Duration position,  Duration duration,  double volume,  bool isMuted,  List<MusicFile> playbackQueue,  int currentIndex,  bool isRandomMode,  bool isShuffleRandomMode,  AppPlaybackMode playbackMode,  EqualizerConfig equalizerConfig,  VisualizerOptimizationOptions currentVisualizerOptions,  List<MusicFile> randomHistory,  List<MusicFile> randomQueue,  int? historyCursor,  int? deckCursor,  bool isVisualizerEnabled,  Color? dynamicStartColor,  Color? dynamicEndColor,  Map<String, Color> currentThemeColorsMap,  bool isLyricsActive,  Duration? sleepTimerRemaining,  Duration? sleepTimerDuration,  double playbackSpeed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AudioSnapshot() when $default != null:
return $default(_that.isPlaying,_that.isBuffering,_that.isTransitioning,_that.isLastActionNext,_that.currentMusic,_that.position,_that.duration,_that.volume,_that.isMuted,_that.playbackQueue,_that.currentIndex,_that.isRandomMode,_that.isShuffleRandomMode,_that.playbackMode,_that.equalizerConfig,_that.currentVisualizerOptions,_that.randomHistory,_that.randomQueue,_that.historyCursor,_that.deckCursor,_that.isVisualizerEnabled,_that.dynamicStartColor,_that.dynamicEndColor,_that.currentThemeColorsMap,_that.isLyricsActive,_that.sleepTimerRemaining,_that.sleepTimerDuration,_that.playbackSpeed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isPlaying,  bool isBuffering,  bool isTransitioning,  bool? isLastActionNext,  MusicFile? currentMusic,  Duration position,  Duration duration,  double volume,  bool isMuted,  List<MusicFile> playbackQueue,  int currentIndex,  bool isRandomMode,  bool isShuffleRandomMode,  AppPlaybackMode playbackMode,  EqualizerConfig equalizerConfig,  VisualizerOptimizationOptions currentVisualizerOptions,  List<MusicFile> randomHistory,  List<MusicFile> randomQueue,  int? historyCursor,  int? deckCursor,  bool isVisualizerEnabled,  Color? dynamicStartColor,  Color? dynamicEndColor,  Map<String, Color> currentThemeColorsMap,  bool isLyricsActive,  Duration? sleepTimerRemaining,  Duration? sleepTimerDuration,  double playbackSpeed)  $default,) {final _that = this;
switch (_that) {
case _AudioSnapshot():
return $default(_that.isPlaying,_that.isBuffering,_that.isTransitioning,_that.isLastActionNext,_that.currentMusic,_that.position,_that.duration,_that.volume,_that.isMuted,_that.playbackQueue,_that.currentIndex,_that.isRandomMode,_that.isShuffleRandomMode,_that.playbackMode,_that.equalizerConfig,_that.currentVisualizerOptions,_that.randomHistory,_that.randomQueue,_that.historyCursor,_that.deckCursor,_that.isVisualizerEnabled,_that.dynamicStartColor,_that.dynamicEndColor,_that.currentThemeColorsMap,_that.isLyricsActive,_that.sleepTimerRemaining,_that.sleepTimerDuration,_that.playbackSpeed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isPlaying,  bool isBuffering,  bool isTransitioning,  bool? isLastActionNext,  MusicFile? currentMusic,  Duration position,  Duration duration,  double volume,  bool isMuted,  List<MusicFile> playbackQueue,  int currentIndex,  bool isRandomMode,  bool isShuffleRandomMode,  AppPlaybackMode playbackMode,  EqualizerConfig equalizerConfig,  VisualizerOptimizationOptions currentVisualizerOptions,  List<MusicFile> randomHistory,  List<MusicFile> randomQueue,  int? historyCursor,  int? deckCursor,  bool isVisualizerEnabled,  Color? dynamicStartColor,  Color? dynamicEndColor,  Map<String, Color> currentThemeColorsMap,  bool isLyricsActive,  Duration? sleepTimerRemaining,  Duration? sleepTimerDuration,  double playbackSpeed)?  $default,) {final _that = this;
switch (_that) {
case _AudioSnapshot() when $default != null:
return $default(_that.isPlaying,_that.isBuffering,_that.isTransitioning,_that.isLastActionNext,_that.currentMusic,_that.position,_that.duration,_that.volume,_that.isMuted,_that.playbackQueue,_that.currentIndex,_that.isRandomMode,_that.isShuffleRandomMode,_that.playbackMode,_that.equalizerConfig,_that.currentVisualizerOptions,_that.randomHistory,_that.randomQueue,_that.historyCursor,_that.deckCursor,_that.isVisualizerEnabled,_that.dynamicStartColor,_that.dynamicEndColor,_that.currentThemeColorsMap,_that.isLyricsActive,_that.sleepTimerRemaining,_that.sleepTimerDuration,_that.playbackSpeed);case _:
  return null;

}
}

}

/// @nodoc


class _AudioSnapshot extends AudioSnapshot {
  const _AudioSnapshot({required this.isPlaying, this.isBuffering = false, required this.isTransitioning, required this.isLastActionNext, required this.currentMusic, required this.position, required this.duration, required this.volume, required this.isMuted, final  List<MusicFile> playbackQueue = const <MusicFile>[], required this.currentIndex, required this.isRandomMode, required this.isShuffleRandomMode, required this.playbackMode, required this.equalizerConfig, required this.currentVisualizerOptions, final  List<MusicFile> randomHistory = const <MusicFile>[], final  List<MusicFile> randomQueue = const <MusicFile>[], required this.historyCursor, required this.deckCursor, required this.isVisualizerEnabled, required this.dynamicStartColor, required this.dynamicEndColor, final  Map<String, Color> currentThemeColorsMap = const <String, Color>{}, required this.isLyricsActive, required this.sleepTimerRemaining, required this.sleepTimerDuration, this.playbackSpeed = 1.0}): _playbackQueue = playbackQueue,_randomHistory = randomHistory,_randomQueue = randomQueue,_currentThemeColorsMap = currentThemeColorsMap,super._();
  

@override final  bool isPlaying;
@override@JsonKey() final  bool isBuffering;
@override final  bool isTransitioning;
@override final  bool? isLastActionNext;
@override final  MusicFile? currentMusic;
@override final  Duration position;
@override final  Duration duration;
@override final  double volume;
@override final  bool isMuted;
 final  List<MusicFile> _playbackQueue;
@override@JsonKey() List<MusicFile> get playbackQueue {
  if (_playbackQueue is EqualUnmodifiableListView) return _playbackQueue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playbackQueue);
}

@override final  int currentIndex;
@override final  bool isRandomMode;
@override final  bool isShuffleRandomMode;
@override final  AppPlaybackMode playbackMode;
@override final  EqualizerConfig equalizerConfig;
@override final  VisualizerOptimizationOptions currentVisualizerOptions;
 final  List<MusicFile> _randomHistory;
@override@JsonKey() List<MusicFile> get randomHistory {
  if (_randomHistory is EqualUnmodifiableListView) return _randomHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_randomHistory);
}

 final  List<MusicFile> _randomQueue;
@override@JsonKey() List<MusicFile> get randomQueue {
  if (_randomQueue is EqualUnmodifiableListView) return _randomQueue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_randomQueue);
}

@override final  int? historyCursor;
@override final  int? deckCursor;
@override final  bool isVisualizerEnabled;
@override final  Color? dynamicStartColor;
@override final  Color? dynamicEndColor;
 final  Map<String, Color> _currentThemeColorsMap;
@override@JsonKey() Map<String, Color> get currentThemeColorsMap {
  if (_currentThemeColorsMap is EqualUnmodifiableMapView) return _currentThemeColorsMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_currentThemeColorsMap);
}

@override final  bool isLyricsActive;
@override final  Duration? sleepTimerRemaining;
@override final  Duration? sleepTimerDuration;
@override@JsonKey() final  double playbackSpeed;

/// Create a copy of AudioSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AudioSnapshotCopyWith<_AudioSnapshot> get copyWith => __$AudioSnapshotCopyWithImpl<_AudioSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AudioSnapshot&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.isBuffering, isBuffering) || other.isBuffering == isBuffering)&&(identical(other.isTransitioning, isTransitioning) || other.isTransitioning == isTransitioning)&&(identical(other.isLastActionNext, isLastActionNext) || other.isLastActionNext == isLastActionNext)&&(identical(other.currentMusic, currentMusic) || other.currentMusic == currentMusic)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&const DeepCollectionEquality().equals(other._playbackQueue, _playbackQueue)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.isRandomMode, isRandomMode) || other.isRandomMode == isRandomMode)&&(identical(other.isShuffleRandomMode, isShuffleRandomMode) || other.isShuffleRandomMode == isShuffleRandomMode)&&(identical(other.playbackMode, playbackMode) || other.playbackMode == playbackMode)&&(identical(other.equalizerConfig, equalizerConfig) || other.equalizerConfig == equalizerConfig)&&(identical(other.currentVisualizerOptions, currentVisualizerOptions) || other.currentVisualizerOptions == currentVisualizerOptions)&&const DeepCollectionEquality().equals(other._randomHistory, _randomHistory)&&const DeepCollectionEquality().equals(other._randomQueue, _randomQueue)&&(identical(other.historyCursor, historyCursor) || other.historyCursor == historyCursor)&&(identical(other.deckCursor, deckCursor) || other.deckCursor == deckCursor)&&(identical(other.isVisualizerEnabled, isVisualizerEnabled) || other.isVisualizerEnabled == isVisualizerEnabled)&&(identical(other.dynamicStartColor, dynamicStartColor) || other.dynamicStartColor == dynamicStartColor)&&(identical(other.dynamicEndColor, dynamicEndColor) || other.dynamicEndColor == dynamicEndColor)&&const DeepCollectionEquality().equals(other._currentThemeColorsMap, _currentThemeColorsMap)&&(identical(other.isLyricsActive, isLyricsActive) || other.isLyricsActive == isLyricsActive)&&(identical(other.sleepTimerRemaining, sleepTimerRemaining) || other.sleepTimerRemaining == sleepTimerRemaining)&&(identical(other.sleepTimerDuration, sleepTimerDuration) || other.sleepTimerDuration == sleepTimerDuration)&&(identical(other.playbackSpeed, playbackSpeed) || other.playbackSpeed == playbackSpeed));
}


@override
int get hashCode => Object.hashAll([runtimeType,isPlaying,isBuffering,isTransitioning,isLastActionNext,currentMusic,position,duration,volume,isMuted,const DeepCollectionEquality().hash(_playbackQueue),currentIndex,isRandomMode,isShuffleRandomMode,playbackMode,equalizerConfig,currentVisualizerOptions,const DeepCollectionEquality().hash(_randomHistory),const DeepCollectionEquality().hash(_randomQueue),historyCursor,deckCursor,isVisualizerEnabled,dynamicStartColor,dynamicEndColor,const DeepCollectionEquality().hash(_currentThemeColorsMap),isLyricsActive,sleepTimerRemaining,sleepTimerDuration,playbackSpeed]);

@override
String toString() {
  return 'AudioSnapshot(isPlaying: $isPlaying, isBuffering: $isBuffering, isTransitioning: $isTransitioning, isLastActionNext: $isLastActionNext, currentMusic: $currentMusic, position: $position, duration: $duration, volume: $volume, isMuted: $isMuted, playbackQueue: $playbackQueue, currentIndex: $currentIndex, isRandomMode: $isRandomMode, isShuffleRandomMode: $isShuffleRandomMode, playbackMode: $playbackMode, equalizerConfig: $equalizerConfig, currentVisualizerOptions: $currentVisualizerOptions, randomHistory: $randomHistory, randomQueue: $randomQueue, historyCursor: $historyCursor, deckCursor: $deckCursor, isVisualizerEnabled: $isVisualizerEnabled, dynamicStartColor: $dynamicStartColor, dynamicEndColor: $dynamicEndColor, currentThemeColorsMap: $currentThemeColorsMap, isLyricsActive: $isLyricsActive, sleepTimerRemaining: $sleepTimerRemaining, sleepTimerDuration: $sleepTimerDuration, playbackSpeed: $playbackSpeed)';
}


}

/// @nodoc
abstract mixin class _$AudioSnapshotCopyWith<$Res> implements $AudioSnapshotCopyWith<$Res> {
  factory _$AudioSnapshotCopyWith(_AudioSnapshot value, $Res Function(_AudioSnapshot) _then) = __$AudioSnapshotCopyWithImpl;
@override @useResult
$Res call({
 bool isPlaying, bool isBuffering, bool isTransitioning, bool? isLastActionNext, MusicFile? currentMusic, Duration position, Duration duration, double volume, bool isMuted, List<MusicFile> playbackQueue, int currentIndex, bool isRandomMode, bool isShuffleRandomMode, AppPlaybackMode playbackMode, EqualizerConfig equalizerConfig, VisualizerOptimizationOptions currentVisualizerOptions, List<MusicFile> randomHistory, List<MusicFile> randomQueue, int? historyCursor, int? deckCursor, bool isVisualizerEnabled, Color? dynamicStartColor, Color? dynamicEndColor, Map<String, Color> currentThemeColorsMap, bool isLyricsActive, Duration? sleepTimerRemaining, Duration? sleepTimerDuration, double playbackSpeed
});


@override $MusicFileCopyWith<$Res>? get currentMusic;

}
/// @nodoc
class __$AudioSnapshotCopyWithImpl<$Res>
    implements _$AudioSnapshotCopyWith<$Res> {
  __$AudioSnapshotCopyWithImpl(this._self, this._then);

  final _AudioSnapshot _self;
  final $Res Function(_AudioSnapshot) _then;

/// Create a copy of AudioSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isPlaying = null,Object? isBuffering = null,Object? isTransitioning = null,Object? isLastActionNext = freezed,Object? currentMusic = freezed,Object? position = null,Object? duration = null,Object? volume = null,Object? isMuted = null,Object? playbackQueue = null,Object? currentIndex = null,Object? isRandomMode = null,Object? isShuffleRandomMode = null,Object? playbackMode = null,Object? equalizerConfig = null,Object? currentVisualizerOptions = null,Object? randomHistory = null,Object? randomQueue = null,Object? historyCursor = freezed,Object? deckCursor = freezed,Object? isVisualizerEnabled = null,Object? dynamicStartColor = freezed,Object? dynamicEndColor = freezed,Object? currentThemeColorsMap = null,Object? isLyricsActive = null,Object? sleepTimerRemaining = freezed,Object? sleepTimerDuration = freezed,Object? playbackSpeed = null,}) {
  return _then(_AudioSnapshot(
isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,isBuffering: null == isBuffering ? _self.isBuffering : isBuffering // ignore: cast_nullable_to_non_nullable
as bool,isTransitioning: null == isTransitioning ? _self.isTransitioning : isTransitioning // ignore: cast_nullable_to_non_nullable
as bool,isLastActionNext: freezed == isLastActionNext ? _self.isLastActionNext : isLastActionNext // ignore: cast_nullable_to_non_nullable
as bool?,currentMusic: freezed == currentMusic ? _self.currentMusic : currentMusic // ignore: cast_nullable_to_non_nullable
as MusicFile?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,playbackQueue: null == playbackQueue ? _self._playbackQueue : playbackQueue // ignore: cast_nullable_to_non_nullable
as List<MusicFile>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,isRandomMode: null == isRandomMode ? _self.isRandomMode : isRandomMode // ignore: cast_nullable_to_non_nullable
as bool,isShuffleRandomMode: null == isShuffleRandomMode ? _self.isShuffleRandomMode : isShuffleRandomMode // ignore: cast_nullable_to_non_nullable
as bool,playbackMode: null == playbackMode ? _self.playbackMode : playbackMode // ignore: cast_nullable_to_non_nullable
as AppPlaybackMode,equalizerConfig: null == equalizerConfig ? _self.equalizerConfig : equalizerConfig // ignore: cast_nullable_to_non_nullable
as EqualizerConfig,currentVisualizerOptions: null == currentVisualizerOptions ? _self.currentVisualizerOptions : currentVisualizerOptions // ignore: cast_nullable_to_non_nullable
as VisualizerOptimizationOptions,randomHistory: null == randomHistory ? _self._randomHistory : randomHistory // ignore: cast_nullable_to_non_nullable
as List<MusicFile>,randomQueue: null == randomQueue ? _self._randomQueue : randomQueue // ignore: cast_nullable_to_non_nullable
as List<MusicFile>,historyCursor: freezed == historyCursor ? _self.historyCursor : historyCursor // ignore: cast_nullable_to_non_nullable
as int?,deckCursor: freezed == deckCursor ? _self.deckCursor : deckCursor // ignore: cast_nullable_to_non_nullable
as int?,isVisualizerEnabled: null == isVisualizerEnabled ? _self.isVisualizerEnabled : isVisualizerEnabled // ignore: cast_nullable_to_non_nullable
as bool,dynamicStartColor: freezed == dynamicStartColor ? _self.dynamicStartColor : dynamicStartColor // ignore: cast_nullable_to_non_nullable
as Color?,dynamicEndColor: freezed == dynamicEndColor ? _self.dynamicEndColor : dynamicEndColor // ignore: cast_nullable_to_non_nullable
as Color?,currentThemeColorsMap: null == currentThemeColorsMap ? _self._currentThemeColorsMap : currentThemeColorsMap // ignore: cast_nullable_to_non_nullable
as Map<String, Color>,isLyricsActive: null == isLyricsActive ? _self.isLyricsActive : isLyricsActive // ignore: cast_nullable_to_non_nullable
as bool,sleepTimerRemaining: freezed == sleepTimerRemaining ? _self.sleepTimerRemaining : sleepTimerRemaining // ignore: cast_nullable_to_non_nullable
as Duration?,sleepTimerDuration: freezed == sleepTimerDuration ? _self.sleepTimerDuration : sleepTimerDuration // ignore: cast_nullable_to_non_nullable
as Duration?,playbackSpeed: null == playbackSpeed ? _self.playbackSpeed : playbackSpeed // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of AudioSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MusicFileCopyWith<$Res>? get currentMusic {
    if (_self.currentMusic == null) {
    return null;
  }

  return $MusicFileCopyWith<$Res>(_self.currentMusic!, (value) {
    return _then(_self.copyWith(currentMusic: value));
  });
}
}

// dart format on
