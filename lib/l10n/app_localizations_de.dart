// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Vynody';

  @override
  String get alwaysOnTop => 'Immer im Vordergrund';

  @override
  String get systemMediaLibrary => 'System-Mediathek';

  @override
  String get scanningDirectory => 'Scanne Verzeichnis...';

  @override
  String filesPreprocessed(Object count) {
    return '$count vorverarbeitet';
  }

  @override
  String filesDiscovered(Object count) {
    return '$count entdeckt';
  }

  @override
  String filesFullyProcessed(Object count) {
    return '$count vollständig verarbeitet';
  }

  @override
  String get directoryAddedSuccess => 'Verzeichnis erfolgreich hinzugefügt';

  @override
  String get directoryAddedNoMusic =>
      'Verzeichnis hinzugefügt, aber keine abspielbaren Audiodateien gefunden';

  @override
  String get scanDirectory => 'Verzeichnis scannen';

  @override
  String get sort => 'Sortieren';

  @override
  String get addRootDirectory => 'Stammverzeichnis hinzufügen';

  @override
  String get goBack => 'Zurück';

  @override
  String get noMediaLibraryPermission => 'Kein Zugriff auf die Mediathek';

  @override
  String get grantPermission => 'Berechtigung erteilen';

  @override
  String get needPermissionToScan =>
      'Berechtigung zum Scannen lokaler Musik erforderlich';

  @override
  String get rebuildTagDatabase => 'Tag-Datenbank neu aufbauen';

  @override
  String get rebuildDatabase => 'Datenbank neu aufbauen';

  @override
  String get confirmRebuildDatabase =>
      'Sollen alle Song-Tags aktualisiert werden? Dies kann einige Zeit dauern.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get rebuildingDatabase => 'Song-Tag-Datenbank wird neu aufgebaut...';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get sortScope => 'Bereich';

  @override
  String get sortOrder => 'Sortierreihenfolge';

  @override
  String get title => 'Titel';

  @override
  String get fileName => 'Dateiname';

  @override
  String get trackNumber => 'Titelnummer';

  @override
  String get ascending => 'Aufsteigend';

  @override
  String get descending => 'Absteigend';

  @override
  String get currentFolderScope => 'Aktueller Ordner';

  @override
  String get globalScope => 'Global';

  @override
  String get visualizerSettings => 'Wiedergabeseiten-Einstellungen';

  @override
  String get algorithm => 'Spektrum';

  @override
  String get appearance => 'Aussehen';

  @override
  String get spectrumAppearanceGroup => 'Spektrum-Aussehen';

  @override
  String get spectrumAdvancedOptions => 'Erweiterte Spektrum-Optionen';

  @override
  String get resetAlgorithm => 'Algorithmus zurücksetzen';

  @override
  String get resetAppearance => 'Aussehen zurücksetzen';

  @override
  String get smoothing => 'Glättung';

  @override
  String get gravity => 'Schwerkraft';

  @override
  String get logScale => 'Logarithmische Skala';

  @override
  String get contrast => 'Kontrast';

  @override
  String get normalization => 'Normalisierung';

  @override
  String get multiplier => 'Multiplikator';

  @override
  String get skipHighFrequency => 'Hohe Frequenzen überspringen';

  @override
  String get frequencyGroups => 'Frequenzgruppen';

  @override
  String get aggregationMode => 'Aggregationsmodus';

  @override
  String get opacity => 'Deckkraft';

  @override
  String get enableGradient => 'Farbverlauf aktivieren';

  @override
  String get startColor => 'Startfarbe';

  @override
  String get endColor => 'Endfarbe';

  @override
  String get gradientRangeStop1 => 'Verlaufsstopp 1';

  @override
  String get gradientRangeStop2 => 'Verlaufsstopp 2';

  @override
  String get gradientRepeatMode => 'Wiederholungsmodus';

  @override
  String get color => 'Farbe';

  @override
  String get followCoverColor => 'Coverfarbe folgen';

  @override
  String get selectColor => 'Farbe auswählen';

  @override
  String get volume => 'Lautstärke';

  @override
  String get clearQueue => 'Warteschlange leeren';

  @override
  String get confirmClearQueue =>
      'Soll die aktuelle Warteschlange wirklich geleert werden?';

  @override
  String get queueCleared => 'Warteschlange geleert';

  @override
  String get locateCurrentSong => 'Aktuellen Song suchen';

  @override
  String get songNotInScannedFolders =>
      'Aktueller Song befindet sich nicht in gescannten Verzeichnissen';

  @override
  String get queue => 'Warteschlange';

  @override
  String get queueEmpty => 'Warteschlange ist leer';

  @override
  String selectedSongs(int count) {
    return '$count Songs ausgewählt';
  }

  @override
  String get unknownArtist => 'Unbekannter Künstler';

  @override
  String deletedSongs(int count) {
    return '$count Songs gelöscht';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get createPlaylist => 'Playlist erstellen';

  @override
  String get playlistName => 'Playlist-Name';

  @override
  String get enterPlaylistName => 'Playlist-Namen eingeben';

  @override
  String get playlistNameExists => 'Playlist-Name existiert bereits';

  @override
  String get renamePlaylist => 'Playlist umbenennen';

  @override
  String get deletePlaylist => 'Playlist löschen';

  @override
  String confirmDeletePlaylist(String name) {
    return 'Soll die Playlist \"$name\" wirklich gelöscht werden?';
  }

  @override
  String get addToPlaylist => 'Zur Playlist hinzufügen';

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get addToQueue => 'Zur Warteschlange hinzufügen';

  @override
  String get addedToQueue => 'Zur Warteschlange hinzugefügt';

  @override
  String songCount(int count) {
    return '$count Songs';
  }

  @override
  String addedToPlaylist(int count, String playlist) {
    return '$count Songs zu $playlist hinzugefügt';
  }

  @override
  String get createNewList => 'Neue Liste erstellen';

  @override
  String createdPlaylist(String name, int count) {
    return 'Playlist \"$name\" mit $count Songs erstellt';
  }

  @override
  String get rename => 'Umbenennen';

  @override
  String get playlist => 'Playlist';

  @override
  String get mostPlayed => 'Am häufigsten gespielt';

  @override
  String get recentlyPlayed => 'Zuletzt gespielt';

  @override
  String get recentlyAdded => 'Kürzlich hinzugefügt';

  @override
  String get albums => 'Alben';

  @override
  String get artists => 'Künstler';

  @override
  String get mostPlayedDescription => 'Sortiert nach vollständigen Wiedergaben';

  @override
  String get recentlyPlayedDescription =>
      'Nach Wiedergabezeit sortiert, einschließlich externer Dateien';

  @override
  String get recentlyAddedDescription =>
      'Sortiert nach Aufnahmezeitpunkt in die Mediathek';

  @override
  String get allTime => 'Gesamte Zeit';

  @override
  String get pastWeek => 'Letzte Woche';

  @override
  String get pastMonth => 'Letzter Monat';

  @override
  String get past90Days => 'Letzte 90 Tage';

  @override
  String get noPlayHistory => 'Noch kein Wiedergabeverlauf';

  @override
  String get noPlayHistoryInRange =>
      'Kein Wiedergabeverlauf in diesem Zeitraum';

  @override
  String get noRecentlyPlayedSongs => 'Kein Wiedergabeverlauf';

  @override
  String get noRecentlyPlayedInRange =>
      'Kein Wiedergabeverlauf in diesem Zeitraum';

  @override
  String get noRecentlyAddedSongs => 'Noch keine Songs in der Mediathek';

  @override
  String get noRecentlyAddedInRange =>
      'In diesem Zeitraum wurden keine Songs hinzugefügt';

  @override
  String get addedOn => 'Hinzugefügt am';

  @override
  String get externalSourceTag => 'Extern';

  @override
  String get lastPlayed => 'Zuletzt gespielt';

  @override
  String playCountLabel(int count) {
    return '$count Wiedergaben';
  }

  @override
  String get playAll => 'Alle abspielen';

  @override
  String get shufflePlay => 'Zufallswiedergabe';

  @override
  String get noAlbums => 'Noch keine Alben verfügbar';

  @override
  String get noArtists => 'Noch keine Künstler verfügbar';

  @override
  String get searchAlbums => 'Alben oder Künstler suchen';

  @override
  String get searchArtists => 'Künstler suchen';

  @override
  String get albumSort => 'Sortieren';

  @override
  String get sortArtistAsc => 'Künstler A-Z';

  @override
  String get sortTitleAsc => 'Albumtitel A-Z';

  @override
  String get sortTrackCount => 'Song-Anzahl';

  @override
  String get sortDuration => 'Gesamtdauer';

  @override
  String get sortRecentAdded => 'Kürzlich hinzugefügt';

  @override
  String get sortAscending => 'Aufsteigend';

  @override
  String get sortDescending => 'Absteigend';

  @override
  String get playNext => 'Als Nächstes abspielen';

  @override
  String get addToFavorites => 'Zu Favoriten hinzufügen';

  @override
  String get removeFromFavorites => 'Aus Favoriten entfernen';

  @override
  String get viewAlbumDetails => 'Album-Details anzeigen';

  @override
  String get viewArtistDetails => 'Künstler-Details anzeigen';

  @override
  String get openFileLocation => 'Dateispeicherort öffnen';

  @override
  String get copyAlbumTitle => 'Albumtitel kopieren';

  @override
  String get copyArtistName => 'Künstlernamen kopieren';

  @override
  String albumCount(int count) {
    return '$count Alben';
  }

  @override
  String get emptyList => 'Liste ist leer';

  @override
  String get dragToAddMusic =>
      'Dateien oder Ordner zum Hinzufügen von Musik ziehen';

  @override
  String get unknownAlbum => 'Unbekanntes Album';

  @override
  String get managePlaylists => 'Playlists verwalten';

  @override
  String get createNewPlaylist => 'Neue Playlist erstellen';

  @override
  String get defaultList => 'Standard-Liste';

  @override
  String get playbackMode => 'Wiedergabemodus';

  @override
  String get playbackOptions => 'Wiedergabeoptionen';

  @override
  String get setVisualizerDisplay => 'Visualizer-Anzeige einstellen';

  @override
  String get noPlaybackContent => 'Kein Wiedergabeinhalt';

  @override
  String get file => 'Datei';

  @override
  String get play => 'Wiedergabe';

  @override
  String get list => 'Mediathek';

  @override
  String get queueTab => 'Warteschlange';

  @override
  String get more => 'Mehr';

  @override
  String get settings => 'Einstellungen';

  @override
  String get themeMode => 'Design';

  @override
  String get themeModeSystem => 'System folgen';

  @override
  String get themeModeLight => 'Hell';

  @override
  String get themeModeDark => 'Dunkel';

  @override
  String get themeColor => 'Designfarbe';

  @override
  String get customThemeColor => 'Benutzerdefinierte Designfarbe';

  @override
  String get themeColorMikuTeal => 'Miku-Türkis';

  @override
  String get themeColorClassicBlue => 'Klassisches Blau';

  @override
  String get themeColorIrisPurple => 'Irisviolett';

  @override
  String get themeColorViolet => 'Violett';

  @override
  String get themeColorSakuraPink => 'Kirschblütenrosa';

  @override
  String get themeColorCoralOrange => 'Korallenorange';

  @override
  String get themeColorAmberGold => 'Bernsteingold';

  @override
  String get themeColorForestGreen => 'Waldgrün';

  @override
  String get themeColorAuroraCyan => 'Polarlichzyan';

  @override
  String get themeColorCrimsonRed => 'Karmesinrot';

  @override
  String get themeColorSlateGrey => 'Schiefergrau';

  @override
  String get immersiveTabBar => 'Immersive Tab-Leiste';

  @override
  String get immersiveTabBarDescription =>
      'Navigationsleiste bei Mausbewegung anzeigen, nach 3 s Inaktivität ausblenden';

  @override
  String get collapseButtonsInLandscapeLyrics =>
      'Schaltflächen im Querformat-Songtext-Modus einklappen';

  @override
  String get collapseButtonsInLandscapeLyricsDescription =>
      'Klappt die 7-Schaltflächen-Zeile ein, richtet den Titel links aus und fügt rechte Aktionstasten im Querformat-Songtext-Modus hinzu';

  @override
  String get sampleStride => 'Abtastschritt';

  @override
  String get sampleStrideDescription =>
      'Größere Werte scannen schneller, aber mit geringerer Wellenformgenauigkeit (Standard: 4)';

  @override
  String get waveformSegments => 'Wellenform-Segmente';

  @override
  String get waveformSegmentsDescription =>
      'Anzahl der Wellenbalken zur Anzeige (Standard: 80)';

  @override
  String get showDeveloperOptions => 'Entwickleroptionen anzeigen';

  @override
  String get playbackBackground => 'Wiedergabe-Hintergrund';

  @override
  String get playbackRadialGradient => 'Mittlerer Dunkelverlauf';

  @override
  String get blurIntensity => 'Unschärfe-Intensität';

  @override
  String get blurredArtwork => 'Unscharfes Cover (Standard)';

  @override
  String get dynamicMesh => 'Dynamisches Mesh';

  @override
  String get solidColor => 'Einfarbig';

  @override
  String get customImage => 'Benutzerdefiniertes Bild';

  @override
  String get presetColors => 'Voreingestellte Farben';

  @override
  String get customColor => 'Benutzerdefinierte Farbe';

  @override
  String get uploadImage => 'Bild auswählen';

  @override
  String get normalOpacity => 'Normale Dunkelschicht-Deckkraft';

  @override
  String get lyricsOpacity => 'Text-Dunkelschicht-Deckkraft';

  @override
  String get chooseImageError => 'Fehler beim Auswählen des Bildes';

  @override
  String get noImageSelected => 'Kein Bild ausgewählt';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get playlistModeSingle => 'Einzeltitel';

  @override
  String get playlistModeSingleLoop => 'Einzeltitel wiederholen';

  @override
  String get playlistModeQueue => 'Wiedergabeliste';

  @override
  String get playlistModeQueueLoop => 'Wiedergabeliste wiederholen';

  @override
  String get playlistModeAutoQueueLoop => 'Auto-Wiedergabeliste wiederholen';

  @override
  String get visualizer => 'Visualizer';

  @override
  String get previous => 'Vorheriger';

  @override
  String get next => 'Nächster';

  @override
  String get pause => 'Pause';

  @override
  String get autoMode => 'Automatikmodus';

  @override
  String get advancedOptions => 'Erweiterte Optionen';

  @override
  String get spectrumQuantity => 'Spektrum-Anzahl';

  @override
  String get speed => 'Geschwindigkeit';

  @override
  String get quantityHigh => 'Hoch';

  @override
  String get quantityMedium => 'Mittel';

  @override
  String get quantityLow => 'Niedrig';

  @override
  String get speedFast => 'Schnell';

  @override
  String get speedMedium => 'Mittel';

  @override
  String get speedSlow => 'Langsam';

  @override
  String get portraitFrequencyGroups => 'Spektrum-Anzahl Hochformat';

  @override
  String get landscapeFrequencyGroups => 'Spektrum-Anzahl Querformat';

  @override
  String get portraitGap => 'Abstand Hochformat';

  @override
  String get landscapeGap => 'Abstand Querformat';

  @override
  String get enableWaveformProgressBar =>
      'Wellenform-Fortschrittsbalken aktivieren';

  @override
  String get enableWaveformProgressBarDescription =>
      'Gesamte Song-Wellenform anstelle des Standardschiebereglers verwenden';

  @override
  String get waveformLongPressSeekSpeed =>
      'Spulgeschwindigkeit bei langem Drücken';

  @override
  String get waveformLongPressSeekSpeedDescription =>
      'Wiedergabegeschwindigkeit beim Gedrückthalten der rechten Seite der Wellenform-Leiste (×)';

  @override
  String get enableWaveformLongPressSeek =>
      'Wellenform-Vorspulen per langem Drücken aktivieren';

  @override
  String get enableWaveformLongPressSeekDescription =>
      'Zum Vorspulen die rechte Seite der Wellenform-Leiste gedrückt halten';

  @override
  String get clearWaveformCache => 'Wellenform-Cache leeren';

  @override
  String get clearWaveformCacheDescription =>
      'Zwischengespeicherte Wellenformdaten aus der Datenbank löschen und neu berechnen';

  @override
  String get waveformCacheCleared => 'Wellenform-Cache geleert';

  @override
  String get storageAndCache => 'Speicher & Cache';

  @override
  String get remoteAudioCache => 'Remote-Audio-Cache';

  @override
  String get remoteAudioCacheDescription =>
      'Lokaler Cache für Navidrome- und WebDAV-Streaming & Vorabladen';

  @override
  String get remoteCacheLimit => 'Remote-Cache-Limit';

  @override
  String get remotePrefetchCount => 'Vorab geladene Remote-Titel';

  @override
  String get remotePrefetchCountDescription =>
      'Nachfolgende Remote-Titel in der Warteschlange für nahtloses Umschalten vorab herunterladen';

  @override
  String get clearRemoteCache => 'Remote-Cache leeren';

  @override
  String get remoteCacheCleared => 'Remote-Audio-Cache geleert';

  @override
  String get unlimited => 'Unbegrenzt';

  @override
  String get off => 'Aus';

  @override
  String get randomMode => 'Zufallsmodus';

  @override
  String get randomHistory => 'Zufallsverlauf';

  @override
  String get randomRange => 'Zufallsbereich';

  @override
  String get randomMethod => 'Zufallsmethode';

  @override
  String get currentQueue => 'Aktuelle Warteschlange';

  @override
  String get globalRange => 'Global (alle Playlists)';

  @override
  String get completeRandom => 'Vollständiger Zufall';

  @override
  String get shuffleRandom => 'Mischen';

  @override
  String get randomQueue => 'Zufalls-Warteschlange';

  @override
  String get notSelected => 'Keine Musik ausgewählt';

  @override
  String get saveTagsToFile => 'Tags in Datei speichern';

  @override
  String get saveCurrentTagsToFile =>
      'Tags des aktuellen Songs in Datei speichern';

  @override
  String get saveQueueTagsToFile =>
      'Alle Tags der Warteschlange in Datei speichern';

  @override
  String get tagsSaved => 'Tags erfolgreich gespeichert';

  @override
  String tagsSavedCount(Object count) {
    return 'Tags gespeichert ($count Songs)';
  }

  @override
  String get tagsSaveFailed => 'Fehler beim Speichern der Tags';

  @override
  String tagsSaveFailedCount(Object count) {
    return 'Fehler beim Speichern von $count Songs';
  }

  @override
  String unsupportedFormat(Object count) {
    return '$count Songs haben ein nicht unterstütztes Format (OGG/Opus)';
  }

  @override
  String get unsupportedFormatSingle =>
      'Dieses Format (OGG/Opus) unterstützt das Speichern von Tags nicht';

  @override
  String get savingTags => 'Speichere Tags...';

  @override
  String get noModifiedTagsToSave => 'Keine geänderten Tags zu speichern';

  @override
  String get clearPlaylist => 'Liste leeren';

  @override
  String get copyTitle => 'Titel kopieren';

  @override
  String get transcodeAction => 'Transkodieren';

  @override
  String get transcodeSectionTitle => 'Audio-Transkodierung';

  @override
  String get transcodeSectionDescription =>
      'Standard-Ausgabeformat und Qualitätsvoreinstellung festlegen.';

  @override
  String get transcodeDefaultFormat => 'Standard-Ausgabeformat';

  @override
  String get transcodeDefaultQuality => 'Standard-Qualitätsvoreinstellung';

  @override
  String get transcodeTitle => 'Audio-Transkodierung';

  @override
  String transcodeSongCount(int count) {
    return '$count Songs';
  }

  @override
  String transcodeCompletedCount(int count) {
    return '$count Transkodierungsaufgaben abgeschlossen';
  }

  @override
  String transcodeCompletedWithFailures(int success, int total, int failed) {
    return '$success/$total Aufgaben abgeschlossen, $failed fehlgeschlagen';
  }

  @override
  String get transcodeFailedGeneric => 'Transkodierung fehlgeschlagen';

  @override
  String get transcodePreparing => 'Transkodierung wird vorbereitet...';

  @override
  String transcodeProgress(int current, int total) {
    return 'Transkodiere $current/$total';
  }

  @override
  String get transcoding => 'Transkodierung läuft...';

  @override
  String get startTranscode => 'Transkodierung starten';

  @override
  String transcodeEngine(Object engine) {
    return 'Engine: $engine';
  }

  @override
  String get transcodeUsingSystemFfmpeg =>
      'Verwende ffmpeg aus dem System-PATH.';

  @override
  String transcodeUsingCustomFfmpeg(Object path) {
    return 'Verwende benutzerdefiniertes ffmpeg: $path';
  }

  @override
  String get transcodeFormat => 'Ausgabeformat';

  @override
  String get transcodeQualityPreset => 'Qualitätsvoreinstellung';

  @override
  String get transcodeQualityLow => 'Niedrig';

  @override
  String get transcodeQualityMedium => 'Mittel';

  @override
  String get transcodeQualityHigh => 'Hoch';

  @override
  String get transcodeQualityExtreme => 'Höchste';

  @override
  String get transcodeLosslessPresetHint =>
      'Dieses verlustfreie Format verwendet keine Qualitätsstufen oder Bitratenmodi.';

  @override
  String get transcodeAdvancedOptions => 'Erweiterte Optionen';

  @override
  String get transcodeAdvancedCustomized =>
      'Erweiterte Parameter wurden manuell geändert';

  @override
  String get transcodeAdvancedFollowingPreset =>
      'Erweiterte Parameter folgen der aktuellen Voreinstellung';

  @override
  String get transcodeLosslessAdvancedHint =>
      'Dieses verlustfreie Format behält nur quellbezogene Optionen bei.';

  @override
  String get transcodeBitRateInvalid => 'Gültige Bitrate eingeben';

  @override
  String get transcodeBitRate => 'Bitrate';

  @override
  String get transcodeBitRateMode => 'Bitratenmodus';

  @override
  String get transcodeEncodingEngine => 'Codierungs-Engine';

  @override
  String get transcodeSystemEncoder => 'Media3 (System)';

  @override
  String get transcodeFfmpegRustEncoder => 'FFmpeg (Rust)';

  @override
  String get transcodeAacEncoder => 'AAC-Encoder';

  @override
  String get transcodeSampleRate => 'Abtastrate';

  @override
  String get transcodeChannels => 'Kanäle';

  @override
  String get transcodeResetToPreset =>
      'Auf aktuelle Voreinstellung zurücksetzen';

  @override
  String get transcodeResetLosslessOptions =>
      'Verlustfreie Optionen zurücksetzen';

  @override
  String get transcodeOutputDirectory => 'Ausgabeverzeichnis';

  @override
  String get transcodeOutputPreview => 'Vorschau';

  @override
  String get transcodeChooseDirectory => 'Verzeichnis auswählen';

  @override
  String get transcodeUseSourceDirectory => 'Quellverzeichnis verwenden';

  @override
  String get transcodeKeepSource => 'Quelldatei behalten';

  @override
  String get transcodeMono => 'Mono';

  @override
  String get transcodeStereo => 'Stereo';

  @override
  String get openFolderLocation => 'Ordnerspeicherort öffnen';

  @override
  String get songTagsSavedToSourceFileAndApp =>
      'Song-Tags in Quelldatei und App gespeichert';

  @override
  String get songTagsSavedToApp => 'Song-Tags in der App gespeichert';

  @override
  String get durationZero => '0:00';

  @override
  String get generateLyrics => 'Songtext generieren';

  @override
  String get generateTimeline => 'Zeitachse generieren';

  @override
  String get queueGenerateLyrics => 'Generierung einreihen';

  @override
  String get pauseAutoScroll => 'Automatisches Scrollen anhalten';

  @override
  String get resumeAutoScroll => 'Automatisches Scrollen fortsetzen';

  @override
  String get translateLyrics => 'Songtext übersetzen';

  @override
  String get clearLyricsCache => 'Aktuellen Songtext-Cache leeren';

  @override
  String get clearTranslationCache => 'Aktuellen Übersetzungs-Cache leeren';

  @override
  String get requery => 'Erneut abfragen';

  @override
  String get sleepTimerTitle => 'Sleep-Timer';

  @override
  String get sleepTimerDescription =>
      'Countdown auswählen. Die Wiedergabe wird nach Ablauf pausiert.';

  @override
  String get sleepTimerRunningTitle => 'Sleep-Timer läuft';

  @override
  String get sleepTimerRunningDescription =>
      'Die Wiedergabe wird nach Ablauf des Countdowns automatisch pausiert.';

  @override
  String get sleepTimerStopAfterCurrentSong => 'Nach dem letzten Titel stoppen';

  @override
  String get remainingTime => 'Verbleibende Zeit';

  @override
  String get startCountdown => 'Countdown starten';

  @override
  String get end => 'Ende';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get equalizerEnabledStatus => 'High-Fidelity-Anpassung aktiviert';

  @override
  String get equalizerDisabledStatus => 'Deaktiviert';

  @override
  String get eqPresetFlat => 'Linear';

  @override
  String get eqPresetPop => 'Pop';

  @override
  String get eqPresetRock => 'Rock';

  @override
  String get eqPresetVocal => 'Gesang';

  @override
  String get eqPresetBassBoost => 'Bass-Verstärkung';

  @override
  String get eqPresetElectronic => 'Elektronisch';

  @override
  String get eqPresetJazz => 'Jazz';

  @override
  String get eqPresetClassical => 'Klassik';

  @override
  String get eqPresetAcoustic => 'Akustisch';

  @override
  String get eqPresetDance => 'Dance';

  @override
  String get eqPresetHifi => 'Hi-Fi';

  @override
  String get eqPresets => 'Equalizer-Voreinstellungen';

  @override
  String get customPresets => 'Benutzerdefinierte Voreinstellungen';

  @override
  String get builtInPresets => 'Integrierte Voreinstellungen';

  @override
  String get saveAsPreset => 'Als Voreinstellung speichern';

  @override
  String get saveCurrentAsPreset =>
      'Aktuelle Einstellung als neue Voreinstellung speichern';

  @override
  String get enterPresetName => 'Voreinstellungsnamen eingeben';

  @override
  String get presetName => 'Voreinstellungsname';

  @override
  String get presetNameAlreadyExists => 'Voreinstellungsname existiert bereits';

  @override
  String get presetNameCannotBeEmpty =>
      'Voreinstellungsname darf nicht leer sein';

  @override
  String get presetSaved => 'Voreinstellung gespeichert';

  @override
  String get updatePreset => 'Voreinstellung aktualisieren';

  @override
  String get presetUpdated => 'Voreinstellung aktualisiert';

  @override
  String get renamePreset => 'Voreinstellung umbenennen';

  @override
  String get presetRenamed => 'Voreinstellung umbenannt';

  @override
  String get saveAsNewPreset => 'Als neue Voreinstellung speichern';

  @override
  String get updateWithCurrentSettings =>
      'Mit aktuellen Einstellungen überschreiben';

  @override
  String get modified => 'Geändert';

  @override
  String get deletePreset => 'Voreinstellung löschen';

  @override
  String get deletePresetConfirm =>
      'Möchten Sie diese Voreinstellung wirklich löschen?';

  @override
  String get custom => 'Benutzerdefiniert';

  @override
  String get noCustomPresets =>
      'Noch keine benutzerdefinierten Voreinstellungen';

  @override
  String get savePresetPrompt =>
      'Aktuelle EQ-Bänder, Bass-Anhebung und Vorverstärkung speichern';

  @override
  String get effects => 'Effekte';

  @override
  String get playbackSpeed => 'Wiedergabegeschwindigkeit';

  @override
  String get playbackSpeedLimit5x => '5x Geschwindigkeitsbegrenzung';

  @override
  String get normal => 'Normal';

  @override
  String get bassBoost => 'Bass-Anhebung';

  @override
  String get preampGain => 'Vorverstärkung';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get close => 'Schließen';

  @override
  String get timelineAdjustmentTitle => 'Zeitachse manuell anpassen';

  @override
  String get timelineAdjustmentDescription =>
      'Nach rechts ziehen verzögert den Text, nach links beschleunigt ihn.';

  @override
  String timelineOffsetEarlier(Object seconds) {
    return '${seconds}s früher';
  }

  @override
  String timelineOffsetLater(Object seconds) {
    return '${seconds}s später';
  }

  @override
  String get timelineOffsetCurrent => 'Aktuelle Verschiebung: 0,0 s';

  @override
  String get enterAcoustidApiKeyTitle => 'AcoustID-API-Schlüssel eingeben';

  @override
  String get acoustidApiKeyDescription =>
      'Für Audio-Fingerprinting. Bei Leerung wird der integrierte Schlüssel wiederhergestellt.';

  @override
  String get acoustidApiKeyHint => 'AcoustID-API-Schlüssel einfügen';

  @override
  String get apiKey => 'API-Schlüssel';

  @override
  String get save => 'Speichern';

  @override
  String get enterLyricsTitle => 'Songtext eingeben';

  @override
  String get lyricsInputHint =>
      'Songtext hier einfügen oder eingeben. Mehrzeiliger Text wird unterstützt.';

  @override
  String get enterGoogleAiStudioApiKeyTitle =>
      'Google AI Studio-API-Schlüssel eingeben';

  @override
  String get googleAiStudioApiKeyDescription =>
      'Wird für Songtext-Generierung, Zeitachse und Übersetzung verwendet.';

  @override
  String get pasteGoogleAiStudioApiKey =>
      'Google AI Studio-API-Schlüssel einfügen';

  @override
  String get enterOpenRouterApiKeyTitle => 'OpenRouter-API-Schlüssel eingeben';

  @override
  String get openRouterApiKeyDescription =>
      'Für OpenRouter-Songtext-Generierung, Zeitachsen-Generierung und Songtext-Übersetzung.';

  @override
  String get pasteOpenRouterApiKey => 'OpenRouter-API-Schlüssel einfügen';

  @override
  String get enterGeminiApiKeyTitle => 'Gemini-API-Schlüssel eingeben';

  @override
  String get geminiApiKeyDescription =>
      'Wird für die Songtext-Übersetzung verwendet.';

  @override
  String get pasteGeminiApiKey => 'Gemini-API-Schlüssel einfügen';

  @override
  String get testConnection => 'Verbindung testen';

  @override
  String get enterApiKey => 'Bitte einen API-Schlüssel eingeben.';

  @override
  String get testingConnection => 'Verbindung wird getestet...';

  @override
  String get getKey => 'Schlüssel besorgen';

  @override
  String get editSongTagsTitle => 'Song-Tags bearbeiten';

  @override
  String get changeArtwork => 'Cover ändern';

  @override
  String get clearArtwork => 'Cover entfernen';

  @override
  String get editSongTagsDescription =>
      'Änderungen können nur in der App oder auch in der Quelldatei gespeichert werden.';

  @override
  String get artistLabel => 'Künstler';

  @override
  String get albumLabel => 'Album';

  @override
  String get trackNumberLabel => 'Titelnummer';

  @override
  String get trackNumberMustBeInteger =>
      'Die Titelnummer muss eine ganze Zahl sein';

  @override
  String get leaveBlankKeepsCurrentValue =>
      'Leer lassen, um dieses Feld zu leeren';

  @override
  String get currentFileFormatCannotWriteBack =>
      'Dieses Dateiformat unterstützt das Zurückschreiben in die Quelldatei nicht.';

  @override
  String get leaveBlankDoesNotClearOriginalValue =>
      'Hinweis: Ein leeres Feld löscht seinen Wert.';

  @override
  String get saveToApp => 'In App speichern';

  @override
  String get saveToSourceFileAndApp => 'In Quelldatei und App speichern';

  @override
  String get saveToSourceFileFailed =>
      'Fehler beim Speichern in der Quelldatei. Prüfen Sie, ob das Format Schreibzugriff unterstützt.';

  @override
  String get fileOccupiedByOtherApp =>
      'Die Datei wird von einer anderen App verwendet';

  @override
  String get saveFailed =>
      'Speichern fehlgeschlagen. Bitte später erneut versuchen.';

  @override
  String apiKeySaved(Object provider) {
    return '$provider-API-Schlüssel gespeichert';
  }

  @override
  String get apiKeySavedAcoustid => 'AcoustID-API-Schlüssel gespeichert';

  @override
  String get generalSectionTitle => 'Oberfläche & Verhalten';

  @override
  String get generalSectionDescription =>
      'Konfigurieren Sie Erscheinungsbild, Wiedergabeinteraktionen und Fenster-Systemverhalten.';

  @override
  String get uiAppearanceGroup => 'Erscheinungsbild & Anzeige';

  @override
  String get playbackBehaviorGroup => 'Wiedergabe & Interaktion';

  @override
  String get systemWindowBehaviorGroup => 'Fenster- & Systemverhalten';

  @override
  String get interfaceLanguage => 'Oberflächensprache';

  @override
  String get interfaceLanguageDescription =>
      'Wählen Sie die Anzeigesprache der Anwendung.';

  @override
  String get scanSectionTitle => 'Scannen';

  @override
  String get scanSectionDescription =>
      'Diese Optionen steuern, wie der Mediathek-Scan Audiodateien behandelt.';

  @override
  String get skipShortAudioDuringScan =>
      'Kurze Audiodateien beim Scannen überspringen';

  @override
  String get skipShortAudioDuringScanDescription =>
      'Audio kürzer als der Schwellenwert wird nicht zur Mediathek hinzugefügt.';

  @override
  String get shortAudioScanThreshold => 'Schwellenwert für kurze Audiodateien';

  @override
  String get shortAudioScanThresholdDescription =>
      'Dateien kürzer als diese Dauer werden übersprungen.';

  @override
  String shortAudioScanThresholdValue(Object seconds) {
    return '$seconds s';
  }

  @override
  String get shortcutSettingsTitle => 'Benutzerdefinierte Tastenkürzel';

  @override
  String get shortcutSettingsDescription =>
      'Klicken Sie, um Tastenkürzel für Player-Aktionen neu zu belegen.';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get lyricsSectionTitle => 'Songtexte';

  @override
  String get lyricsSectionDescription =>
      'Diese Einstellungen betreffen nur die Generierung von Songtexten und Zeitachsen.';

  @override
  String get lyricsTranslationTargetLanguageLabel => 'Übersetzungszielsprache';

  @override
  String get lyricsTranslationTargetLanguageDescription =>
      'Standardmäßig der Systemsprache folgen oder manuell auswählen.';

  @override
  String get lyricsSaveMethodLabel => 'Speicherort für Songtexte';

  @override
  String get lyricsSaveMethodDescription =>
      'Wählen Sie, wo Songtexte beim Schreiben gespeichert werden.';

  @override
  String get lyricsSaveMethodOriginal => 'Wie Quelle';

  @override
  String get lyricsSaveMethodEmbedded => 'Eingebettet';

  @override
  String get lyricsSaveMethodLrcFile => 'LRC-Datei';

  @override
  String get lyricsStyleLabel => 'Songtext-Stil';

  @override
  String get lyricsStyleDescription =>
      'Wählen Sie den Anzeigestil für das Songtext-Panel.';

  @override
  String get lyricsStyleTraditional => 'Traditionell';

  @override
  String get lyricsStyleApple => 'Fokus Zeile für Zeile';

  @override
  String get resumeLyricsSync => 'Synchronisierung fortsetzen';

  @override
  String get followSystemLanguage => 'System folgen';

  @override
  String get autoSwitchLyricsProvider => 'Automatischer Anbieterwechsel';

  @override
  String get autoSwitchLyricsProviderEnabledDesc =>
      'Google AI Studio wird zuerst versucht. Wenn sowohl das Haupt- als auch das Ausweichmodell mit 429- oder 5xx-Fehlern fehlschlagen, wechselt die App automatisch zu OpenRouter und versucht es weiter.';

  @override
  String get autoSwitchLyricsProviderDisabledDesc =>
      'Sie müssen die API-Schlüssel für Google AI Studio und OpenRouter eingeben, bevor der automatische Wechsel aktiviert werden kann.';

  @override
  String get lyricsAiProviderTitle => 'KI-Anbieter für Songtexte';

  @override
  String get lyricsAiProviderDescription =>
      'Betrifft nur die Generierung von Songtexten und Zeitachsen. Übersetzung verwendet immer Google AI Studio.';

  @override
  String get googleAiStudioApiKeySaved =>
      'Google AI Studio-API-Schlüssel gespeichert';

  @override
  String get googleAiStudioApiKeyMissing =>
      'Kein Google AI Studio-API-Schlüssel gespeichert. Sie werden daran erinnert.';

  @override
  String get openRouterApiKeySaved => 'OpenRouter-API-Schlüssel gespeichert';

  @override
  String get openRouterApiKeyMissing =>
      'Kein OpenRouter-API-Schlüssel gespeichert. Sie werden daran erinnert.';

  @override
  String get apiKeySavedStatus => 'Gespeichert';

  @override
  String get apiKeyMissingStatus => 'Nicht ausgefüllt';

  @override
  String get platformApiKeysSectionTitle => 'Plattform-API-Schlüssel';

  @override
  String get fill => 'Ausfüllen';

  @override
  String get modify => 'Ändern';

  @override
  String get geminiModelsSectionTitle => 'Modell auswählen';

  @override
  String get geminiModelsSectionDescription =>
      'Diese Modelle werden für die Generierung von Songtexten, Zeitachsen und Übersetzung verwendet.';

  @override
  String get primaryModelLabel => 'Primäres Modell';

  @override
  String get backupModelLabel => 'Backup-Modell';

  @override
  String get translationModelLabel => 'Übersetzungsmodell';

  @override
  String get fetching => 'Abrufen...';

  @override
  String get fetchModelList => 'Modellliste abrufen';

  @override
  String get restoreDefault => 'Standard wiederherstellen';

  @override
  String get acoustidSectionTitle => 'Audio-Fingerprinting';

  @override
  String get acoustidApiKeyTitle => 'AcoustID-API-Schlüssel';

  @override
  String get acoustidApiKeyHelp =>
      'AcoustID wird für Audio-Fingerprinting verwendet. Wir empfehlen Ihren eigenen API-Schlüssel.';

  @override
  String get acoustidApiKeySaved => 'AcoustID-API-Schlüssel gespeichert';

  @override
  String get acoustidApiKeyDefault =>
      'Der integrierte Schlüssel wird verwendet. Ersetzen Sie ihn durch Ihren eigenen.';

  @override
  String get applyForApiKey =>
      'API-Schlüssel beantragen: https://acoustid.org/new-application';

  @override
  String get queueTabBarFavoriteAdded => 'Zu Favoriten hinzugefügt';

  @override
  String get queueTabBarFavoriteRemoved => 'Aus Favoriten entfernt';

  @override
  String get tagCompletion => 'Tag-Vervollständigung';

  @override
  String get tagCompletionDescription =>
      'Tags mit AcoustID- und MusicBrainz-Ergebnissen abgleichen';

  @override
  String get goToSettings => 'Zu den Einstellungen';

  @override
  String get searchReleaseTitles => 'Veröffentlichungstitel suchen';

  @override
  String get closeSearch => 'Suche schließen';

  @override
  String get refreshResults => 'Ergebnisse aktualisieren';

  @override
  String get filterMusicBrainzReleaseTitle =>
      'MusicBrainz-Veröffentlichungstitel filtern';

  @override
  String get clearSearch => 'Suche zurücksetzen';

  @override
  String get localTitle => 'Lokaler Titel';

  @override
  String get queryConditions => 'Abfragebedingungen';

  @override
  String get musicBrainzLoading => 'MusicBrainz wird geladen';

  @override
  String get musicBrainzLoadingWithResults =>
      'Vorhandene Ergebnisse bleiben im Bereich';

  @override
  String get musicBrainzLoadingHint => 'Bitte warten';

  @override
  String get musicBrainzQueryFailed => 'MusicBrainz-Abfrage fehlgeschlagen';

  @override
  String get musicBrainzNetworkErrorHint =>
      'Die Anfrage ist fehlgeschlagen, meist aufgrund von Netzwerkproblemen oder Zeitüberschreitung.';

  @override
  String get musicBrainzFilteredEmptyHint =>
      'Keine Veröffentlichungstitel mit diesem Schlüsselwort unter den aktuellen Filtern.';

  @override
  String get musicBrainzEmptyHint =>
      'MusicBrainz hat keine verwendbaren Ergebnisse zurückgegeben. Versuchen Sie, die Filter zu lockern.';

  @override
  String get musicBrainzEmptyMoreCompleteHint =>
      'Später erneut versuchen oder prüfen, ob die Titel-/Künstlerinformationen vollständiger sind.';

  @override
  String get retry => 'Wiederholen';

  @override
  String get noMatchingRelease => 'Keine passende Veröffentlichung gefunden';

  @override
  String get noMatchingResults => 'Keine passenden Ergebnisse gefunden';

  @override
  String get networkConnectionFailed => 'Netzwerkverbindung fehlgeschlagen';

  @override
  String get searchAgain => 'Erneut suchen';

  @override
  String get acoustidRecognitionRecords => 'AcoustID-Erkennungsdatensätze';

  @override
  String get musicBrainzRecordings => 'MusicBrainz-Aufnahmen';

  @override
  String get noExpandableReleaseGroups =>
      'Keine erweiterbaren Veröffentlichungsgruppen';

  @override
  String get noExpandableReleases => 'Keine erweiterbaren Veröffentlichungen';

  @override
  String get noMatchingResultHint =>
      'Später erneut versuchen oder Informationen prüfen.';

  @override
  String releaseCountLabel(int count) {
    return '$count Veröffentlichungsversionen';
  }

  @override
  String recordingCountLabel(int count) {
    return '$count Aufnahmen';
  }

  @override
  String trackCountShort(int count) {
    return '$count Titel';
  }

  @override
  String scoreLabel(int score) {
    return 'Punktzahl $score';
  }

  @override
  String matchScoreLabel(int score) {
    return 'Übereinstimmung $score%';
  }

  @override
  String get editQueryCondition => 'Abfragebedingung bearbeiten';

  @override
  String get enterNewQueryText => 'Neuen Abfragetext eingeben';

  @override
  String get durationLabel => 'Dauer';

  @override
  String get customShortcuts => 'Benutzerdefinierte Tastenkürzel';

  @override
  String get pressShortcutCombo => 'Tastenkombination drücken';

  @override
  String get clickToRecord => 'Klicken zum Festlegen';

  @override
  String get searchingLyrics => 'Songtexte suchen';

  @override
  String get noLyrics => 'Noch keine Songtexte';

  @override
  String get providerLabel => 'Anbieter';

  @override
  String get modelLabel => 'Modell';

  @override
  String get unspecified => 'Nicht angegeben';

  @override
  String targetTimeLabel(String duration) {
    return 'Zielzeit $duration';
  }

  @override
  String get songDeletedSkipped => 'Song gelöscht, übersprungen';

  @override
  String get songDeleted => 'Song gelöscht';

  @override
  String get lyricsTaskUploading => 'Hochladen';

  @override
  String get lyricsTaskWaiting => 'Warten';

  @override
  String get lyricsTaskRequesting => 'Anfrage läuft';

  @override
  String get lyricsTaskGenerating => 'Generieren';

  @override
  String get lyricsTaskRetrying => 'Wiederholen';

  @override
  String get lyricsTaskProcessing => 'Verarbeitung';

  @override
  String get unknownModel => 'Unbekanntes Modell';

  @override
  String selectedFolders(int count) {
    return '$count Ordner ausgewählt';
  }

  @override
  String foldersDeleted(int count) {
    return '$count Ordner gelöscht';
  }

  @override
  String get persistentAccessDenied =>
      'Zugriff auf diesen Ordner konnte nicht gespeichert werden. Bitte erneut auswählen.';

  @override
  String get folderAddFailed => 'Ordner konnte nicht hinzugefügt werden';

  @override
  String get sleepTimer => 'Sleep-Timer';

  @override
  String sleepTimerRemaining(Object duration) {
    return 'Sleep-Timer $duration';
  }

  @override
  String get unknownArtistOrAlbum => 'Unbekannt';

  @override
  String get pressAgainToExit => 'Erneut drücken, um die App zu beenden';

  @override
  String get tagCompletionSuccessWithCover =>
      'Tags vervollständigt und gespeichert, Cover heruntergeladen';

  @override
  String get tagCompletionSuccess => 'Tags vervollständigt und gespeichert';

  @override
  String get selectOnlineLyrics => 'Online-Songtexte auswählen';

  @override
  String get increaseLyricsFont => 'Schriftgröße vergrößern';

  @override
  String get decreaseLyricsFont => 'Schriftgröße verkleinern';

  @override
  String get restoreDefaultSize => 'Standardgröße wiederherstellen';

  @override
  String get adjustLyricsFont => 'Textgröße anpassen';

  @override
  String get searchingOnlineLyrics => 'Online-Songtexte suchen';

  @override
  String get onlineLyricsResults => 'Online-Songtext-Ergebnisse';

  @override
  String get untitledLyrics => 'Unbenannter Songtext';

  @override
  String get hasTimeline => 'Mit Zeitachse';

  @override
  String get viewLyricsDetails => 'Songtext-Details anzeigen';

  @override
  String get lyricsDetails => 'Songtext-Details';

  @override
  String get lyricsContent => 'Songtext-Inhalt';

  @override
  String get noLyricsContent => 'Kein Songtext-Inhalt';

  @override
  String get queryContentLabel => 'Inhalt';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String dropAddedSongs(int addedCount) {
    return '$addedCount Songs hinzugefügt';
  }

  @override
  String dropAddedSongsWithExisting(int addedCount, int existingCount) {
    return '$addedCount Songs hinzugefügt, $existingCount bereits vorhanden';
  }

  @override
  String get copyCover => 'Cover in Zwischenablage kopieren';

  @override
  String get copyCoverSuccess =>
      'Cover erfolgreich in die Zwischenablage kopiert';

  @override
  String get searchLyricsPlaceholder =>
      'Songtitel, Künstler oder Text eingeben';

  @override
  String get share => 'Teilen';

  @override
  String get windowsSettingsTitle => 'Windows-Einstellungen';

  @override
  String get fileAssociationTitle => 'Dateizuordnung';

  @override
  String get fileAssociationDescription =>
      'Musikformate (mp3, flac, wav...) dieser App zuordnen.';

  @override
  String get associateButton => 'Zuordnen';

  @override
  String get disassociateButton => 'Zuordnung aufheben';

  @override
  String get associationSuccess =>
      'Zuordnung erfolgreich! Falls Doppelklick nicht funktioniert, wählen Sie Vynody in den Standard-Apps.';

  @override
  String get disassociationSuccess => 'Dateizuordnung erfolgreich entfernt.';

  @override
  String associationFailed(Object error) {
    return 'Zuordnung fehlgeschlagen: $error';
  }

  @override
  String get onboardingTitle => 'Willkommen bei Vynody';

  @override
  String get onboardingSubtitle =>
      'Ein paar einfache Schritte, um Ihre Musikreise zu beginnen.';

  @override
  String get onboardingStepFileAssociation => 'Dateitypen zuordnen';

  @override
  String get onboardingFileAssociationDesc =>
      'Ordnen Sie Musikformate Vynody zu, um per Doppelklick abzuspielen.';

  @override
  String get onboardingFileAssociationTip =>
      'Nach der Zuordnung fordert das System Sie möglicherweise auf, eine Standard-App auszuwählen. Bitte wählen Sie \'Vynody\' aus der Liste und aktivieren Sie \'Immer diese App verwenden\'.';

  @override
  String get onboardingStepRootDirectory => 'Musikverzeichnis hinzufügen';

  @override
  String get onboardingRootDirectoryDesc =>
      'Wählen Sie den Ordner mit Ihrer Musik. Vynody erstellt automatisch Ihre Mediathek.';

  @override
  String get onboardingAndroidPermissionTip =>
      'Hinweis: Unter Android ist der Zugriff auf die Medienbibliothek erforderlich, um lokale Musik zu importieren und zu scannen. Beim Tippen auf [Ordner auswählen] wird nach der Berechtigung gefragt, bitte erlauben Sie diese.';

  @override
  String get onboardingSelectDirectory => 'Ordner auswählen';

  @override
  String get onboardingSuccessTitle => 'Alles bereit!';

  @override
  String get onboardingSuccessDesc =>
      'Mediathek erfolgreich hinzugefügt. Genießen Sie Ihre Musik!';

  @override
  String get onboardingStartButton => 'Vynody starten';

  @override
  String get onboardingSkip => 'Später einrichten';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingBack => 'Zurück';

  @override
  String get resetOnboarding => 'Einführungsguide zurücksetzen';

  @override
  String get resetOnboardingDesc =>
      'Der Einführungsguide wird beim nächsten Start erneut angezeigt.';

  @override
  String get songProperties => 'Song-Eigenschaften';

  @override
  String get failedToLoadDetails => 'Details konnten nicht geladen werden';

  @override
  String get noPropertiesAvailable =>
      'Keine detaillierten Eigenschaften verfügbar';

  @override
  String get detailFilePath => 'Dateipfad';

  @override
  String get detailFormat => 'Format';

  @override
  String get detailCodec => 'Codec';

  @override
  String get detailDuration => 'Dauer';

  @override
  String get detailFileSize => 'Dateigröße';

  @override
  String get detailBitrate => 'Bitrate';

  @override
  String get detailSampleRate => 'Abtastrate';

  @override
  String get detailChannels => 'Kanäle';

  @override
  String get detailBitDepth => 'Bittiefe';

  @override
  String get detailMono => 'Mono';

  @override
  String get detailStereo => 'Stereo';

  @override
  String detailChannelsCount(int count) {
    return '$count Kanäle';
  }

  @override
  String get localNetworkPermissionDeniedTitle =>
      'Lokaler Netzwerkzugriff eingeschränkt';

  @override
  String get localNetworkPermissionDeniedMessage =>
      'Keine lokale IP-Adresse verfügbar oder der Zugriff auf das lokale Netzwerk wurde verweigert.\n\nBitte überprüfen Sie Folgendes:\n1. Stellen Sie sicher, dass Ihr Gerät mit einem WLAN oder lokalen Netzwerk verbunden ist.\n2. Stellen Sie sicher, dass die App in den Systemeinstellungen auf das lokale Netzwerk zugreifen darf:\n   - iOS/macOS: Gehen Sie zu Einstellungen > Datenschutz & Sicherheit > Lokales Netzwerk und aktivieren Sie Vynody.\n   - Windows: Stellen Sie sicher, dass Sie verbunden sind, und überprüfen Sie die Firewall-Einstellungen, um Vynody den Zugriff zu erlauben.';

  @override
  String get localNetworkPermissionWindowsMessage =>
      'Keine lokale IP-Adresse verfügbar.\n\nPrüfen Sie:\n1. LAN-Verbindung (Wi-Fi oder Ethernet).\n2. Überprüfen Sie die Windows-Firewall für Vynody.';

  @override
  String get openSettingsButton => 'Einstellungen öffnen';

  @override
  String get closeButton => 'Schließen';

  @override
  String get copyTranslationResults => 'Übersetzungsergebnisse kopieren';

  @override
  String get writeLyricsToFile => 'Songtext in Datei schreiben';

  @override
  String get selectLyricSource => 'Songtext-Quelle auswählen';

  @override
  String get regenerateLyrics => 'Songtext neu generieren';

  @override
  String get regenerateLyricsConfirmation =>
      'Der aktuelle Songtext wird gelöscht und neu generiert. Fortfahren?';

  @override
  String get regenerateTimeline => 'Zeitachse neu generieren';

  @override
  String get regenerateTimelineConfirmation =>
      'Die aktuelle Zeitachse wird gelöscht und neu generiert. Fortfahren?';

  @override
  String get retranslateLyrics => 'Songtext neu übersetzen';

  @override
  String get retranslateLyricsConfirmation =>
      'Die aktuelle Übersetzung wird gelöscht und neu erstellt. Fortfahren?';

  @override
  String get translationCopiedToClipboard =>
      'Übersetzung in die Zwischenablage kopiert';

  @override
  String get writingLyrics => 'Songtext wird geschrieben...';

  @override
  String get lyricsWrittenToFile => 'Songtext erfolgreich in Datei geschrieben';

  @override
  String get writeLyricsFailed => 'Fehler beim Schreiben des Songtexts';

  @override
  String get externalLrcFile => 'Externe LRC-Datei';

  @override
  String get embeddedLyrics => 'Eingebetteter Songtext';

  @override
  String get manuallyAdjustedLyrics => 'Manuell angepasster Songtext';

  @override
  String get lrclibOnlineLyrics => 'LrcLib-Online-Songtext';

  @override
  String get aiGeneratedLyrics => 'KI-generierter Songtext';

  @override
  String get matchScore => 'Übereinstimmung';

  @override
  String get untitledRelease => 'Unbenannte Veröffentlichung';

  @override
  String get localSongFileNotFoundForGeneration =>
      'Die lokale Songdatei existiert nicht. Songtext kann nicht generiert werden.';

  @override
  String get localSongFileNotFoundForTimeline =>
      'Die lokale Songdatei existiert nicht. Zeitachse kann nicht generiert werden.';

  @override
  String get noLyricsForTimelineGeneration =>
      'Kein Songtext für die Zeitachsengenerierung verfügbar.';

  @override
  String get noLyricsAvailableForTranslation =>
      'Kein Songtext für die Übersetzung verfügbar.';

  @override
  String get noCurrentSongAvailable => 'Kein aktueller Song verfügbar.';

  @override
  String get invalidTargetLanguage => 'Ungültige Zielsprache.';

  @override
  String get songAlreadyQueuedForTranslation =>
      'Der Song ist bereits für die Übersetzung in der Warteschlange.';

  @override
  String get songAlreadyQueuedForGeneration =>
      'Der Song ist bereits für die Generierung in der Warteschlange.';

  @override
  String get songNoLongerExistsForTranslation =>
      'Der Song existiert nicht mehr. Übersetzung nicht möglich.';

  @override
  String get generationFailed => 'Generierung fehlgeschlagen.';

  @override
  String get generatingLyrics => 'Generiere Songtext';

  @override
  String get generatingTimeline => 'Generiere Zeitachse';

  @override
  String get regeneratingLyrics => 'Generiere Songtext neu';

  @override
  String get translatingLyrics => 'Übersetze Songtext';

  @override
  String get transcodingSongFile => 'Transkodiere Songdatei';

  @override
  String get uploadingSongFile => 'Lade Songdatei hoch';

  @override
  String get fileUploadedWaitingForReadiness =>
      'Datei hochgeladen, warte auf Bereitschaft';

  @override
  String get waitingForFileReadiness => 'Warte auf Dateibereitschaft';

  @override
  String get requestingModelResponse => 'Fordere Modellantwort an';

  @override
  String retryingTaskKindGeneration(Object taskKind) {
    return 'Wiederhole $taskKind-Generierung';
  }

  @override
  String get retrying => 'Wiederholen';

  @override
  String get processing => 'Verarbeitung';

  @override
  String get timeline => 'Zeitachse';

  @override
  String get lyrics => 'Songtext';

  @override
  String lyricGenerationError(Object error) {
    return 'Fehler bei der Songtext-Generierung: $error';
  }

  @override
  String timelineGenerationError(Object error) {
    return 'Fehler bei der Zeitachsen-Generierung: $error';
  }

  @override
  String get unknownGenerationError =>
      'Unbekannter Fehler bei der Songtext-Generierung.';

  @override
  String get unknownTimelineGenerationError =>
      'Unbekannter Fehler bei der Zeitachsen-Generierung.';

  @override
  String get unknownTranslationError =>
      'Unbekannter Fehler bei der Songtext-Übersetzung.';

  @override
  String get unknownError => 'Unbekannter Fehler';

  @override
  String get modelRefusedToGenerateLyrics =>
      'Das Modell hat die Songtext-Generierung verweigert.';

  @override
  String get modelRefusedToGenerateTimeline =>
      'Das Modell hat die Zeitachsen-Generierung verweigert.';

  @override
  String get doubaoPreUploadTranscodingFailed =>
      'Audio-Transkodierung vor Doubao-Upload fehlgeschlagen.';

  @override
  String get doubaoTempTranscodeNotInTempDir =>
      'Die temporäre Doubao-Datei wurde nicht im Temp-Verzeichnis erstellt.';

  @override
  String get doubaoEmptyStreamingResponse =>
      'Doubao hat eine leere Streaming-Antwort zurückgegeben.';

  @override
  String get doubaoEmptyResponse =>
      'Doubao hat eine leere Antwort zurückgegeben.';

  @override
  String get geminiEmptyStreamingResponse =>
      'Gemini hat eine leere Streaming-Antwort zurückgegeben.';

  @override
  String get geminiEmptyResponse =>
      'Gemini hat eine leere Antwort zurückgegeben.';

  @override
  String get openRouterEmptyStreamingResponse =>
      'OpenRouter hat eine leere Streaming-Antwort zurückgegeben.';

  @override
  String get openRouterEmptyResponse =>
      'OpenRouter hat eine leere Antwort zurückgegeben.';

  @override
  String get deepseekEmptyStreamingResponse =>
      'DeepSeek hat eine leere Streaming-Antwort zurückgegeben.';

  @override
  String get deepseekEmptyResponse =>
      'DeepSeek hat eine leere Antwort zurückgegeben.';

  @override
  String get customProviderEmptyStreamingResponse =>
      'Der benutzerdefinierte Anbieter hat eine leere Streaming-Antwort zurückgegeben.';

  @override
  String get customProviderEmptyResponse =>
      'Der benutzerdefinierte Anbieter hat eine leere Antwort zurückgegeben.';

  @override
  String get fileUploadFailed =>
      'Datei-Upload fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get uploadedFileNotReady =>
      'Die hochgeladene Datei wurde nicht bereit. Später erneut versuchen.';

  @override
  String get audioTranscodingFailed => 'Audio-Transkodierung fehlgeschlagen.';

  @override
  String get tempTranscodeNotInTempDir =>
      'Die temporäre Transkodierungsdatei wurde nicht im Temp-Verzeichnis erstellt.';

  @override
  String get networkRequestFailedCheckProxy =>
      'Netzwerkanfrage fehlgeschlagen. Überprüfen Sie Ihre Verbindung und Proxy-Einstellungen.';

  @override
  String get quotaExhaustedToday =>
      'Das heutige Kontingent ist aufgebraucht. Morgen erneut versuchen.';

  @override
  String get googleAiHeavyLoad =>
      'Google AI ist stark ausgelastet und vorübergehend nicht verfügbar.';

  @override
  String lyricsGenerationFailedWithError(Object error) {
    return 'Songtext-Generierung fehlgeschlagen: $error';
  }

  @override
  String missingApiKeyForAction(Object action, Object providerName) {
    return 'Kein API-Schlüssel für $providerName gefunden. $action nicht möglich.';
  }

  @override
  String locationNotSupportedForModel(String modelName) {
    return 'Standort wird für $modelName nicht unterstützt';
  }

  @override
  String get googleServerFlaky =>
      'Google hat gerade Probleme. Ein erneuter Versuch könnte funktionieren.';

  @override
  String get translateLyricsAction => 'Songtext übersetzen';

  @override
  String get generateLyricsAction => 'Songtext generieren';

  @override
  String get generateTimelineAction => 'Zeitachse generieren';

  @override
  String get deepseekOnlyTranslation =>
      'DeepSeek ist nur für die Songtext-Übersetzung verfügbar.';

  @override
  String get customProviderOnlyTranslation =>
      'Der benutzerdefinierte Anbieter ist nur für die Übersetzung verfügbar.';

  @override
  String get customProviderNoBaseUrl =>
      'Keine Basis-URL für den benutzerdefinierten Anbieter konfiguriert.';

  @override
  String get pleaseEnterApiKey => 'Bitte einen API-Schlüssel eingeben.';

  @override
  String get connectionSuccessVerificationPassed =>
      'Verbindung erfolgreich, Verifizierung bestanden.';

  @override
  String connectionSuccessDetectedModels(Object count) {
    return 'Verbindung erfolgreich, $count Modelle erkannt.';
  }

  @override
  String testFailedWithStatus(Object message, Object statusCode) {
    return 'Test fehlgeschlagen ($statusCode): $message';
  }

  @override
  String get testFailedCheckNetworkOrApiKey =>
      'Test fehlgeschlagen. Netzwerk oder API-Schlüssel prüfen.';

  @override
  String testFailedStatusCheckApiKey(Object statusCode) {
    return 'Test fehlgeschlagen ($statusCode). API-Schlüssel prüfen.';
  }

  @override
  String get enterGoogleAiStudioApiKeyFirst =>
      'Bitte zuerst einen Google AI Studio-API-Schlüssel eingeben.';

  @override
  String get enterDoubaoApiKeyFirst =>
      'Bitte zuerst einen Doubao-API-Schlüssel eingeben.';

  @override
  String get enterDeepseekApiKeyFirst =>
      'Bitte zuerst einen DeepSeek-API-Schlüssel eingeben.';

  @override
  String get enterCustomApiKeyAndBaseUrl =>
      'Bitte zuerst den benutzerdefinierten API-Schlüssel und die Basis-URL eingeben.';

  @override
  String fetchedCountModels(Object count) {
    return '$count Modelle abgerufen.';
  }

  @override
  String requestFailedWithStatus(Object message, Object statusCode) {
    return 'Anfrage fehlgeschlagen ($statusCode): $message';
  }

  @override
  String get requestFailedCheckNetwork =>
      'Anfrage fehlgeschlagen. Netzwerk prüfen.';

  @override
  String requestFailedStatus(Object statusCode) {
    return 'Anfrage fehlgeschlagen ($statusCode).';
  }

  @override
  String get doubao => 'Doubao';

  @override
  String get noModelSelected => 'Kein Modell ausgewählt';

  @override
  String get acoustidRequestFailed => 'AcoustID-Anfrage fehlgeschlagen';

  @override
  String acoustidRequestReturnedStatus(Object statusCode) {
    return 'AcoustID-Anfrage gab $statusCode zurück. Fordern Sie Ihren eigenen API-Schlüssel an.';
  }

  @override
  String get writeTagDatabaseFailed =>
      'Fehler beim Schreiben der Tag-Datenbank';

  @override
  String get playPause => 'Abspielen / Pause';

  @override
  String get nextTrack => 'Nächster';

  @override
  String get previousTrack => 'Vorheriger';

  @override
  String get volumeUp => 'Lauter';

  @override
  String get volumeDown => 'Leiser';

  @override
  String get toggleMute => 'Stumm schalten';

  @override
  String get seekForward5s => '5 s vorwärts';

  @override
  String get seekBackward5s => '5 s rückwärts';

  @override
  String get toggleFullScreen => 'Vollbild umschalten';

  @override
  String get playPauseDescription => 'Steuert den aktuellen Wiedergabestatus.';

  @override
  String get nextDescription => 'Zum nächsten Song springen.';

  @override
  String get previousDescription => 'Zum vorherigen Song zurückkehren.';

  @override
  String get volumeUpDescription => 'Lautstärke jedes Mal um 5% erhöhen.';

  @override
  String get volumeDownDescription => 'Lautstärke jedes Mal um 5% verringern.';

  @override
  String get toggleMuteDescription => 'Stummschaltung ein-/ausschalten.';

  @override
  String get seekForward5sDescription => '5 Sekunden vorwärts springen.';

  @override
  String get seekBackward5sDescription => '5 Sekunden rückwärts springen.';

  @override
  String get toggleFullScreenDescription =>
      'Zwischen Fenster- und Vollbildmodus wechseln.';

  @override
  String get unknownKey => 'Unbekannte Taste';

  @override
  String get removeFromQueue => 'Aus Warteschlange entfernen';

  @override
  String get removeFromPlaylist => 'Aus Playlist entfernen';

  @override
  String get alreadyLatestVersion => 'Sie haben bereits die neueste Version.';

  @override
  String get updateAvailable => 'Update verfügbar';

  @override
  String newVersionAvailable(Object version) {
    return 'Neue Version v$version verfügbar. Von GitHub Releases herunterladen.';
  }

  @override
  String get openRelease => 'Zu Release';

  @override
  String get checkUpdateFailedNetwork =>
      'Update-Prüfung fehlgeschlagen. Netzwerkproblem oder GitHub-Limit.';

  @override
  String get tags => 'Tags';

  @override
  String get about => 'Über';

  @override
  String get rebuildIndex => 'Index neu aufbauen';

  @override
  String get rebuildIndexDescription =>
      'Alle Song-Datensätze löschen (außer externe Quellen) und alle Stammverzeichnisse erneut scannen.';

  @override
  String get rebuildIndexConfirmation =>
      'Alle Datensätze löschen und erneut scannen? Dies kann einige Zeit dauern.';

  @override
  String get rebuildIndexStarted => 'Index-Neuaufbau gestartet';

  @override
  String get rebuild => 'Neu aufbauen';

  @override
  String get advanced => 'Erweitert';

  @override
  String get advancedOptionsDescription =>
      'Optionen für Debugging und Verhaltenssteuerung.';

  @override
  String get showDeveloperOptionsDescription =>
      'Erweiterte Debug-Optionen anzeigen.';

  @override
  String get onboardingReset =>
      'Einführungsguide zurückgesetzt. Wird beim Neustart wirksam.';

  @override
  String get tagsSectionDescription =>
      'Konfiguration von Audio-Metadaten und automatischer Vervollständigung.';

  @override
  String get autoSaveToSourceFile => 'Automatisch in Quelldatei speichern';

  @override
  String get autoSaveToSourceFileDescription =>
      'Tags automatisch in die physische Audiodatei schreiben.';

  @override
  String get aboutSectionDescription =>
      'Versionsinfo, Projektlinks und verwandte Ressourcen.';

  @override
  String get checkForUpdates => 'Nach Updates suchen';

  @override
  String get storeUpdateNotice =>
      'Updates für diese App werden vom Microsoft Store verwaltet. Sie können im Microsoft Store nach der neuesten Version suchen.';

  @override
  String get openMicrosoftStore => 'Zum Microsoft Store';

  @override
  String get appStoreUpdateNotice =>
      'Updates für diese App werden über den App Store verwaltet. Sie können im App Store nach der neuesten Version suchen.';

  @override
  String get openAppStore => 'Zum App Store';

  @override
  String get lyricsGenerationModel => 'Songtext-Generierungsmodell';

  @override
  String get lyricsGenerationModelDescription =>
      'Für KI-generierte Songtexte und Zeitachsen-Korrektur.';

  @override
  String get lyricsTranslationModel => 'Songtext-Übersetzungsmodell';

  @override
  String get lyricsTranslationModelDescription =>
      'Zum Übersetzen von Songtexten in die Zielsprache.';

  @override
  String get onlyForLyricTranslation => 'Nur für Übersetzung';

  @override
  String get fillApiKeyFirstEnablesModels =>
      'Füllen Sie mindestens einen API-Schlüssel aus, um die Modellauswahl zu aktivieren.';

  @override
  String get customApiProvider => 'Benutzerdefinierter API-Anbieter';

  @override
  String get clearedGoogleAiStudioApiKey =>
      'Google AI Studio-API-Schlüssel gelöscht';

  @override
  String get clearedOpenRouterApiKey => 'OpenRouter-API-Schlüssel gelöscht';

  @override
  String get clearedDoubaoApiKey => 'Doubao-API-Schlüssel gelöscht';

  @override
  String get clearedDeepseekApiKey => 'DeepSeek-API-Schlüssel gelöscht';

  @override
  String get clearedCustomProviderConfig =>
      'Benutzerdefinierte Anbieterkonfiguration gelöscht';

  @override
  String get savedDoubaoApiKey => 'Doubao-API-Schlüssel gespeichert';

  @override
  String get savedDeepseekApiKey => 'DeepSeek-API-Schlüssel gespeichert';

  @override
  String get savedCustomProviderConfig =>
      'Benutzerdefinierte Anbieterkonfiguration gespeichert';

  @override
  String get noMatchingFoldersOrSongs =>
      'Keine passenden Ordner oder Songs gefunden';

  @override
  String get searching => 'Suchen...';

  @override
  String get listView => 'Listenansicht';

  @override
  String get gridView => 'Rasteransicht';

  @override
  String get hybridView => 'Hybridansicht';

  @override
  String songsCountFormat(Object count) {
    return '$count Songs';
  }

  @override
  String get searchInFolderAndSubfolders =>
      'Im Ordner und Unterordnern suchen...';

  @override
  String get shuffle => 'Zufallswiedergabe';

  @override
  String get search => 'Suchen';

  @override
  String get selectFolders => 'Ordner auswählen';

  @override
  String get removeDirectory => 'Verzeichnis entfernen';

  @override
  String removeRootDirectoryConfirmation(Object name) {
    return 'Stammverzeichnis \"$name\" wirklich entfernen? Physische Dateien werden nicht gelöscht.';
  }

  @override
  String get deselectAll => 'Alle abwählen';

  @override
  String get favorites => 'Favoriten';

  @override
  String get aggregationPeak => 'Spitze';

  @override
  String get aggregationMean => 'Mittelwert';

  @override
  String get aggregationRms => 'RMS';

  @override
  String get filesToTranscode => 'Zu transkodierende Dateien';

  @override
  String get chooseAndroidOutputDirectoryFirst =>
      'Bitte zuerst ein Android-Ausgabeverzeichnis wählen.';

  @override
  String currentSongProgressPercent(Object percent) {
    return 'Aktueller Song $percent%';
  }

  @override
  String overallProgressPercent(Object percent) {
    return 'Gesamt $percent%';
  }

  @override
  String get pleaseChooseOutputDirectory =>
      'Bitte ein Ausgabeverzeichnis wählen.';

  @override
  String selectedArtistsCount(Object count) {
    return '$count Künstler ausgewählt';
  }

  @override
  String selectedAlbumsCount(Object count) {
    return '$count Alben ausgewählt';
  }

  @override
  String get simplifiedChinese => 'Vereinfachtes Chinesisch';

  @override
  String get traditionalChinese => 'Traditionelles Chinesisch';

  @override
  String get chineseLanguage => 'Chinesisch';

  @override
  String get englishLanguage => 'Englisch';

  @override
  String get japaneseLanguage => 'Japanisch';

  @override
  String get koreanLanguage => 'Koreanisch';

  @override
  String get frenchLanguage => 'Französisch';

  @override
  String get germanLanguage => 'Deutsch';

  @override
  String get spanishLanguage => 'Spanisch';

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
  String get portugueseLanguage => 'Portugiesisch';

  @override
  String get russianLanguage => 'Russisch';

  @override
  String get systemLanguage => 'Systemsprache';

  @override
  String get targetLanguage => 'Zielsprache';

  @override
  String get whatAreAiLyrics => 'Was sind KI-Songtexte?';

  @override
  String get whatIsAiLyricTranslation => 'Was ist KI-Songtext-Übersetzung?';

  @override
  String get aiLyricsIntroGeneration =>
      'KI kann Songtexte aus dem Song generieren und zeitlich ausrichten.';

  @override
  String get aiLyricsIntroTranslation =>
      'KI kann Songtexte in Ihre bevorzugte Sprache übersetzen.';

  @override
  String get whyNeedApiKey => 'Warum brauche ich einen API-Schlüssel?';

  @override
  String get apiKeyExplanation =>
      'Ein API-Schlüssel ist Ihre Zugangsberechtigung für einen KI-Anbieter. Die App verwendet ihn, um direkt Anfragen zur Songtext-Generierung, Zeitachsen-Anpassung oder Übersetzung an den Anbieter zu senden.';

  @override
  String get apiKeyLocalOnly =>
      'Ihr API-Schlüssel wird nur lokal gespeichert und niemals an Vynody-Server gesendet.';

  @override
  String get chooseAnAiProvider => 'Wählen Sie einen KI-Anbieter:';

  @override
  String get googleProviderPros =>
      'Offizieller Google-Kanal, leistungsstarke Gemini-Modelle, großzügige kostenlose Kontingente.';

  @override
  String get googleProviderCons =>
      'Kann bei hoher Last 429-Fehler verursachen. Bei Bedarf Anbieter wechseln.';

  @override
  String get openRouterProviderPros =>
      'Modell-Aggregator mit Zugang zu mehreren Anbietern und einigen kostenlosen Modellen.';

  @override
  String get openRouterProviderCons =>
      'Aufladungen können Gebühren enthalten. Website nur auf Englisch.';

  @override
  String get doubaoProviderPros =>
      'Von ByteDance, stark bei Chinesisch. 500k kostenlose Tokens pro Modell für Neulinge.';

  @override
  String get doubaoProviderCons =>
      'Registrierung erfordert echte Identitätsprüfung.';

  @override
  String get deepseekProviderPros =>
      'Gutes Chinesisch-Verständnis, niedriger Preis, ideal für Übersetzung.';

  @override
  String get deepseekProviderCons =>
      'Nur Texteingabe. Für Songtext-Generierung ist ein anderer Anbieter nötig.';

  @override
  String get highlights => 'Highlights';

  @override
  String get notes => 'Hinweise';

  @override
  String enterProviderApiKey(Object provider) {
    return 'Geben Sie Ihren $provider-API-Schlüssel ein:';
  }

  @override
  String get pasteYourApiKey => 'API-Schlüssel hier einfügen';

  @override
  String get getApiKey => 'API-Schlüssel besorgen';

  @override
  String get testConnectionButton => 'Verbindung testen';

  @override
  String get enableAiLyricGeneration => 'KI-Songtext-Generierung aktivieren';

  @override
  String get enableAiLyricTranslation => 'KI-Songtext-Übersetzung aktivieren';

  @override
  String get notNow => 'Jetzt nicht';

  @override
  String get startSetup => 'Einrichtung starten';

  @override
  String get chooseAiProvider => 'KI-Anbieter wählen';

  @override
  String get backStep => 'Zurück';

  @override
  String get continueAction => 'Fortfahren';

  @override
  String get nextStep => 'Weiter';

  @override
  String get configureApiKey => 'API-Schlüssel konfigurieren';

  @override
  String get saveAndFinish => 'Speichern und abschließen';

  @override
  String get testing => 'Test läuft...';

  @override
  String get noteTitle => 'Hinweis';

  @override
  String get deepseekTextInputOnlyNote =>
      'DeepSeek unterstützt nur Texteingabe. Für Songtext-Generierung einen anderen Anbieter nutzen.';

  @override
  String retryAttemptOfMax(Object attempt, Object maxRetry) {
    return 'Versuch $attempt/$maxRetry';
  }

  @override
  String generatingTaskKind(Object taskKind) {
    return 'Generiere $taskKind';
  }

  @override
  String connectionTestException(Object error) {
    return 'Verbindungstest-Fehler: $error';
  }

  @override
  String get testingConnectionProgress => 'Verbindung wird getestet...';

  @override
  String get clear => 'Löschen';

  @override
  String get enterDoubaoApiKey => 'Doubao-API-Schlüssel eingeben';

  @override
  String get doubaoApiKeyDescription =>
      'Geben Sie Ihren Volcano/Doubao-API-Schlüssel für Generierung und Übersetzung ein.';

  @override
  String get enterDeepseekApiKey => 'DeepSeek-API-Schlüssel eingeben';

  @override
  String get deepseekApiKeyDescription =>
      'Geben Sie Ihren DeepSeek-API-Schlüssel nur für die Übersetzung ein.';

  @override
  String get pleaseEnterApiKeyHint => 'Bitte API-Schlüssel eingeben';

  @override
  String get platform => 'Plattform';

  @override
  String get showRecommendedOnly => 'Nur empfohlene anzeigen';

  @override
  String get noAvailableChannels => 'Keine verfügbaren Kanäle';

  @override
  String get noMatchingModels => 'Keine passenden Modelle gefunden';

  @override
  String get leaveEmpty => 'Leer lassen';

  @override
  String get leaveEmptyFallbackDescription =>
      'Auswählen, um kein Backup-Modell zu verwenden.';

  @override
  String get modelSearchHint => 'Modellname oder ID eingeben';

  @override
  String sendFilesFailed(Object error) {
    return 'Senden fehlgeschlagen: $error';
  }

  @override
  String get scanningFolderMusic => 'Scanne Ordner nach Musikdateien...';

  @override
  String scanFolderFailed(Object error) {
    return 'Scannen fehlgeschlagen: $error';
  }

  @override
  String get noMusicFilesFound => 'Keine unterstützten Musikdateien gefunden';

  @override
  String sendFolderFailed(Object error) {
    return 'Senden des Ordners fehlgeschlagen: $error';
  }

  @override
  String get lanSharingStartFailed =>
      'LAN-Freigabe fehlgeschlagen. Netzwerkberechtigungen prüfen.';

  @override
  String syncingLyricsToDevice(Object deviceName) {
    return 'Songtexte zu $deviceName synchronisieren...';
  }

  @override
  String syncLyricsSuccess(Object matched, Object overwritten, Object skipped) {
    return 'Synchronisation abgeschlossen: $matched übereinstimmend, $overwritten aktualisiert, $skipped übersprungen';
  }

  @override
  String syncLyricsFailed(Object error) {
    return 'Songtext-Synchronisation fehlgeschlagen: $error';
  }

  @override
  String syncingLyricsFromDevice(Object deviceName) {
    return 'Songtexte von $deviceName empfangen...';
  }

  @override
  String get transferInProgressDoNotLeave =>
      'Übertragung läuft. Bitte verlassen Sie die Freigabeseite nicht.';

  @override
  String get lanSharingTitle => 'LAN-Verbindung';

  @override
  String get lanSharingEnabledStatus => 'LAN-Freigabe aktiviert';

  @override
  String get lanSharingDisabledStatus => 'LAN-Freigabe deaktiviert';

  @override
  String lanSharingRunningStatus(Object ip, Object port) {
    return 'Lokale IP: $ip (Port: $port)';
  }

  @override
  String get lanSharingDefaultOffHint =>
      'Standardmäßig deaktiviert. Die Aktivierung erfordert LAN-Berechtigung.';

  @override
  String get receiveDirectoryNotSetWarning =>
      'Kein Empfangsverzeichnis festgelegt. Bitte eins einrichten.';

  @override
  String get receiveDirectoryNoWritePermission =>
      'Das aktuelle Verzeichnis hat keine Schreibberechtigung. Bitte ändern.';

  @override
  String get restoreDefaultDirectory => 'Standardverzeichnis wiederherstellen';

  @override
  String get chooseOtherDirectory => 'Anderes Verzeichnis wählen';

  @override
  String get receiveDirectoryRestoredDefault =>
      'Standard-Empfangsverzeichnis wiederhergestellt';

  @override
  String receiveDirectoryUpdated(Object path) {
    return 'Empfangsverzeichnis aktualisiert auf: $path';
  }

  @override
  String get receiveDirectoryTitle => 'Empfangsverzeichnis';

  @override
  String get linkCopiedToClipboard => 'Link in die Zwischenablage kopiert';

  @override
  String get nearbyDevices => 'Geräte in der Nähe';

  @override
  String get searchingDevices => 'Suche nach anderen Geräten im LAN...';

  @override
  String get startSharingToFindDevices =>
      'Freigabe aktivieren, um Geräte zu finden';

  @override
  String get deviceOnline => 'Online';

  @override
  String get deviceOffline => 'Getrennt';

  @override
  String get sendMusicFiles => 'Musikdateien senden';

  @override
  String get sendFolder => 'Ordner senden';

  @override
  String get syncLyricsToDeviceAction => 'Songtexte an Gerät senden';

  @override
  String get syncLyricsFromDeviceAction => 'Songtexte von Gerät empfangen';

  @override
  String loadDevicesError(Object error) {
    return 'Fehler beim Laden der Geräte: $error';
  }

  @override
  String incomingFilesFormat(Object name1, Object name2, Object count) {
    return '$name1, $name2 und $count weitere Dateien';
  }

  @override
  String get incomingTransferRequestTitle =>
      'Eingehende Dateiübertragungsanfrage';

  @override
  String incomingTransferFrom(Object senderName) {
    return 'Anfrage von \"$senderName\":';
  }

  @override
  String fileSizeMb(Object sizeMb) {
    return 'Dateigröße: $sizeMb MB';
  }

  @override
  String get receiveFileHint =>
      'Empfangene Dateien werden im Musikordner gespeichert und zur Mediathek hinzugefügt.';

  @override
  String get reject => 'Ablehnen';

  @override
  String get accept => 'Annehmen';

  @override
  String get incomingLyricsExportTitle => 'Songtext-Exportanfrage';

  @override
  String incomingLyricsExportFrom(Object senderName) {
    return 'Gerät \"$senderName\" möchte Ihre Songtext-Bibliothek lesen und exportieren.';
  }

  @override
  String get incomingLyricsImportTitle => 'Songtext-Importanfrage';

  @override
  String incomingLyricsImportFrom(Object senderName, Object count) {
    return 'Gerät \"$senderName\" möchte Songtexte für $count Titel auf Ihr Gerät importieren.';
  }

  @override
  String get lyricsRequestRejected =>
      'Die Songtext-Synchronisationsanfrage wurde abgelehnt.';

  @override
  String sendCompleted(Object fileName) {
    return '\"$fileName\" gesendet';
  }

  @override
  String receiveCompleted(int count) {
    return '$count Songs erfolgreich empfangen';
  }

  @override
  String transferCancelledWithReason(Object direction, Object reason) {
    return '$direction abgebrochen ($reason)';
  }

  @override
  String transferFailedFormat(Object direction, Object fileName) {
    return '$direction \"$fileName\" fehlgeschlagen';
  }

  @override
  String sendingToDevice(Object deviceName) {
    return 'Sende an $deviceName';
  }

  @override
  String receivingFromDevice(Object deviceName) {
    return 'Empfange von $deviceName';
  }

  @override
  String progressFormat(Object percent) {
    return 'Fortschritt: $percent%';
  }

  @override
  String get currentlyTransferring => 'Derzeit wird übertragen';

  @override
  String get fileConflictTitle => 'Dateikonflikt';

  @override
  String get fileConflictMessage =>
      'Auf dem Zielgerät existiert bereits eine Datei mit demselben Namen:';

  @override
  String get fileConflictChooseAction => 'Bitte wählen Sie eine Aktion:';

  @override
  String get skipAction => 'Überspringen';

  @override
  String get overwriteAction => 'Überschreiben';

  @override
  String get skipAllAction => 'Alle überspringen';

  @override
  String get overwriteAllAction => 'Alle überschreiben';

  @override
  String get sendDirection => 'Senden';

  @override
  String get receiveDirection => 'Empfangen';

  @override
  String get fileAssociationEnabled => 'Verknüpfung aktiviert';

  @override
  String get fileAssociationDisabled => 'Verknüpfung deaktiviert';

  @override
  String get windowsAutoRepairShortcut =>
      'Startmenü-Verknüpfung automatisch reparieren';

  @override
  String get windowsAutoRepairShortcutDescription =>
      'Überprüft und erstellt die Startmenü-Verknüpfung bei jedem Start, um den korrekten Namen und das Symbol der Mediensteuerung anzuzeigen';

  @override
  String get confirmDisableShortcutRepair => 'Diese Funktion deaktivieren?';

  @override
  String get confirmDisableShortcutRepairContent =>
      'Ohne die Startmenü-Verknüpfung zeigt die Windows-Mediensteuerung die App möglicherweise als \"Unbekannt\" an und kein Symbol. Möchten Sie diese Funktion wirklich deaktivieren?';

  @override
  String get confirmDisable => 'Deaktivieren';

  @override
  String get enableSystemTray => 'System Tray aktivieren';

  @override
  String get enableSystemTrayDescription =>
      'Symbol in der Taskleiste anzeigen für schnelle Wiedergabesteuerung';

  @override
  String get closeToTray => 'Beim Schließen im Hintergrund minimieren';

  @override
  String get closeToTrayDescription =>
      'Beim Schließen des Hauptfensters im Hintergrund weiterspielen, ohne die App zu beenden';

  @override
  String get closeWindowActionTitle => 'Beim Schließen des Fensters';

  @override
  String get closeWindowActionDescription =>
      'Aktion beim Klick auf die Schließen-Schaltfläche auswählen';

  @override
  String get closeWindowActionAsk => 'Jedes Mal fragen';

  @override
  String get closeWindowActionMinimize => 'In den System-Tray minimieren';

  @override
  String get closeWindowActionExit => 'Anwendung beenden';

  @override
  String get closeWindowActionRemember =>
      'Auswahl merken und nicht mehr fragen';

  @override
  String get closeWindowActionTrayDisabledTip =>
      '(System-Tray muss zuerst aktiviert werden)';

  @override
  String get closeWindowDialogTitle => 'Fenster schließen bestätigen';

  @override
  String get closeWindowDialogContent =>
      'Bitte wählen Sie die Aktion beim Schließen des Fensters:';

  @override
  String get googleAiStudioApiKey => 'Google AI Studio API Key';

  @override
  String get openRouterApiKey => 'OpenRouter API Key';

  @override
  String get doubaoApiKey => 'Doubao API Key';

  @override
  String get deepseekApiKey => 'DeepSeek API Key';

  @override
  String get unexpectedResponseFormat => 'Unerwartetes Antwortformat.';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get openaiCompatibleEndpoint => 'OpenAI-kompatibler API-Endpunkt';

  @override
  String onboardingAddedDirectoriesCount(Object count) {
    return 'Hinzugefügte Verzeichnisse ($count):';
  }

  @override
  String get gnomeDisksOpenFailed =>
      'Festplatten-Dienstprogramm konnte nicht automatisch geöffnet werden. Bitte öffnen Sie \"Disks\" manuell aus Ihrem Anwendungsmenü.';

  @override
  String get gnomeDisksNotInstalled =>
      'gnome-disks ist nicht installiert. Bitte öffnen Sie Ihr Festplatten-Dienstprogramm, um zu konfigurieren.';

  @override
  String get linuxMountGuideTitle =>
      'Automatische Festplatteneinbindung konfigurieren';

  @override
  String get linuxMountGuideDescription =>
      'Standardmäßig bindet Linux externe Partitionen nicht automatisch ein. Wenn Sie keine automatische Einbindung beim Start konfigurieren, kann sich der Pfad externer Partitionen nach jedem Neustart ändern, sodass der Player nicht auf das Musikverzeichnis zugreifen kann. Um dies zu vermeiden, konfigurieren Sie bitte die automatische Einbindung der Partition mit Ihrer Musik beim Systemstart.';

  @override
  String get linuxMountGuideWarning =>
      'Achtung: Wenn sich Ihre Musik auf einer externen oder internen Partition befindet, die eingehängt werden muss, MÜSSEN Sie diese auf \"Beim Systemstart automatisch einhängen\" konfigurieren. Andernfalls wird das Musikverzeichnis nach einem Neustart möglicherweise nicht gefunden oder Sie müssen ein Passwort eingeben, um darauf zuzugreifen.';

  @override
  String get linuxMountGuideStep1 =>
      '1. Öffnen Sie das \"Disks\"-Dienstprogramm des Systems';

  @override
  String get linuxMountGuideStep2 =>
      '2. Wählen Sie Ihre Musikpartition aus und klicken Sie auf das ⚙️ Zahnradsymbol (Zusätzliche Partitionsoptionen)';

  @override
  String get linuxMountGuideStep3 =>
      '3. Wählen Sie \"Mount-Optionen bearbeiten\", deaktivieren Sie \"Benutzersitzungs-Standardwerte\" und aktivieren Sie \"Beim Systemstart einbinden\"';

  @override
  String get linuxMountGuideOpenButton =>
      'Datenträgerverwaltung (Disks) öffnen';

  @override
  String get unmute => 'Stummschaltung aufheben';

  @override
  String get mute => 'Stumm';

  @override
  String get disableSystemTray => 'System Tray deaktivieren';

  @override
  String get restoreWindow => 'Fenster wiederherstellen';

  @override
  String get hideWindow => 'Fenster ausblenden';

  @override
  String get onboardingAndroidBatteryTitle =>
      'Schutz für Hintergrund-Wiedergabe';

  @override
  String get onboardingAndroidBatteryDescription =>
      'Aufgrund der strengen Akku-Optimierungsrichtlinien von Android empfehlen wir, die Akku-Einschränkung für Vynody auf „Nicht eingeschränkt“ (Unrestricted) zu setzen, um zu verhindern, dass die Musikwiedergabe im Hintergrund beendet wird.';

  @override
  String get onboardingAndroidBatteryStep1 =>
      '1. Tippen Sie unten auf die Schaltfläche „Zu den Einstellungen“.';

  @override
  String get onboardingAndroidBatteryStep2 =>
      '2. Erlauben Sie im Systemdialog das Ignorieren der Akku-Optimierung oder navigieren Sie zu den Akku-Einstellungen.';

  @override
  String get onboardingAndroidBatteryStep3 =>
      '3. Wenn Sie zu den Einstellungen weitergeleitet werden, wählen Sie „Nicht eingeschränkt“ oder „Keine Einschränkung“.';

  @override
  String get onboardingAndroidBatteryButton => 'Zu den Einstellungen';

  @override
  String get onboardingAndroidBatteryStatusOptimized =>
      'Status: Eingeschränkt (Wiedergabe stoppt eventuell im Hintergrund)';

  @override
  String get onboardingAndroidBatteryStatusUnrestricted =>
      'Status: Nicht eingeschränkt (empfohlen, Wiedergabe geschützt)';

  @override
  String get onboardingAndroidMediaTitle => 'Zugriff auf die Musikbibliothek';

  @override
  String get onboardingAndroidMediaDescription =>
      'Nach der Freigabe kann Vynody alle Musikdateien aus der Systemmedienbibliothek direkt lesen – ohne ordnerweise Auswählen. Sie können Musik auch ohne Freigabe manuell aus Ordnern importieren.';

  @override
  String get onboardingAndroidMediaStep1 =>
      '1. Sofort einsatzbereit: Zeigt alle Musikstücke auf Ihrem Telefon direkt an';

  @override
  String get onboardingAndroidMediaStep2 =>
      '2. Automatisch entdecken: Neue Musik erscheint automatisch in der Bibliothek';

  @override
  String get onboardingAndroidMediaStep3 =>
      '3. Datenschutz sicher: Liest nur lokale Audiodateien und lädt Ihre Bibliothek nicht automatisch hoch (ausgenommen Cloud-Dienste wie AI-Songtexte)';

  @override
  String get onboardingAndroidMediaButton =>
      'Zugriff auf Musikbibliothek gewähren';

  @override
  String get onboardingAndroidMediaStatusGranted =>
      'Status: Gewährt (Empfohlen)';

  @override
  String get onboardingAndroidMediaStatusNotGranted =>
      'Status: Nicht gewährt (Ordner können später manuell importiert werden)';

  @override
  String get exitApp => 'Beenden';

  @override
  String get showScanProgressToastSetting => 'Scan-Status-Toast anzeigen';

  @override
  String get showScanProgressToastSettingDescription =>
      'Zeigt den Echtzeit-Scan-Fortschritt am oberen Bildschirmrand an, wenn Ordner gescannt werden.';

  @override
  String get openPlaybackOnDirectorySongTap =>
      'Beim Tippen auf einen Titel zur Wiedergabeseite wechseln';

  @override
  String get openPlaybackOnDirectorySongTapDescription =>
      'Wechselt automatisch zur Wiedergabeseite, wenn im Ordneransicht ein Titel angetippt wird.';

  @override
  String get defaultToLyricsModeOnPlaybackOpen =>
      'Standardmäßig Songtext-Modus auf der Wiedergabeseite';

  @override
  String get defaultToLyricsModeOnPlaybackOpenDescription =>
      'Wechselt beim Öffnen der Wiedergabeseite automatisch in den Songtext-Modus.';

  @override
  String get tapCoverToEnterLyricsMode =>
      'Cover antippen, um den Textmodus zu öffnen';

  @override
  String get longPressLyricsPanelToOpenMenu =>
      'Lange auf das Songtext-Panel drücken, um das Menü zu öffnen';

  @override
  String get gotIt => 'Verstanden';

  @override
  String get scanToastHiddenHint =>
      'Scan-Status-Toast ausgeblendet. Sie können ihn in Einstellungen - Oberfläche wieder aktivieren.';

  @override
  String get doubleSpeedPlayingSwipeUpToLock =>
      'Schnellvorlauf aktiv... Nach oben wischen zum Sperren';

  @override
  String get doubleSpeedLockedSwipeDownToUnlock =>
      'Schnellvorlauf gesperrt. Lange drücken und nach unten wischen zum Entsperren';

  @override
  String get doubleSpeedUnlocked => 'Schnellvorlauf entsperrt';

  @override
  String get lyricsImportExportHeader => 'Import & Export';

  @override
  String get exportAction => 'Exportieren';

  @override
  String get importAction => 'Importieren';

  @override
  String get exportLyricsLabel => 'Songtext-Sicherung exportieren';

  @override
  String get exportLyricsDescription =>
      'Alle zwischengespeicherten und angepassten Songtexte als JSON-Datei exportieren';

  @override
  String get importLyricsLabel => 'Songtext-Sicherung importieren';

  @override
  String get importLyricsDescription =>
      'Songtext-Cache aus einer exportierten JSON-Datei importieren';

  @override
  String exportSuccess(int count) {
    return '$count Songtexte erfolgreich exportiert.';
  }

  @override
  String exportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String importSuccess(int count) {
    return 'Import abgeschlossen! $count Songtexte erfolgreich importiert.';
  }

  @override
  String importFailed(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get importConflictsTitle => 'Import-Konflikte';

  @override
  String importConflictsMessage(int conflictCount) {
    return '$conflictCount widersprüchliche Songtexte in der Sicherung gefunden (existieren lokal, sind aber unterschiedlich). Bitte wählen Sie eine Vorgehensweise:';
  }

  @override
  String get overwriteAll => 'Alle überschreiben';

  @override
  String get skipAllConflicts => 'Konflikte überspringen';

  @override
  String get decideOneByOne => 'Einzeln entscheiden';

  @override
  String conflictResolutionTitle(int current, int total) {
    return 'Konflikt lösen ($current/$total)';
  }

  @override
  String get conflictExistingLabel => 'Vorhandene Songtexte';

  @override
  String get conflictImportedLabel => 'Importierte Songtexte';

  @override
  String conflictSourceLabel(String source) {
    return 'Quelle: $source';
  }

  @override
  String conflictTimeLabel(String time) {
    return 'Zeit: $time';
  }

  @override
  String get overwriteThis => 'Überschreiben';

  @override
  String get skipThis => 'Überspringen';

  @override
  String get overwriteRemaining => 'Alle verbleibenden überschreiben';

  @override
  String get skipRemaining => 'Alle verbleibenden überspringen';

  @override
  String get invalidBackupFile => 'Ungültige Sicherungsdatei';

  @override
  String get exportLogs => 'Protokolle exportieren';

  @override
  String get exportLogsSuccess => 'Protokolle erfolgreich exportiert';

  @override
  String get exportLogsFailed => 'Exportieren der Protokolle fehlgeschlagen';

  @override
  String get noLogFileFound => 'Keine Protokolldatei gefunden';

  @override
  String get uiDisplayScale => 'UI-Skalierung';

  @override
  String get uiDisplayScaleDescription =>
      'Größe aller UI-Elemente und Texte global anpassen, optimiert für Fahrzeug-Displays';

  @override
  String get uiDisplayScaleDialogTitle => 'UI-Skalierung / Fahrzeugmodus';

  @override
  String uiDisplayScaleCurrent(int percent) {
    return 'Aktuelle Skalierung: $percent%';
  }

  @override
  String get audioSettings => 'Audio-Einstellungen';

  @override
  String get audioSettingsDescription =>
      'Audiowiedergabe, Equalizer-Bänder und Wiedergabegeschwindigkeit verwalten';

  @override
  String get equalizerBandCount => 'Anzahl der Equalizer-Bänder';

  @override
  String get equalizerBandCountDescription =>
      'Anzahl der im Equalizer angezeigten Bänder konfigurieren. Bei vielen Bändern wird automatisches horizontales Scrollen aktiviert.';

  @override
  String bandsCountOption(int count) {
    return '$count Bänder';
  }

  @override
  String get enableFadeEffect => 'Audio-Überblendungseffekt';

  @override
  String get enableFadeEffectDescription =>
      'Sanfte Ein-/Ausblendungen und Überblendungen beim Titelwechsel, Abspielen und Pausieren aktivieren';

  @override
  String get buttonLayoutSettings => 'Schaltflächen-Layout';

  @override
  String get playbackButtonLayoutTitle =>
      'Schaltflächen-Layout der Wiedergabeseite';

  @override
  String get playbackButtonLayoutDescription =>
      'Passen Sie die Reihenfolge und Anzeige der Schaltflächen in den 7- und 5-Schaltflächen-Zeilen an';

  @override
  String get topButtonsRowTitle => 'Reihenfolge der 7-Schaltflächen-Zeile';

  @override
  String get mainButtonsRowTitle =>
      'Linker & rechter Button der 5-Schaltflächen-Zeile';

  @override
  String get mainControlsLeftButton => 'Linke Schaltfläche';

  @override
  String get mainControlsRightButton => 'Rechte Schaltfläche';

  @override
  String get lyricsHeaderRightButtonTitle =>
      'Rechte Schaltfläche bei eingeklappter Songtext-Titelleiste';

  @override
  String get resetButtonOrder => 'Standard-Layout wiederherstellen';

  @override
  String get btnMore => 'Mehr-Menü';

  @override
  String get btnFavorite => 'Favorit';

  @override
  String get btnPlaylistMode => 'Wiedergabemodus';

  @override
  String get btnShuffle => 'Zufallswiedergabe';

  @override
  String get btnTagCompletion => 'Tag-Vervollständigung';

  @override
  String get btnSleepTimer => 'Sleeptimer';

  @override
  String get btnEqualizer => 'Equalizer';

  @override
  String get btnVisualizer => 'Visualizer';

  @override
  String get btnVolume => 'Lautstärke';

  @override
  String get remoteControlAction => 'Fernsteuerung';

  @override
  String get remoteControlRequestTitle => 'Fernsteuerungsanfrage';

  @override
  String remoteControlRequestFrom(String name) {
    return 'Gerät \"$name\" möchte die Wiedergabe steuern';
  }

  @override
  String get remotePinPairHint =>
      'Bitte gib den folgenden Kopplungs-PIN-Code auf dem Steuergerät ein:';

  @override
  String get remotePinExpiresIn => 'PIN läuft ab in:';

  @override
  String get allowDirectly => 'Direkt zulassen';

  @override
  String get enterRemotePinTitle => 'Gerätekopplung';

  @override
  String enterRemotePinPrompt(String name) {
    return 'Gib die 4-stellige PIN ein, die auf \"$name\" angezeigt wird:';
  }

  @override
  String get remotePinInvalid =>
      'Ungültige oder abgelaufene PIN. Bitte versuche es erneut.';

  @override
  String remotePinCooldown(int seconds) {
    return 'Falsche PIN, erneuter Versuch in ${seconds}s';
  }

  @override
  String remotePinAttemptsRemaining(int count) {
    return '(noch $count Versuche)';
  }

  @override
  String get remotePinTooManyAttempts =>
      'Zu viele Fehlversuche. Kopplungssitzung abgelaufen.';

  @override
  String get remoteConnected => 'Verbunden';

  @override
  String get remoteConnecting => 'Verbinde...';

  @override
  String get remoteDisconnect => 'Trennen';

  @override
  String get remoteConnectFailed => 'Fernverbindung fehlgeschlagen';

  @override
  String controlledByRemoteDevices(String devices) {
    return 'Wird von folgenden Remote-Geräten gesteuert: $devices';
  }

  @override
  String get trustedDevicesTitle => 'Vertrauenswürdige Fernbedienungsgeräte';

  @override
  String get manageTrustedDevicesTitle =>
      'Vertrauenswürdige Fernbedienungsgeräte verwalten';

  @override
  String get removeTrustedDevice => 'Vertrauen entfernen';

  @override
  String get noMusicPlaying => 'Keine Musikwiedergabe';

  @override
  String get previousSong => 'Vorheriger Titel';

  @override
  String get nextSong => 'Nächster Titel';

  @override
  String get shufflePlayback => 'Zufallswiedergabe';

  @override
  String get allowRemoteControlTitle => 'Fernsteuerung zulassen';

  @override
  String get allowRemoteControlSubtitle =>
      'Ermöglicht anderen LAN-Geräten nach der Kopplung die Steuerung der Musikwiedergabe';

  @override
  String get remoteControlDisabledOnHost =>
      'Fernsteuerung ist auf dem Zielgerät deaktiviert';

  @override
  String get trustThisDevice =>
      'Diesem Gerät vertrauen und künftig automatisch zulassen';

  @override
  String get remoteRequestRejected =>
      'Die Verbindungsanfrage wurde vom Zielgerät abgelehnt.';

  @override
  String get turkishLanguage => 'Türkisch';

  @override
  String get nativeLanguageTr => 'Türkçe';

  @override
  String trustedDevicesCount(int count) {
    return '$count vertrauenswürdige Geräte';
  }

  @override
  String get noTrustedDevices => 'Keine vertrauenswürdigen Geräte';

  @override
  String get noTrustedDevicesHint =>
      'Geräte werden hier angezeigt, wenn beim Koppeln „Diesem Gerät vertrauen“ ausgewählt wurde';

  @override
  String pairedAtFormat(String time) {
    return 'Gekoppelt am: $time';
  }

  @override
  String transferCancelled(String direction) {
    return '$direction abgebrochen';
  }

  @override
  String get audioFiles => 'Audiodateien';

  @override
  String get remotePairCancelledByClient =>
      'Die Kopplungsanfrage wurde vom Zielgerät abgebrochen.';

  @override
  String get proFeatureAiLyricsTitle => 'KI-Songtexte & Übersetzung';

  @override
  String get proFeatureAiLyricsDesc =>
      'KI-Songtextgenerierung, Zeitachsen-Synchronisation und Übersetzung';

  @override
  String get proFeatureTagCompletionTitle => 'Metadaten-Autovervollständigung';

  @override
  String get proFeatureTagCompletionDesc =>
      'Automatische Vervollständigung von Tags und Album-Metadaten über MusicBrainz';

  @override
  String get proFeatureEqualizerTitle =>
      'Mehrband-Equalizer & Geschwindigkeit (EQ)';

  @override
  String get proFeatureEqualizerDesc =>
      'Professionelle Frequenzabstimmung, 0,5x–5,0x Wiedergabegeschwindigkeit, Vorverstärkung und Soundstile';

  @override
  String get proFeatureCustomThemeColorTitle =>
      'Vollspektrum-Designs & Erweiterte Farbgebung';

  @override
  String get proFeatureCustomThemeColorDesc =>
      'Schalten Sie die freie Farbauswahlpalette und exklusive Premium-Voreinstellungen frei';

  @override
  String get proFeatureFftVisualizerTitle => 'Echtzeit-FFT-Audiospektrum';

  @override
  String get proFeatureFftVisualizerDesc =>
      '6 Spektrum-Stile (Klassische Balken, Glatte Welle, Schwebende Kappen, Radial Halo, Neon-Matrix, Gespiegelte Welle) & Vollbild-Ambient-Modus';

  @override
  String get proFeatureWaveformBarTitle =>
      'Dynamische Wellenform-Fortschrittsleiste';

  @override
  String get proFeatureWaveformBarDesc =>
      'Echtzeit-Wellenformextraktion mit flüssiger interaktiver Suche';

  @override
  String get proFeatureLanSharingTitle => 'LAN-Musikfreigabe';

  @override
  String get proFeatureLanSharingDesc =>
      'Schnelle Dateifreigabe und Übertragung im lokalen Netzwerk';

  @override
  String get proFeatureRemoteControlTitle =>
      'Geräteübergreifende Fernsteuerung';

  @override
  String get proFeatureRemoteControlDesc =>
      'Nahtlose Verbindung und kabellose Wiedergabesteuerung zwischen Geräten';

  @override
  String get proFeatureTranscoderTitle => 'Stapel-Audiokonverter';

  @override
  String get proFeatureTranscoderDesc =>
      'Schnelle verlustfreie Formatkonvertierung und Export für tragbare Geräte';

  @override
  String get proFeatureDynamicMeshBackgroundTitle =>
      'Dynamischer Mesh-Hintergrund';

  @override
  String get proFeatureDynamicMeshBackgroundDesc =>
      'Fließende Farbverlaufsanimationen basierend auf Album-Cover mit anpassbarer Geschwindigkeit';

  @override
  String get proFeatureCustomImageBackgroundTitle =>
      'Benutzerdefiniertes Hintergrundbild';

  @override
  String get proFeatureCustomImageBackgroundDesc =>
      'Eigene Bilder und Fotos als immersiven Wiedergabehintergrund importieren';

  @override
  String get proCommunityUnlocked =>
      'Community-Edition: Alle Pro-Funktionen dauerhaft freigeschaltet';

  @override
  String proTrialActive(int days) {
    return 'Kostenlose Testphase aktiv (noch $days Tage)';
  }

  @override
  String get proTrialExpired =>
      'Testphase abgelaufen. Upgrade auf Pro für alle Funktionen';

  @override
  String get proPermanentlyActivated =>
      'Alle Pro-Funktionen dauerhaft aktiviert';

  @override
  String proStatusTrialTitle(int days) {
    return 'Lizenzstatus: $days Tage kostenlose Testphase aktiv';
  }

  @override
  String get proStatusTrialExpiredTitle =>
      'Lizenzstatus: Testphase abgelaufen (Funktionen eingeschränkt)';

  @override
  String get proStatusActivatedTitle => 'Lizenzstatus: Vynody Pro aktiviert';

  @override
  String proSettingsTrialRemaining(int days) {
    return 'Noch $days Tage Testphase';
  }

  @override
  String get proSettingsUpgradePrompt =>
      'Upgrade für KI-Texte, FFT-Spektrum und Pro-Funktionen';

  @override
  String get proSettingsLifetimeNotice =>
      'Alle Pro-Funktionen und zukünftige Updates inklusive';

  @override
  String get proSettingsUpgrade => 'Upgrade';

  @override
  String get proSettingsView => 'Ansehen';

  @override
  String get connectingToStore => 'Verbindung zum Store wird hergestellt...';

  @override
  String get buyFullVersionWindowsTrial =>
      'Vollversion im Microsoft Store kaufen';

  @override
  String get buyFullVersionWindows => 'Vollversion im Microsoft Store kaufen';

  @override
  String unlockProLifetimeWithPrice(String price) {
    return '$price Dauerhafte Pro-Freischaltung';
  }

  @override
  String get buyProTrialEarly => 'Dauerhafte Pro-Lizenz kaufen';

  @override
  String get upgradeToProNow => 'Jetzt auf Pro upgraden';

  @override
  String get iUnderstand => 'Verstanden';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get restoringPurchases => 'Käufe werden wiederhergestellt...';

  @override
  String get sharingProDescription =>
      'Die LAN-Verbindung ist eine exklusive Vynody Pro-Funktion. Schalten Sie sie frei, um blitzschnelle Dateiübertragung, Mediathek-Synchronisation und drahtlose Fernsteuerung im lokalen Netzwerk zu nutzen.';

  @override
  String get sharingHighlightSpeedTitle => 'Schnelle LAN-Übertragung';

  @override
  String get sharingHighlightSpeedDesc =>
      'Direkte verlustfreie Übertragung im WLAN ohne Datenverbrauch oder Komprimierung.';

  @override
  String get sharingHighlightSyncTitle => 'Mediathek- & Text-Synchronisation';

  @override
  String get sharingHighlightSyncDesc =>
      'Ein-Klick-Übertragung heruntergeladener Texte und Lieder zur geräteübergreifenden Synchronisation.';

  @override
  String get sharingHighlightRemoteTitle => 'Kabellose Fernsteuerung';

  @override
  String get sharingHighlightRemoteDesc =>
      'Nahtlose Steuerung von Wiedergabe, Titeln und Lautstärke über Smartphones, Tablets und PCs.';

  @override
  String get sharingHighlightSecurityTitle =>
      'Ende-zu-Ende TLS-Verschlüsselung';

  @override
  String get sharingHighlightSecurityDesc =>
      'Vollständige TLS-Zertifikatsverschlüsselung und Geräte-Pairing für sichere Übertragungen.';

  @override
  String get upgradeToProToUnlock => 'Auf Vynody Pro upgraden';

  @override
  String get proOneTimePurchaseNotice =>
      'Einmaliger Kauf, schaltet alle Pro-Funktionen auf dieser Plattform dauerhaft frei';

  @override
  String get proOneTimePurchaseNoticeApple =>
      'Einmaliger Kauf, schaltet alle Pro-Funktionen auf Apple-Plattformen (iPhone / iPad / Mac) dauerhaft frei';

  @override
  String get proUniversalPurchaseNoticeApple =>
      'Einmaliger Kauf, nutzbar auf iPhone, iPad und Mac';

  @override
  String get iapPurchaseSuccess =>
      'Vynody Pro erfolgreich gekauft! Vielen Dank für Ihre Unterstützung!';

  @override
  String get iapRestoreSuccess =>
      'Vynody Pro-Käufe erfolgreich wiederhergestellt!';

  @override
  String iapPurchaseCancelledOrFailed(String message) {
    return 'Kauf nicht abgeschlossen oder abgebrochen: $message';
  }

  @override
  String get tabLanSharing => '局域网互传 & 遥控';

  @override
  String get tabCloudServers => '云端媒体库';

  @override
  String get addRemoteServer => '添加媒体服务器';

  @override
  String get editRemoteServer => '编辑媒体服务器';

  @override
  String get serverName => '服务器名称';

  @override
  String get serverNameAlreadyExists => '服务器名称已存在，请使用其他名称';

  @override
  String get serverType => '服务类型';

  @override
  String get serverUrl => '服务器地址 (URL)';

  @override
  String get serverUsername => '用户名';

  @override
  String get serverPassword => '密码 / Token';

  @override
  String get customPath => '指定路径 (可选)';

  @override
  String get maxBitRate => '转码码率限制 (kbps)';

  @override
  String get ignoreSsl => '忽略 SSL 证书校验';

  @override
  String get connectionSuccess => '连接成功';

  @override
  String get connectionFailed => '连接失败';

  @override
  String get noRemoteServers => '暂无连接的媒体服务器';

  @override
  String get noRemoteServersDesc =>
      '添加 Navidrome (Subsonic) 或 WebDAV 服务器，畅享自建私有云音乐';

  @override
  String get browseServer => '浏览';

  @override
  String get manageServer => '管理';

  @override
  String get deleteServerConfirm => '确定要删除此媒体服务器连接吗？';

  @override
  String get remoteSongCannotEditTags =>
      'Tags von Remote-Titeln können nicht geändert werden';

  @override
  String get addToServerPlaylist => '添加到服务端歌单';

  @override
  String get addToLocalPlaylist => '添加到本地歌单';

  @override
  String get serverPlaylists => '服务端歌单';

  @override
  String get localPlaylists => '本地歌单';

  @override
  String get createNewServerPlaylist => '新建服务端歌单';

  @override
  String get downloadSong => '下载歌曲';

  @override
  String get downloadAlbum => '下载整张专辑';

  @override
  String get downloadArtist => '下载艺术家全部歌曲';

  @override
  String downloadStarted(Object title) {
    return '正在下载: $title';
  }

  @override
  String downloadCompleted(Object title) {
    return '已保存至本地音乐库: $title';
  }

  @override
  String downloadFailed(Object error) {
    return '下载失败: $error';
  }

  @override
  String get alreadyDownloaded => '该歌曲已在本地音乐库中存在';

  @override
  String get starItem => '加入服务端收藏';

  @override
  String get unstarItem => '取消服务端收藏';

  @override
  String get starredSuccess => '已加入服务端收藏';

  @override
  String get unstarredSuccess => '已取消服务端收藏';

  @override
  String batchDownloadStarted(Object count) {
    return '正在后台下载 $count 首歌曲...';
  }

  @override
  String batchDownloadCompleted(Object count) {
    return '已下载 $count 首歌曲到本地音乐库';
  }

  @override
  String get viewAlbum => '查看专辑';

  @override
  String get viewArtist => '查看艺术家';

  @override
  String get downloadManager => '下载管理';

  @override
  String get downloadingTab => '正在下载';

  @override
  String get completedTab => '已完成';

  @override
  String get pauseAll => '全部暂停';

  @override
  String get resumeAll => '全部继续';

  @override
  String get cancelAll => '全部取消';

  @override
  String get clearCompleted => '清空记录';

  @override
  String get noActiveDownloads => '没有正在进行的下载任务';

  @override
  String get noCompletedDownloads => '暂无已完成的下载记录';

  @override
  String get viewDownloadProgress => '查看进度';

  @override
  String get addedToDownloadQueue => '已加入下载队列';

  @override
  String batchAddedToDownloadQueue(Object count) {
    return '已将 $count 首歌曲加入下载队列';
  }

  @override
  String get downloadFolder => '下载保存目录';

  @override
  String get downloadAllAudio => '下载本目录全部音频';
}
