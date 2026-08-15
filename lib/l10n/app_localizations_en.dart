// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vynody';

  @override
  String get alwaysOnTop => 'Always on Top';

  @override
  String get systemMediaLibrary => 'System Media Library';

  @override
  String get scanningDirectory => 'Scanning directory...';

  @override
  String filesPreprocessed(Object count) {
    return 'Preprocessed $count';
  }

  @override
  String filesDiscovered(Object count) {
    return 'Discovered $count';
  }

  @override
  String filesFullyProcessed(Object count) {
    return 'Fully processed $count';
  }

  @override
  String get directoryAddedSuccess => 'Directory added successfully';

  @override
  String get directoryAddedNoMusic =>
      'Directory added, but no playable audio files found';

  @override
  String get scanDirectory => 'Scan Directory';

  @override
  String get sort => 'Sort';

  @override
  String get addRootDirectory => 'Add Root Directory';

  @override
  String get goBack => 'Go Back';

  @override
  String get noMediaLibraryPermission => 'No media library access permission';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get needPermissionToScan => 'Permission required to scan local music';

  @override
  String get rebuildTagDatabase => 'Rebuild Tag Database';

  @override
  String get rebuildDatabase => 'Rebuild Database';

  @override
  String get confirmRebuildDatabase =>
      'Are you sure you want to manually refresh all song tag information? This may take some time to reload covers and metadata.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'OK';

  @override
  String get rebuildingDatabase => 'Rebuilding song tag database...';

  @override
  String get sortBy => 'Sort By';

  @override
  String get sortScope => 'Scope';

  @override
  String get sortOrder => 'Sort Order';

  @override
  String get title => 'Title';

  @override
  String get fileName => 'File Name';

  @override
  String get trackNumber => 'Track Number';

  @override
  String get ascending => 'Ascending';

  @override
  String get descending => 'Descending';

  @override
  String get currentFolderScope => 'Current Folder';

  @override
  String get globalScope => 'Global';

  @override
  String get visualizerSettings => 'Playback Page Settings';

  @override
  String get algorithm => 'Spectrum';

  @override
  String get appearance => 'Appearance';

  @override
  String get spectrumAppearanceGroup => 'Spectrum Appearance';

  @override
  String get spectrumAdvancedOptions => 'Spectrum Advanced Options';

  @override
  String get resetAlgorithm => 'Reset Algorithm';

  @override
  String get resetAppearance => 'Reset Appearance';

  @override
  String get smoothing => 'Smoothing';

  @override
  String get gravity => 'Gravity';

  @override
  String get logScale => 'Log Scale';

  @override
  String get contrast => 'Contrast';

  @override
  String get normalization => 'Normalization';

  @override
  String get multiplier => 'Multiplier';

  @override
  String get skipHighFrequency => 'Skip High Frequency';

  @override
  String get frequencyGroups => 'Frequency Groups';

  @override
  String get aggregationMode => 'Aggregation Mode';

  @override
  String get opacity => 'Opacity';

  @override
  String get enableGradient => 'Enable Gradient';

  @override
  String get startColor => 'Start Color';

  @override
  String get endColor => 'End Color';

  @override
  String get gradientRangeStop1 => 'Gradient Range Stop 1';

  @override
  String get gradientRangeStop2 => 'Gradient Range Stop 2';

  @override
  String get gradientRepeatMode => 'Gradient Repeat Mode';

  @override
  String get color => 'Color';

  @override
  String get followCoverColor => 'Follow Cover Color';

  @override
  String get selectColor => 'Select Color';

  @override
  String get volume => 'Volume';

  @override
  String get clearQueue => 'Clear Queue';

  @override
  String get confirmClearQueue =>
      'Are you sure you want to clear the current queue?';

  @override
  String get queueCleared => 'Queue cleared';

  @override
  String get locateCurrentSong => 'Locate Current Song';

  @override
  String get songNotInScannedFolders =>
      'Current song is not in the scanned directories';

  @override
  String get queue => 'Queue';

  @override
  String get queueEmpty => 'Queue is empty';

  @override
  String selectedSongs(int count) {
    return '$count songs selected';
  }

  @override
  String get unknownArtist => 'Unknown Artist';

  @override
  String deletedSongs(int count) {
    return '$count songs deleted';
  }

  @override
  String get delete => 'Delete';

  @override
  String get createPlaylist => 'Create Playlist';

  @override
  String get playlistName => 'Playlist Name';

  @override
  String get enterPlaylistName => 'Enter playlist name';

  @override
  String get playlistNameExists => 'Playlist name already exists';

  @override
  String get renamePlaylist => 'Rename Playlist';

  @override
  String get deletePlaylist => 'Delete Playlist';

  @override
  String confirmDeletePlaylist(String name) {
    return 'Are you sure you want to delete the playlist \"$name\"?';
  }

  @override
  String get addToPlaylist => 'Add to Playlist';

  @override
  String get selectAll => 'Select All';

  @override
  String get addToQueue => 'Add to Queue';

  @override
  String get addedToQueue => 'Added to Queue';

  @override
  String songCount(int count) {
    return '$count songs';
  }

  @override
  String addedToPlaylist(int count, String playlist) {
    return 'Added $count songs to $playlist';
  }

  @override
  String get createNewList => 'Create New List';

  @override
  String createdPlaylist(String name, int count) {
    return 'Created playlist \"$name\" and added $count songs';
  }

  @override
  String get rename => 'Rename';

  @override
  String get playlist => 'Playlist';

  @override
  String get mostPlayed => 'Most Played';

  @override
  String get recentlyPlayed => 'Recently Played';

  @override
  String get recentlyAdded => 'Recently Added';

  @override
  String get albums => 'Albums';

  @override
  String get artists => 'Artists';

  @override
  String get mostPlayedDescription => 'Ranked by completed plays';

  @override
  String get recentlyPlayedDescription =>
      'Sorted by play time, including external files';

  @override
  String get recentlyAddedDescription =>
      'Sorted by when songs entered your library';

  @override
  String get allTime => 'All Time';

  @override
  String get pastWeek => 'Past Week';

  @override
  String get pastMonth => 'Past Month';

  @override
  String get past90Days => 'Past 90 Days';

  @override
  String get noPlayHistory => 'No play history yet';

  @override
  String get noPlayHistoryInRange => 'No play history in this time range';

  @override
  String get noRecentlyPlayedSongs => 'No play history yet';

  @override
  String get noRecentlyPlayedInRange => 'No play history in this time range';

  @override
  String get noRecentlyAddedSongs => 'No songs in your library yet';

  @override
  String get noRecentlyAddedInRange => 'No songs were added in this time range';

  @override
  String get addedOn => 'Added On';

  @override
  String get externalSourceTag => 'External';

  @override
  String get lastPlayed => 'Last played';

  @override
  String playCountLabel(int count) {
    return '$count plays';
  }

  @override
  String get playAll => 'Play All';

  @override
  String get shufflePlay => 'Shuffle Play';

  @override
  String get noAlbums => 'No albums found yet';

  @override
  String get noArtists => 'No artists found yet';

  @override
  String get searchAlbums => 'Search albums or artists';

  @override
  String get searchArtists => 'Search artists';

  @override
  String get albumSort => 'Sort';

  @override
  String get sortArtistAsc => 'Artist A-Z';

  @override
  String get sortTitleAsc => 'Album Title A-Z';

  @override
  String get sortTrackCount => 'Song Count';

  @override
  String get sortDuration => 'Total Duration';

  @override
  String get sortRecentAdded => 'Recently Added';

  @override
  String get sortAscending => 'Ascending';

  @override
  String get sortDescending => 'Descending';

  @override
  String get playNext => 'Play Next';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get viewAlbumDetails => 'View Album Details';

  @override
  String get viewArtistDetails => 'View Artist Details';

  @override
  String get openFileLocation => 'Open File Location';

  @override
  String get copyAlbumTitle => 'Copy Album Title';

  @override
  String get copyArtistName => 'Copy Artist Name';

  @override
  String albumCount(int count) {
    return '$count albums';
  }

  @override
  String get emptyList => 'List is empty';

  @override
  String get dragToAddMusic => 'Drag files or folders to add music';

  @override
  String get unknownAlbum => 'Unknown Album';

  @override
  String get managePlaylists => 'Manage Playlists';

  @override
  String get createNewPlaylist => 'Create New Playlist';

  @override
  String get defaultList => 'Default List';

  @override
  String get playbackMode => 'Playback Mode';

  @override
  String get playbackOptions => 'Playback Options';

  @override
  String get setVisualizerDisplay => 'Set Visualizer Display';

  @override
  String get noPlaybackContent => 'No playback content';

  @override
  String get file => 'File';

  @override
  String get play => 'Play';

  @override
  String get list => 'Library';

  @override
  String get queueTab => 'Queue';

  @override
  String get more => 'More';

  @override
  String get settings => 'Settings';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeModeSystem => 'Follow System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get immersiveTabBar => 'Immersive Tab Bar';

  @override
  String get immersiveTabBarDescription =>
      'Show the navigation bar when the mouse moves, then hide it after 3 seconds of inactivity';

  @override
  String get collapseButtonsInLandscapeLyrics =>
      'Collapse buttons in landscape lyrics mode';

  @override
  String get collapseButtonsInLandscapeLyricsDescription =>
      'Collapse the 7-button row, left-align title, and add action buttons in landscape lyrics mode';

  @override
  String get sampleStride => 'Sample Stride';

  @override
  String get sampleStrideDescription =>
      'Larger values scan faster but with lower waveform precision (default: 4)';

  @override
  String get waveformSegments => 'Waveform Segments';

  @override
  String get waveformSegmentsDescription =>
      'Number of waveform bars to display (default: 80)';

  @override
  String get showDeveloperOptions => 'Show Developer Options';

  @override
  String get playbackBackground => 'Playback Background';

  @override
  String get playbackRadialGradient => 'Center Dark Gradient';

  @override
  String get blurIntensity => 'Blur Intensity';

  @override
  String get blurredArtwork => 'Blurred Artwork (Default)';

  @override
  String get dynamicMesh => 'Dynamic Mesh';

  @override
  String get solidColor => 'Solid Color';

  @override
  String get customImage => 'Custom Image';

  @override
  String get presetColors => 'Preset Colors';

  @override
  String get customColor => 'Custom Color';

  @override
  String get uploadImage => 'Select Image';

  @override
  String get normalOpacity => 'Normal Dark Layer Opacity';

  @override
  String get lyricsOpacity => 'Lyrics Dark Layer Opacity';

  @override
  String get chooseImageError => 'Failed to select image';

  @override
  String get noImageSelected => 'No image selected';

  @override
  String get unknown => 'Unknown';

  @override
  String get playlistModeSingle => 'Single';

  @override
  String get playlistModeSingleLoop => 'Single Loop';

  @override
  String get playlistModeQueue => 'Queue';

  @override
  String get playlistModeQueueLoop => 'Queue Loop';

  @override
  String get playlistModeAutoQueueLoop => 'Auto Queue Loop';

  @override
  String get visualizer => 'Visualizer';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get pause => 'Pause';

  @override
  String get autoMode => 'Auto Mode';

  @override
  String get advancedOptions => 'Advanced Options';

  @override
  String get spectrumQuantity => 'Spectrum Quantity';

  @override
  String get speed => 'Speed';

  @override
  String get quantityHigh => 'High';

  @override
  String get quantityMedium => 'Medium';

  @override
  String get quantityLow => 'Low';

  @override
  String get speedFast => 'Fast';

  @override
  String get speedMedium => 'Medium';

  @override
  String get speedSlow => 'Slow';

  @override
  String get portraitFrequencyGroups => 'Portrait Freq Quantity';

  @override
  String get landscapeFrequencyGroups => 'Landscape Freq Quantity';

  @override
  String get portraitGap => 'Portrait Gap';

  @override
  String get landscapeGap => 'Landscape Gap';

  @override
  String get enableWaveformProgressBar => 'Enable Waveform Progress Bar';

  @override
  String get enableWaveformProgressBarDescription =>
      'Use full-song waveform instead of standard slider';

  @override
  String get waveformLongPressSeekSpeed => 'Long-press Waveform Seek Speed';

  @override
  String get waveformLongPressSeekSpeedDescription =>
      'Playback speed when holding the right side of the waveform progress bar (×)';

  @override
  String get enableWaveformLongPressSeek => 'Enable Long-press Waveform Seek';

  @override
  String get enableWaveformLongPressSeekDescription =>
      'Hold the right side of the waveform progress bar to fast-forward playback';

  @override
  String get randomMode => 'Random Mode';

  @override
  String get randomHistory => 'Random History';

  @override
  String get randomRange => 'Random Range';

  @override
  String get randomMethod => 'Random Method';

  @override
  String get currentQueue => 'Current Queue';

  @override
  String get globalRange => 'Global (All Playlists)';

  @override
  String get completeRandom => 'Complete Random';

  @override
  String get shuffleRandom => 'Shuffle Random';

  @override
  String get randomQueue => 'Random Queue';

  @override
  String get notSelected => 'No Music Selected';

  @override
  String get saveTagsToFile => 'Save Tags to File';

  @override
  String get saveCurrentTagsToFile => 'Save current song tags to file';

  @override
  String get saveQueueTagsToFile => 'Save all queue tags to file';

  @override
  String get tagsSaved => 'Tags saved successfully';

  @override
  String tagsSavedCount(Object count) {
    return 'Tags saved ($count songs)';
  }

  @override
  String get tagsSaveFailed => 'Failed to save tags';

  @override
  String tagsSaveFailedCount(Object count) {
    return 'Failed to save $count songs';
  }

  @override
  String unsupportedFormat(Object count) {
    return '$count songs have unsupported formats (OGG/Opus cannot be saved)';
  }

  @override
  String get unsupportedFormatSingle =>
      'This format (OGG/Opus) does not support saving tags';

  @override
  String get savingTags => 'Saving tags...';

  @override
  String get noModifiedTagsToSave => 'No modified tags to save';

  @override
  String get clearPlaylist => 'Clear List';

  @override
  String get copyTitle => 'Copy Title';

  @override
  String get transcodeAction => 'Transcode';

  @override
  String get transcodeSectionTitle => 'Audio Transcoding';

  @override
  String get transcodeSectionDescription =>
      'Set default output format and quality preset for audio conversion.';

  @override
  String get transcodeDefaultFormat => 'Default Output Format';

  @override
  String get transcodeDefaultQuality => 'Default Quality Preset';

  @override
  String get transcodeTitle => 'Audio Transcode';

  @override
  String transcodeSongCount(int count) {
    return '$count songs';
  }

  @override
  String transcodeCompletedCount(int count) {
    return 'Transcoded $count files';
  }

  @override
  String transcodeCompletedWithFailures(int success, int total, int failed) {
    return 'Transcoded $success / $total files, $failed failed';
  }

  @override
  String get transcodeFailedGeneric => 'Transcode failed';

  @override
  String get transcodePreparing => 'Preparing transcode...';

  @override
  String transcodeProgress(int current, int total) {
    return 'Transcoding $current / $total';
  }

  @override
  String get transcoding => 'Transcoding...';

  @override
  String get startTranscode => 'Start Transcode';

  @override
  String transcodeEngine(Object engine) {
    return 'Engine: $engine';
  }

  @override
  String get transcodeUsingSystemFfmpeg =>
      'Using ffmpeg from your system PATH.';

  @override
  String transcodeUsingCustomFfmpeg(Object path) {
    return 'Using custom ffmpeg: $path';
  }

  @override
  String get transcodeFormat => 'Output Format';

  @override
  String get transcodeQualityPreset => 'Quality Preset';

  @override
  String get transcodeQualityLow => 'Low';

  @override
  String get transcodeQualityMedium => 'Medium';

  @override
  String get transcodeQualityHigh => 'High';

  @override
  String get transcodeQualityExtreme => 'Highest';

  @override
  String get transcodeLosslessPresetHint =>
      'This lossless format does not use quality tiers or bitrate mode.';

  @override
  String get transcodeAdvancedOptions => 'Advanced Options';

  @override
  String get transcodeAdvancedCustomized =>
      'Advanced parameters were customized';

  @override
  String get transcodeAdvancedFollowingPreset =>
      'Advanced parameters follow the current preset';

  @override
  String get transcodeLosslessAdvancedHint =>
      'Only source-preserving options are available for this lossless format.';

  @override
  String get transcodeBitRateInvalid => 'Please enter a valid bitrate';

  @override
  String get transcodeBitRate => 'Bitrate';

  @override
  String get transcodeBitRateMode => 'Bitrate Mode';

  @override
  String get transcodeEncodingEngine => 'Encoding Engine';

  @override
  String get transcodeSystemEncoder => 'Media3 (System)';

  @override
  String get transcodeFfmpegRustEncoder => 'FFmpeg (Rust)';

  @override
  String get transcodeAacEncoder => 'AAC Encoder';

  @override
  String get transcodeSampleRate => 'Sample Rate';

  @override
  String get transcodeChannels => 'Channels';

  @override
  String get transcodeResetToPreset => 'Reset to Current Preset';

  @override
  String get transcodeResetLosslessOptions => 'Reset Lossless Options';

  @override
  String get transcodeOutputDirectory => 'Output Directory';

  @override
  String get transcodeOutputPreview => 'Preview';

  @override
  String get transcodeChooseDirectory => 'Choose Directory';

  @override
  String get transcodeUseSourceDirectory => 'Use Source Directory';

  @override
  String get transcodeKeepSource => 'Keep source';

  @override
  String get transcodeMono => 'Mono';

  @override
  String get transcodeStereo => 'Stereo';

  @override
  String get openFolderLocation => 'Open Folder Location';

  @override
  String get songTagsSavedToSourceFileAndApp =>
      'Song tags saved to the source file and the app';

  @override
  String get songTagsSavedToApp => 'Song tags saved to the app';

  @override
  String get durationZero => '0:00';

  @override
  String get generateLyrics => 'Generate Lyrics';

  @override
  String get generateTimeline => 'Generate Timeline';

  @override
  String get queueGenerateLyrics => 'Queue Lyrics Generation';

  @override
  String get pauseAutoScroll => 'Pause Auto Scroll';

  @override
  String get resumeAutoScroll => 'Resume Auto Scroll';

  @override
  String get translateLyrics => 'Translate Lyrics';

  @override
  String get clearLyricsCache => 'Clear Current Lyrics Cache';

  @override
  String get clearTranslationCache => 'Clear Current Translation Cache';

  @override
  String get requery => 'Requery';

  @override
  String get sleepTimerTitle => 'Sleep Timer';

  @override
  String get sleepTimerDescription =>
      'Choose a countdown and playback will pause when time is up.';

  @override
  String get sleepTimerRunningTitle => 'Sleep Timer Running';

  @override
  String get sleepTimerRunningDescription =>
      'Playback will pause automatically when the countdown ends.';

  @override
  String get sleepTimerStopAfterCurrentSong =>
      'Stop after the last song finishes';

  @override
  String get remainingTime => 'Remaining time';

  @override
  String get startCountdown => 'Start Countdown';

  @override
  String get end => 'End';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get equalizerEnabledStatus => 'High-fidelity adjustment enabled';

  @override
  String get equalizerDisabledStatus => 'Disabled';

  @override
  String get effects => 'Effects';

  @override
  String get playbackSpeed => 'Playback Speed';

  @override
  String get normal => 'Normal';

  @override
  String get bassBoost => 'Bass Boost';

  @override
  String get preampGain => 'Preamp Gain';

  @override
  String get reset => 'Reset';

  @override
  String get close => 'Close';

  @override
  String get timelineAdjustmentTitle => 'Adjust Timeline';

  @override
  String get timelineAdjustmentDescription =>
      'Drag right to delay the lyrics, drag left to make them play earlier.';

  @override
  String timelineOffsetEarlier(Object seconds) {
    return 'Ahead by ${seconds}s';
  }

  @override
  String timelineOffsetLater(Object seconds) {
    return 'Behind by ${seconds}s';
  }

  @override
  String get timelineOffsetCurrent => 'Current offset: 0.0s';

  @override
  String get enterAcoustidApiKeyTitle => 'Enter AcoustID API Key';

  @override
  String get acoustidApiKeyDescription =>
      'Used for audio fingerprinting. Leaving it blank will restore the built-in default key.';

  @override
  String get acoustidApiKeyHint => 'Paste your AcoustID API Key';

  @override
  String get apiKey => 'API Key';

  @override
  String get save => 'Save';

  @override
  String get enterLyricsTitle => 'Enter Lyrics';

  @override
  String get lyricsInputHint =>
      'Paste or type lyrics here. Multiline text is supported.';

  @override
  String get enterGoogleAiStudioApiKeyTitle => 'Enter Google AI Studio API Key';

  @override
  String get googleAiStudioApiKeyDescription =>
      'Used for lyric generation, timeline generation, and translation in Google AI Studio.';

  @override
  String get pasteGoogleAiStudioApiKey => 'Paste Google AI Studio API Key';

  @override
  String get enterOpenRouterApiKeyTitle => 'Enter OpenRouter API Key';

  @override
  String get openRouterApiKeyDescription =>
      'Used for lyric generation and timeline generation in OpenRouter. Translation always uses Gemini.';

  @override
  String get pasteOpenRouterApiKey => 'Paste OpenRouter API Key';

  @override
  String get enterGeminiApiKeyTitle => 'Enter Gemini API Key';

  @override
  String get geminiApiKeyDescription => 'Used for lyric translation.';

  @override
  String get pasteGeminiApiKey => 'Paste Gemini API Key';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get enterApiKey => 'Please enter an API key.';

  @override
  String get testingConnection => 'Testing connection...';

  @override
  String get getKey => 'Get key';

  @override
  String get editSongTagsTitle => 'Edit Song Tags';

  @override
  String get changeArtwork => 'Change Cover';

  @override
  String get clearArtwork => 'Clear Cover';

  @override
  String get editSongTagsDescription =>
      'You can save changes only in the app, or write them back to the source file as well.';

  @override
  String get artistLabel => 'Artist';

  @override
  String get albumLabel => 'Album';

  @override
  String get trackNumberLabel => 'Track Number';

  @override
  String get trackNumberMustBeInteger => 'Track number must be an integer';

  @override
  String get leaveBlankKeepsCurrentValue => 'Leave blank to clear this field';

  @override
  String get currentFileFormatCannotWriteBack =>
      'This file format does not support writing back to the source file. Changes can only be saved in the app.';

  @override
  String get leaveBlankDoesNotClearOriginalValue =>
      'Tip: leaving a field blank will clear its value.';

  @override
  String get saveToApp => 'Save to App';

  @override
  String get saveToSourceFileAndApp => 'Save to Source File and App';

  @override
  String get saveToSourceFileFailed =>
      'Failed to save to the source file. Please make sure the file format supports writing and the file is not in use.';

  @override
  String get fileOccupiedByOtherApp =>
      'The file is occupied by another app and cannot be written';

  @override
  String get saveFailed => 'Save failed. Please try again later.';

  @override
  String apiKeySaved(Object provider) {
    return '$provider API key saved';
  }

  @override
  String get apiKeySavedAcoustid => 'AcoustID API key saved';

  @override
  String get generalSectionTitle => 'Interface & Behavior';

  @override
  String get generalSectionDescription =>
      'Configure appearance, playback interactions, and window system behaviors.';

  @override
  String get uiAppearanceGroup => 'Appearance & Display';

  @override
  String get playbackBehaviorGroup => 'Playback & Interaction';

  @override
  String get systemWindowBehaviorGroup => 'Window & System Behavior';

  @override
  String get interfaceLanguage => 'Interface Language';

  @override
  String get interfaceLanguageDescription =>
      'Select the display language of the application.';

  @override
  String get scanSectionTitle => 'Scanning';

  @override
  String get scanSectionDescription =>
      'These options control how the library scan treats audio files.';

  @override
  String get skipShortAudioDuringScan => 'Skip short audio during scan';

  @override
  String get skipShortAudioDuringScanDescription =>
      'Audio shorter than the threshold will not be added to the library.';

  @override
  String get shortAudioScanThreshold => 'Short audio threshold';

  @override
  String get shortAudioScanThresholdDescription =>
      'Files shorter than this duration will be skipped.';

  @override
  String shortAudioScanThresholdValue(Object seconds) {
    return '$seconds s';
  }

  @override
  String get shortcutSettingsTitle => 'Custom Shortcuts';

  @override
  String get shortcutSettingsDescription =>
      'Click to re-record and save shortcuts for player actions.';

  @override
  String get edit => 'Edit';

  @override
  String get lyricsSectionTitle => 'Lyrics';

  @override
  String get lyricsSectionDescription =>
      'These settings only affect lyric generation and timeline generation.';

  @override
  String get lyricsTranslationTargetLanguageLabel =>
      'Translation target language';

  @override
  String get lyricsTranslationTargetLanguageDescription =>
      'Defaults to the system language, or choose one manually.';

  @override
  String get lyricsSaveMethodLabel => 'Lyric Storage Location';

  @override
  String get lyricsSaveMethodDescription =>
      'Select where lyrics are saved when writing to file.';

  @override
  String get lyricsSaveMethodOriginal => 'As Source';

  @override
  String get lyricsSaveMethodEmbedded => 'Embedded';

  @override
  String get lyricsSaveMethodLrcFile => 'LRC File';

  @override
  String get lyricsStyleLabel => 'Lyric Panel Style';

  @override
  String get lyricsStyleDescription =>
      'Choose the display and interaction style for the lyric panel.';

  @override
  String get lyricsStyleTraditional => 'Traditional';

  @override
  String get lyricsStyleApple => 'Line-by-Line Focus';

  @override
  String get resumeLyricsSync => 'Resume Sync';

  @override
  String get followSystemLanguage => 'Follow system';

  @override
  String get autoSwitchLyricsProvider => 'Auto-switch lyric provider';

  @override
  String get autoSwitchLyricsProviderEnabledDesc =>
      'Google AI Studio is tried first. If both the primary and fallback models fail with 429 or 5xx errors, the app automatically switches to OpenRouter and keeps trying.';

  @override
  String get autoSwitchLyricsProviderDisabledDesc =>
      'You need API keys for both Google AI Studio and OpenRouter before auto-switching can be enabled.';

  @override
  String get lyricsAiProviderTitle => 'Lyrics AI Provider';

  @override
  String get lyricsAiProviderDescription =>
      'This only affects lyric generation and timeline generation. Translation always uses Google AI Studio.';

  @override
  String get googleAiStudioApiKeySaved => 'Google AI Studio API key saved';

  @override
  String get googleAiStudioApiKeyMissing =>
      'No Google AI Studio API key is saved yet. Lyric generation and timeline generation will prompt you first.';

  @override
  String get openRouterApiKeySaved => 'OpenRouter API key saved';

  @override
  String get openRouterApiKeyMissing =>
      'No OpenRouter API key is saved yet. Lyric generation and timeline generation will prompt you first.';

  @override
  String get apiKeySavedStatus => 'Saved';

  @override
  String get apiKeyMissingStatus => 'Not filled';

  @override
  String get platformApiKeysSectionTitle => 'Platform API Keys';

  @override
  String get fill => 'Fill in';

  @override
  String get modify => 'Modify';

  @override
  String get geminiModelsSectionTitle => 'Select Model';

  @override
  String get geminiModelsSectionDescription =>
      'These models are used for lyric generation, timeline generation, and lyric translation in Google AI Studio.';

  @override
  String get primaryModelLabel => 'Primary model';

  @override
  String get backupModelLabel => 'Fallback model';

  @override
  String get translationModelLabel => 'Translation model';

  @override
  String get fetching => 'Fetching...';

  @override
  String get fetchModelList => 'Fetch model list';

  @override
  String get restoreDefault => 'Restore default';

  @override
  String get acoustidSectionTitle => 'Fingerprinting';

  @override
  String get acoustidApiKeyTitle => 'AcoustID API Key';

  @override
  String get acoustidApiKeyHelp =>
      'AcoustID is used for audio fingerprinting. We recommend using your own API key.';

  @override
  String get acoustidApiKeySaved => 'AcoustID API key saved';

  @override
  String get acoustidApiKeyDefault =>
      'The built-in default key is currently in use. We recommend replacing it with your own key.';

  @override
  String get applyForApiKey =>
      'Apply for API key: https://acoustid.org/new-application';

  @override
  String get queueTabBarFavoriteAdded => 'Added to favorites';

  @override
  String get queueTabBarFavoriteRemoved => 'Removed from favorites';

  @override
  String get tagCompletion => 'Tag completion';

  @override
  String get tagCompletionDescription =>
      'Match tags with AcoustID and MusicBrainz results';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get searchReleaseTitles => 'Search release titles';

  @override
  String get closeSearch => 'Close search';

  @override
  String get refreshResults => 'Refresh results';

  @override
  String get filterMusicBrainzReleaseTitle =>
      'Filter MusicBrainz release titles';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get localTitle => 'Local title';

  @override
  String get queryConditions => 'Query conditions';

  @override
  String get musicBrainzLoading => 'MusicBrainz is loading';

  @override
  String get musicBrainzLoadingWithResults =>
      'Existing results will stay in the panel';

  @override
  String get musicBrainzLoadingHint => 'Please wait';

  @override
  String get musicBrainzQueryFailed => 'MusicBrainz query failed';

  @override
  String get musicBrainzNetworkErrorHint =>
      'The request failed, usually because of unstable network, timeout, or server rejection. Try again later.';

  @override
  String get musicBrainzFilteredEmptyHint =>
      'No release titles containing that keyword were found under the current filters.';

  @override
  String get musicBrainzEmptyHint =>
      'MusicBrainz returned no usable results. Try loosening the title, artist, or album filters.';

  @override
  String get musicBrainzEmptyMoreCompleteHint =>
      'Try again later, or confirm the current title or artist info is more complete.';

  @override
  String get retry => 'Retry';

  @override
  String get noMatchingRelease => 'No matching release found';

  @override
  String get noMatchingResults => 'No matching results found';

  @override
  String get networkConnectionFailed => 'Network connection failed';

  @override
  String get searchAgain => 'Search again';

  @override
  String get acoustidRecognitionRecords => 'AcoustID recognition records';

  @override
  String get musicBrainzRecordings => 'MusicBrainz recordings';

  @override
  String get noExpandableReleaseGroups =>
      'No expandable release groups available';

  @override
  String get noExpandableReleases => 'No expandable releases available';

  @override
  String get noMatchingResultHint =>
      'Try again later, or confirm the current title or artist info is more complete.';

  @override
  String releaseCountLabel(int count) {
    return '$count release versions';
  }

  @override
  String recordingCountLabel(int count) {
    return '$count recordings';
  }

  @override
  String trackCountShort(int count) {
    return '$count tracks';
  }

  @override
  String scoreLabel(int score) {
    return 'Score $score';
  }

  @override
  String matchScoreLabel(int score) {
    return 'Match $score%';
  }

  @override
  String get editQueryCondition => 'Edit query condition';

  @override
  String get enterNewQueryText => 'Enter new query text';

  @override
  String get durationLabel => 'Duration';

  @override
  String get customShortcuts => 'Custom Shortcuts';

  @override
  String get pressShortcutCombo => 'Press the shortcut combination';

  @override
  String get clickToRecord => 'Click to record';

  @override
  String get searchingLyrics => 'Searching lyrics';

  @override
  String get noLyrics => 'No lyrics yet';

  @override
  String get providerLabel => 'Provider';

  @override
  String get modelLabel => 'Model';

  @override
  String get unspecified => 'Not specified';

  @override
  String targetTimeLabel(String duration) {
    return 'Target time $duration';
  }

  @override
  String get songDeletedSkipped => 'Song deleted, skipped';

  @override
  String get songDeleted => 'Song deleted';

  @override
  String get lyricsTaskUploading => 'Uploading';

  @override
  String get lyricsTaskWaiting => 'Waiting';

  @override
  String get lyricsTaskRequesting => 'Requesting';

  @override
  String get lyricsTaskGenerating => 'Generating';

  @override
  String get lyricsTaskRetrying => 'Retrying';

  @override
  String get lyricsTaskProcessing => 'Processing';

  @override
  String get unknownModel => 'Unknown model';

  @override
  String selectedFolders(int count) {
    return '$count folders selected';
  }

  @override
  String foldersDeleted(int count) {
    return '$count folders deleted';
  }

  @override
  String get persistentAccessDenied =>
      'Could not save access to that folder. Please select it again.';

  @override
  String get folderAddFailed => 'Failed to add the folder';

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String sleepTimerRemaining(Object duration) {
    return 'Sleep timer $duration';
  }

  @override
  String get unknownArtistOrAlbum => 'Unknown';

  @override
  String get pressAgainToExit => 'Press again to exit';

  @override
  String get tagCompletionSuccessWithCover =>
      'Tags completed and saved, cover downloaded to temporary directory';

  @override
  String get tagCompletionSuccess => 'Tags completed and saved';

  @override
  String get selectOnlineLyrics => 'Select online lyrics';

  @override
  String get increaseLyricsFont => 'Increase lyrics font';

  @override
  String get decreaseLyricsFont => 'Decrease lyrics font';

  @override
  String get restoreDefaultSize => 'Restore default size';

  @override
  String get adjustLyricsFont => 'Adjust Text Size';

  @override
  String get searchingOnlineLyrics => 'Searching online lyrics';

  @override
  String get onlineLyricsResults => 'Online Lyrics Results';

  @override
  String get untitledLyrics => 'Untitled lyrics';

  @override
  String get hasTimeline => 'With timeline';

  @override
  String get viewLyricsDetails => 'View lyrics details';

  @override
  String get lyricsDetails => 'Lyrics details';

  @override
  String get lyricsContent => 'Lyrics content';

  @override
  String get noLyricsContent => 'No lyrics content';

  @override
  String get queryContentLabel => 'Content';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String dropAddedSongs(int addedCount) {
    return 'Added $addedCount songs';
  }

  @override
  String dropAddedSongsWithExisting(int addedCount, int existingCount) {
    return 'Added $addedCount songs, $existingCount already existed';
  }

  @override
  String get copyCover => 'Copy Cover to Clipboard';

  @override
  String get copyCoverSuccess => 'Cover copied to clipboard';

  @override
  String get searchLyricsPlaceholder =>
      'Enter song title, artist, or lyrics to search';

  @override
  String get share => 'Share';

  @override
  String get windowsSettingsTitle => 'Windows Settings';

  @override
  String get fileAssociationTitle => 'File Association';

  @override
  String get fileAssociationDescription =>
      'Associate common music formats (mp3, flac, wav, etc.) with this app to open them by double-clicking.';

  @override
  String get associateButton => 'Associate';

  @override
  String get disassociateButton => 'Remove';

  @override
  String get associationSuccess =>
      'Association successful! If double-clicking doesn\'t work, please select Vynody in Windows Default Apps settings.';

  @override
  String get disassociationSuccess => 'File association removed successfully.';

  @override
  String associationFailed(Object error) {
    return 'Failed to associate: $error';
  }

  @override
  String get onboardingTitle => 'Welcome to Vynody';

  @override
  String get onboardingSubtitle =>
      'Just a few simple steps to start your music journey.';

  @override
  String get onboardingStepFileAssociation => 'Associate File Types';

  @override
  String get onboardingFileAssociationDesc =>
      'Associate common music formats (mp3, flac, wav, etc.) with Vynody to play music by double-clicking them in file explorer.';

  @override
  String get onboardingFileAssociationTip =>
      'After associating, the system may pop up an \'Open with\' selection menu. Please make sure to choose \'Vynody\' from the list and select \'Always use this app\'.';

  @override
  String get onboardingStepRootDirectory => 'Add Music Root Directory';

  @override
  String get onboardingRootDirectoryDesc =>
      'Select the folder where your music files are stored. Vynody will scan and build your personal music library automatically.';

  @override
  String get onboardingAndroidPermissionTip =>
      'Note: On Android, importing and scanning local music requires granting media library access permission. Tapping [Select Folder] will prompt for permission, please allow it.';

  @override
  String get onboardingSelectDirectory => 'Select Folder';

  @override
  String get onboardingSuccessTitle => 'All Set!';

  @override
  String get onboardingSuccessDesc =>
      'Successfully added your media library. Let\'s start enjoying music!';

  @override
  String get onboardingStartButton => 'Get Started';

  @override
  String get onboardingSkip => 'Set Up Later';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingBack => 'Back';

  @override
  String get resetOnboarding => 'Reset Onboarding';

  @override
  String get resetOnboardingDesc =>
      'Clear the onboarding status. The welcome guide will be shown again on next startup.';

  @override
  String get songProperties => 'Song Properties';

  @override
  String get failedToLoadDetails => 'Failed to load details';

  @override
  String get noPropertiesAvailable => 'No properties available';

  @override
  String get detailFilePath => 'File Path';

  @override
  String get detailFormat => 'Format';

  @override
  String get detailCodec => 'Codec';

  @override
  String get detailDuration => 'Duration';

  @override
  String get detailFileSize => 'File Size';

  @override
  String get detailBitrate => 'Bitrate';

  @override
  String get detailSampleRate => 'Sample Rate';

  @override
  String get detailChannels => 'Channels';

  @override
  String get detailBitDepth => 'Bit Depth';

  @override
  String get detailMono => 'Mono';

  @override
  String get detailStereo => 'Stereo';

  @override
  String detailChannelsCount(int count) {
    return '$count Channels';
  }

  @override
  String get localNetworkPermissionDeniedTitle =>
      'Local Network Access Restricted';

  @override
  String get localNetworkPermissionDeniedMessage =>
      'No available local network IP address detected, or local network permission was denied.\n\nPlease check the following:\n1. Make sure your device is connected to a Wi-Fi or local network.\n2. Ensure the app has permission to access the local network in system settings:\n   - iOS/macOS: Go to system Settings > Privacy & Security > Local Network, and turn on the switch for Vynody.\n   - Windows: Make sure you are connected, and verify that Windows Firewall allows Vynody to access the network.';

  @override
  String get localNetworkPermissionWindowsMessage =>
      'No available local network IP address detected.\n\nPlease check the following:\n1. Make sure your device is connected to a local network (Wi-Fi or Ethernet).\n2. If connected but the error persists, check Windows Firewall settings to ensure Vynody is allowed through the firewall.';

  @override
  String get openSettingsButton => 'Open Settings';

  @override
  String get closeButton => 'Close';

  @override
  String get copyTranslationResults => 'Copy translation results';

  @override
  String get writeLyricsToFile => 'Write lyrics to file';

  @override
  String get selectLyricSource => 'Select lyric source';

  @override
  String get regenerateLyrics => 'Regenerate Lyrics';

  @override
  String get regenerateLyricsConfirmation =>
      'This will clear the current lyrics and regenerate. Continue?';

  @override
  String get regenerateTimeline => 'Regenerate Timeline';

  @override
  String get regenerateTimelineConfirmation =>
      'This will clear the current timeline and regenerate. Continue?';

  @override
  String get retranslateLyrics => 'Re-translate Lyrics';

  @override
  String get retranslateLyricsConfirmation =>
      'This will clear the current translation and re-translate. Continue?';

  @override
  String get translationCopiedToClipboard =>
      'Translation results copied to clipboard';

  @override
  String get writingLyrics => 'Writing lyrics...';

  @override
  String get lyricsWrittenToFile => 'Lyrics written to file successfully';

  @override
  String get writeLyricsFailed => 'Failed to write lyrics';

  @override
  String get externalLrcFile => 'External LRC file';

  @override
  String get embeddedLyrics => 'Embedded lyrics';

  @override
  String get manuallyAdjustedLyrics => 'Manually adjusted lyrics';

  @override
  String get lrclibOnlineLyrics => 'LrcLib online lyrics';

  @override
  String get aiGeneratedLyrics => 'AI generated lyrics';

  @override
  String get matchScore => 'Match';

  @override
  String get untitledRelease => 'Untitled Release';

  @override
  String get localSongFileNotFoundForGeneration =>
      'The local song file does not exist, so lyrics cannot be generated.';

  @override
  String get localSongFileNotFoundForTimeline =>
      'The local song file does not exist, so a timeline cannot be generated.';

  @override
  String get noLyricsForTimelineGeneration =>
      'No lyrics available for timeline generation.';

  @override
  String get noLyricsAvailableForTranslation =>
      'No lyrics are available for translation.';

  @override
  String get noCurrentSongAvailable => 'No current song available.';

  @override
  String get invalidTargetLanguage => 'Invalid target language.';

  @override
  String get songAlreadyQueuedForTranslation =>
      'The current song is already queued for translation.';

  @override
  String get songAlreadyQueuedForGeneration =>
      'The current song is already queued for lyrics generation.';

  @override
  String get songNoLongerExistsForTranslation =>
      'The current song no longer exists, so lyrics cannot be translated.';

  @override
  String get generationFailed => 'Generation failed.';

  @override
  String get generatingLyrics => 'Generating lyrics';

  @override
  String get generatingTimeline => 'Generating timeline';

  @override
  String get regeneratingLyrics => 'Regenerating lyrics';

  @override
  String get translatingLyrics => 'Translating lyrics';

  @override
  String get transcodingSongFile => 'Transcoding song file';

  @override
  String get uploadingSongFile => 'Uploading song file';

  @override
  String get fileUploadedWaitingForReadiness =>
      'File uploaded, waiting for readiness';

  @override
  String get waitingForFileReadiness => 'Waiting for file readiness';

  @override
  String get requestingModelResponse => 'Requesting model response';

  @override
  String retryingTaskKindGeneration(Object taskKind) {
    return 'Retrying $taskKind generation';
  }

  @override
  String get retrying => 'Retrying';

  @override
  String get processing => 'Processing';

  @override
  String get timeline => 'timeline';

  @override
  String get lyrics => 'lyrics';

  @override
  String lyricGenerationError(Object error) {
    return 'An error occurred while generating lyrics: $error';
  }

  @override
  String timelineGenerationError(Object error) {
    return 'An error occurred while generating the timeline: $error';
  }

  @override
  String get unknownGenerationError =>
      'An unknown error occurred while generating lyrics.';

  @override
  String get unknownTimelineGenerationError =>
      'An unknown error occurred while generating the timeline.';

  @override
  String get unknownTranslationError =>
      'An unknown error occurred while translating lyrics.';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get modelRefusedToGenerateLyrics =>
      'The model refused to generate lyrics.';

  @override
  String get modelRefusedToGenerateTimeline =>
      'The model refused to generate the timeline.';

  @override
  String get doubaoPreUploadTranscodingFailed =>
      'Audio transcoding failed before Doubao upload.';

  @override
  String get doubaoTempTranscodeNotInTempDir =>
      'The temporary transcoded file was not created in the temp directory.';

  @override
  String get doubaoEmptyStreamingResponse =>
      'Doubao returned an empty streaming response.';

  @override
  String get doubaoEmptyResponse => 'Doubao returned an empty response.';

  @override
  String get geminiEmptyStreamingResponse =>
      'Gemini returned an empty streaming response.';

  @override
  String get geminiEmptyResponse => 'Gemini returned an empty response.';

  @override
  String get openRouterEmptyStreamingResponse =>
      'OpenRouter returned an empty streaming response.';

  @override
  String get openRouterEmptyResponse =>
      'OpenRouter returned an empty response.';

  @override
  String get deepseekEmptyStreamingResponse =>
      'DeepSeek returned an empty streaming response.';

  @override
  String get deepseekEmptyResponse => 'DeepSeek returned an empty response.';

  @override
  String get customProviderEmptyStreamingResponse =>
      'Custom provider returned an empty streaming response.';

  @override
  String get customProviderEmptyResponse =>
      'Custom provider returned an empty response.';

  @override
  String get fileUploadFailed => 'File upload failed. Please try again.';

  @override
  String get uploadedFileNotReady =>
      'The uploaded file did not become ready. Please try again later.';

  @override
  String get audioTranscodingFailed => 'Audio transcoding failed.';

  @override
  String get tempTranscodeNotInTempDir =>
      'The temporary transcoded file was not created in the temp directory.';

  @override
  String get networkRequestFailedCheckProxy =>
      'Network request failed. Please check your network and proxy settings.';

  @override
  String get quotaExhaustedToday =>
      'Today\'s quota has been exhausted. Please try again after it resets tomorrow.';

  @override
  String get googleAiHeavyLoad =>
      'Google AI is under heavy load and is temporarily unavailable.';

  @override
  String lyricsGenerationFailedWithError(Object error) {
    return 'Lyrics generation failed: $error';
  }

  @override
  String missingApiKeyForAction(Object action, Object providerName) {
    return 'API key for $providerName was not found, so $action is unavailable.';
  }

  @override
  String get googleServerFlaky =>
      'Google is having a rough moment. Please try again and it may succeed.';

  @override
  String get translateLyricsAction => 'translate lyrics';

  @override
  String get generateLyricsAction => 'generate lyrics';

  @override
  String get generateTimelineAction => 'generate timeline';

  @override
  String get deepseekOnlyTranslation =>
      'DeepSeek is only available for lyric translation.';

  @override
  String get customProviderOnlyTranslation =>
      'Custom provider is only available for lyric translation.';

  @override
  String get customProviderNoBaseUrl =>
      'Custom provider base URL is not configured.';

  @override
  String get pleaseEnterApiKey => 'Please enter an API key.';

  @override
  String get connectionSuccessVerificationPassed =>
      'Connection successful, verification passed.';

  @override
  String connectionSuccessDetectedModels(Object count) {
    return 'Connection successful, detected $count models.';
  }

  @override
  String testFailedWithStatus(Object message, Object statusCode) {
    return 'Test failed ($statusCode): $message';
  }

  @override
  String get testFailedCheckNetworkOrApiKey =>
      'Test failed. Please check your network or API key.';

  @override
  String testFailedStatusCheckApiKey(Object statusCode) {
    return 'Test failed ($statusCode). Please check whether the API key is valid.';
  }

  @override
  String get enterGoogleAiStudioApiKeyFirst =>
      'Please enter a Google AI Studio API key first.';

  @override
  String get enterDoubaoApiKeyFirst => 'Please enter a Doubao API key first.';

  @override
  String get enterDeepseekApiKeyFirst =>
      'Please enter a DeepSeek API key first.';

  @override
  String get enterCustomApiKeyAndBaseUrl =>
      'Please enter the custom API key and base URL first.';

  @override
  String fetchedCountModels(Object count) {
    return 'Fetched $count models.';
  }

  @override
  String requestFailedWithStatus(Object message, Object statusCode) {
    return 'Request failed ($statusCode): $message';
  }

  @override
  String get requestFailedCheckNetwork => 'Request failed. Check your network.';

  @override
  String requestFailedStatus(Object statusCode) {
    return 'Request failed ($statusCode).';
  }

  @override
  String get doubao => 'Doubao';

  @override
  String get custom => 'Custom';

  @override
  String get noModelSelected => 'No model selected';

  @override
  String get acoustidRequestFailed => 'AcoustID request failed';

  @override
  String acoustidRequestReturnedStatus(Object statusCode) {
    return 'AcoustID request returned $statusCode. Please apply for your own AcoustID API key and fill it in settings.';
  }

  @override
  String get writeTagDatabaseFailed => 'Failed to write tag database';

  @override
  String get playPause => 'Play / Pause';

  @override
  String get nextTrack => 'Next';

  @override
  String get previousTrack => 'Previous';

  @override
  String get volumeUp => 'Volume Up';

  @override
  String get volumeDown => 'Volume Down';

  @override
  String get toggleMute => 'Toggle Mute';

  @override
  String get seekForward5s => 'Seek Forward 5s';

  @override
  String get seekBackward5s => 'Seek Backward 5s';

  @override
  String get toggleFullScreen => 'Toggle Full Screen';

  @override
  String get playPauseDescription => 'Control the current playback state.';

  @override
  String get nextDescription => 'Skip to the next song.';

  @override
  String get previousDescription => 'Go back to the previous song.';

  @override
  String get volumeUpDescription => 'Increase volume by 5% each time.';

  @override
  String get volumeDownDescription => 'Decrease volume by 5% each time.';

  @override
  String get toggleMuteDescription => 'Toggle mute.';

  @override
  String get seekForward5sDescription => 'Seek forward 5 seconds.';

  @override
  String get seekBackward5sDescription => 'Seek backward 5 seconds.';

  @override
  String get toggleFullScreenDescription =>
      'Switch between windowed mode and full screen.';

  @override
  String get unknownKey => 'Unknown key';

  @override
  String get removeFromQueue => 'Remove from Queue';

  @override
  String get removeFromPlaylist => 'Remove from Playlist';

  @override
  String get alreadyLatestVersion => 'You are already on the latest version.';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String newVersionAvailable(Object version) {
    return 'A new version v$version is available. Download from the GitHub Release page.';
  }

  @override
  String get openRelease => 'Open Release';

  @override
  String get checkUpdateFailedNetwork =>
      'Failed to check for updates. It may be a network issue or GitHub rate limit.';

  @override
  String get tags => 'Tags';

  @override
  String get about => 'About';

  @override
  String get rebuildIndex => 'Rebuild Index';

  @override
  String get rebuildIndexDescription =>
      'Clear all song records (except external sources) and rescan all root directories.';

  @override
  String get rebuildIndexConfirmation =>
      'Are you sure you want to clear all song records (except external sources) and re-scan all root directories? This process may take some time.';

  @override
  String get rebuildIndexStarted => 'Rebuild index started';

  @override
  String get rebuild => 'Rebuild';

  @override
  String get advanced => 'Advanced';

  @override
  String get advancedOptionsDescription =>
      'Options for debugging and behavior tuning.';

  @override
  String get showDeveloperOptionsDescription =>
      'Show more advanced options intended for debugging.';

  @override
  String get onboardingReset =>
      'Onboarding has been reset. It will take effect on next startup.';

  @override
  String get tagsSectionDescription =>
      'Configure audio file metadata and auto-completion.';

  @override
  String get autoSaveToSourceFile => 'Auto-save to Source File';

  @override
  String get autoSaveToSourceFileDescription =>
      'Automatically write tags back to the physical audio file when completed.';

  @override
  String get aboutSectionDescription =>
      'Version info, project links, and related info.';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get storeUpdateNotice =>
      'Updates for this app are managed by Microsoft Store. You can check for or get the latest version in Microsoft Store.';

  @override
  String get openMicrosoftStore => 'Go to Microsoft Store';

  @override
  String get appStoreUpdateNotice =>
      'Updates for this app are managed by App Store. You can visit App Store to check for or get the latest version.';

  @override
  String get openAppStore => 'Go to App Store';

  @override
  String get lyricsGenerationModel => 'Lyrics Generation Model';

  @override
  String get lyricsGenerationModelDescription =>
      'Used for AI-generated lyrics and timeline generation/correction.';

  @override
  String get lyricsTranslationModel => 'Lyrics Translation Model';

  @override
  String get lyricsTranslationModelDescription =>
      'Used for translating lyrics to the target language.';

  @override
  String get onlyForLyricTranslation => 'Only for lyric translation';

  @override
  String get fillApiKeyFirstEnablesModels =>
      'Please fill in at least one API key to enable model selection.';

  @override
  String get customApiProvider => 'Custom API Provider';

  @override
  String get clearedGoogleAiStudioApiKey => 'Cleared Google AI Studio API Key';

  @override
  String get clearedOpenRouterApiKey => 'Cleared OpenRouter API Key';

  @override
  String get clearedDoubaoApiKey => 'Cleared Doubao API Key';

  @override
  String get clearedDeepseekApiKey => 'Cleared DeepSeek API Key';

  @override
  String get clearedCustomProviderConfig =>
      'Cleared custom provider configuration';

  @override
  String get savedDoubaoApiKey => 'Saved Doubao API Key';

  @override
  String get savedDeepseekApiKey => 'Saved DeepSeek API Key';

  @override
  String get savedCustomProviderConfig => 'Saved custom provider configuration';

  @override
  String get noMatchingFoldersOrSongs => 'No matching folders or songs found';

  @override
  String get searching => 'Searching...';

  @override
  String get listView => 'List View';

  @override
  String get gridView => 'Grid View';

  @override
  String get hybridView => 'Hybrid View';

  @override
  String songsCountFormat(Object count) {
    return '$count songs';
  }

  @override
  String get searchInFolderAndSubfolders =>
      'Search in folder and subfolders...';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get search => 'Search';

  @override
  String get selectFolders => 'Select Folders';

  @override
  String get removeDirectory => 'Remove Directory';

  @override
  String removeRootDirectoryConfirmation(Object name) {
    return 'Are you sure you want to remove the root directory \"$name\"? This will not delete physical files on disk.';
  }

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get favorites => 'Favorites';

  @override
  String get aggregationPeak => 'Peak';

  @override
  String get aggregationMean => 'Mean';

  @override
  String get aggregationRms => 'RMS';

  @override
  String get filesToTranscode => 'Files to Transcode';

  @override
  String get chooseAndroidOutputDirectoryFirst =>
      'Please choose an Android output directory first.';

  @override
  String currentSongProgressPercent(Object percent) {
    return 'Current song $percent%';
  }

  @override
  String overallProgressPercent(Object percent) {
    return 'Overall $percent%';
  }

  @override
  String get pleaseChooseOutputDirectory =>
      'Please choose an output directory.';

  @override
  String selectedArtistsCount(Object count) {
    return 'Selected $count artists';
  }

  @override
  String selectedAlbumsCount(Object count) {
    return 'Selected $count albums';
  }

  @override
  String get simplifiedChinese => 'Simplified Chinese';

  @override
  String get traditionalChinese => 'Traditional Chinese';

  @override
  String get chineseLanguage => 'Chinese';

  @override
  String get englishLanguage => 'English';

  @override
  String get japaneseLanguage => 'Japanese';

  @override
  String get koreanLanguage => 'Korean';

  @override
  String get frenchLanguage => 'French';

  @override
  String get germanLanguage => 'German';

  @override
  String get spanishLanguage => 'Spanish';

  @override
  String get nativeLanguageZh => '简体中文';

  @override
  String get nativeLanguageZhHant => '繁體中文';

  @override
  String get nativeLanguageEn => 'English';

  @override
  String get nativeLanguageJa => '日本語';

  @override
  String get nativeLanguageKo => '한국어';

  @override
  String get nativeLanguageFr => 'Français';

  @override
  String get nativeLanguageDe => 'Deutsch';

  @override
  String get nativeLanguageEs => 'Español';

  @override
  String get portugueseLanguage => 'Portuguese';

  @override
  String get russianLanguage => 'Russian';

  @override
  String get systemLanguage => 'System language';

  @override
  String get targetLanguage => 'Target language';

  @override
  String get whatAreAiLyrics => 'What are AI lyrics?';

  @override
  String get whatIsAiLyricTranslation => 'What is AI lyric translation?';

  @override
  String get aiLyricsIntroGeneration =>
      'AI can generate lyrics from the song and align them to a timeline.';

  @override
  String get aiLyricsIntroTranslation =>
      'AI can translate lyrics into your preferred language so the song is easier to understand.';

  @override
  String get whyNeedApiKey => 'Why do I need an API key?';

  @override
  String get apiKeyExplanation =>
      'An API key is your access credential for an AI provider. The app uses it to send requests directly for lyric generation, timeline adjustment, or translation.';

  @override
  String get apiKeyLocalOnly =>
      'Your API key is stored only on this device and is never uploaded to Vynody developer servers.';

  @override
  String get chooseAnAiProvider => 'Choose an AI provider:';

  @override
  String get googleProviderPros =>
      'Official Google channel with strong Gemini models and generous free quotas.';

  @override
  String get googleProviderCons =>
      'High traffic can occasionally cause 429 errors. If that happens, switch to another provider.';

  @override
  String get openRouterProviderPros =>
      'A model aggregator with access to many providers and some free models.';

  @override
  String get openRouterProviderCons =>
      'Top-ups may include processing fees, and the website is English-only.';

  @override
  String get doubaoProviderPros =>
      'Built by ByteDance, strong for Chinese text. New users get 500k free tokens per model.';

  @override
  String get doubaoProviderCons =>
      'Registration is relatively involved and requires real-name verification.';

  @override
  String get deepseekProviderPros =>
      'Good Chinese understanding, low pricing, and well suited for lyric translation.';

  @override
  String get deepseekProviderCons =>
      'Text input only. Lyric generation and timeline adjustment require an API key from another provider.';

  @override
  String get highlights => 'Highlights';

  @override
  String get notes => 'Notes';

  @override
  String enterProviderApiKey(Object provider) {
    return 'Enter your $provider API key:';
  }

  @override
  String get pasteYourApiKey => 'Paste your API key here';

  @override
  String get getApiKey => 'Get API key';

  @override
  String get testConnectionButton => 'Test connection';

  @override
  String get enableAiLyricGeneration => 'Enable AI Lyric Generation';

  @override
  String get enableAiLyricTranslation => 'Enable AI Lyric Translation';

  @override
  String get notNow => 'Not now';

  @override
  String get startSetup => 'Start setup';

  @override
  String get chooseAiProvider => 'Choose AI Provider';

  @override
  String get backStep => 'Back';

  @override
  String get continueAction => 'Continue';

  @override
  String get nextStep => 'Next';

  @override
  String get configureApiKey => 'Configure API Key';

  @override
  String get saveAndFinish => 'Save and finish';

  @override
  String get testing => 'Testing...';

  @override
  String get noteTitle => 'Note';

  @override
  String get deepseekTextInputOnlyNote =>
      'DeepSeek supports text input only. Lyric generation and timeline adjustment require an API key from another provider.';

  @override
  String retryAttemptOfMax(Object attempt, Object maxRetry) {
    return 'Retry $attempt / $maxRetry';
  }

  @override
  String generatingTaskKind(Object taskKind) {
    return 'Generating $taskKind';
  }

  @override
  String connectionTestException(Object error) {
    return 'Connection test error: $error';
  }

  @override
  String get testingConnectionProgress => 'Testing connection...';

  @override
  String get clear => 'Clear';

  @override
  String get enterDoubaoApiKey => 'Enter Doubao API Key';

  @override
  String get doubaoApiKeyDescription =>
      'Please enter your Volcano/Doubao API key for lyric generation and translation.';

  @override
  String get enterDeepseekApiKey => 'Enter DeepSeek API Key';

  @override
  String get deepseekApiKeyDescription =>
      'Please enter your DeepSeek API key for lyric translation only.';

  @override
  String get pleaseEnterApiKeyHint => 'Please enter API key';

  @override
  String get platform => 'Platform';

  @override
  String get showRecommendedOnly => 'Show recommended only';

  @override
  String get noAvailableChannels => 'No available channels';

  @override
  String get noMatchingModels => 'No matching models found';

  @override
  String get leaveEmpty => 'Leave empty';

  @override
  String get leaveEmptyFallbackDescription =>
      'Select this to not set a backup model.';

  @override
  String get modelSearchHint => 'Enter model name, ID';

  @override
  String sendFilesFailed(Object error) {
    return 'Failed to send files: $error';
  }

  @override
  String get scanningFolderMusic => 'Scanning folder for music files...';

  @override
  String scanFolderFailed(Object error) {
    return 'Failed to scan folder: $error';
  }

  @override
  String get noMusicFilesFound =>
      'No supported music files found in this folder';

  @override
  String sendFolderFailed(Object error) {
    return 'Failed to send folder: $error';
  }

  @override
  String get lanSharingStartFailed =>
      'LAN sharing failed to start. Please check local network permissions.';

  @override
  String syncingLyricsToDevice(Object deviceName) {
    return 'Syncing lyrics to $deviceName...';
  }

  @override
  String syncLyricsSuccess(Object matched, Object overwritten, Object skipped) {
    return 'Sync complete: $matched matched, $overwritten updated, $skipped skipped';
  }

  @override
  String syncLyricsFailed(Object error) {
    return 'Failed to sync lyrics: $error';
  }

  @override
  String syncingLyricsFromDevice(Object deviceName) {
    return 'Syncing lyrics from $deviceName...';
  }

  @override
  String get transferInProgressDoNotLeave =>
      'Transfer in progress, please do not leave the sharing page';

  @override
  String get lanSharingTitle => 'LAN Connect';

  @override
  String get lanSharingEnabledStatus => 'LAN sharing is enabled';

  @override
  String get lanSharingDisabledStatus => 'LAN sharing is disabled';

  @override
  String lanSharingRunningStatus(Object ip, Object port) {
    return 'Local IP: $ip (Port: $port)';
  }

  @override
  String get lanSharingDefaultOffHint =>
      'Disabled by default. Enabling will request local network permission.';

  @override
  String get receiveDirectoryNotSetWarning =>
      'A receive directory must be set to receive files. Please set one.';

  @override
  String receiveDirectoryUpdated(Object path) {
    return 'Receive directory updated to: $path';
  }

  @override
  String get receiveDirectoryTitle => 'Receive Directory';

  @override
  String get linkCopiedToClipboard => 'Link copied to clipboard';

  @override
  String get nearbyDevices => 'Nearby Devices';

  @override
  String get searchingDevices => 'Searching for other devices on the LAN...';

  @override
  String get startSharingToFindDevices => 'Enable sharing to discover devices';

  @override
  String get deviceOnline => 'Online';

  @override
  String get deviceOffline => 'Offline';

  @override
  String get sendMusicFiles => 'Send Music Files';

  @override
  String get sendFolder => 'Send Folder';

  @override
  String get syncLyricsToDeviceAction => 'Sync Lyrics to Device';

  @override
  String get syncLyricsFromDeviceAction => 'Sync Lyrics from Device';

  @override
  String loadDevicesError(Object error) {
    return 'Failed to load devices: $error';
  }

  @override
  String incomingFilesFormat(Object name1, Object name2, Object count) {
    return '$name1, $name2 and $count other files';
  }

  @override
  String get incomingTransferRequestTitle => 'Incoming File Transfer Request';

  @override
  String incomingTransferFrom(Object senderName) {
    return 'Request from \"$senderName\":';
  }

  @override
  String fileSizeMb(Object sizeMb) {
    return 'File size: $sizeMb MB';
  }

  @override
  String get receiveFileHint =>
      'Received files will be saved to the music folder and added to the library.';

  @override
  String get reject => 'Reject';

  @override
  String get accept => 'Accept';

  @override
  String get incomingLyricsExportTitle => 'Lyrics Export Request';

  @override
  String incomingLyricsExportFrom(Object senderName) {
    return 'Device \"$senderName\" requested to read and export your lyrics library.';
  }

  @override
  String get incomingLyricsImportTitle => 'Lyrics Import Request';

  @override
  String incomingLyricsImportFrom(Object senderName, Object count) {
    return 'Device \"$senderName\" requested to import lyrics for $count songs into your device.';
  }

  @override
  String get lyricsRequestRejected =>
      'The remote device rejected the lyrics sync request.';

  @override
  String sendCompleted(Object fileName) {
    return '\"$fileName\" sent';
  }

  @override
  String receiveCompleted(int count) {
    return 'Successfully received $count songs';
  }

  @override
  String transferCancelledWithReason(Object direction, Object reason) {
    return '$direction cancelled ($reason)';
  }

  @override
  String transferFailedFormat(Object direction, Object fileName) {
    return '$direction \"$fileName\" failed';
  }

  @override
  String sendingToDevice(Object deviceName) {
    return 'Sending to $deviceName';
  }

  @override
  String receivingFromDevice(Object deviceName) {
    return 'Receiving from $deviceName';
  }

  @override
  String progressFormat(Object percent) {
    return 'Progress: $percent%';
  }

  @override
  String get currentlyTransferring => 'Currently Transferring';

  @override
  String get fileConflictTitle => 'File Conflict';

  @override
  String get fileConflictMessage =>
      'A file with the same name already exists on the target device:';

  @override
  String get fileConflictChooseAction => 'Please choose an action:';

  @override
  String get skipAction => 'Skip';

  @override
  String get overwriteAction => 'Overwrite';

  @override
  String get skipAllAction => 'Skip All';

  @override
  String get overwriteAllAction => 'Overwrite All';

  @override
  String get sendDirection => 'Send';

  @override
  String get receiveDirection => 'Receive';

  @override
  String get fileAssociationEnabled => 'Associated';

  @override
  String get fileAssociationDisabled => 'Not Associated';

  @override
  String get windowsAutoRepairShortcut => 'Auto-repair Start Menu Shortcut';

  @override
  String get windowsAutoRepairShortcutDescription =>
      'Automatically check and create the Start Menu shortcut on each startup to display the correct media control name and icon';

  @override
  String get confirmDisableShortcutRepair => 'Disable this feature?';

  @override
  String get confirmDisableShortcutRepairContent =>
      'Without the Start Menu shortcut, Windows media controls may display the app as \"Unknown\" and show no icon. Are you sure you want to disable this?';

  @override
  String get confirmDisable => 'Disable';

  @override
  String get enableSystemTray => 'Enable System Tray';

  @override
  String get enableSystemTrayDescription =>
      'Show icon in the system tray for quick playback control';

  @override
  String get closeToTray => 'Minimize to Tray on Close';

  @override
  String get closeToTrayDescription =>
      'Keep the app running in the background when closing the main window';

  @override
  String get closeWindowActionTitle => 'When closing window';

  @override
  String get closeWindowActionDescription =>
      'Choose what happens when clicking the close button';

  @override
  String get closeWindowActionAsk => 'Always ask';

  @override
  String get closeWindowActionMinimize => 'Minimize to system tray';

  @override
  String get closeWindowActionExit => 'Exit application';

  @override
  String get closeWindowActionRemember =>
      'Remember my choice and don\'t ask again';

  @override
  String get closeWindowActionTrayDisabledTip =>
      '(System tray must be enabled)';

  @override
  String get closeWindowDialogTitle => 'Close Window';

  @override
  String get closeWindowDialogContent =>
      'Please select what should happen when clicking the close button:';

  @override
  String get googleAiStudioApiKey => 'Google AI Studio API Key';

  @override
  String get openRouterApiKey => 'OpenRouter API Key';

  @override
  String get doubaoApiKey => 'Doubao API Key';

  @override
  String get deepseekApiKey => 'DeepSeek API Key';

  @override
  String get unexpectedResponseFormat => 'Unexpected response format.';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get openaiCompatibleEndpoint => 'OpenAI-compatible API endpoint';

  @override
  String onboardingAddedDirectoriesCount(Object count) {
    return 'Added directories ($count):';
  }

  @override
  String get gnomeDisksOpenFailed =>
      'Failed to open Disk Utility automatically. Please open \"Disks\" manually from your application menu.';

  @override
  String get gnomeDisksNotInstalled =>
      'gnome-disks is not installed. Please open your system\'s disk utility to configure.';

  @override
  String get linuxMountGuideTitle => 'Configure Disk Auto-Mount';

  @override
  String get linuxMountGuideDescription =>
      'By default, Linux does not auto-mount external partitions. If you don\'t configure mount-on-boot, the mount path of external partitions may change after each reboot, preventing the player from accessing the music directory. To avoid this, please set the partition containing your music to auto-mount on boot.';

  @override
  String get linuxMountGuideWarning =>
      'Warning: If your music is located on an external or internal drive partition that requires mounting, you MUST configure it to \"auto-mount at system startup\". Otherwise, the music directory may not be found after a restart, or you may be required to enter a password to access it.';

  @override
  String get linuxMountGuideStep1 => '1. Open the system \"Disks\" utility';

  @override
  String get linuxMountGuideStep2 =>
      '2. Select your music partition, click the ⚙️ gear icon (Additional partition options)';

  @override
  String get linuxMountGuideStep3 =>
      '3. Select \"Edit Mount Options\", turn off \"User Session Defaults\" and check \"Mount at system startup\"';

  @override
  String get linuxMountGuideOpenButton => 'Open Disk Manager (Disks)';

  @override
  String get unmute => 'Unmute';

  @override
  String get mute => 'Mute';

  @override
  String get disableSystemTray => 'Disable System Tray';

  @override
  String get restoreWindow => 'Restore Window';

  @override
  String get hideWindow => 'Hide Window';

  @override
  String get onboardingAndroidBatteryTitle => 'Background Playback Protection';

  @override
  String get onboardingAndroidBatteryDescription =>
      'Due to Android\'s strict battery optimization policies, to prevent music playback from being killed in the background, we recommend setting Vynody\'s battery restriction to \"Unrestricted\".';

  @override
  String get onboardingAndroidBatteryStep1 =>
      '1. Tap the \"Go to Settings\" button below.';

  @override
  String get onboardingAndroidBatteryStep2 =>
      '2. Allow ignoring battery optimizations in the system prompt, or navigate to the battery settings.';

  @override
  String get onboardingAndroidBatteryStep3 =>
      '3. If navigated to settings, select \"Unrestricted\" or \"No restriction\".';

  @override
  String get onboardingAndroidBatteryButton => 'Go to Settings';

  @override
  String get onboardingAndroidBatteryStatusOptimized =>
      'Status: Restricted (playback may stop in background)';

  @override
  String get onboardingAndroidBatteryStatusUnrestricted =>
      'Status: Unrestricted (recommended, playback protected)';

  @override
  String get onboardingAndroidMediaTitle => 'Access Your Music Library';

  @override
  String get onboardingAndroidMediaDescription =>
      'Once granted, Vynody can directly read all music from your system media library — no need to pick folders manually. You can still import music from specific folders without granting permission.';

  @override
  String get onboardingAndroidMediaStep1 =>
      '1. Ready to go: Instantly shows all music already on your phone';

  @override
  String get onboardingAndroidMediaStep2 =>
      '2. Auto-discover: Newly downloaded or transferred music appears automatically';

  @override
  String get onboardingAndroidMediaStep3 =>
      '3. Privacy safe: Only reads local audio files and won\'t auto-upload your library (except when using cloud services like AI lyrics)';

  @override
  String get onboardingAndroidMediaButton => 'Grant Music Library Access';

  @override
  String get onboardingAndroidMediaStatusGranted =>
      'Status: Granted (Recommended)';

  @override
  String get onboardingAndroidMediaStatusNotGranted =>
      'Status: Not granted (you can import folders manually later)';

  @override
  String get exitApp => 'Exit';

  @override
  String get showScanProgressToastSetting => 'Show Scanning Status Toast';

  @override
  String get showScanProgressToastSettingDescription =>
      'Display real-time scanning progress at the top of the screen when scanning folders.';

  @override
  String get openPlaybackOnDirectorySongTap =>
      'Open playback page when tapping a song';

  @override
  String get openPlaybackOnDirectorySongTapDescription =>
      'Automatically open the playback page when tapping a song in directory view.';

  @override
  String get defaultToLyricsModeOnPlaybackOpen =>
      'Default to lyrics mode on playback page';

  @override
  String get defaultToLyricsModeOnPlaybackOpenDescription =>
      'Automatically show lyrics mode when opening the playback page.';

  @override
  String get tapCoverToEnterLyricsMode => 'Tap cover to enter lyrics mode';

  @override
  String get longPressLyricsPanelToOpenMenu =>
      'Long press lyrics panel to open menu';

  @override
  String get gotIt => 'Got it';

  @override
  String get scanToastHiddenHint =>
      'Scanning status toast hidden. You can re-enable it in Settings - Interface.';

  @override
  String get doubleSpeedPlayingSwipeUpToLock =>
      'Fast forwarding... Swipe up to lock';

  @override
  String get doubleSpeedLockedSwipeDownToUnlock =>
      'Fast forward locked. Long press and swipe down to unlock';

  @override
  String get doubleSpeedUnlocked => 'Fast forward unlocked';

  @override
  String get lyricsImportExportHeader => 'Import & Export';

  @override
  String get exportAction => 'Export';

  @override
  String get importAction => 'Import';

  @override
  String get exportLyricsLabel => 'Export Lyrics Backup';

  @override
  String get exportLyricsDescription =>
      'Export all cached and adjusted lyrics to a JSON file';

  @override
  String get importLyricsLabel => 'Import Lyrics Backup';

  @override
  String get importLyricsDescription =>
      'Import lyrics cache from an exported JSON file';

  @override
  String exportSuccess(int count) {
    return 'Successfully exported $count lyrics.';
  }

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String importSuccess(int count) {
    return 'Import complete! Successfully imported $count lyrics.';
  }

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get importConflictsTitle => 'Import Conflicts';

  @override
  String importConflictsMessage(int conflictCount) {
    return 'Found $conflictCount conflicting lyrics in the backup (exists locally but different). Please select how to proceed:';
  }

  @override
  String get overwriteAll => 'Overwrite All';

  @override
  String get skipAllConflicts => 'Skip Conflicts';

  @override
  String get decideOneByOne => 'Decide One by One';

  @override
  String conflictResolutionTitle(int current, int total) {
    return 'Resolve Conflict ($current/$total)';
  }

  @override
  String get conflictExistingLabel => 'Existing Lyrics';

  @override
  String get conflictImportedLabel => 'Imported Lyrics';

  @override
  String conflictSourceLabel(String source) {
    return 'Source: $source';
  }

  @override
  String conflictTimeLabel(String time) {
    return 'Time: $time';
  }

  @override
  String get overwriteThis => 'Overwrite';

  @override
  String get skipThis => 'Skip';

  @override
  String get overwriteRemaining => 'Overwrite All Remaining';

  @override
  String get skipRemaining => 'Skip All Remaining';

  @override
  String get invalidBackupFile => 'Invalid backup file';

  @override
  String get exportLogs => 'Export Logs';

  @override
  String get exportLogsSuccess => 'Logs exported successfully';

  @override
  String get exportLogsFailed => 'Failed to export logs';

  @override
  String get noLogFileFound => 'No log file found';

  @override
  String get uiDisplayScale => 'UI Display Scale';

  @override
  String get uiDisplayScaleDescription =>
      'Globally adjust size of all UI components and text for car displays';

  @override
  String get uiDisplayScaleDialogTitle => 'UI Display Scale / Car Mode';

  @override
  String uiDisplayScaleCurrent(int percent) {
    return 'Current scale: $percent%';
  }

  @override
  String get audioSettings => 'Audio Settings';

  @override
  String get audioSettingsDescription =>
      'Manage audio playback, equalizer bands, and speed configurations';

  @override
  String get equalizerBandCount => 'Equalizer Band Count';

  @override
  String get equalizerBandCountDescription =>
      'Configure number of bands in equalizer panel. High band modes will automatically enable smooth horizontal scrolling.';

  @override
  String bandsCountOption(int count) {
    return '$count Bands';
  }

  @override
  String get enableFadeEffect => 'Audio Fade Effect';

  @override
  String get enableFadeEffectDescription =>
      'Enable smooth fade transitions during song switching, play, and pause';

  @override
  String get buttonLayoutSettings => 'Button Layout';

  @override
  String get playbackButtonLayoutTitle => 'Playback Page Controls Layout';

  @override
  String get playbackButtonLayoutDescription =>
      'Customize button order and icons on the playback page';

  @override
  String get topButtonsRowTitle => '7-Button Row Order';

  @override
  String get mainButtonsRowTitle => '5-Button Row Left & Right Buttons';

  @override
  String get mainControlsLeftButton => 'Left Button';

  @override
  String get mainControlsRightButton => 'Right Button';

  @override
  String get lyricsHeaderRightButtonTitle =>
      'Lyrics Title Bar Collapsed Button';

  @override
  String get resetButtonOrder => 'Reset to Default';

  @override
  String get btnMore => 'More Menu';

  @override
  String get btnFavorite => 'Favorite';

  @override
  String get btnPlaylistMode => 'Playback Mode';

  @override
  String get btnShuffle => 'Shuffle';

  @override
  String get btnTagCompletion => 'Tag Completion';

  @override
  String get btnSleepTimer => 'Sleep Timer';

  @override
  String get btnEqualizer => 'Equalizer';

  @override
  String get btnVisualizer => 'Visualizer';

  @override
  String get btnVolume => 'Volume';

  @override
  String get remoteControlAction => 'Remote Control';

  @override
  String get remoteControlRequestTitle => 'Remote Control Request';

  @override
  String remoteControlRequestFrom(String name) {
    return 'Device \"$name\" requests to control playback';
  }

  @override
  String get remotePinPairHint =>
      'Please enter the pairing PIN code on your controlling device:';

  @override
  String get remotePinExpiresIn => 'PIN expires in:';

  @override
  String get allowDirectly => 'Allow Directly';

  @override
  String get enterRemotePinTitle => 'Device Pairing';

  @override
  String enterRemotePinPrompt(String name) {
    return 'Enter the 4-digit PIN displayed on \"$name\":';
  }

  @override
  String get remotePinInvalid => 'Invalid or expired PIN. Please try again.';

  @override
  String get remoteConnected => 'Connected';

  @override
  String get remoteConnecting => 'Connecting...';

  @override
  String get remoteDisconnect => 'Disconnect';

  @override
  String get remoteConnectFailed => 'Remote connection failed';

  @override
  String controlledByRemoteDevices(String devices) {
    return 'Controlled by remote device(s): $devices';
  }

  @override
  String get trustedDevicesTitle => 'Trusted Remote Devices';

  @override
  String get removeTrustedDevice => 'Remove Trust';

  @override
  String get noMusicPlaying => 'No music playing';

  @override
  String get previousSong => 'Previous';

  @override
  String get nextSong => 'Next';

  @override
  String get shufflePlayback => 'Shuffle';

  @override
  String get allowRemoteControlTitle => 'Allow Remote Control';

  @override
  String get allowRemoteControlSubtitle =>
      'Allow other devices on the local network to control music playback after pairing';

  @override
  String get remoteControlDisabledOnHost =>
      'Remote control is disabled on the target device';
}
