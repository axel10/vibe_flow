import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// The title of the application
  ///
  /// In zh, this message translates to:
  /// **'Vynody'**
  String get appTitle;

  /// Tooltip for always on top / pin button in window title bar
  ///
  /// In zh, this message translates to:
  /// **'置顶'**
  String get alwaysOnTop;

  /// System media library
  ///
  /// In zh, this message translates to:
  /// **'系统媒体库'**
  String get systemMediaLibrary;

  /// Scanning directory message
  ///
  /// In zh, this message translates to:
  /// **'正在扫描目录...'**
  String get scanningDirectory;

  /// Scanning progress toast message showing how many files have had text metadata preprocessed
  ///
  /// In zh, this message translates to:
  /// **'预处理 {count} '**
  String filesPreprocessed(Object count);

  /// Scanning progress toast message showing how many files have been discovered
  ///
  /// In zh, this message translates to:
  /// **'已发现 {count} '**
  String filesDiscovered(Object count);

  /// Scanning progress toast message showing how many songs have been fully processed with thumbnails and theme colors
  ///
  /// In zh, this message translates to:
  /// **'完整处理 {count} '**
  String filesFullyProcessed(Object count);

  /// Directory added successfully
  ///
  /// In zh, this message translates to:
  /// **'目录添加成功'**
  String get directoryAddedSuccess;

  /// Directory added but no audio files found
  ///
  /// In zh, this message translates to:
  /// **'目录已添加，但未发现可播放音频文件'**
  String get directoryAddedNoMusic;

  /// Scan directory button
  ///
  /// In zh, this message translates to:
  /// **'扫描目录'**
  String get scanDirectory;

  /// Sort option
  ///
  /// In zh, this message translates to:
  /// **'排序'**
  String get sort;

  /// Add root directory
  ///
  /// In zh, this message translates to:
  /// **'添加根目录'**
  String get addRootDirectory;

  /// Go back to parent directory
  ///
  /// In zh, this message translates to:
  /// **'返回上一层'**
  String get goBack;

  /// No media library permission
  ///
  /// In zh, this message translates to:
  /// **'未获得媒体库访问权限'**
  String get noMediaLibraryPermission;

  /// Grant permission button
  ///
  /// In zh, this message translates to:
  /// **'给予权限'**
  String get grantPermission;

  /// Need permission to scan local music
  ///
  /// In zh, this message translates to:
  /// **'需授予权限以扫描本地音乐'**
  String get needPermissionToScan;

  /// Rebuild tag database
  ///
  /// In zh, this message translates to:
  /// **'重建标签数据库'**
  String get rebuildTagDatabase;

  /// Rebuild database
  ///
  /// In zh, this message translates to:
  /// **'重建数据库'**
  String get rebuildDatabase;

  /// Confirm rebuild database message
  ///
  /// In zh, this message translates to:
  /// **'确定要手动刷新所有歌曲的标签信息吗？这可能需要一些时间来重新加载封面和元数据。'**
  String get confirmRebuildDatabase;

  /// Cancel button
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// Confirm button
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirm;

  /// Rebuilding database message
  ///
  /// In zh, this message translates to:
  /// **'正在重建歌曲标签数据库...'**
  String get rebuildingDatabase;

  /// Sort by
  ///
  /// In zh, this message translates to:
  /// **'排序方式'**
  String get sortBy;

  /// No description provided for @sortScope.
  ///
  /// In zh, this message translates to:
  /// **'作用域'**
  String get sortScope;

  /// No description provided for @sortOrder.
  ///
  /// In zh, this message translates to:
  /// **'排序顺序'**
  String get sortOrder;

  /// Title
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get title;

  /// File name
  ///
  /// In zh, this message translates to:
  /// **'文件名'**
  String get fileName;

  /// Track number
  ///
  /// In zh, this message translates to:
  /// **'轨道号'**
  String get trackNumber;

  /// Ascending order
  ///
  /// In zh, this message translates to:
  /// **'升序'**
  String get ascending;

  /// Descending order
  ///
  /// In zh, this message translates to:
  /// **'降序'**
  String get descending;

  /// Current folder sort scope
  ///
  /// In zh, this message translates to:
  /// **'当前目录'**
  String get currentFolderScope;

  /// Global sort scope
  ///
  /// In zh, this message translates to:
  /// **'全局'**
  String get globalScope;

  /// Visualizer settings
  ///
  /// In zh, this message translates to:
  /// **'播放页设置'**
  String get visualizerSettings;

  /// Spectrum tab
  ///
  /// In zh, this message translates to:
  /// **'频谱'**
  String get algorithm;

  /// Appearance tab
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get appearance;

  /// Spectrum appearance group
  ///
  /// In zh, this message translates to:
  /// **'频谱外观'**
  String get spectrumAppearanceGroup;

  /// Spectrum advanced options
  ///
  /// In zh, this message translates to:
  /// **'频谱高级选项'**
  String get spectrumAdvancedOptions;

  /// Reset algorithm button
  ///
  /// In zh, this message translates to:
  /// **'重置算法'**
  String get resetAlgorithm;

  /// Reset appearance button
  ///
  /// In zh, this message translates to:
  /// **'重置外观'**
  String get resetAppearance;

  /// Smoothing coefficient
  ///
  /// In zh, this message translates to:
  /// **'平滑系数 (Smoothing)'**
  String get smoothing;

  /// Gravity coefficient
  ///
  /// In zh, this message translates to:
  /// **'重力系数 (Gravity)'**
  String get gravity;

  /// Log scale
  ///
  /// In zh, this message translates to:
  /// **'对数缩放 (Log Scale)'**
  String get logScale;

  /// Contrast
  ///
  /// In zh, this message translates to:
  /// **'对比度 (Contrast)'**
  String get contrast;

  /// Normalization
  ///
  /// In zh, this message translates to:
  /// **'归一化 (Normalization)'**
  String get normalization;

  /// Multiplier
  ///
  /// In zh, this message translates to:
  /// **'增益 (Multiplier)'**
  String get multiplier;

  /// Skip high frequency
  ///
  /// In zh, this message translates to:
  /// **'跳过高频'**
  String get skipHighFrequency;

  /// Frequency groups
  ///
  /// In zh, this message translates to:
  /// **'频率分组 (Frequency Groups)'**
  String get frequencyGroups;

  /// Aggregation mode
  ///
  /// In zh, this message translates to:
  /// **'聚合模式 (Aggregation Mode)'**
  String get aggregationMode;

  /// Opacity
  ///
  /// In zh, this message translates to:
  /// **'透明度 (Opacity)'**
  String get opacity;

  /// Enable gradient
  ///
  /// In zh, this message translates to:
  /// **'启用渐变色'**
  String get enableGradient;

  /// Start color
  ///
  /// In zh, this message translates to:
  /// **'起始颜色'**
  String get startColor;

  /// End color
  ///
  /// In zh, this message translates to:
  /// **'结束颜色'**
  String get endColor;

  /// Gradient range stop 1
  ///
  /// In zh, this message translates to:
  /// **'渐变范围 Stop 1'**
  String get gradientRangeStop1;

  /// Gradient range stop 2
  ///
  /// In zh, this message translates to:
  /// **'渐变范围 Stop 2'**
  String get gradientRangeStop2;

  /// Gradient repeat mode
  ///
  /// In zh, this message translates to:
  /// **'渐变重复模式 (TileMode)'**
  String get gradientRepeatMode;

  /// Color
  ///
  /// In zh, this message translates to:
  /// **'颜色'**
  String get color;

  /// Follow cover color
  ///
  /// In zh, this message translates to:
  /// **'跟随封面变色'**
  String get followCoverColor;

  /// Select color
  ///
  /// In zh, this message translates to:
  /// **'选择颜色'**
  String get selectColor;

  /// Volume
  ///
  /// In zh, this message translates to:
  /// **'音量'**
  String get volume;

  /// Clear queue
  ///
  /// In zh, this message translates to:
  /// **'清空队列'**
  String get clearQueue;

  /// Confirm clear queue message
  ///
  /// In zh, this message translates to:
  /// **'确定要清空当前队列吗？'**
  String get confirmClearQueue;

  /// Queue cleared message
  ///
  /// In zh, this message translates to:
  /// **'队列已清空'**
  String get queueCleared;

  /// Locate current playing song button tooltip
  ///
  /// In zh, this message translates to:
  /// **'定位当前播放'**
  String get locateCurrentSong;

  /// Toast message shown when the current song cannot be found in scanned directories
  ///
  /// In zh, this message translates to:
  /// **'当前歌曲不在扫描的目录中'**
  String get songNotInScannedFolders;

  /// Queue
  ///
  /// In zh, this message translates to:
  /// **'队列'**
  String get queue;

  /// Queue is empty
  ///
  /// In zh, this message translates to:
  /// **'队列为空'**
  String get queueEmpty;

  /// Selected songs count
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} 首'**
  String selectedSongs(int count);

  /// Unknown artist
  ///
  /// In zh, this message translates to:
  /// **'未知艺术家'**
  String get unknownArtist;

  /// Deleted songs count
  ///
  /// In zh, this message translates to:
  /// **'已删除 {count} 首歌曲'**
  String deletedSongs(int count);

  /// Delete button
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// Create playlist
  ///
  /// In zh, this message translates to:
  /// **'创建播放列表'**
  String get createPlaylist;

  /// Playlist name
  ///
  /// In zh, this message translates to:
  /// **'播放列表名称'**
  String get playlistName;

  /// Enter playlist name hint
  ///
  /// In zh, this message translates to:
  /// **'请输入播放列表名称'**
  String get enterPlaylistName;

  /// Error message when playlist name already exists
  ///
  /// In zh, this message translates to:
  /// **'播放列表名称已存在'**
  String get playlistNameExists;

  /// Rename playlist
  ///
  /// In zh, this message translates to:
  /// **'重命名播放列表'**
  String get renamePlaylist;

  /// Delete playlist
  ///
  /// In zh, this message translates to:
  /// **'删除播放列表'**
  String get deletePlaylist;

  /// Confirm delete playlist message
  ///
  /// In zh, this message translates to:
  /// **'确定要删除播放列表\"{name}\"吗？'**
  String confirmDeletePlaylist(String name);

  /// Add to playlist
  ///
  /// In zh, this message translates to:
  /// **'添加到播放列表'**
  String get addToPlaylist;

  /// Select all
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get selectAll;

  /// Add to queue
  ///
  /// In zh, this message translates to:
  /// **'添加到队列'**
  String get addToQueue;

  /// Added to queue
  ///
  /// In zh, this message translates to:
  /// **'已添加到队列'**
  String get addedToQueue;

  /// Song count
  ///
  /// In zh, this message translates to:
  /// **'{count} 首歌曲'**
  String songCount(int count);

  /// Added to playlist message
  ///
  /// In zh, this message translates to:
  /// **'已添加 {count} 首歌曲到{playlist}'**
  String addedToPlaylist(int count, String playlist);

  /// Create new list
  ///
  /// In zh, this message translates to:
  /// **'新建列表'**
  String get createNewList;

  /// Created playlist message
  ///
  /// In zh, this message translates to:
  /// **'已创建播放列表\"{name}\"并添加 {count} 首歌曲'**
  String createdPlaylist(String name, int count);

  /// Rename
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get rename;

  /// Playlist
  ///
  /// In zh, this message translates to:
  /// **'播放列表'**
  String get playlist;

  /// No description provided for @mostPlayed.
  ///
  /// In zh, this message translates to:
  /// **'最多播放'**
  String get mostPlayed;

  /// No description provided for @recentlyPlayed.
  ///
  /// In zh, this message translates to:
  /// **'最近播放'**
  String get recentlyPlayed;

  /// No description provided for @recentlyAdded.
  ///
  /// In zh, this message translates to:
  /// **'最近添加'**
  String get recentlyAdded;

  /// Albums tab and section label
  ///
  /// In zh, this message translates to:
  /// **'专辑'**
  String get albums;

  /// Artists tab and section label
  ///
  /// In zh, this message translates to:
  /// **'艺术家'**
  String get artists;

  /// No description provided for @mostPlayedDescription.
  ///
  /// In zh, this message translates to:
  /// **'按有效播放次数排序'**
  String get mostPlayedDescription;

  /// No description provided for @recentlyPlayedDescription.
  ///
  /// In zh, this message translates to:
  /// **'按最近播放时间排序，包含未入库文件'**
  String get recentlyPlayedDescription;

  /// No description provided for @recentlyAddedDescription.
  ///
  /// In zh, this message translates to:
  /// **'按进入媒体库的时间排序'**
  String get recentlyAddedDescription;

  /// No description provided for @allTime.
  ///
  /// In zh, this message translates to:
  /// **'全部时间'**
  String get allTime;

  /// No description provided for @pastWeek.
  ///
  /// In zh, this message translates to:
  /// **'过去一周'**
  String get pastWeek;

  /// No description provided for @pastMonth.
  ///
  /// In zh, this message translates to:
  /// **'过去一个月'**
  String get pastMonth;

  /// No description provided for @past90Days.
  ///
  /// In zh, this message translates to:
  /// **'过去三个月'**
  String get past90Days;

  /// No description provided for @noPlayHistory.
  ///
  /// In zh, this message translates to:
  /// **'还没有播放记录'**
  String get noPlayHistory;

  /// No description provided for @noPlayHistoryInRange.
  ///
  /// In zh, this message translates to:
  /// **'这个时间范围内还没有播放记录'**
  String get noPlayHistoryInRange;

  /// No description provided for @noRecentlyPlayedSongs.
  ///
  /// In zh, this message translates to:
  /// **'暂无播放历史记录'**
  String get noRecentlyPlayedSongs;

  /// No description provided for @noRecentlyPlayedInRange.
  ///
  /// In zh, this message translates to:
  /// **'这个时间范围内暂无播放历史'**
  String get noRecentlyPlayedInRange;

  /// No description provided for @noRecentlyAddedSongs.
  ///
  /// In zh, this message translates to:
  /// **'媒体库中还没有歌曲'**
  String get noRecentlyAddedSongs;

  /// No description provided for @noRecentlyAddedInRange.
  ///
  /// In zh, this message translates to:
  /// **'这个时间范围内没有新添加的歌曲'**
  String get noRecentlyAddedInRange;

  /// No description provided for @addedOn.
  ///
  /// In zh, this message translates to:
  /// **'添加时间'**
  String get addedOn;

  /// No description provided for @externalSourceTag.
  ///
  /// In zh, this message translates to:
  /// **'外部'**
  String get externalSourceTag;

  /// No description provided for @lastPlayed.
  ///
  /// In zh, this message translates to:
  /// **'最近播放'**
  String get lastPlayed;

  /// No description provided for @playCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'{count} 次'**
  String playCountLabel(int count);

  /// Play all songs in the current album
  ///
  /// In zh, this message translates to:
  /// **'播放全部'**
  String get playAll;

  /// Shuffle play songs in the current album
  ///
  /// In zh, this message translates to:
  /// **'随机播放'**
  String get shufflePlay;

  /// Empty state text when no albums are available
  ///
  /// In zh, this message translates to:
  /// **'还没有可显示的专辑'**
  String get noAlbums;

  /// Empty state text when no artists are available
  ///
  /// In zh, this message translates to:
  /// **'还没有可显示的艺术家'**
  String get noArtists;

  /// Search albums or artists placeholder
  ///
  /// In zh, this message translates to:
  /// **'搜索专辑或艺术家'**
  String get searchAlbums;

  /// Search artists placeholder
  ///
  /// In zh, this message translates to:
  /// **'搜索艺术家'**
  String get searchArtists;

  /// Album sort button label
  ///
  /// In zh, this message translates to:
  /// **'排序'**
  String get albumSort;

  /// Sort albums by artist ascending
  ///
  /// In zh, this message translates to:
  /// **'艺术家 A-Z'**
  String get sortArtistAsc;

  /// Sort albums by album title ascending
  ///
  /// In zh, this message translates to:
  /// **'专辑名 A-Z'**
  String get sortTitleAsc;

  /// Sort albums by song count
  ///
  /// In zh, this message translates to:
  /// **'歌曲数量'**
  String get sortTrackCount;

  /// Sort albums by total duration
  ///
  /// In zh, this message translates to:
  /// **'总时长'**
  String get sortDuration;

  /// Sort albums by recent add time
  ///
  /// In zh, this message translates to:
  /// **'最近添加'**
  String get sortRecentAdded;

  /// Ascending sort order
  ///
  /// In zh, this message translates to:
  /// **'升序'**
  String get sortAscending;

  /// Descending sort order
  ///
  /// In zh, this message translates to:
  /// **'降序'**
  String get sortDescending;

  /// Play next action
  ///
  /// In zh, this message translates to:
  /// **'下一首播放'**
  String get playNext;

  /// Add current album or song to favorites
  ///
  /// In zh, this message translates to:
  /// **'加入收藏'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In zh, this message translates to:
  /// **'取消收藏'**
  String get removeFromFavorites;

  /// View album details action
  ///
  /// In zh, this message translates to:
  /// **'查看专辑详情'**
  String get viewAlbumDetails;

  /// View artist details action
  ///
  /// In zh, this message translates to:
  /// **'查看艺术家详情'**
  String get viewArtistDetails;

  /// Open the file location action
  ///
  /// In zh, this message translates to:
  /// **'打开文件所在位置'**
  String get openFileLocation;

  /// Copy album title action
  ///
  /// In zh, this message translates to:
  /// **'复制专辑名'**
  String get copyAlbumTitle;

  /// Copy artist name action
  ///
  /// In zh, this message translates to:
  /// **'复制艺术家名'**
  String get copyArtistName;

  /// Album count summary
  ///
  /// In zh, this message translates to:
  /// **'{count} 张专辑'**
  String albumCount(int count);

  /// List is empty
  ///
  /// In zh, this message translates to:
  /// **'列表为空'**
  String get emptyList;

  /// Drag to add music hint
  ///
  /// In zh, this message translates to:
  /// **'拖入文件或文件夹以添加音乐'**
  String get dragToAddMusic;

  /// Unknown album
  ///
  /// In zh, this message translates to:
  /// **'未知专辑'**
  String get unknownAlbum;

  /// Manage playlists
  ///
  /// In zh, this message translates to:
  /// **'管理播放列表'**
  String get managePlaylists;

  /// Create new playlist
  ///
  /// In zh, this message translates to:
  /// **'创建新播放列表'**
  String get createNewPlaylist;

  /// Default playlist
  ///
  /// In zh, this message translates to:
  /// **'默认列表'**
  String get defaultList;

  /// Playback mode
  ///
  /// In zh, this message translates to:
  /// **'播放模式'**
  String get playbackMode;

  /// Playback options
  ///
  /// In zh, this message translates to:
  /// **'播放选项'**
  String get playbackOptions;

  /// Set visualizer display
  ///
  /// In zh, this message translates to:
  /// **'设置频谱显示'**
  String get setVisualizerDisplay;

  /// No playback content
  ///
  /// In zh, this message translates to:
  /// **'当前没有播放内容'**
  String get noPlaybackContent;

  /// File tab
  ///
  /// In zh, this message translates to:
  /// **'文件'**
  String get file;

  /// Play tab
  ///
  /// In zh, this message translates to:
  /// **'播放'**
  String get play;

  /// List tab
  ///
  /// In zh, this message translates to:
  /// **'媒体库'**
  String get list;

  /// Queue tab
  ///
  /// In zh, this message translates to:
  /// **'队列'**
  String get queueTab;

  /// More tab
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get more;

  /// Settings
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// Theme mode label
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get themeMode;

  /// Theme mode option for following the system theme
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeModeSystem;

  /// Theme mode option for light mode
  ///
  /// In zh, this message translates to:
  /// **'亮色'**
  String get themeModeLight;

  /// Theme mode option for dark mode
  ///
  /// In zh, this message translates to:
  /// **'暗色'**
  String get themeModeDark;

  /// Immersive Tab Bar label
  ///
  /// In zh, this message translates to:
  /// **'沉浸式标签栏'**
  String get immersiveTabBar;

  /// Immersive Tab Bar description
  ///
  /// In zh, this message translates to:
  /// **'鼠标移动时显示导航栏，3 秒无操作后隐藏'**
  String get immersiveTabBarDescription;

  /// Collapse buttons in landscape lyrics mode label
  ///
  /// In zh, this message translates to:
  /// **'进入横屏歌词模式后收起按钮'**
  String get collapseButtonsInLandscapeLyrics;

  /// Collapse buttons in landscape lyrics mode description
  ///
  /// In zh, this message translates to:
  /// **'进入横屏歌词模式时收起 7 按钮行、标题左对齐并在右侧显示快捷按钮'**
  String get collapseButtonsInLandscapeLyricsDescription;

  /// Sample Stride label
  ///
  /// In zh, this message translates to:
  /// **'采样步长'**
  String get sampleStride;

  /// Sample Stride description
  ///
  /// In zh, this message translates to:
  /// **'值越大扫描越快但波形精度越低 (默认: 4)'**
  String get sampleStrideDescription;

  /// Waveform Segments label
  ///
  /// In zh, this message translates to:
  /// **'波形分段'**
  String get waveformSegments;

  /// Waveform Segments description
  ///
  /// In zh, this message translates to:
  /// **'要显示的波形柱数量 (默认: 80)'**
  String get waveformSegmentsDescription;

  /// Show developer options label
  ///
  /// In zh, this message translates to:
  /// **'显示开发人员选项'**
  String get showDeveloperOptions;

  /// No description provided for @playbackBackground.
  ///
  /// In zh, this message translates to:
  /// **'播放页背景'**
  String get playbackBackground;

  /// No description provided for @playbackRadialGradient.
  ///
  /// In zh, this message translates to:
  /// **'中心暗色渐变'**
  String get playbackRadialGradient;

  /// No description provided for @blurIntensity.
  ///
  /// In zh, this message translates to:
  /// **'模糊强度'**
  String get blurIntensity;

  /// No description provided for @blurredArtwork.
  ///
  /// In zh, this message translates to:
  /// **'模糊封面 (默认)'**
  String get blurredArtwork;

  /// No description provided for @dynamicMesh.
  ///
  /// In zh, this message translates to:
  /// **'动态流变'**
  String get dynamicMesh;

  /// No description provided for @solidColor.
  ///
  /// In zh, this message translates to:
  /// **'纯色'**
  String get solidColor;

  /// No description provided for @customImage.
  ///
  /// In zh, this message translates to:
  /// **'自定义图片'**
  String get customImage;

  /// No description provided for @presetColors.
  ///
  /// In zh, this message translates to:
  /// **'预设颜色'**
  String get presetColors;

  /// No description provided for @customColor.
  ///
  /// In zh, this message translates to:
  /// **'自定义颜色'**
  String get customColor;

  /// No description provided for @uploadImage.
  ///
  /// In zh, this message translates to:
  /// **'选择图片'**
  String get uploadImage;

  /// No description provided for @normalOpacity.
  ///
  /// In zh, this message translates to:
  /// **'常规暗色层不透明度'**
  String get normalOpacity;

  /// No description provided for @lyricsOpacity.
  ///
  /// In zh, this message translates to:
  /// **'歌词暗色层不透明度'**
  String get lyricsOpacity;

  /// No description provided for @chooseImageError.
  ///
  /// In zh, this message translates to:
  /// **'选择图片失败'**
  String get chooseImageError;

  /// No description provided for @noImageSelected.
  ///
  /// In zh, this message translates to:
  /// **'未选择图片'**
  String get noImageSelected;

  /// No description provided for @unknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get unknown;

  /// No description provided for @playlistModeSingle.
  ///
  /// In zh, this message translates to:
  /// **'单曲播放'**
  String get playlistModeSingle;

  /// No description provided for @playlistModeSingleLoop.
  ///
  /// In zh, this message translates to:
  /// **'单曲循环'**
  String get playlistModeSingleLoop;

  /// No description provided for @playlistModeQueue.
  ///
  /// In zh, this message translates to:
  /// **'播放列表'**
  String get playlistModeQueue;

  /// No description provided for @playlistModeQueueLoop.
  ///
  /// In zh, this message translates to:
  /// **'列表循环'**
  String get playlistModeQueueLoop;

  /// No description provided for @playlistModeAutoQueueLoop.
  ///
  /// In zh, this message translates to:
  /// **'自动列表循环'**
  String get playlistModeAutoQueueLoop;

  /// No description provided for @visualizer.
  ///
  /// In zh, this message translates to:
  /// **'可视化'**
  String get visualizer;

  /// No description provided for @previous.
  ///
  /// In zh, this message translates to:
  /// **'上一首'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In zh, this message translates to:
  /// **'下一首'**
  String get next;

  /// No description provided for @pause.
  ///
  /// In zh, this message translates to:
  /// **'暂停'**
  String get pause;

  /// No description provided for @autoMode.
  ///
  /// In zh, this message translates to:
  /// **'自动模式'**
  String get autoMode;

  /// No description provided for @advancedOptions.
  ///
  /// In zh, this message translates to:
  /// **'高级选项'**
  String get advancedOptions;

  /// No description provided for @spectrumQuantity.
  ///
  /// In zh, this message translates to:
  /// **'频谱数量'**
  String get spectrumQuantity;

  /// No description provided for @speed.
  ///
  /// In zh, this message translates to:
  /// **'速度'**
  String get speed;

  /// No description provided for @quantityHigh.
  ///
  /// In zh, this message translates to:
  /// **'多'**
  String get quantityHigh;

  /// No description provided for @quantityMedium.
  ///
  /// In zh, this message translates to:
  /// **'中'**
  String get quantityMedium;

  /// No description provided for @quantityLow.
  ///
  /// In zh, this message translates to:
  /// **'少'**
  String get quantityLow;

  /// No description provided for @speedFast.
  ///
  /// In zh, this message translates to:
  /// **'快'**
  String get speedFast;

  /// No description provided for @speedMedium.
  ///
  /// In zh, this message translates to:
  /// **'中'**
  String get speedMedium;

  /// No description provided for @speedSlow.
  ///
  /// In zh, this message translates to:
  /// **'慢'**
  String get speedSlow;

  /// No description provided for @portraitFrequencyGroups.
  ///
  /// In zh, this message translates to:
  /// **'竖屏频谱数量'**
  String get portraitFrequencyGroups;

  /// No description provided for @landscapeFrequencyGroups.
  ///
  /// In zh, this message translates to:
  /// **'横屏频谱数量'**
  String get landscapeFrequencyGroups;

  /// No description provided for @portraitGap.
  ///
  /// In zh, this message translates to:
  /// **'竖屏频谱间距'**
  String get portraitGap;

  /// No description provided for @landscapeGap.
  ///
  /// In zh, this message translates to:
  /// **'横屏频谱间距'**
  String get landscapeGap;

  /// Enable Waveform Progress Bar label
  ///
  /// In zh, this message translates to:
  /// **'启用波形进度条'**
  String get enableWaveformProgressBar;

  /// No description provided for @enableWaveformProgressBarDescription.
  ///
  /// In zh, this message translates to:
  /// **'使用整首歌的波形图代替标准滑块'**
  String get enableWaveformProgressBarDescription;

  /// Long-press waveform progress bar fast-forward speed label
  ///
  /// In zh, this message translates to:
  /// **'长按波形快进速度'**
  String get waveformLongPressSeekSpeed;

  /// No description provided for @waveformLongPressSeekSpeedDescription.
  ///
  /// In zh, this message translates to:
  /// **'长按波形进度条右侧时快进的播放速度（×）'**
  String get waveformLongPressSeekSpeedDescription;

  /// No description provided for @enableWaveformLongPressSeek.
  ///
  /// In zh, this message translates to:
  /// **'启用长按波形快进'**
  String get enableWaveformLongPressSeek;

  /// No description provided for @enableWaveformLongPressSeekDescription.
  ///
  /// In zh, this message translates to:
  /// **'长按波形进度条右侧区域启用快进播放'**
  String get enableWaveformLongPressSeekDescription;

  /// No description provided for @randomMode.
  ///
  /// In zh, this message translates to:
  /// **'随机模式'**
  String get randomMode;

  /// No description provided for @randomHistory.
  ///
  /// In zh, this message translates to:
  /// **'随机历史'**
  String get randomHistory;

  /// No description provided for @randomRange.
  ///
  /// In zh, this message translates to:
  /// **'随机范围'**
  String get randomRange;

  /// No description provided for @randomMethod.
  ///
  /// In zh, this message translates to:
  /// **'随机方式'**
  String get randomMethod;

  /// No description provided for @currentQueue.
  ///
  /// In zh, this message translates to:
  /// **'当前队列'**
  String get currentQueue;

  /// No description provided for @globalRange.
  ///
  /// In zh, this message translates to:
  /// **'全局 (包含所有列表歌曲)'**
  String get globalRange;

  /// No description provided for @completeRandom.
  ///
  /// In zh, this message translates to:
  /// **'完全随机'**
  String get completeRandom;

  /// No description provided for @shuffleRandom.
  ///
  /// In zh, this message translates to:
  /// **'洗牌随机'**
  String get shuffleRandom;

  /// No description provided for @randomQueue.
  ///
  /// In zh, this message translates to:
  /// **'随机队列'**
  String get randomQueue;

  /// No description provided for @notSelected.
  ///
  /// In zh, this message translates to:
  /// **'未选择音乐'**
  String get notSelected;

  /// No description provided for @saveTagsToFile.
  ///
  /// In zh, this message translates to:
  /// **'保存标签到文件'**
  String get saveTagsToFile;

  /// No description provided for @saveCurrentTagsToFile.
  ///
  /// In zh, this message translates to:
  /// **'保存当前歌曲标签到文件'**
  String get saveCurrentTagsToFile;

  /// No description provided for @saveQueueTagsToFile.
  ///
  /// In zh, this message translates to:
  /// **'保存队列中所有标签到文件'**
  String get saveQueueTagsToFile;

  /// No description provided for @tagsSaved.
  ///
  /// In zh, this message translates to:
  /// **'标签保存成功'**
  String get tagsSaved;

  /// No description provided for @tagsSavedCount.
  ///
  /// In zh, this message translates to:
  /// **'标签已保存 ({count} 首)'**
  String tagsSavedCount(Object count);

  /// No description provided for @tagsSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存标签失败'**
  String get tagsSaveFailed;

  /// No description provided for @tagsSaveFailedCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 首保存失败'**
  String tagsSaveFailedCount(Object count);

  /// No description provided for @unsupportedFormat.
  ///
  /// In zh, this message translates to:
  /// **'{count} 首歌曲格式不支持保存标签 (OGG/Opus)'**
  String unsupportedFormat(Object count);

  /// No description provided for @unsupportedFormatSingle.
  ///
  /// In zh, this message translates to:
  /// **'此格式 (OGG/Opus) 不支持保存标签'**
  String get unsupportedFormatSingle;

  /// No description provided for @savingTags.
  ///
  /// In zh, this message translates to:
  /// **'正在保存标签...'**
  String get savingTags;

  /// No description provided for @noModifiedTagsToSave.
  ///
  /// In zh, this message translates to:
  /// **'没有需要保存的已修改标签'**
  String get noModifiedTagsToSave;

  /// No description provided for @clearPlaylist.
  ///
  /// In zh, this message translates to:
  /// **'清空列表'**
  String get clearPlaylist;

  /// No description provided for @copyTitle.
  ///
  /// In zh, this message translates to:
  /// **'复制标题'**
  String get copyTitle;

  /// No description provided for @transcodeAction.
  ///
  /// In zh, this message translates to:
  /// **'转码'**
  String get transcodeAction;

  /// No description provided for @transcodeSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'音频转码'**
  String get transcodeSectionTitle;

  /// No description provided for @transcodeSectionDescription.
  ///
  /// In zh, this message translates to:
  /// **'设置默认输出格式和质量预设。'**
  String get transcodeSectionDescription;

  /// No description provided for @transcodeDefaultFormat.
  ///
  /// In zh, this message translates to:
  /// **'默认输出格式'**
  String get transcodeDefaultFormat;

  /// No description provided for @transcodeDefaultQuality.
  ///
  /// In zh, this message translates to:
  /// **'默认质量预设'**
  String get transcodeDefaultQuality;

  /// No description provided for @transcodeTitle.
  ///
  /// In zh, this message translates to:
  /// **'音频转码'**
  String get transcodeTitle;

  /// No description provided for @transcodeSongCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 首歌曲'**
  String transcodeSongCount(int count);

  /// No description provided for @transcodeCompletedCount.
  ///
  /// In zh, this message translates to:
  /// **'已完成 {count} 个转码任务'**
  String transcodeCompletedCount(int count);

  /// No description provided for @transcodeCompletedWithFailures.
  ///
  /// In zh, this message translates to:
  /// **'已完成 {success}/{total} 个转码任务，失败 {failed} 个'**
  String transcodeCompletedWithFailures(int success, int total, int failed);

  /// No description provided for @transcodeFailedGeneric.
  ///
  /// In zh, this message translates to:
  /// **'转码失败'**
  String get transcodeFailedGeneric;

  /// No description provided for @transcodePreparing.
  ///
  /// In zh, this message translates to:
  /// **'正在准备转码...'**
  String get transcodePreparing;

  /// No description provided for @transcodeProgress.
  ///
  /// In zh, this message translates to:
  /// **'正在转码 {current}/{total}'**
  String transcodeProgress(int current, int total);

  /// No description provided for @transcoding.
  ///
  /// In zh, this message translates to:
  /// **'转码中...'**
  String get transcoding;

  /// No description provided for @startTranscode.
  ///
  /// In zh, this message translates to:
  /// **'开始转码'**
  String get startTranscode;

  /// No description provided for @transcodeEngine.
  ///
  /// In zh, this message translates to:
  /// **'引擎：{engine}'**
  String transcodeEngine(Object engine);

  /// No description provided for @transcodeUsingSystemFfmpeg.
  ///
  /// In zh, this message translates to:
  /// **'使用系统 PATH 中的 ffmpeg。'**
  String get transcodeUsingSystemFfmpeg;

  /// No description provided for @transcodeUsingCustomFfmpeg.
  ///
  /// In zh, this message translates to:
  /// **'使用自定义 ffmpeg：{path}'**
  String transcodeUsingCustomFfmpeg(Object path);

  /// No description provided for @transcodeFormat.
  ///
  /// In zh, this message translates to:
  /// **'输出格式'**
  String get transcodeFormat;

  /// No description provided for @transcodeQualityPreset.
  ///
  /// In zh, this message translates to:
  /// **'质量预设'**
  String get transcodeQualityPreset;

  /// No description provided for @transcodeQualityLow.
  ///
  /// In zh, this message translates to:
  /// **'低'**
  String get transcodeQualityLow;

  /// No description provided for @transcodeQualityMedium.
  ///
  /// In zh, this message translates to:
  /// **'中'**
  String get transcodeQualityMedium;

  /// No description provided for @transcodeQualityHigh.
  ///
  /// In zh, this message translates to:
  /// **'高'**
  String get transcodeQualityHigh;

  /// No description provided for @transcodeQualityExtreme.
  ///
  /// In zh, this message translates to:
  /// **'最高'**
  String get transcodeQualityExtreme;

  /// No description provided for @transcodeLosslessPresetHint.
  ///
  /// In zh, this message translates to:
  /// **'当前无损格式不使用质量档位和码率控制模式。'**
  String get transcodeLosslessPresetHint;

  /// No description provided for @transcodeAdvancedOptions.
  ///
  /// In zh, this message translates to:
  /// **'高级选项'**
  String get transcodeAdvancedOptions;

  /// No description provided for @transcodeAdvancedCustomized.
  ///
  /// In zh, this message translates to:
  /// **'高级参数已被手动修改'**
  String get transcodeAdvancedCustomized;

  /// No description provided for @transcodeAdvancedFollowingPreset.
  ///
  /// In zh, this message translates to:
  /// **'高级参数跟随当前预设'**
  String get transcodeAdvancedFollowingPreset;

  /// No description provided for @transcodeLosslessAdvancedHint.
  ///
  /// In zh, this message translates to:
  /// **'当前无损格式仅保留与源文件相关的高级选项。'**
  String get transcodeLosslessAdvancedHint;

  /// No description provided for @transcodeBitRateInvalid.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的比特率'**
  String get transcodeBitRateInvalid;

  /// No description provided for @transcodeBitRate.
  ///
  /// In zh, this message translates to:
  /// **'比特率'**
  String get transcodeBitRate;

  /// No description provided for @transcodeBitRateMode.
  ///
  /// In zh, this message translates to:
  /// **'码率控制模式'**
  String get transcodeBitRateMode;

  /// No description provided for @transcodeEncodingEngine.
  ///
  /// In zh, this message translates to:
  /// **'编码引擎'**
  String get transcodeEncodingEngine;

  /// No description provided for @transcodeSystemEncoder.
  ///
  /// In zh, this message translates to:
  /// **'Media3 (系统)'**
  String get transcodeSystemEncoder;

  /// No description provided for @transcodeFfmpegRustEncoder.
  ///
  /// In zh, this message translates to:
  /// **'FFmpeg (Rust)'**
  String get transcodeFfmpegRustEncoder;

  /// No description provided for @transcodeAacEncoder.
  ///
  /// In zh, this message translates to:
  /// **'AAC 编码器'**
  String get transcodeAacEncoder;

  /// No description provided for @transcodeSampleRate.
  ///
  /// In zh, this message translates to:
  /// **'采样率'**
  String get transcodeSampleRate;

  /// No description provided for @transcodeChannels.
  ///
  /// In zh, this message translates to:
  /// **'声道'**
  String get transcodeChannels;

  /// No description provided for @transcodeResetToPreset.
  ///
  /// In zh, this message translates to:
  /// **'重置为当前预设'**
  String get transcodeResetToPreset;

  /// No description provided for @transcodeResetLosslessOptions.
  ///
  /// In zh, this message translates to:
  /// **'重置无损选项'**
  String get transcodeResetLosslessOptions;

  /// No description provided for @transcodeOutputDirectory.
  ///
  /// In zh, this message translates to:
  /// **'输出目录'**
  String get transcodeOutputDirectory;

  /// No description provided for @transcodeOutputPreview.
  ///
  /// In zh, this message translates to:
  /// **'预览'**
  String get transcodeOutputPreview;

  /// No description provided for @transcodeChooseDirectory.
  ///
  /// In zh, this message translates to:
  /// **'选择目录'**
  String get transcodeChooseDirectory;

  /// No description provided for @transcodeUseSourceDirectory.
  ///
  /// In zh, this message translates to:
  /// **'使用源文件目录'**
  String get transcodeUseSourceDirectory;

  /// No description provided for @transcodeKeepSource.
  ///
  /// In zh, this message translates to:
  /// **'保持源文件'**
  String get transcodeKeepSource;

  /// No description provided for @transcodeMono.
  ///
  /// In zh, this message translates to:
  /// **'单声道'**
  String get transcodeMono;

  /// No description provided for @transcodeStereo.
  ///
  /// In zh, this message translates to:
  /// **'双声道'**
  String get transcodeStereo;

  /// No description provided for @openFolderLocation.
  ///
  /// In zh, this message translates to:
  /// **'打开文件夹所在位置'**
  String get openFolderLocation;

  /// No description provided for @songTagsSavedToSourceFileAndApp.
  ///
  /// In zh, this message translates to:
  /// **'歌曲标签已保存到源文件和 App'**
  String get songTagsSavedToSourceFileAndApp;

  /// No description provided for @songTagsSavedToApp.
  ///
  /// In zh, this message translates to:
  /// **'歌曲标签已保存到 App'**
  String get songTagsSavedToApp;

  /// No description provided for @durationZero.
  ///
  /// In zh, this message translates to:
  /// **'0:00'**
  String get durationZero;

  /// No description provided for @generateLyrics.
  ///
  /// In zh, this message translates to:
  /// **'生成歌词'**
  String get generateLyrics;

  /// No description provided for @generateTimeline.
  ///
  /// In zh, this message translates to:
  /// **'生成时间轴'**
  String get generateTimeline;

  /// No description provided for @queueGenerateLyrics.
  ///
  /// In zh, this message translates to:
  /// **'排队生成'**
  String get queueGenerateLyrics;

  /// No description provided for @pauseAutoScroll.
  ///
  /// In zh, this message translates to:
  /// **'暂停自动滚动'**
  String get pauseAutoScroll;

  /// No description provided for @resumeAutoScroll.
  ///
  /// In zh, this message translates to:
  /// **'恢复自动滚动'**
  String get resumeAutoScroll;

  /// No description provided for @translateLyrics.
  ///
  /// In zh, this message translates to:
  /// **'翻译歌词'**
  String get translateLyrics;

  /// No description provided for @clearLyricsCache.
  ///
  /// In zh, this message translates to:
  /// **'清除当前歌词缓存'**
  String get clearLyricsCache;

  /// No description provided for @clearTranslationCache.
  ///
  /// In zh, this message translates to:
  /// **'清除当前翻译缓存'**
  String get clearTranslationCache;

  /// No description provided for @requery.
  ///
  /// In zh, this message translates to:
  /// **'重新查询'**
  String get requery;

  /// No description provided for @sleepTimerTitle.
  ///
  /// In zh, this message translates to:
  /// **'睡眠定时器'**
  String get sleepTimerTitle;

  /// No description provided for @sleepTimerDescription.
  ///
  /// In zh, this message translates to:
  /// **'选择倒计时，时间到后会暂停播放。'**
  String get sleepTimerDescription;

  /// No description provided for @sleepTimerRunningTitle.
  ///
  /// In zh, this message translates to:
  /// **'睡眠定时器运行中'**
  String get sleepTimerRunningTitle;

  /// No description provided for @sleepTimerRunningDescription.
  ///
  /// In zh, this message translates to:
  /// **'倒计时结束后会自动暂停当前播放。'**
  String get sleepTimerRunningDescription;

  /// No description provided for @sleepTimerStopAfterCurrentSong.
  ///
  /// In zh, this message translates to:
  /// **'播放完最后一首歌曲后停止'**
  String get sleepTimerStopAfterCurrentSong;

  /// No description provided for @remainingTime.
  ///
  /// In zh, this message translates to:
  /// **'剩余时间'**
  String get remainingTime;

  /// No description provided for @startCountdown.
  ///
  /// In zh, this message translates to:
  /// **'开始倒计时'**
  String get startCountdown;

  /// No description provided for @end.
  ///
  /// In zh, this message translates to:
  /// **'结束'**
  String get end;

  /// No description provided for @equalizer.
  ///
  /// In zh, this message translates to:
  /// **'均衡器'**
  String get equalizer;

  /// No description provided for @equalizerEnabledStatus.
  ///
  /// In zh, this message translates to:
  /// **'已启用高保真调节'**
  String get equalizerEnabledStatus;

  /// No description provided for @equalizerDisabledStatus.
  ///
  /// In zh, this message translates to:
  /// **'已禁用'**
  String get equalizerDisabledStatus;

  /// No description provided for @effects.
  ///
  /// In zh, this message translates to:
  /// **'特效'**
  String get effects;

  /// No description provided for @playbackSpeed.
  ///
  /// In zh, this message translates to:
  /// **'播放速度'**
  String get playbackSpeed;

  /// No description provided for @normal.
  ///
  /// In zh, this message translates to:
  /// **'正常'**
  String get normal;

  /// No description provided for @bassBoost.
  ///
  /// In zh, this message translates to:
  /// **'低音增强'**
  String get bassBoost;

  /// No description provided for @preampGain.
  ///
  /// In zh, this message translates to:
  /// **'前置增益'**
  String get preampGain;

  /// No description provided for @reset.
  ///
  /// In zh, this message translates to:
  /// **'重置'**
  String get reset;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @timelineAdjustmentTitle.
  ///
  /// In zh, this message translates to:
  /// **'手动调整时间轴'**
  String get timelineAdjustmentTitle;

  /// No description provided for @timelineAdjustmentDescription.
  ///
  /// In zh, this message translates to:
  /// **'向右拖动会让歌词整体延后，向左拖动会让歌词整体提前。'**
  String get timelineAdjustmentDescription;

  /// No description provided for @timelineOffsetEarlier.
  ///
  /// In zh, this message translates to:
  /// **'提前 {seconds} 秒'**
  String timelineOffsetEarlier(Object seconds);

  /// No description provided for @timelineOffsetLater.
  ///
  /// In zh, this message translates to:
  /// **'延后 {seconds} 秒'**
  String timelineOffsetLater(Object seconds);

  /// No description provided for @timelineOffsetCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前偏移：0.0 秒'**
  String get timelineOffsetCurrent;

  /// No description provided for @enterAcoustidApiKeyTitle.
  ///
  /// In zh, this message translates to:
  /// **'填写 AcoustID API Key'**
  String get enterAcoustidApiKeyTitle;

  /// No description provided for @acoustidApiKeyDescription.
  ///
  /// In zh, this message translates to:
  /// **'用于音频指纹识别。留空后会恢复使用应用内置的默认 key。'**
  String get acoustidApiKeyDescription;

  /// No description provided for @acoustidApiKeyHint.
  ///
  /// In zh, this message translates to:
  /// **'粘贴你的 AcoustID API Key'**
  String get acoustidApiKeyHint;

  /// No description provided for @apiKey.
  ///
  /// In zh, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @enterLyricsTitle.
  ///
  /// In zh, this message translates to:
  /// **'填写歌词'**
  String get enterLyricsTitle;

  /// No description provided for @lyricsInputHint.
  ///
  /// In zh, this message translates to:
  /// **'在这里粘贴或输入歌词，支持多行文本'**
  String get lyricsInputHint;

  /// No description provided for @enterGoogleAiStudioApiKeyTitle.
  ///
  /// In zh, this message translates to:
  /// **'填写 Google AI Studio API Key'**
  String get enterGoogleAiStudioApiKeyTitle;

  /// No description provided for @googleAiStudioApiKeyDescription.
  ///
  /// In zh, this message translates to:
  /// **'用于 Google AI Studio 的歌词生成、时间轴生成和翻译。'**
  String get googleAiStudioApiKeyDescription;

  /// No description provided for @pasteGoogleAiStudioApiKey.
  ///
  /// In zh, this message translates to:
  /// **'粘贴 Google AI Studio API Key'**
  String get pasteGoogleAiStudioApiKey;

  /// No description provided for @enterOpenRouterApiKeyTitle.
  ///
  /// In zh, this message translates to:
  /// **'填写 OpenRouter API Key'**
  String get enterOpenRouterApiKeyTitle;

  /// No description provided for @openRouterApiKeyDescription.
  ///
  /// In zh, this message translates to:
  /// **'用于 OpenRouter 的歌词生成和时间轴生成，翻译始终走 Gemini。'**
  String get openRouterApiKeyDescription;

  /// No description provided for @pasteOpenRouterApiKey.
  ///
  /// In zh, this message translates to:
  /// **'粘贴 OpenRouter API Key'**
  String get pasteOpenRouterApiKey;

  /// No description provided for @enterGeminiApiKeyTitle.
  ///
  /// In zh, this message translates to:
  /// **'填写 Gemini API Key'**
  String get enterGeminiApiKeyTitle;

  /// No description provided for @geminiApiKeyDescription.
  ///
  /// In zh, this message translates to:
  /// **'用于歌词翻译。'**
  String get geminiApiKeyDescription;

  /// No description provided for @pasteGeminiApiKey.
  ///
  /// In zh, this message translates to:
  /// **'粘贴 Gemini API Key'**
  String get pasteGeminiApiKey;

  /// No description provided for @testConnection.
  ///
  /// In zh, this message translates to:
  /// **'测试连接'**
  String get testConnection;

  /// No description provided for @enterApiKey.
  ///
  /// In zh, this message translates to:
  /// **'请输入 API key。'**
  String get enterApiKey;

  /// No description provided for @testingConnection.
  ///
  /// In zh, this message translates to:
  /// **'正在测试连接...'**
  String get testingConnection;

  /// No description provided for @getKey.
  ///
  /// In zh, this message translates to:
  /// **'获取key'**
  String get getKey;

  /// No description provided for @editSongTagsTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑歌曲标签'**
  String get editSongTagsTitle;

  /// No description provided for @changeArtwork.
  ///
  /// In zh, this message translates to:
  /// **'更换封面'**
  String get changeArtwork;

  /// No description provided for @clearArtwork.
  ///
  /// In zh, this message translates to:
  /// **'清除封面'**
  String get clearArtwork;

  /// No description provided for @editSongTagsDescription.
  ///
  /// In zh, this message translates to:
  /// **'修改后可以只保存到 App，也可以同步写回源文件。'**
  String get editSongTagsDescription;

  /// No description provided for @artistLabel.
  ///
  /// In zh, this message translates to:
  /// **'艺术家'**
  String get artistLabel;

  /// No description provided for @albumLabel.
  ///
  /// In zh, this message translates to:
  /// **'专辑'**
  String get albumLabel;

  /// No description provided for @trackNumberLabel.
  ///
  /// In zh, this message translates to:
  /// **'曲目号'**
  String get trackNumberLabel;

  /// No description provided for @trackNumberMustBeInteger.
  ///
  /// In zh, this message translates to:
  /// **'曲目号必须是整数'**
  String get trackNumberMustBeInteger;

  /// No description provided for @leaveBlankKeepsCurrentValue.
  ///
  /// In zh, this message translates to:
  /// **'留空则清空该项'**
  String get leaveBlankKeepsCurrentValue;

  /// No description provided for @currentFileFormatCannotWriteBack.
  ///
  /// In zh, this message translates to:
  /// **'当前文件格式不支持写回源文件，只能保存到 App。'**
  String get currentFileFormatCannotWriteBack;

  /// No description provided for @leaveBlankDoesNotClearOriginalValue.
  ///
  /// In zh, this message translates to:
  /// **'提示：留空会清空对应标签的值。'**
  String get leaveBlankDoesNotClearOriginalValue;

  /// No description provided for @saveToApp.
  ///
  /// In zh, this message translates to:
  /// **'保存到 App'**
  String get saveToApp;

  /// No description provided for @saveToSourceFileAndApp.
  ///
  /// In zh, this message translates to:
  /// **'保存到源文件和 App'**
  String get saveToSourceFileAndApp;

  /// No description provided for @saveToSourceFileFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存到源文件失败，请确认文件格式支持写入且文件未被占用'**
  String get saveToSourceFileFailed;

  /// No description provided for @fileOccupiedByOtherApp.
  ///
  /// In zh, this message translates to:
  /// **'文件被其他 App 占用，无法写入'**
  String get fileOccupiedByOtherApp;

  /// No description provided for @saveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败，请稍后重试'**
  String get saveFailed;

  /// No description provided for @apiKeySaved.
  ///
  /// In zh, this message translates to:
  /// **'{provider} API Key 已保存'**
  String apiKeySaved(Object provider);

  /// No description provided for @apiKeySavedAcoustid.
  ///
  /// In zh, this message translates to:
  /// **'AcoustID API Key 已保存'**
  String get apiKeySavedAcoustid;

  /// No description provided for @generalSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'界面与行为'**
  String get generalSectionTitle;

  /// No description provided for @generalSectionDescription.
  ///
  /// In zh, this message translates to:
  /// **'配置软件的界面外观、播放交互以及窗口与系统行为。'**
  String get generalSectionDescription;

  /// No description provided for @uiAppearanceGroup.
  ///
  /// In zh, this message translates to:
  /// **'外观与显示'**
  String get uiAppearanceGroup;

  /// No description provided for @playbackBehaviorGroup.
  ///
  /// In zh, this message translates to:
  /// **'播放与交互行为'**
  String get playbackBehaviorGroup;

  /// No description provided for @systemWindowBehaviorGroup.
  ///
  /// In zh, this message translates to:
  /// **'窗口与系统行为'**
  String get systemWindowBehaviorGroup;

  /// No description provided for @interfaceLanguage.
  ///
  /// In zh, this message translates to:
  /// **'界面语言'**
  String get interfaceLanguage;

  /// No description provided for @interfaceLanguageDescription.
  ///
  /// In zh, this message translates to:
  /// **'选择软件的界面显示语言。'**
  String get interfaceLanguageDescription;

  /// No description provided for @scanSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'扫描'**
  String get scanSectionTitle;

  /// No description provided for @scanSectionDescription.
  ///
  /// In zh, this message translates to:
  /// **'这些选项会控制媒体库扫描如何处理音频文件。'**
  String get scanSectionDescription;

  /// No description provided for @skipShortAudioDuringScan.
  ///
  /// In zh, this message translates to:
  /// **'扫描时跳过短音频'**
  String get skipShortAudioDuringScan;

  /// No description provided for @skipShortAudioDuringScanDescription.
  ///
  /// In zh, this message translates to:
  /// **'短于阈值的音频不会加入媒体库。'**
  String get skipShortAudioDuringScanDescription;

  /// No description provided for @shortAudioScanThreshold.
  ///
  /// In zh, this message translates to:
  /// **'短音频阈值'**
  String get shortAudioScanThreshold;

  /// No description provided for @shortAudioScanThresholdDescription.
  ///
  /// In zh, this message translates to:
  /// **'短于该时长的文件会被跳过。'**
  String get shortAudioScanThresholdDescription;

  /// No description provided for @shortAudioScanThresholdValue.
  ///
  /// In zh, this message translates to:
  /// **'{seconds} 秒'**
  String shortAudioScanThresholdValue(Object seconds);

  /// No description provided for @shortcutSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'自定义快捷键'**
  String get shortcutSettingsTitle;

  /// No description provided for @shortcutSettingsDescription.
  ///
  /// In zh, this message translates to:
  /// **'点击后可以为播放器操作重新录制快捷键并保存。'**
  String get shortcutSettingsDescription;

  /// No description provided for @edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// No description provided for @lyricsSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'歌词'**
  String get lyricsSectionTitle;

  /// No description provided for @lyricsSectionDescription.
  ///
  /// In zh, this message translates to:
  /// **'这里的配置只影响歌词生成和时间轴生成。'**
  String get lyricsSectionDescription;

  /// No description provided for @lyricsTranslationTargetLanguageLabel.
  ///
  /// In zh, this message translates to:
  /// **'翻译目标语言'**
  String get lyricsTranslationTargetLanguageLabel;

  /// No description provided for @lyricsTranslationTargetLanguageDescription.
  ///
  /// In zh, this message translates to:
  /// **'默认跟随系统语言，也可以单独指定。'**
  String get lyricsTranslationTargetLanguageDescription;

  /// No description provided for @lyricsSaveMethodLabel.
  ///
  /// In zh, this message translates to:
  /// **'歌词保存位置'**
  String get lyricsSaveMethodLabel;

  /// No description provided for @lyricsSaveMethodDescription.
  ///
  /// In zh, this message translates to:
  /// **'选择将歌词写入文件时的保存位置。'**
  String get lyricsSaveMethodDescription;

  /// No description provided for @lyricsSaveMethodOriginal.
  ///
  /// In zh, this message translates to:
  /// **'原处'**
  String get lyricsSaveMethodOriginal;

  /// No description provided for @lyricsSaveMethodEmbedded.
  ///
  /// In zh, this message translates to:
  /// **'内嵌'**
  String get lyricsSaveMethodEmbedded;

  /// No description provided for @lyricsSaveMethodLrcFile.
  ///
  /// In zh, this message translates to:
  /// **'LRC文件'**
  String get lyricsSaveMethodLrcFile;

  /// No description provided for @lyricsStyleLabel.
  ///
  /// In zh, this message translates to:
  /// **'歌词面板样式'**
  String get lyricsStyleLabel;

  /// No description provided for @lyricsStyleDescription.
  ///
  /// In zh, this message translates to:
  /// **'选择歌词面板的展示和交互样式。'**
  String get lyricsStyleDescription;

  /// No description provided for @lyricsStyleTraditional.
  ///
  /// In zh, this message translates to:
  /// **'传统滚动'**
  String get lyricsStyleTraditional;

  /// No description provided for @lyricsStyleApple.
  ///
  /// In zh, this message translates to:
  /// **'逐行聚焦'**
  String get lyricsStyleApple;

  /// No description provided for @resumeLyricsSync.
  ///
  /// In zh, this message translates to:
  /// **'恢复歌词同步'**
  String get resumeLyricsSync;

  /// No description provided for @followSystemLanguage.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get followSystemLanguage;

  /// No description provided for @autoSwitchLyricsProvider.
  ///
  /// In zh, this message translates to:
  /// **'自动切换歌词供应商'**
  String get autoSwitchLyricsProvider;

  /// No description provided for @autoSwitchLyricsProviderEnabledDesc.
  ///
  /// In zh, this message translates to:
  /// **'开启后会先请求 Google AI Studio；主模型和备用模型都因 429 或 5xx 失败时，再自动切到 OpenRouter 继续请求。'**
  String get autoSwitchLyricsProviderEnabledDesc;

  /// No description provided for @autoSwitchLyricsProviderDisabledDesc.
  ///
  /// In zh, this message translates to:
  /// **'请先同时填写 Google AI Studio 和 OpenRouter 的 API Key，才可以开启自动切换。'**
  String get autoSwitchLyricsProviderDisabledDesc;

  /// No description provided for @lyricsAiProviderTitle.
  ///
  /// In zh, this message translates to:
  /// **'歌词生成 AI 提供方'**
  String get lyricsAiProviderTitle;

  /// No description provided for @lyricsAiProviderDescription.
  ///
  /// In zh, this message translates to:
  /// **'这里只影响歌词生成和时间轴生成。翻译始终走 Google AI Studio。'**
  String get lyricsAiProviderDescription;

  /// No description provided for @googleAiStudioApiKeySaved.
  ///
  /// In zh, this message translates to:
  /// **'Google AI Studio API Key 已保存'**
  String get googleAiStudioApiKeySaved;

  /// No description provided for @googleAiStudioApiKeyMissing.
  ///
  /// In zh, this message translates to:
  /// **'当前未保存 Google AI Studio key，歌词生成和时间轴生成会先弹窗提示。'**
  String get googleAiStudioApiKeyMissing;

  /// No description provided for @openRouterApiKeySaved.
  ///
  /// In zh, this message translates to:
  /// **'OpenRouter API Key 已保存'**
  String get openRouterApiKeySaved;

  /// No description provided for @openRouterApiKeyMissing.
  ///
  /// In zh, this message translates to:
  /// **'当前未保存 OpenRouter key，歌词生成和时间轴生成会先弹窗提示。'**
  String get openRouterApiKeyMissing;

  /// No description provided for @apiKeySavedStatus.
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get apiKeySavedStatus;

  /// No description provided for @apiKeyMissingStatus.
  ///
  /// In zh, this message translates to:
  /// **'未填写'**
  String get apiKeyMissingStatus;

  /// No description provided for @platformApiKeysSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'平台 API Key'**
  String get platformApiKeysSectionTitle;

  /// No description provided for @fill.
  ///
  /// In zh, this message translates to:
  /// **'填写'**
  String get fill;

  /// No description provided for @modify.
  ///
  /// In zh, this message translates to:
  /// **'修改'**
  String get modify;

  /// No description provided for @geminiModelsSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择模型'**
  String get geminiModelsSectionTitle;

  /// No description provided for @geminiModelsSectionDescription.
  ///
  /// In zh, this message translates to:
  /// **'这些模型会用于 Google AI Studio 的歌词生成、时间轴生成以及歌词翻译。'**
  String get geminiModelsSectionDescription;

  /// No description provided for @primaryModelLabel.
  ///
  /// In zh, this message translates to:
  /// **'主模型'**
  String get primaryModelLabel;

  /// No description provided for @backupModelLabel.
  ///
  /// In zh, this message translates to:
  /// **'备用模型'**
  String get backupModelLabel;

  /// No description provided for @translationModelLabel.
  ///
  /// In zh, this message translates to:
  /// **'翻译模型'**
  String get translationModelLabel;

  /// No description provided for @fetching.
  ///
  /// In zh, this message translates to:
  /// **'获取中...'**
  String get fetching;

  /// No description provided for @fetchModelList.
  ///
  /// In zh, this message translates to:
  /// **'获取模型列表'**
  String get fetchModelList;

  /// No description provided for @restoreDefault.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认'**
  String get restoreDefault;

  /// No description provided for @acoustidSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'听歌识曲'**
  String get acoustidSectionTitle;

  /// No description provided for @acoustidApiKeyTitle.
  ///
  /// In zh, this message translates to:
  /// **'AcoustID API Key'**
  String get acoustidApiKeyTitle;

  /// No description provided for @acoustidApiKeyHelp.
  ///
  /// In zh, this message translates to:
  /// **'AcoustID 用于听歌识曲，建议使用你自己的 API Key。'**
  String get acoustidApiKeyHelp;

  /// No description provided for @acoustidApiKeySaved.
  ///
  /// In zh, this message translates to:
  /// **'AcoustID API Key 已保存'**
  String get acoustidApiKeySaved;

  /// No description provided for @acoustidApiKeyDefault.
  ///
  /// In zh, this message translates to:
  /// **'当前使用应用内置的默认 key，建议申请你自己的 key 后替换。'**
  String get acoustidApiKeyDefault;

  /// No description provided for @applyForApiKey.
  ///
  /// In zh, this message translates to:
  /// **'申请 API key: https://acoustid.org/new-application'**
  String get applyForApiKey;

  /// No description provided for @queueTabBarFavoriteAdded.
  ///
  /// In zh, this message translates to:
  /// **'已加入收藏'**
  String get queueTabBarFavoriteAdded;

  /// No description provided for @queueTabBarFavoriteRemoved.
  ///
  /// In zh, this message translates to:
  /// **'已取消收藏'**
  String get queueTabBarFavoriteRemoved;

  /// No description provided for @tagCompletion.
  ///
  /// In zh, this message translates to:
  /// **'歌曲标签补全'**
  String get tagCompletion;

  /// No description provided for @tagCompletionDescription.
  ///
  /// In zh, this message translates to:
  /// **'根据 AcoustID 和 MusicBrainz 结果匹配标签'**
  String get tagCompletionDescription;

  /// No description provided for @goToSettings.
  ///
  /// In zh, this message translates to:
  /// **'去设置页'**
  String get goToSettings;

  /// No description provided for @searchReleaseTitles.
  ///
  /// In zh, this message translates to:
  /// **'搜索 release 标题'**
  String get searchReleaseTitles;

  /// No description provided for @closeSearch.
  ///
  /// In zh, this message translates to:
  /// **'关闭搜索'**
  String get closeSearch;

  /// No description provided for @refreshResults.
  ///
  /// In zh, this message translates to:
  /// **'刷新结果'**
  String get refreshResults;

  /// No description provided for @filterMusicBrainzReleaseTitle.
  ///
  /// In zh, this message translates to:
  /// **'过滤 MusicBrainz release 标题'**
  String get filterMusicBrainzReleaseTitle;

  /// No description provided for @clearSearch.
  ///
  /// In zh, this message translates to:
  /// **'清空搜索'**
  String get clearSearch;

  /// No description provided for @localTitle.
  ///
  /// In zh, this message translates to:
  /// **'本地标题'**
  String get localTitle;

  /// No description provided for @queryConditions.
  ///
  /// In zh, this message translates to:
  /// **'查询条件'**
  String get queryConditions;

  /// No description provided for @musicBrainzLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在查询 MusicBrainz'**
  String get musicBrainzLoading;

  /// No description provided for @musicBrainzLoadingWithResults.
  ///
  /// In zh, this message translates to:
  /// **'现有结果会先保留在面板里'**
  String get musicBrainzLoadingWithResults;

  /// No description provided for @musicBrainzLoadingHint.
  ///
  /// In zh, this message translates to:
  /// **'请稍候'**
  String get musicBrainzLoadingHint;

  /// No description provided for @musicBrainzQueryFailed.
  ///
  /// In zh, this message translates to:
  /// **'MusicBrainz 查询失败'**
  String get musicBrainzQueryFailed;

  /// No description provided for @musicBrainzNetworkErrorHint.
  ///
  /// In zh, this message translates to:
  /// **'MusicBrainz 请求失败，通常是网络连接不稳定、超时或被服务端拒绝。可以稍后重试。'**
  String get musicBrainzNetworkErrorHint;

  /// No description provided for @musicBrainzFilteredEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'当前过滤条件下没有包含该关键词的 release 标题。'**
  String get musicBrainzFilteredEmptyHint;

  /// No description provided for @musicBrainzEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'MusicBrainz 没有返回可用结果。可以放宽标题、艺人或专辑条件后再试一次。'**
  String get musicBrainzEmptyHint;

  /// No description provided for @musicBrainzEmptyMoreCompleteHint.
  ///
  /// In zh, this message translates to:
  /// **'可以稍后重试，或者确认当前歌曲标题/艺人信息是否更完整。'**
  String get musicBrainzEmptyMoreCompleteHint;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @noMatchingRelease.
  ///
  /// In zh, this message translates to:
  /// **'没有找到匹配的 release'**
  String get noMatchingRelease;

  /// No description provided for @noMatchingResults.
  ///
  /// In zh, this message translates to:
  /// **'没有找到匹配结果'**
  String get noMatchingResults;

  /// No description provided for @networkConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'网络连接失败'**
  String get networkConnectionFailed;

  /// No description provided for @searchAgain.
  ///
  /// In zh, this message translates to:
  /// **'重新搜索'**
  String get searchAgain;

  /// No description provided for @acoustidRecognitionRecords.
  ///
  /// In zh, this message translates to:
  /// **'AcoustID 识别记录'**
  String get acoustidRecognitionRecords;

  /// No description provided for @musicBrainzRecordings.
  ///
  /// In zh, this message translates to:
  /// **'MusicBrainz 录音'**
  String get musicBrainzRecordings;

  /// No description provided for @noExpandableReleaseGroups.
  ///
  /// In zh, this message translates to:
  /// **'没有可展开的发行版分组'**
  String get noExpandableReleaseGroups;

  /// No description provided for @noExpandableReleases.
  ///
  /// In zh, this message translates to:
  /// **'没有可展开的发行版'**
  String get noExpandableReleases;

  /// No description provided for @noMatchingResultHint.
  ///
  /// In zh, this message translates to:
  /// **'可以稍后重试，或者确认当前歌曲标题/艺人信息是否更完整。'**
  String get noMatchingResultHint;

  /// No description provided for @releaseCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个发行版'**
  String releaseCountLabel(int count);

  /// No description provided for @recordingCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条录音'**
  String recordingCountLabel(int count);

  /// No description provided for @trackCountShort.
  ///
  /// In zh, this message translates to:
  /// **'{count} 首'**
  String trackCountShort(int count);

  /// No description provided for @scoreLabel.
  ///
  /// In zh, this message translates to:
  /// **'评分 {score}'**
  String scoreLabel(int score);

  /// No description provided for @matchScoreLabel.
  ///
  /// In zh, this message translates to:
  /// **'匹配度 {score}%'**
  String matchScoreLabel(int score);

  /// No description provided for @editQueryCondition.
  ///
  /// In zh, this message translates to:
  /// **'编辑查询条件'**
  String get editQueryCondition;

  /// No description provided for @enterNewQueryText.
  ///
  /// In zh, this message translates to:
  /// **'输入新的查询文字'**
  String get enterNewQueryText;

  /// No description provided for @durationLabel.
  ///
  /// In zh, this message translates to:
  /// **'时长'**
  String get durationLabel;

  /// No description provided for @customShortcuts.
  ///
  /// In zh, this message translates to:
  /// **'自定义快捷键'**
  String get customShortcuts;

  /// No description provided for @pressShortcutCombo.
  ///
  /// In zh, this message translates to:
  /// **'请按下组合键'**
  String get pressShortcutCombo;

  /// No description provided for @clickToRecord.
  ///
  /// In zh, this message translates to:
  /// **'点击录制'**
  String get clickToRecord;

  /// No description provided for @searchingLyrics.
  ///
  /// In zh, this message translates to:
  /// **'正在查找歌词'**
  String get searchingLyrics;

  /// No description provided for @noLyrics.
  ///
  /// In zh, this message translates to:
  /// **'暂无歌词'**
  String get noLyrics;

  /// No description provided for @providerLabel.
  ///
  /// In zh, this message translates to:
  /// **'提供商'**
  String get providerLabel;

  /// No description provided for @modelLabel.
  ///
  /// In zh, this message translates to:
  /// **'模型'**
  String get modelLabel;

  /// No description provided for @unspecified.
  ///
  /// In zh, this message translates to:
  /// **'未指定'**
  String get unspecified;

  /// No description provided for @targetTimeLabel.
  ///
  /// In zh, this message translates to:
  /// **'目标时间 {duration}'**
  String targetTimeLabel(String duration);

  /// No description provided for @songDeletedSkipped.
  ///
  /// In zh, this message translates to:
  /// **'歌曲已删除，已跳过'**
  String get songDeletedSkipped;

  /// No description provided for @songDeleted.
  ///
  /// In zh, this message translates to:
  /// **'歌曲已删除'**
  String get songDeleted;

  /// No description provided for @lyricsTaskUploading.
  ///
  /// In zh, this message translates to:
  /// **'上传中'**
  String get lyricsTaskUploading;

  /// No description provided for @lyricsTaskWaiting.
  ///
  /// In zh, this message translates to:
  /// **'等待就绪'**
  String get lyricsTaskWaiting;

  /// No description provided for @lyricsTaskRequesting.
  ///
  /// In zh, this message translates to:
  /// **'请求中'**
  String get lyricsTaskRequesting;

  /// No description provided for @lyricsTaskGenerating.
  ///
  /// In zh, this message translates to:
  /// **'生成中'**
  String get lyricsTaskGenerating;

  /// No description provided for @lyricsTaskRetrying.
  ///
  /// In zh, this message translates to:
  /// **'重试中'**
  String get lyricsTaskRetrying;

  /// No description provided for @lyricsTaskProcessing.
  ///
  /// In zh, this message translates to:
  /// **'正在处理'**
  String get lyricsTaskProcessing;

  /// No description provided for @unknownModel.
  ///
  /// In zh, this message translates to:
  /// **'未知模型'**
  String get unknownModel;

  /// No description provided for @selectedFolders.
  ///
  /// In zh, this message translates to:
  /// **'已选中 {count} 个目录'**
  String selectedFolders(int count);

  /// No description provided for @foldersDeleted.
  ///
  /// In zh, this message translates to:
  /// **'已删除 {count} 个目录'**
  String foldersDeleted(int count);

  /// No description provided for @persistentAccessDenied.
  ///
  /// In zh, this message translates to:
  /// **'无法保存该目录的访问权限，请重新选择一次'**
  String get persistentAccessDenied;

  /// No description provided for @folderAddFailed.
  ///
  /// In zh, this message translates to:
  /// **'目录添加失败'**
  String get folderAddFailed;

  /// No description provided for @sleepTimer.
  ///
  /// In zh, this message translates to:
  /// **'睡眠定时器'**
  String get sleepTimer;

  /// No description provided for @sleepTimerRemaining.
  ///
  /// In zh, this message translates to:
  /// **'睡眠定时器 {duration}'**
  String sleepTimerRemaining(Object duration);

  /// No description provided for @unknownArtistOrAlbum.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get unknownArtistOrAlbum;

  /// No description provided for @pressAgainToExit.
  ///
  /// In zh, this message translates to:
  /// **'再按一次退出应用'**
  String get pressAgainToExit;

  /// No description provided for @tagCompletionSuccessWithCover.
  ///
  /// In zh, this message translates to:
  /// **'标签已补全并保存，封面已下载到临时目录'**
  String get tagCompletionSuccessWithCover;

  /// No description provided for @tagCompletionSuccess.
  ///
  /// In zh, this message translates to:
  /// **'标签已补全并保存'**
  String get tagCompletionSuccess;

  /// No description provided for @selectOnlineLyrics.
  ///
  /// In zh, this message translates to:
  /// **'选择在线歌词'**
  String get selectOnlineLyrics;

  /// No description provided for @increaseLyricsFont.
  ///
  /// In zh, this message translates to:
  /// **'增大歌词文字'**
  String get increaseLyricsFont;

  /// No description provided for @decreaseLyricsFont.
  ///
  /// In zh, this message translates to:
  /// **'减小歌词文字'**
  String get decreaseLyricsFont;

  /// No description provided for @restoreDefaultSize.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认大小'**
  String get restoreDefaultSize;

  /// No description provided for @adjustLyricsFont.
  ///
  /// In zh, this message translates to:
  /// **'调整文字大小'**
  String get adjustLyricsFont;

  /// No description provided for @searchingOnlineLyrics.
  ///
  /// In zh, this message translates to:
  /// **'正在查询在线歌词'**
  String get searchingOnlineLyrics;

  /// No description provided for @onlineLyricsResults.
  ///
  /// In zh, this message translates to:
  /// **'在线歌词结果'**
  String get onlineLyricsResults;

  /// No description provided for @untitledLyrics.
  ///
  /// In zh, this message translates to:
  /// **'未命名歌词'**
  String get untitledLyrics;

  /// No description provided for @hasTimeline.
  ///
  /// In zh, this message translates to:
  /// **'带时间轴'**
  String get hasTimeline;

  /// No description provided for @viewLyricsDetails.
  ///
  /// In zh, this message translates to:
  /// **'查看歌词详情'**
  String get viewLyricsDetails;

  /// No description provided for @lyricsDetails.
  ///
  /// In zh, this message translates to:
  /// **'歌词详情'**
  String get lyricsDetails;

  /// No description provided for @lyricsContent.
  ///
  /// In zh, this message translates to:
  /// **'歌词内容'**
  String get lyricsContent;

  /// No description provided for @noLyricsContent.
  ///
  /// In zh, this message translates to:
  /// **'无歌词内容'**
  String get noLyricsContent;

  /// No description provided for @queryContentLabel.
  ///
  /// In zh, this message translates to:
  /// **'内容'**
  String get queryContentLabel;

  /// No description provided for @yes.
  ///
  /// In zh, this message translates to:
  /// **'是'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In zh, this message translates to:
  /// **'否'**
  String get no;

  /// No description provided for @dropAddedSongs.
  ///
  /// In zh, this message translates to:
  /// **'已添加 {addedCount} 首歌曲'**
  String dropAddedSongs(int addedCount);

  /// No description provided for @dropAddedSongsWithExisting.
  ///
  /// In zh, this message translates to:
  /// **'已添加 {addedCount} 首歌曲，{existingCount} 首已存在'**
  String dropAddedSongsWithExisting(int addedCount, int existingCount);

  /// No description provided for @copyCover.
  ///
  /// In zh, this message translates to:
  /// **'复制封面到剪贴板'**
  String get copyCover;

  /// No description provided for @copyCoverSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已成功复制封面'**
  String get copyCoverSuccess;

  /// No description provided for @searchLyricsPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'输入歌名、歌手或歌词进行搜索'**
  String get searchLyricsPlaceholder;

  /// Share tab label
  ///
  /// In zh, this message translates to:
  /// **'共享'**
  String get share;

  /// No description provided for @windowsSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'Windows 专属设置'**
  String get windowsSettingsTitle;

  /// No description provided for @fileAssociationTitle.
  ///
  /// In zh, this message translates to:
  /// **'文件打开方式关联'**
  String get fileAssociationTitle;

  /// No description provided for @fileAssociationDescription.
  ///
  /// In zh, this message translates to:
  /// **'将常见的音乐格式（mp3, flac, wav 等）关联到此应用，支持双击直接打开播放。'**
  String get fileAssociationDescription;

  /// No description provided for @associateButton.
  ///
  /// In zh, this message translates to:
  /// **'一键关联'**
  String get associateButton;

  /// No description provided for @disassociateButton.
  ///
  /// In zh, this message translates to:
  /// **'取消关联'**
  String get disassociateButton;

  /// No description provided for @associationSuccess.
  ///
  /// In zh, this message translates to:
  /// **'关联成功！若双击文件未生效，请在 Windows 系统设置的【默认应用】中选择 Vynody。'**
  String get associationSuccess;

  /// No description provided for @disassociationSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已成功清除文件关联。'**
  String get disassociationSuccess;

  /// No description provided for @associationFailed.
  ///
  /// In zh, this message translates to:
  /// **'关联失败：{error}'**
  String associationFailed(Object error);

  /// No description provided for @onboardingTitle.
  ///
  /// In zh, this message translates to:
  /// **'欢迎使用 Vynody'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'只需几个简单步骤，即可开启你的音乐之旅。'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingStepFileAssociation.
  ///
  /// In zh, this message translates to:
  /// **'关联文件打开方式'**
  String get onboardingStepFileAssociation;

  /// No description provided for @onboardingFileAssociationDesc.
  ///
  /// In zh, this message translates to:
  /// **'将常见的音乐格式（mp3, flac, wav 等）与 Vynody 关联，在文件管理器中双击即可直接播放。'**
  String get onboardingFileAssociationDesc;

  /// No description provided for @onboardingFileAssociationTip.
  ///
  /// In zh, this message translates to:
  /// **'关联后，系统可能会弹出选择默认打开程序的对话框。请务必在列表中选择「Vynody」并设为始终使用。'**
  String get onboardingFileAssociationTip;

  /// No description provided for @onboardingStepRootDirectory.
  ///
  /// In zh, this message translates to:
  /// **'添加音乐根目录'**
  String get onboardingStepRootDirectory;

  /// No description provided for @onboardingRootDirectoryDesc.
  ///
  /// In zh, this message translates to:
  /// **'选择存储音乐文件的文件夹。Vynody 会自动扫描并建立你的本地音乐库。'**
  String get onboardingRootDirectoryDesc;

  /// No description provided for @onboardingAndroidPermissionTip.
  ///
  /// In zh, this message translates to:
  /// **'注意：Android 系统在导入与扫描本地歌曲时需要授予媒体库访问权限。点击【选择文件夹】时将触发权限请求，请予以允许。'**
  String get onboardingAndroidPermissionTip;

  /// No description provided for @onboardingSelectDirectory.
  ///
  /// In zh, this message translates to:
  /// **'选择文件夹'**
  String get onboardingSelectDirectory;

  /// No description provided for @onboardingSuccessTitle.
  ///
  /// In zh, this message translates to:
  /// **'一切准备就绪！'**
  String get onboardingSuccessTitle;

  /// No description provided for @onboardingSuccessDesc.
  ///
  /// In zh, this message translates to:
  /// **'已成功添加媒体库。让我们开始享受音乐吧！'**
  String get onboardingSuccessDesc;

  /// No description provided for @onboardingStartButton.
  ///
  /// In zh, this message translates to:
  /// **'进入 Vynody'**
  String get onboardingStartButton;

  /// No description provided for @onboardingSkip.
  ///
  /// In zh, this message translates to:
  /// **'稍后设置'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In zh, this message translates to:
  /// **'下一步'**
  String get onboardingNext;

  /// No description provided for @onboardingBack.
  ///
  /// In zh, this message translates to:
  /// **'上一步'**
  String get onboardingBack;

  /// No description provided for @resetOnboarding.
  ///
  /// In zh, this message translates to:
  /// **'重置新手引导'**
  String get resetOnboarding;

  /// No description provided for @resetOnboardingDesc.
  ///
  /// In zh, this message translates to:
  /// **'清除首次启动引导状态，下次启动应用时重新显示新手引导。'**
  String get resetOnboardingDesc;

  /// No description provided for @songProperties.
  ///
  /// In zh, this message translates to:
  /// **'歌曲属性'**
  String get songProperties;

  /// No description provided for @failedToLoadDetails.
  ///
  /// In zh, this message translates to:
  /// **'无法获取详细信息'**
  String get failedToLoadDetails;

  /// No description provided for @noPropertiesAvailable.
  ///
  /// In zh, this message translates to:
  /// **'暂无歌曲详细属性'**
  String get noPropertiesAvailable;

  /// No description provided for @detailFilePath.
  ///
  /// In zh, this message translates to:
  /// **'文件路径'**
  String get detailFilePath;

  /// No description provided for @detailFormat.
  ///
  /// In zh, this message translates to:
  /// **'格式'**
  String get detailFormat;

  /// No description provided for @detailCodec.
  ///
  /// In zh, this message translates to:
  /// **'编码'**
  String get detailCodec;

  /// No description provided for @detailDuration.
  ///
  /// In zh, this message translates to:
  /// **'时长'**
  String get detailDuration;

  /// No description provided for @detailFileSize.
  ///
  /// In zh, this message translates to:
  /// **'文件大小'**
  String get detailFileSize;

  /// No description provided for @detailBitrate.
  ///
  /// In zh, this message translates to:
  /// **'比特率'**
  String get detailBitrate;

  /// No description provided for @detailSampleRate.
  ///
  /// In zh, this message translates to:
  /// **'采样率'**
  String get detailSampleRate;

  /// No description provided for @detailChannels.
  ///
  /// In zh, this message translates to:
  /// **'声道数'**
  String get detailChannels;

  /// No description provided for @detailBitDepth.
  ///
  /// In zh, this message translates to:
  /// **'采样深度'**
  String get detailBitDepth;

  /// No description provided for @detailMono.
  ///
  /// In zh, this message translates to:
  /// **'单声道 (Mono)'**
  String get detailMono;

  /// No description provided for @detailStereo.
  ///
  /// In zh, this message translates to:
  /// **'立体声 (Stereo)'**
  String get detailStereo;

  /// No description provided for @detailChannelsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 声道'**
  String detailChannelsCount(int count);

  /// No description provided for @localNetworkPermissionDeniedTitle.
  ///
  /// In zh, this message translates to:
  /// **'局域网访问受限'**
  String get localNetworkPermissionDeniedTitle;

  /// No description provided for @localNetworkPermissionDeniedMessage.
  ///
  /// In zh, this message translates to:
  /// **'未检测到可用的局域网 IP 地址，或局域网访问权限被拒绝。\n\n请按照以下步骤操作：\n1. 确保您的设备已连接到 Wi-Fi 或局域网。\n2. 确保在系统设置中允许本应用访问局域网：\n   - iOS/macOS: 请前往系统的「设置 > 隐私与安全性 > 局域网」，开启「Vynody」的开关。\n   - Windows: 请确保已连接到网络，并检查 Windows 防火墙设置是否允许「Vynody」通过。'**
  String get localNetworkPermissionDeniedMessage;

  /// No description provided for @localNetworkPermissionWindowsMessage.
  ///
  /// In zh, this message translates to:
  /// **'未检测到可用的局域网 IP 地址。\n\n请按照以下步骤操作：\n1. 确保您的设备已连接到局域网（Wi-Fi 或以太网）。\n2. 如果已连接但仍提示此错误，请检查 Windows 防火墙设置，确保允许「Vynody」通过防火墙访问网络。'**
  String get localNetworkPermissionWindowsMessage;

  /// No description provided for @openSettingsButton.
  ///
  /// In zh, this message translates to:
  /// **'前往设置'**
  String get openSettingsButton;

  /// No description provided for @closeButton.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get closeButton;

  /// No description provided for @copyTranslationResults.
  ///
  /// In zh, this message translates to:
  /// **'复制翻译结果'**
  String get copyTranslationResults;

  /// No description provided for @writeLyricsToFile.
  ///
  /// In zh, this message translates to:
  /// **'将歌词写入文件'**
  String get writeLyricsToFile;

  /// No description provided for @selectLyricSource.
  ///
  /// In zh, this message translates to:
  /// **'选择歌词来源'**
  String get selectLyricSource;

  /// No description provided for @regenerateLyrics.
  ///
  /// In zh, this message translates to:
  /// **'重新生成歌词'**
  String get regenerateLyrics;

  /// No description provided for @regenerateLyricsConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'将清空当前歌词并重新生成，是否继续？'**
  String get regenerateLyricsConfirmation;

  /// No description provided for @regenerateTimeline.
  ///
  /// In zh, this message translates to:
  /// **'重新生成时间轴'**
  String get regenerateTimeline;

  /// No description provided for @regenerateTimelineConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'将清空当前时间轴并重新生成，是否继续？'**
  String get regenerateTimelineConfirmation;

  /// No description provided for @retranslateLyrics.
  ///
  /// In zh, this message translates to:
  /// **'重新翻译歌词'**
  String get retranslateLyrics;

  /// No description provided for @retranslateLyricsConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'将清空当前翻译并重新翻译，是否继续？'**
  String get retranslateLyricsConfirmation;

  /// No description provided for @translationCopiedToClipboard.
  ///
  /// In zh, this message translates to:
  /// **'已复制翻译结果到剪贴板'**
  String get translationCopiedToClipboard;

  /// No description provided for @writingLyrics.
  ///
  /// In zh, this message translates to:
  /// **'正在写入歌词...'**
  String get writingLyrics;

  /// No description provided for @lyricsWrittenToFile.
  ///
  /// In zh, this message translates to:
  /// **'歌词写入文件成功'**
  String get lyricsWrittenToFile;

  /// No description provided for @writeLyricsFailed.
  ///
  /// In zh, this message translates to:
  /// **'写入歌词失败'**
  String get writeLyricsFailed;

  /// No description provided for @externalLrcFile.
  ///
  /// In zh, this message translates to:
  /// **'同名外置LRC文件'**
  String get externalLrcFile;

  /// No description provided for @embeddedLyrics.
  ///
  /// In zh, this message translates to:
  /// **'音频内嵌歌词'**
  String get embeddedLyrics;

  /// No description provided for @manuallyAdjustedLyrics.
  ///
  /// In zh, this message translates to:
  /// **'手动修改的歌词'**
  String get manuallyAdjustedLyrics;

  /// No description provided for @lrclibOnlineLyrics.
  ///
  /// In zh, this message translates to:
  /// **'LrcLib在线歌词'**
  String get lrclibOnlineLyrics;

  /// No description provided for @aiGeneratedLyrics.
  ///
  /// In zh, this message translates to:
  /// **'AI生成的歌词'**
  String get aiGeneratedLyrics;

  /// No description provided for @matchScore.
  ///
  /// In zh, this message translates to:
  /// **'匹配度'**
  String get matchScore;

  /// No description provided for @untitledRelease.
  ///
  /// In zh, this message translates to:
  /// **'未命名发行版'**
  String get untitledRelease;

  /// No description provided for @localSongFileNotFoundForGeneration.
  ///
  /// In zh, this message translates to:
  /// **'本地歌曲文件不存在，无法生成歌词。'**
  String get localSongFileNotFoundForGeneration;

  /// No description provided for @localSongFileNotFoundForTimeline.
  ///
  /// In zh, this message translates to:
  /// **'本地歌曲文件不存在，无法生成时间轴。'**
  String get localSongFileNotFoundForTimeline;

  /// No description provided for @noLyricsForTimelineGeneration.
  ///
  /// In zh, this message translates to:
  /// **'没有可用歌词，无法生成时间轴。'**
  String get noLyricsForTimelineGeneration;

  /// No description provided for @noLyricsAvailableForTranslation.
  ///
  /// In zh, this message translates to:
  /// **'没有可用于翻译的歌词。'**
  String get noLyricsAvailableForTranslation;

  /// No description provided for @noCurrentSongAvailable.
  ///
  /// In zh, this message translates to:
  /// **'没有可用的当前歌曲。'**
  String get noCurrentSongAvailable;

  /// No description provided for @invalidTargetLanguage.
  ///
  /// In zh, this message translates to:
  /// **'目标语言无效。'**
  String get invalidTargetLanguage;

  /// No description provided for @songAlreadyQueuedForTranslation.
  ///
  /// In zh, this message translates to:
  /// **'当前歌曲的歌词任务已在排队或翻译中。'**
  String get songAlreadyQueuedForTranslation;

  /// No description provided for @songAlreadyQueuedForGeneration.
  ///
  /// In zh, this message translates to:
  /// **'当前歌曲的歌词任务已在排队或生成中。'**
  String get songAlreadyQueuedForGeneration;

  /// No description provided for @songNoLongerExistsForTranslation.
  ///
  /// In zh, this message translates to:
  /// **'当前歌曲已不存在，无法翻译歌词。'**
  String get songNoLongerExistsForTranslation;

  /// No description provided for @generationFailed.
  ///
  /// In zh, this message translates to:
  /// **'生成失败。'**
  String get generationFailed;

  /// No description provided for @generatingLyrics.
  ///
  /// In zh, this message translates to:
  /// **'正在生成歌词'**
  String get generatingLyrics;

  /// No description provided for @generatingTimeline.
  ///
  /// In zh, this message translates to:
  /// **'正在生成时间轴'**
  String get generatingTimeline;

  /// No description provided for @regeneratingLyrics.
  ///
  /// In zh, this message translates to:
  /// **'正在重新生成歌词'**
  String get regeneratingLyrics;

  /// No description provided for @translatingLyrics.
  ///
  /// In zh, this message translates to:
  /// **'正在翻译歌词'**
  String get translatingLyrics;

  /// No description provided for @transcodingSongFile.
  ///
  /// In zh, this message translates to:
  /// **'正在转码歌曲文件'**
  String get transcodingSongFile;

  /// No description provided for @uploadingSongFile.
  ///
  /// In zh, this message translates to:
  /// **'正在上传歌曲文件'**
  String get uploadingSongFile;

  /// No description provided for @fileUploadedWaitingForReadiness.
  ///
  /// In zh, this message translates to:
  /// **'文件已上传，正在等待文件就绪'**
  String get fileUploadedWaitingForReadiness;

  /// No description provided for @waitingForFileReadiness.
  ///
  /// In zh, this message translates to:
  /// **'正在等待文件就绪'**
  String get waitingForFileReadiness;

  /// No description provided for @requestingModelResponse.
  ///
  /// In zh, this message translates to:
  /// **'正在请求模型响应'**
  String get requestingModelResponse;

  /// No description provided for @retryingTaskKindGeneration.
  ///
  /// In zh, this message translates to:
  /// **'正在重试生成{taskKind}'**
  String retryingTaskKindGeneration(Object taskKind);

  /// No description provided for @retrying.
  ///
  /// In zh, this message translates to:
  /// **'正在重试'**
  String get retrying;

  /// No description provided for @processing.
  ///
  /// In zh, this message translates to:
  /// **'正在处理'**
  String get processing;

  /// No description provided for @timeline.
  ///
  /// In zh, this message translates to:
  /// **'时间轴'**
  String get timeline;

  /// No description provided for @lyrics.
  ///
  /// In zh, this message translates to:
  /// **'歌词'**
  String get lyrics;

  /// No description provided for @lyricGenerationError.
  ///
  /// In zh, this message translates to:
  /// **'生成歌词时发生错误：{error}'**
  String lyricGenerationError(Object error);

  /// No description provided for @timelineGenerationError.
  ///
  /// In zh, this message translates to:
  /// **'生成时间轴时发生错误：{error}'**
  String timelineGenerationError(Object error);

  /// No description provided for @unknownGenerationError.
  ///
  /// In zh, this message translates to:
  /// **'生成歌词时发生未知错误。'**
  String get unknownGenerationError;

  /// No description provided for @unknownTimelineGenerationError.
  ///
  /// In zh, this message translates to:
  /// **'生成时间轴时发生未知错误。'**
  String get unknownTimelineGenerationError;

  /// No description provided for @unknownTranslationError.
  ///
  /// In zh, this message translates to:
  /// **'翻译歌词时发生未知错误。'**
  String get unknownTranslationError;

  /// No description provided for @unknownError.
  ///
  /// In zh, this message translates to:
  /// **'未知错误'**
  String get unknownError;

  /// No description provided for @modelRefusedToGenerateLyrics.
  ///
  /// In zh, this message translates to:
  /// **'模型拒绝生成歌词。'**
  String get modelRefusedToGenerateLyrics;

  /// No description provided for @modelRefusedToGenerateTimeline.
  ///
  /// In zh, this message translates to:
  /// **'模型拒绝生成时间轴。'**
  String get modelRefusedToGenerateTimeline;

  /// No description provided for @doubaoPreUploadTranscodingFailed.
  ///
  /// In zh, this message translates to:
  /// **'豆包上传前音频转码失败。'**
  String get doubaoPreUploadTranscodingFailed;

  /// No description provided for @doubaoTempTranscodeNotInTempDir.
  ///
  /// In zh, this message translates to:
  /// **'豆包临时转码文件未生成在临时目录。'**
  String get doubaoTempTranscodeNotInTempDir;

  /// No description provided for @doubaoEmptyStreamingResponse.
  ///
  /// In zh, this message translates to:
  /// **'豆包返回了空流响应。'**
  String get doubaoEmptyStreamingResponse;

  /// No description provided for @doubaoEmptyResponse.
  ///
  /// In zh, this message translates to:
  /// **'豆包返回了空响应。'**
  String get doubaoEmptyResponse;

  /// No description provided for @geminiEmptyStreamingResponse.
  ///
  /// In zh, this message translates to:
  /// **'Gemini 返回了空流响应。'**
  String get geminiEmptyStreamingResponse;

  /// No description provided for @geminiEmptyResponse.
  ///
  /// In zh, this message translates to:
  /// **'Gemini 返回了空响应。'**
  String get geminiEmptyResponse;

  /// No description provided for @openRouterEmptyStreamingResponse.
  ///
  /// In zh, this message translates to:
  /// **'OpenRouter 返回了空流响应。'**
  String get openRouterEmptyStreamingResponse;

  /// No description provided for @openRouterEmptyResponse.
  ///
  /// In zh, this message translates to:
  /// **'OpenRouter 返回了空响应。'**
  String get openRouterEmptyResponse;

  /// No description provided for @deepseekEmptyStreamingResponse.
  ///
  /// In zh, this message translates to:
  /// **'DeepSeek 返回了空流响应。'**
  String get deepseekEmptyStreamingResponse;

  /// No description provided for @deepseekEmptyResponse.
  ///
  /// In zh, this message translates to:
  /// **'DeepSeek 返回了空响应。'**
  String get deepseekEmptyResponse;

  /// No description provided for @customProviderEmptyStreamingResponse.
  ///
  /// In zh, this message translates to:
  /// **'自定义供应商返回了空流响应。'**
  String get customProviderEmptyStreamingResponse;

  /// No description provided for @customProviderEmptyResponse.
  ///
  /// In zh, this message translates to:
  /// **'自定义供应商返回了空响应。'**
  String get customProviderEmptyResponse;

  /// No description provided for @fileUploadFailed.
  ///
  /// In zh, this message translates to:
  /// **'文件上传失败，请重试。'**
  String get fileUploadFailed;

  /// No description provided for @uploadedFileNotReady.
  ///
  /// In zh, this message translates to:
  /// **'上传后的文件未能就绪，请稍后重试。'**
  String get uploadedFileNotReady;

  /// No description provided for @audioTranscodingFailed.
  ///
  /// In zh, this message translates to:
  /// **'音频转码失败。'**
  String get audioTranscodingFailed;

  /// No description provided for @tempTranscodeNotInTempDir.
  ///
  /// In zh, this message translates to:
  /// **'临时转码文件未生成在临时目录。'**
  String get tempTranscodeNotInTempDir;

  /// No description provided for @networkRequestFailedCheckProxy.
  ///
  /// In zh, this message translates to:
  /// **'网络请求失败，请检查网络以及代理状态。'**
  String get networkRequestFailedCheckProxy;

  /// No description provided for @quotaExhaustedToday.
  ///
  /// In zh, this message translates to:
  /// **'今天额度已用完，请等待明天额度恢复再试'**
  String get quotaExhaustedToday;

  /// No description provided for @googleAiHeavyLoad.
  ///
  /// In zh, this message translates to:
  /// **'谷歌AI服务遭遇大量请求，暂时不可用'**
  String get googleAiHeavyLoad;

  /// No description provided for @lyricsGenerationFailedWithError.
  ///
  /// In zh, this message translates to:
  /// **'生成歌词失败：{error}'**
  String lyricsGenerationFailedWithError(Object error);

  /// No description provided for @missingApiKeyForAction.
  ///
  /// In zh, this message translates to:
  /// **'未找到 {providerName} API Key，无法{action}。'**
  String missingApiKeyForAction(Object action, Object providerName);

  /// No description provided for @googleServerFlaky.
  ///
  /// In zh, this message translates to:
  /// **'Google服务器开小差了，重试一下或许会成功哦'**
  String get googleServerFlaky;

  /// No description provided for @translateLyricsAction.
  ///
  /// In zh, this message translates to:
  /// **'翻译歌词'**
  String get translateLyricsAction;

  /// No description provided for @generateLyricsAction.
  ///
  /// In zh, this message translates to:
  /// **'生成歌词'**
  String get generateLyricsAction;

  /// No description provided for @generateTimelineAction.
  ///
  /// In zh, this message translates to:
  /// **'生成时间轴'**
  String get generateTimelineAction;

  /// No description provided for @deepseekOnlyTranslation.
  ///
  /// In zh, this message translates to:
  /// **'DeepSeek 仅支持歌词翻译。'**
  String get deepseekOnlyTranslation;

  /// No description provided for @customProviderOnlyTranslation.
  ///
  /// In zh, this message translates to:
  /// **'自定义供应商仅支持歌词翻译。'**
  String get customProviderOnlyTranslation;

  /// No description provided for @customProviderNoBaseUrl.
  ///
  /// In zh, this message translates to:
  /// **'未配置自定义供应商的 Base URL。'**
  String get customProviderNoBaseUrl;

  /// No description provided for @pleaseEnterApiKey.
  ///
  /// In zh, this message translates to:
  /// **'请输入 API key。'**
  String get pleaseEnterApiKey;

  /// No description provided for @connectionSuccessVerificationPassed.
  ///
  /// In zh, this message translates to:
  /// **'连接成功，已通过验证。'**
  String get connectionSuccessVerificationPassed;

  /// No description provided for @connectionSuccessDetectedModels.
  ///
  /// In zh, this message translates to:
  /// **'连接成功，检测到 {count} 个模型。'**
  String connectionSuccessDetectedModels(Object count);

  /// No description provided for @testFailedWithStatus.
  ///
  /// In zh, this message translates to:
  /// **'测试失败（{statusCode}）：{message}'**
  String testFailedWithStatus(Object message, Object statusCode);

  /// No description provided for @testFailedCheckNetworkOrApiKey.
  ///
  /// In zh, this message translates to:
  /// **'测试失败，请检查网络或 API key。'**
  String get testFailedCheckNetworkOrApiKey;

  /// No description provided for @testFailedStatusCheckApiKey.
  ///
  /// In zh, this message translates to:
  /// **'测试失败（{statusCode}），请检查 API key 是否有效。'**
  String testFailedStatusCheckApiKey(Object statusCode);

  /// No description provided for @enterGoogleAiStudioApiKeyFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先填写 Google AI Studio API Key。'**
  String get enterGoogleAiStudioApiKeyFirst;

  /// No description provided for @enterDoubaoApiKeyFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先填写豆包 API Key。'**
  String get enterDoubaoApiKeyFirst;

  /// No description provided for @enterDeepseekApiKeyFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先填写 DeepSeek API Key。'**
  String get enterDeepseekApiKeyFirst;

  /// No description provided for @enterCustomApiKeyAndBaseUrl.
  ///
  /// In zh, this message translates to:
  /// **'请先填写自定义 API Key 和 Base URL。'**
  String get enterCustomApiKeyAndBaseUrl;

  /// No description provided for @fetchedCountModels.
  ///
  /// In zh, this message translates to:
  /// **'已获取 {count} 个模型。'**
  String fetchedCountModels(Object count);

  /// No description provided for @requestFailedWithStatus.
  ///
  /// In zh, this message translates to:
  /// **'请求失败（{statusCode}）：{message}'**
  String requestFailedWithStatus(Object message, Object statusCode);

  /// No description provided for @requestFailedCheckNetwork.
  ///
  /// In zh, this message translates to:
  /// **'请求失败，请检查网络。'**
  String get requestFailedCheckNetwork;

  /// No description provided for @requestFailedStatus.
  ///
  /// In zh, this message translates to:
  /// **'请求失败（{statusCode}）。'**
  String requestFailedStatus(Object statusCode);

  /// No description provided for @doubao.
  ///
  /// In zh, this message translates to:
  /// **'豆包'**
  String get doubao;

  /// No description provided for @custom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get custom;

  /// No description provided for @noModelSelected.
  ///
  /// In zh, this message translates to:
  /// **'未选择模型'**
  String get noModelSelected;

  /// No description provided for @acoustidRequestFailed.
  ///
  /// In zh, this message translates to:
  /// **'AcoustID 请求失败'**
  String get acoustidRequestFailed;

  /// No description provided for @acoustidRequestReturnedStatus.
  ///
  /// In zh, this message translates to:
  /// **'AcoustID 请求返回 {statusCode}。请申请你自己的 AcoustID API key 并填入设置页。'**
  String acoustidRequestReturnedStatus(Object statusCode);

  /// No description provided for @writeTagDatabaseFailed.
  ///
  /// In zh, this message translates to:
  /// **'写入标签数据库失败'**
  String get writeTagDatabaseFailed;

  /// No description provided for @playPause.
  ///
  /// In zh, this message translates to:
  /// **'播放 / 暂停'**
  String get playPause;

  /// No description provided for @nextTrack.
  ///
  /// In zh, this message translates to:
  /// **'下一首'**
  String get nextTrack;

  /// No description provided for @previousTrack.
  ///
  /// In zh, this message translates to:
  /// **'上一首'**
  String get previousTrack;

  /// No description provided for @volumeUp.
  ///
  /// In zh, this message translates to:
  /// **'音量增加'**
  String get volumeUp;

  /// No description provided for @volumeDown.
  ///
  /// In zh, this message translates to:
  /// **'音量减少'**
  String get volumeDown;

  /// No description provided for @toggleMute.
  ///
  /// In zh, this message translates to:
  /// **'静音切换'**
  String get toggleMute;

  /// No description provided for @seekForward5s.
  ///
  /// In zh, this message translates to:
  /// **'快进 5 秒'**
  String get seekForward5s;

  /// No description provided for @seekBackward5s.
  ///
  /// In zh, this message translates to:
  /// **'后退 5 秒'**
  String get seekBackward5s;

  /// No description provided for @toggleFullScreen.
  ///
  /// In zh, this message translates to:
  /// **'切换全屏'**
  String get toggleFullScreen;

  /// No description provided for @playPauseDescription.
  ///
  /// In zh, this message translates to:
  /// **'控制当前播放状态。'**
  String get playPauseDescription;

  /// No description provided for @nextDescription.
  ///
  /// In zh, this message translates to:
  /// **'切换到下一首歌曲。'**
  String get nextDescription;

  /// No description provided for @previousDescription.
  ///
  /// In zh, this message translates to:
  /// **'切换到上一首歌曲。'**
  String get previousDescription;

  /// No description provided for @volumeUpDescription.
  ///
  /// In zh, this message translates to:
  /// **'每次增加 5% 音量。'**
  String get volumeUpDescription;

  /// No description provided for @volumeDownDescription.
  ///
  /// In zh, this message translates to:
  /// **'每次减少 5% 音量。'**
  String get volumeDownDescription;

  /// No description provided for @toggleMuteDescription.
  ///
  /// In zh, this message translates to:
  /// **'切换静音。'**
  String get toggleMuteDescription;

  /// No description provided for @seekForward5sDescription.
  ///
  /// In zh, this message translates to:
  /// **'向前快进 5 秒。'**
  String get seekForward5sDescription;

  /// No description provided for @seekBackward5sDescription.
  ///
  /// In zh, this message translates to:
  /// **'向后快退 5 秒。'**
  String get seekBackward5sDescription;

  /// No description provided for @toggleFullScreenDescription.
  ///
  /// In zh, this message translates to:
  /// **'在窗口模式和全屏模式之间切换。'**
  String get toggleFullScreenDescription;

  /// No description provided for @unknownKey.
  ///
  /// In zh, this message translates to:
  /// **'未知按键'**
  String get unknownKey;

  /// No description provided for @removeFromQueue.
  ///
  /// In zh, this message translates to:
  /// **'从队列中移除'**
  String get removeFromQueue;

  /// No description provided for @removeFromPlaylist.
  ///
  /// In zh, this message translates to:
  /// **'从歌单中移除'**
  String get removeFromPlaylist;

  /// No description provided for @alreadyLatestVersion.
  ///
  /// In zh, this message translates to:
  /// **'当前已经是最新版本。'**
  String get alreadyLatestVersion;

  /// No description provided for @updateAvailable.
  ///
  /// In zh, this message translates to:
  /// **'发现新版本'**
  String get updateAvailable;

  /// No description provided for @newVersionAvailable.
  ///
  /// In zh, this message translates to:
  /// **'检测到新版本 v{version}，前往 GitHub Release 页面下载更新。'**
  String newVersionAvailable(Object version);

  /// No description provided for @openRelease.
  ///
  /// In zh, this message translates to:
  /// **'前往 Release'**
  String get openRelease;

  /// No description provided for @checkUpdateFailedNetwork.
  ///
  /// In zh, this message translates to:
  /// **'检查更新失败，可能是网络问题或 GitHub 限流。'**
  String get checkUpdateFailedNetwork;

  /// No description provided for @tags.
  ///
  /// In zh, this message translates to:
  /// **'标签'**
  String get tags;

  /// No description provided for @about.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// No description provided for @rebuildIndex.
  ///
  /// In zh, this message translates to:
  /// **'重建索引'**
  String get rebuildIndex;

  /// No description provided for @rebuildIndexDescription.
  ///
  /// In zh, this message translates to:
  /// **'清空除外部来源以外的所有歌曲记录并重新扫描所有根目录。'**
  String get rebuildIndexDescription;

  /// No description provided for @rebuildIndexConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'确认清空除外部来源以外的所有歌曲记录并重新扫描所有根目录吗？此操作需要一些时间。'**
  String get rebuildIndexConfirmation;

  /// No description provided for @rebuildIndexStarted.
  ///
  /// In zh, this message translates to:
  /// **'重建索引已启动'**
  String get rebuildIndexStarted;

  /// No description provided for @rebuild.
  ///
  /// In zh, this message translates to:
  /// **'重建'**
  String get rebuild;

  /// No description provided for @advanced.
  ///
  /// In zh, this message translates to:
  /// **'高级'**
  String get advanced;

  /// No description provided for @advancedOptionsDescription.
  ///
  /// In zh, this message translates to:
  /// **'更偏调试和行为控制的选项。'**
  String get advancedOptionsDescription;

  /// No description provided for @showDeveloperOptionsDescription.
  ///
  /// In zh, this message translates to:
  /// **'显示更多偏调试用途的高级项。'**
  String get showDeveloperOptionsDescription;

  /// No description provided for @onboardingReset.
  ///
  /// In zh, this message translates to:
  /// **'已重置新手引导状态，下次启动时生效。'**
  String get onboardingReset;

  /// No description provided for @tagsSectionDescription.
  ///
  /// In zh, this message translates to:
  /// **'关于音频文件元数据和自动补全的配置。'**
  String get tagsSectionDescription;

  /// No description provided for @autoSaveToSourceFile.
  ///
  /// In zh, this message translates to:
  /// **'自动写入源文件'**
  String get autoSaveToSourceFile;

  /// No description provided for @autoSaveToSourceFileDescription.
  ///
  /// In zh, this message translates to:
  /// **'补全或更新歌曲标签时，默认同步写入物理音频文件。'**
  String get autoSaveToSourceFileDescription;

  /// No description provided for @aboutSectionDescription.
  ///
  /// In zh, this message translates to:
  /// **'版本信息、项目链接和相关资料。'**
  String get aboutSectionDescription;

  /// No description provided for @checkForUpdates.
  ///
  /// In zh, this message translates to:
  /// **'检查更新'**
  String get checkForUpdates;

  /// No description provided for @storeUpdateNotice.
  ///
  /// In zh, this message translates to:
  /// **'当前应用由 Microsoft Store 托管更新。您可以前往 Microsoft Store 查看或获取最新版本。'**
  String get storeUpdateNotice;

  /// No description provided for @openMicrosoftStore.
  ///
  /// In zh, this message translates to:
  /// **'前往 Microsoft Store'**
  String get openMicrosoftStore;

  /// No description provided for @appStoreUpdateNotice.
  ///
  /// In zh, this message translates to:
  /// **'当前应用由 App Store 托管更新。您可以前往 App Store 查看或获取最新版本。'**
  String get appStoreUpdateNotice;

  /// No description provided for @openAppStore.
  ///
  /// In zh, this message translates to:
  /// **'前往 App Store'**
  String get openAppStore;

  /// No description provided for @lyricsGenerationModel.
  ///
  /// In zh, this message translates to:
  /// **'歌词生成模型'**
  String get lyricsGenerationModel;

  /// No description provided for @lyricsGenerationModelDescription.
  ///
  /// In zh, this message translates to:
  /// **'用于 AI 听歌生成歌词，以及给现有歌词生成/修正时间轴。'**
  String get lyricsGenerationModelDescription;

  /// No description provided for @lyricsTranslationModel.
  ///
  /// In zh, this message translates to:
  /// **'歌词翻译模型'**
  String get lyricsTranslationModel;

  /// No description provided for @lyricsTranslationModelDescription.
  ///
  /// In zh, this message translates to:
  /// **'用于把歌词翻译到目标语言。'**
  String get lyricsTranslationModelDescription;

  /// No description provided for @onlyForLyricTranslation.
  ///
  /// In zh, this message translates to:
  /// **'仅用于歌词翻译'**
  String get onlyForLyricTranslation;

  /// No description provided for @fillApiKeyFirstEnablesModels.
  ///
  /// In zh, this message translates to:
  /// **'请先填写至少一个 API Key，模型选择才会启用。'**
  String get fillApiKeyFirstEnablesModels;

  /// No description provided for @customApiProvider.
  ///
  /// In zh, this message translates to:
  /// **'自定义 API 供应商'**
  String get customApiProvider;

  /// No description provided for @clearedGoogleAiStudioApiKey.
  ///
  /// In zh, this message translates to:
  /// **'已清空 Google AI Studio API Key'**
  String get clearedGoogleAiStudioApiKey;

  /// No description provided for @clearedOpenRouterApiKey.
  ///
  /// In zh, this message translates to:
  /// **'已清空 OpenRouter API Key'**
  String get clearedOpenRouterApiKey;

  /// No description provided for @clearedDoubaoApiKey.
  ///
  /// In zh, this message translates to:
  /// **'已清空豆包 API Key'**
  String get clearedDoubaoApiKey;

  /// No description provided for @clearedDeepseekApiKey.
  ///
  /// In zh, this message translates to:
  /// **'已清空 DeepSeek API Key'**
  String get clearedDeepseekApiKey;

  /// No description provided for @clearedCustomProviderConfig.
  ///
  /// In zh, this message translates to:
  /// **'已清空自定义供应商配置'**
  String get clearedCustomProviderConfig;

  /// No description provided for @savedDoubaoApiKey.
  ///
  /// In zh, this message translates to:
  /// **'已保存豆包 API Key'**
  String get savedDoubaoApiKey;

  /// No description provided for @savedDeepseekApiKey.
  ///
  /// In zh, this message translates to:
  /// **'已保存 DeepSeek API Key'**
  String get savedDeepseekApiKey;

  /// No description provided for @savedCustomProviderConfig.
  ///
  /// In zh, this message translates to:
  /// **'已保存自定义供应商配置'**
  String get savedCustomProviderConfig;

  /// No description provided for @noMatchingFoldersOrSongs.
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配的文件夹或歌曲'**
  String get noMatchingFoldersOrSongs;

  /// No description provided for @searching.
  ///
  /// In zh, this message translates to:
  /// **'正在搜索...'**
  String get searching;

  /// No description provided for @listView.
  ///
  /// In zh, this message translates to:
  /// **'列表视图'**
  String get listView;

  /// No description provided for @gridView.
  ///
  /// In zh, this message translates to:
  /// **'网格视图'**
  String get gridView;

  /// No description provided for @hybridView.
  ///
  /// In zh, this message translates to:
  /// **'混合视图'**
  String get hybridView;

  /// No description provided for @songsCountFormat.
  ///
  /// In zh, this message translates to:
  /// **'{count} 首歌曲'**
  String songsCountFormat(Object count);

  /// No description provided for @searchInFolderAndSubfolders.
  ///
  /// In zh, this message translates to:
  /// **'在当前目录及子目录下搜索...'**
  String get searchInFolderAndSubfolders;

  /// No description provided for @shuffle.
  ///
  /// In zh, this message translates to:
  /// **'随机播放'**
  String get shuffle;

  /// No description provided for @search.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// No description provided for @selectFolders.
  ///
  /// In zh, this message translates to:
  /// **'选择目录'**
  String get selectFolders;

  /// No description provided for @removeDirectory.
  ///
  /// In zh, this message translates to:
  /// **'移除目录'**
  String get removeDirectory;

  /// No description provided for @removeRootDirectoryConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'确定要移除根目录 \"{name}\" 吗？此操作不会删除磁盘上的物理文件。'**
  String removeRootDirectoryConfirmation(Object name);

  /// No description provided for @deselectAll.
  ///
  /// In zh, this message translates to:
  /// **'取消全选'**
  String get deselectAll;

  /// No description provided for @favorites.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get favorites;

  /// No description provided for @aggregationPeak.
  ///
  /// In zh, this message translates to:
  /// **'峰值'**
  String get aggregationPeak;

  /// No description provided for @aggregationMean.
  ///
  /// In zh, this message translates to:
  /// **'平均值'**
  String get aggregationMean;

  /// No description provided for @aggregationRms.
  ///
  /// In zh, this message translates to:
  /// **'均方根'**
  String get aggregationRms;

  /// No description provided for @filesToTranscode.
  ///
  /// In zh, this message translates to:
  /// **'待转码文件'**
  String get filesToTranscode;

  /// No description provided for @chooseAndroidOutputDirectoryFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先选择一个 Android 输出目录。'**
  String get chooseAndroidOutputDirectoryFirst;

  /// No description provided for @currentSongProgressPercent.
  ///
  /// In zh, this message translates to:
  /// **'当前歌曲 {percent}%'**
  String currentSongProgressPercent(Object percent);

  /// No description provided for @overallProgressPercent.
  ///
  /// In zh, this message translates to:
  /// **'总体 {percent}%'**
  String overallProgressPercent(Object percent);

  /// No description provided for @pleaseChooseOutputDirectory.
  ///
  /// In zh, this message translates to:
  /// **'请先选择一个输出目录。'**
  String get pleaseChooseOutputDirectory;

  /// No description provided for @selectedArtistsCount.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} 位艺术家'**
  String selectedArtistsCount(Object count);

  /// No description provided for @selectedAlbumsCount.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} 张专辑'**
  String selectedAlbumsCount(Object count);

  /// No description provided for @simplifiedChinese.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get simplifiedChinese;

  /// No description provided for @traditionalChinese.
  ///
  /// In zh, this message translates to:
  /// **'繁体中文'**
  String get traditionalChinese;

  /// No description provided for @chineseLanguage.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get chineseLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In zh, this message translates to:
  /// **'英文'**
  String get englishLanguage;

  /// No description provided for @japaneseLanguage.
  ///
  /// In zh, this message translates to:
  /// **'日文'**
  String get japaneseLanguage;

  /// No description provided for @koreanLanguage.
  ///
  /// In zh, this message translates to:
  /// **'韩文'**
  String get koreanLanguage;

  /// No description provided for @frenchLanguage.
  ///
  /// In zh, this message translates to:
  /// **'法文'**
  String get frenchLanguage;

  /// No description provided for @germanLanguage.
  ///
  /// In zh, this message translates to:
  /// **'德文'**
  String get germanLanguage;

  /// No description provided for @spanishLanguage.
  ///
  /// In zh, this message translates to:
  /// **'西班牙文'**
  String get spanishLanguage;

  /// No description provided for @nativeLanguageZh.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get nativeLanguageZh;

  /// No description provided for @nativeLanguageZhHant.
  ///
  /// In zh, this message translates to:
  /// **'繁體中文'**
  String get nativeLanguageZhHant;

  /// No description provided for @nativeLanguageEn.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get nativeLanguageEn;

  /// No description provided for @nativeLanguageJa.
  ///
  /// In zh, this message translates to:
  /// **'日本語'**
  String get nativeLanguageJa;

  /// No description provided for @nativeLanguageKo.
  ///
  /// In zh, this message translates to:
  /// **'한국어'**
  String get nativeLanguageKo;

  /// No description provided for @nativeLanguageFr.
  ///
  /// In zh, this message translates to:
  /// **'Français'**
  String get nativeLanguageFr;

  /// No description provided for @nativeLanguageDe.
  ///
  /// In zh, this message translates to:
  /// **'Deutsch'**
  String get nativeLanguageDe;

  /// No description provided for @nativeLanguageEs.
  ///
  /// In zh, this message translates to:
  /// **'Español'**
  String get nativeLanguageEs;

  /// No description provided for @portugueseLanguage.
  ///
  /// In zh, this message translates to:
  /// **'葡萄牙文'**
  String get portugueseLanguage;

  /// No description provided for @russianLanguage.
  ///
  /// In zh, this message translates to:
  /// **'俄文'**
  String get russianLanguage;

  /// No description provided for @systemLanguage.
  ///
  /// In zh, this message translates to:
  /// **'系统语言'**
  String get systemLanguage;

  /// No description provided for @targetLanguage.
  ///
  /// In zh, this message translates to:
  /// **'目标语言'**
  String get targetLanguage;

  /// No description provided for @whatAreAiLyrics.
  ///
  /// In zh, this message translates to:
  /// **'什么是 AI 歌词？'**
  String get whatAreAiLyrics;

  /// No description provided for @whatIsAiLyricTranslation.
  ///
  /// In zh, this message translates to:
  /// **'什么是 AI 歌词翻译？'**
  String get whatIsAiLyricTranslation;

  /// No description provided for @aiLyricsIntroGeneration.
  ///
  /// In zh, this message translates to:
  /// **'AI 可以根据歌曲内容生成歌词，并自动匹配时间轴。'**
  String get aiLyricsIntroGeneration;

  /// No description provided for @aiLyricsIntroTranslation.
  ///
  /// In zh, this message translates to:
  /// **'AI 可以把歌词翻译成你熟悉的语言，方便理解歌曲内容。'**
  String get aiLyricsIntroTranslation;

  /// No description provided for @whyNeedApiKey.
  ///
  /// In zh, this message translates to:
  /// **'为什么需要 API Key？'**
  String get whyNeedApiKey;

  /// No description provided for @apiKeyExplanation.
  ///
  /// In zh, this message translates to:
  /// **'API Key 相当于你在 AI 服务商那里的访问凭证。应用会用它直接向服务商发起请求，完成歌词生成、时间轴调整或翻译。'**
  String get apiKeyExplanation;

  /// No description provided for @apiKeyLocalOnly.
  ///
  /// In zh, this message translates to:
  /// **'API Key 只保存在你的本地设备，不会上传到 Vynody 开发者服务器。'**
  String get apiKeyLocalOnly;

  /// No description provided for @chooseAnAiProvider.
  ///
  /// In zh, this message translates to:
  /// **'选择一个 AI 服务商：'**
  String get chooseAnAiProvider;

  /// No description provided for @googleProviderPros.
  ///
  /// In zh, this message translates to:
  /// **'Google 官方通道，Gemini 模型能力强，免费额度较多。'**
  String get googleProviderPros;

  /// No description provided for @googleProviderCons.
  ///
  /// In zh, this message translates to:
  /// **'中国大陆直连受限，需要稳定的 VPN/代理。请求人数较多时可能报 429，遇到 429 请切换到其他渠道。'**
  String get googleProviderCons;

  /// No description provided for @openRouterProviderPros.
  ///
  /// In zh, this message translates to:
  /// **'海外大模型聚合平台，可使用多个模型，也有部分免费模型。'**
  String get openRouterProviderPros;

  /// No description provided for @openRouterProviderCons.
  ///
  /// In zh, this message translates to:
  /// **'充值需要支付手续费，网页只有英文。'**
  String get openRouterProviderCons;

  /// No description provided for @doubaoProviderPros.
  ///
  /// In zh, this message translates to:
  /// **'字节跳动出品，国内访问快，中文效果好。新用户每个模型有 50 万免费 token。'**
  String get doubaoProviderPros;

  /// No description provided for @doubaoProviderCons.
  ///
  /// In zh, this message translates to:
  /// **'注册步骤相对繁琐，需要实名认证。'**
  String get doubaoProviderCons;

  /// No description provided for @deepseekProviderPros.
  ///
  /// In zh, this message translates to:
  /// **'中文理解好，价格便宜，适合歌词翻译。'**
  String get deepseekProviderPros;

  /// No description provided for @deepseekProviderCons.
  ///
  /// In zh, this message translates to:
  /// **'仅支持文本输入。如需歌词生成、时间轴调整，需要填入其他渠道 API Key。'**
  String get deepseekProviderCons;

  /// No description provided for @highlights.
  ///
  /// In zh, this message translates to:
  /// **'【特点】'**
  String get highlights;

  /// No description provided for @notes.
  ///
  /// In zh, this message translates to:
  /// **'【注意事项】'**
  String get notes;

  /// No description provided for @enterProviderApiKey.
  ///
  /// In zh, this message translates to:
  /// **'请输入 {provider} 的 API Key：'**
  String enterProviderApiKey(Object provider);

  /// No description provided for @pasteYourApiKey.
  ///
  /// In zh, this message translates to:
  /// **'在此粘贴你的 API Key'**
  String get pasteYourApiKey;

  /// No description provided for @getApiKey.
  ///
  /// In zh, this message translates to:
  /// **'获取 API Key'**
  String get getApiKey;

  /// No description provided for @testConnectionButton.
  ///
  /// In zh, this message translates to:
  /// **'测试连接'**
  String get testConnectionButton;

  /// No description provided for @enableAiLyricGeneration.
  ///
  /// In zh, this message translates to:
  /// **'启用 AI 歌词生成'**
  String get enableAiLyricGeneration;

  /// No description provided for @enableAiLyricTranslation.
  ///
  /// In zh, this message translates to:
  /// **'启用 AI 歌词翻译'**
  String get enableAiLyricTranslation;

  /// No description provided for @notNow.
  ///
  /// In zh, this message translates to:
  /// **'暂不启用'**
  String get notNow;

  /// No description provided for @startSetup.
  ///
  /// In zh, this message translates to:
  /// **'开始配置'**
  String get startSetup;

  /// No description provided for @chooseAiProvider.
  ///
  /// In zh, this message translates to:
  /// **'选择 AI 服务商'**
  String get chooseAiProvider;

  /// No description provided for @backStep.
  ///
  /// In zh, this message translates to:
  /// **'上一步'**
  String get backStep;

  /// No description provided for @continueAction.
  ///
  /// In zh, this message translates to:
  /// **'继续'**
  String get continueAction;

  /// No description provided for @nextStep.
  ///
  /// In zh, this message translates to:
  /// **'下一步'**
  String get nextStep;

  /// No description provided for @configureApiKey.
  ///
  /// In zh, this message translates to:
  /// **'配置 API Key'**
  String get configureApiKey;

  /// No description provided for @saveAndFinish.
  ///
  /// In zh, this message translates to:
  /// **'保存并完成'**
  String get saveAndFinish;

  /// No description provided for @testing.
  ///
  /// In zh, this message translates to:
  /// **'正在测试...'**
  String get testing;

  /// No description provided for @noteTitle.
  ///
  /// In zh, this message translates to:
  /// **'提示'**
  String get noteTitle;

  /// No description provided for @deepseekTextInputOnlyNote.
  ///
  /// In zh, this message translates to:
  /// **'DeepSeek 仅支持文本输入。如需歌词生成、时间轴调整，需要填入其他渠道 API Key。'**
  String get deepseekTextInputOnlyNote;

  /// No description provided for @retryAttemptOfMax.
  ///
  /// In zh, this message translates to:
  /// **'重试第 {attempt} 次 / 共 {maxRetry} 次'**
  String retryAttemptOfMax(Object attempt, Object maxRetry);

  /// No description provided for @generatingTaskKind.
  ///
  /// In zh, this message translates to:
  /// **'正在生成{taskKind}'**
  String generatingTaskKind(Object taskKind);

  /// No description provided for @connectionTestException.
  ///
  /// In zh, this message translates to:
  /// **'连接测试异常：{error}'**
  String connectionTestException(Object error);

  /// No description provided for @testingConnectionProgress.
  ///
  /// In zh, this message translates to:
  /// **'正在测试连接...'**
  String get testingConnectionProgress;

  /// No description provided for @clear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get clear;

  /// No description provided for @enterDoubaoApiKey.
  ///
  /// In zh, this message translates to:
  /// **'输入豆包 API Key'**
  String get enterDoubaoApiKey;

  /// No description provided for @doubaoApiKeyDescription.
  ///
  /// In zh, this message translates to:
  /// **'请输入火山方舟 / 豆包的 API Key，用于歌词生成和翻译。'**
  String get doubaoApiKeyDescription;

  /// No description provided for @enterDeepseekApiKey.
  ///
  /// In zh, this message translates to:
  /// **'输入 DeepSeek API Key'**
  String get enterDeepseekApiKey;

  /// No description provided for @deepseekApiKeyDescription.
  ///
  /// In zh, this message translates to:
  /// **'请输入 DeepSeek 的 API Key，仅用于歌词翻译。'**
  String get deepseekApiKeyDescription;

  /// No description provided for @pleaseEnterApiKeyHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入 API Key'**
  String get pleaseEnterApiKeyHint;

  /// No description provided for @platform.
  ///
  /// In zh, this message translates to:
  /// **'平台'**
  String get platform;

  /// No description provided for @showRecommendedOnly.
  ///
  /// In zh, this message translates to:
  /// **'仅显示推荐模型'**
  String get showRecommendedOnly;

  /// No description provided for @noAvailableChannels.
  ///
  /// In zh, this message translates to:
  /// **'暂无可用渠道'**
  String get noAvailableChannels;

  /// No description provided for @noMatchingModels.
  ///
  /// In zh, this message translates to:
  /// **'没有找到匹配的模型'**
  String get noMatchingModels;

  /// No description provided for @leaveEmpty.
  ///
  /// In zh, this message translates to:
  /// **'留空'**
  String get leaveEmpty;

  /// No description provided for @leaveEmptyFallbackDescription.
  ///
  /// In zh, this message translates to:
  /// **'不设置备用模型时可选择此项。'**
  String get leaveEmptyFallbackDescription;

  /// No description provided for @modelSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'输入模型名、ID'**
  String get modelSearchHint;

  /// Toast when sending files fails
  ///
  /// In zh, this message translates to:
  /// **'发送文件失败: {error}'**
  String sendFilesFailed(Object error);

  /// No description provided for @scanningFolderMusic.
  ///
  /// In zh, this message translates to:
  /// **'正在扫描文件夹中的音乐文件...'**
  String get scanningFolderMusic;

  /// Toast when scanning folder fails
  ///
  /// In zh, this message translates to:
  /// **'扫描文件夹失败: {error}'**
  String scanFolderFailed(Object error);

  /// No description provided for @noMusicFilesFound.
  ///
  /// In zh, this message translates to:
  /// **'未在此文件夹中找到支持的音乐文件'**
  String get noMusicFilesFound;

  /// Toast when sending folder fails
  ///
  /// In zh, this message translates to:
  /// **'发送文件夹失败: {error}'**
  String sendFolderFailed(Object error);

  /// No description provided for @lanSharingStartFailed.
  ///
  /// In zh, this message translates to:
  /// **'局域网共享启动失败，请检查本地网络权限是否已开启'**
  String get lanSharingStartFailed;

  /// Toast when syncing lyrics to a device
  ///
  /// In zh, this message translates to:
  /// **'正在向 {deviceName} 同步歌词...'**
  String syncingLyricsToDevice(Object deviceName);

  /// Toast when sync completes
  ///
  /// In zh, this message translates to:
  /// **'同步成功: 匹配 {matched} 首, 更新 {overwritten} 首, 忽略 {skipped} 首'**
  String syncLyricsSuccess(Object matched, Object overwritten, Object skipped);

  /// Toast when sync fails
  ///
  /// In zh, this message translates to:
  /// **'同步歌词失败: {error}'**
  String syncLyricsFailed(Object error);

  /// Toast when syncing lyrics from a device
  ///
  /// In zh, this message translates to:
  /// **'正在从 {deviceName} 同步歌词...'**
  String syncingLyricsFromDevice(Object deviceName);

  /// No description provided for @transferInProgressDoNotLeave.
  ///
  /// In zh, this message translates to:
  /// **'正在传输文件，请勿离开共享页'**
  String get transferInProgressDoNotLeave;

  /// No description provided for @lanSharingTitle.
  ///
  /// In zh, this message translates to:
  /// **'局域网文件共享'**
  String get lanSharingTitle;

  /// No description provided for @lanSharingEnabledStatus.
  ///
  /// In zh, this message translates to:
  /// **'局域网共享已开启'**
  String get lanSharingEnabledStatus;

  /// No description provided for @lanSharingDisabledStatus.
  ///
  /// In zh, this message translates to:
  /// **'局域网共享未开启'**
  String get lanSharingDisabledStatus;

  /// Status text showing IP and port
  ///
  /// In zh, this message translates to:
  /// **'本机 IP: {ip}（端口: {port}）'**
  String lanSharingRunningStatus(Object ip, Object port);

  /// No description provided for @lanSharingDefaultOffHint.
  ///
  /// In zh, this message translates to:
  /// **'默认关闭，开启后会请求局域网权限'**
  String get lanSharingDefaultOffHint;

  /// No description provided for @receiveDirectoryNotSetWarning.
  ///
  /// In zh, this message translates to:
  /// **'未设置接收文件保存目录时将无法接收文件，建议先设置。'**
  String get receiveDirectoryNotSetWarning;

  /// Toast when receive directory is updated
  ///
  /// In zh, this message translates to:
  /// **'接收目录已更新为: {path}'**
  String receiveDirectoryUpdated(Object path);

  /// No description provided for @receiveDirectoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'接收文件保存目录'**
  String get receiveDirectoryTitle;

  /// No description provided for @linkCopiedToClipboard.
  ///
  /// In zh, this message translates to:
  /// **'链接已复制到剪贴板'**
  String get linkCopiedToClipboard;

  /// No description provided for @nearbyDevices.
  ///
  /// In zh, this message translates to:
  /// **'附近的设备'**
  String get nearbyDevices;

  /// No description provided for @searchingDevices.
  ///
  /// In zh, this message translates to:
  /// **'正在寻找局域网内其他设备...'**
  String get searchingDevices;

  /// No description provided for @startSharingToFindDevices.
  ///
  /// In zh, this message translates to:
  /// **'开启共享后开始寻找设备'**
  String get startSharingToFindDevices;

  /// No description provided for @deviceOnline.
  ///
  /// In zh, this message translates to:
  /// **'在线'**
  String get deviceOnline;

  /// No description provided for @deviceOffline.
  ///
  /// In zh, this message translates to:
  /// **'已断开'**
  String get deviceOffline;

  /// No description provided for @sendMusicFiles.
  ///
  /// In zh, this message translates to:
  /// **'发送音乐文件'**
  String get sendMusicFiles;

  /// No description provided for @sendFolder.
  ///
  /// In zh, this message translates to:
  /// **'发送文件夹'**
  String get sendFolder;

  /// No description provided for @syncLyricsToDeviceAction.
  ///
  /// In zh, this message translates to:
  /// **'同步歌词至该设备'**
  String get syncLyricsToDeviceAction;

  /// No description provided for @syncLyricsFromDeviceAction.
  ///
  /// In zh, this message translates to:
  /// **'从该设备同步歌词'**
  String get syncLyricsFromDeviceAction;

  /// Error message when loading devices fails
  ///
  /// In zh, this message translates to:
  /// **'加载设备出错: {error}'**
  String loadDevicesError(Object error);

  /// File names in incoming transfer dialog
  ///
  /// In zh, this message translates to:
  /// **'{name1}、{name2} 等共 {count} 个文件'**
  String incomingFilesFormat(Object name1, Object name2, Object count);

  /// No description provided for @incomingTransferRequestTitle.
  ///
  /// In zh, this message translates to:
  /// **'收到文件共享请求'**
  String get incomingTransferRequestTitle;

  /// Who sent the request
  ///
  /// In zh, this message translates to:
  /// **'来自 \"{senderName}\" 的发送请求：'**
  String incomingTransferFrom(Object senderName);

  /// File size in megabytes
  ///
  /// In zh, this message translates to:
  /// **'文件大小: {sizeMb} MB'**
  String fileSizeMb(Object sizeMb);

  /// No description provided for @receiveFileHint.
  ///
  /// In zh, this message translates to:
  /// **'提示：接收后文件将自动保存至本地音乐文件夹并加入媒体库。'**
  String get receiveFileHint;

  /// No description provided for @reject.
  ///
  /// In zh, this message translates to:
  /// **'拒绝'**
  String get reject;

  /// No description provided for @accept.
  ///
  /// In zh, this message translates to:
  /// **'接收'**
  String get accept;

  /// No description provided for @incomingLyricsExportTitle.
  ///
  /// In zh, this message translates to:
  /// **'收到歌词导出读取请求'**
  String get incomingLyricsExportTitle;

  /// Who requested to export/read lyrics
  ///
  /// In zh, this message translates to:
  /// **'设备 \"{senderName}\" 申请读取并导出您设备上的歌词库。'**
  String incomingLyricsExportFrom(Object senderName);

  /// No description provided for @incomingLyricsImportTitle.
  ///
  /// In zh, this message translates to:
  /// **'收到歌词导入更新请求'**
  String get incomingLyricsImportTitle;

  /// Who requested to import/push lyrics
  ///
  /// In zh, this message translates to:
  /// **'设备 \"{senderName}\" 申请向您设备导入共 {count} 首歌曲的歌词。'**
  String incomingLyricsImportFrom(Object senderName, Object count);

  /// No description provided for @lyricsRequestRejected.
  ///
  /// In zh, this message translates to:
  /// **'对方拒绝了歌词同步请求'**
  String get lyricsRequestRejected;

  /// Toast when sending completes
  ///
  /// In zh, this message translates to:
  /// **'\"{fileName}\" 发送完毕'**
  String sendCompleted(Object fileName);

  /// Toast when receiving completes
  ///
  /// In zh, this message translates to:
  /// **'成功接收了 {count} 首歌曲'**
  String receiveCompleted(int count);

  /// Toast when transfer is cancelled with reason
  ///
  /// In zh, this message translates to:
  /// **'{direction}已取消（{reason}）'**
  String transferCancelledWithReason(Object direction, Object reason);

  /// Toast when transfer fails
  ///
  /// In zh, this message translates to:
  /// **'{direction} \"{fileName}\" 失败'**
  String transferFailedFormat(Object direction, Object fileName);

  /// Title for send progress dialog
  ///
  /// In zh, this message translates to:
  /// **'正在发送到 {deviceName}'**
  String sendingToDevice(Object deviceName);

  /// Title for receive progress dialog
  ///
  /// In zh, this message translates to:
  /// **'正在从 {deviceName} 接收'**
  String receivingFromDevice(Object deviceName);

  /// Transfer progress percentage
  ///
  /// In zh, this message translates to:
  /// **'进度: {percent}%'**
  String progressFormat(Object percent);

  /// No description provided for @currentlyTransferring.
  ///
  /// In zh, this message translates to:
  /// **'当前正在传输'**
  String get currentlyTransferring;

  /// No description provided for @fileConflictTitle.
  ///
  /// In zh, this message translates to:
  /// **'文件冲突'**
  String get fileConflictTitle;

  /// No description provided for @fileConflictMessage.
  ///
  /// In zh, this message translates to:
  /// **'目标设备已存在同名文件：'**
  String get fileConflictMessage;

  /// No description provided for @fileConflictChooseAction.
  ///
  /// In zh, this message translates to:
  /// **'请选择您要执行的操作：'**
  String get fileConflictChooseAction;

  /// No description provided for @skipAction.
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get skipAction;

  /// No description provided for @overwriteAction.
  ///
  /// In zh, this message translates to:
  /// **'覆盖'**
  String get overwriteAction;

  /// No description provided for @skipAllAction.
  ///
  /// In zh, this message translates to:
  /// **'全部跳过'**
  String get skipAllAction;

  /// No description provided for @overwriteAllAction.
  ///
  /// In zh, this message translates to:
  /// **'全部覆盖'**
  String get overwriteAllAction;

  /// No description provided for @sendDirection.
  ///
  /// In zh, this message translates to:
  /// **'发送'**
  String get sendDirection;

  /// No description provided for @receiveDirection.
  ///
  /// In zh, this message translates to:
  /// **'接收'**
  String get receiveDirection;

  /// No description provided for @fileAssociationEnabled.
  ///
  /// In zh, this message translates to:
  /// **'已开启关联'**
  String get fileAssociationEnabled;

  /// No description provided for @fileAssociationDisabled.
  ///
  /// In zh, this message translates to:
  /// **'未开启关联'**
  String get fileAssociationDisabled;

  /// No description provided for @windowsAutoRepairShortcut.
  ///
  /// In zh, this message translates to:
  /// **'自动修复开始菜单快捷方式'**
  String get windowsAutoRepairShortcut;

  /// No description provided for @windowsAutoRepairShortcutDescription.
  ///
  /// In zh, this message translates to:
  /// **'每次启动时自动检查并创建开始菜单快捷方式以正确显示媒体控制项名称与图标'**
  String get windowsAutoRepairShortcutDescription;

  /// No description provided for @confirmDisableShortcutRepair.
  ///
  /// In zh, this message translates to:
  /// **'确定关闭此功能吗？'**
  String get confirmDisableShortcutRepair;

  /// No description provided for @confirmDisableShortcutRepairContent.
  ///
  /// In zh, this message translates to:
  /// **'如果缺少开始菜单快捷方式，Windows 媒体控制中心（音量调节弹窗）将会把软件显示为\"未知应用\"，并且无法展示应用图标。是否确定关闭此功能？'**
  String get confirmDisableShortcutRepairContent;

  /// No description provided for @confirmDisable.
  ///
  /// In zh, this message translates to:
  /// **'确定关闭'**
  String get confirmDisable;

  /// No description provided for @enableSystemTray.
  ///
  /// In zh, this message translates to:
  /// **'启用系统托盘'**
  String get enableSystemTray;

  /// No description provided for @enableSystemTrayDescription.
  ///
  /// In zh, this message translates to:
  /// **'在系统任务栏托盘中显示图标，方便快速控制播放'**
  String get enableSystemTrayDescription;

  /// No description provided for @closeToTray.
  ///
  /// In zh, this message translates to:
  /// **'点击关闭按钮时最小化到后台'**
  String get closeToTray;

  /// No description provided for @closeToTrayDescription.
  ///
  /// In zh, this message translates to:
  /// **'关闭主界面时保持后台播放，不直接退出程序'**
  String get closeToTrayDescription;

  /// No description provided for @closeWindowActionTitle.
  ///
  /// In zh, this message translates to:
  /// **'点击关闭按钮时'**
  String get closeWindowActionTitle;

  /// No description provided for @closeWindowActionDescription.
  ///
  /// In zh, this message translates to:
  /// **'选择点击主界面关闭按钮时的操作'**
  String get closeWindowActionDescription;

  /// No description provided for @closeWindowActionAsk.
  ///
  /// In zh, this message translates to:
  /// **'每次询问'**
  String get closeWindowActionAsk;

  /// No description provided for @closeWindowActionMinimize.
  ///
  /// In zh, this message translates to:
  /// **'最小化到系统托盘'**
  String get closeWindowActionMinimize;

  /// No description provided for @closeWindowActionExit.
  ///
  /// In zh, this message translates to:
  /// **'完全退出应用'**
  String get closeWindowActionExit;

  /// No description provided for @closeWindowActionRemember.
  ///
  /// In zh, this message translates to:
  /// **'记住我的选择，不再提示'**
  String get closeWindowActionRemember;

  /// No description provided for @closeWindowActionTrayDisabledTip.
  ///
  /// In zh, this message translates to:
  /// **'（需先启用系统托盘）'**
  String get closeWindowActionTrayDisabledTip;

  /// No description provided for @closeWindowDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'关闭应用确认'**
  String get closeWindowDialogTitle;

  /// No description provided for @closeWindowDialogContent.
  ///
  /// In zh, this message translates to:
  /// **'请选择点击关闭按钮时的操作：'**
  String get closeWindowDialogContent;

  /// No description provided for @googleAiStudioApiKey.
  ///
  /// In zh, this message translates to:
  /// **'Google AI Studio API Key'**
  String get googleAiStudioApiKey;

  /// No description provided for @openRouterApiKey.
  ///
  /// In zh, this message translates to:
  /// **'OpenRouter API Key'**
  String get openRouterApiKey;

  /// No description provided for @doubaoApiKey.
  ///
  /// In zh, this message translates to:
  /// **'豆包 API Key'**
  String get doubaoApiKey;

  /// No description provided for @deepseekApiKey.
  ///
  /// In zh, this message translates to:
  /// **'DeepSeek API Key'**
  String get deepseekApiKey;

  /// No description provided for @unexpectedResponseFormat.
  ///
  /// In zh, this message translates to:
  /// **'意外的响应格式。'**
  String get unexpectedResponseFormat;

  /// No description provided for @baseUrl.
  ///
  /// In zh, this message translates to:
  /// **'Base URL'**
  String get baseUrl;

  /// No description provided for @openaiCompatibleEndpoint.
  ///
  /// In zh, this message translates to:
  /// **'兼容 OpenAI 的 API 端点'**
  String get openaiCompatibleEndpoint;

  /// No description provided for @onboardingAddedDirectoriesCount.
  ///
  /// In zh, this message translates to:
  /// **'已添加的目录（{count}）：'**
  String onboardingAddedDirectoriesCount(Object count);

  /// No description provided for @gnomeDisksOpenFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法自动打开磁盘管理器，请在应用菜单中手动搜索并打开「磁盘 (Disks)」'**
  String get gnomeDisksOpenFailed;

  /// No description provided for @gnomeDisksNotInstalled.
  ///
  /// In zh, this message translates to:
  /// **'系统未安装 gnome-disks，请手动打开系统磁盘管理工具进行配置。'**
  String get gnomeDisksNotInstalled;

  /// No description provided for @linuxMountGuideTitle.
  ///
  /// In zh, this message translates to:
  /// **'配置硬盘自动挂载'**
  String get linuxMountGuideTitle;

  /// No description provided for @linuxMountGuideDescription.
  ///
  /// In zh, this message translates to:
  /// **'Linux默认设置下不会挂载外置分区，如果没有设置启动时挂载分区则每次重启时外置分区的路径可能发生变化，从而导致播放器访问不到音乐目录。为了避免这种情况，请将存放音乐的分区设置成启动时自动挂载。'**
  String get linuxMountGuideDescription;

  /// No description provided for @linuxMountGuideWarning.
  ///
  /// In zh, this message translates to:
  /// **'注意：如果您的音乐位于需要挂载才能使用的外置/内部硬盘分区内，务必将该分区设置为「开机自动挂载」。否则，每次重启系统后可能会出现找不到音乐目录，或者需要输入密码授权才能访问的问题。'**
  String get linuxMountGuideWarning;

  /// No description provided for @linuxMountGuideStep1.
  ///
  /// In zh, this message translates to:
  /// **'1. 打开系统的「磁盘 (Disks)」管理器'**
  String get linuxMountGuideStep1;

  /// No description provided for @linuxMountGuideStep2.
  ///
  /// In zh, this message translates to:
  /// **'2. 选中包含音乐的分区，点击 ⚙️ 齿轮图标（附加分区选项）'**
  String get linuxMountGuideStep2;

  /// No description provided for @linuxMountGuideStep3.
  ///
  /// In zh, this message translates to:
  /// **'3. 选择\"编辑挂载选项\"，关闭\"用户会话默认值\"并勾选\"系统启动时挂载\"'**
  String get linuxMountGuideStep3;

  /// No description provided for @linuxMountGuideOpenButton.
  ///
  /// In zh, this message translates to:
  /// **'打开磁盘管理器 (Disks)'**
  String get linuxMountGuideOpenButton;

  /// No description provided for @unmute.
  ///
  /// In zh, this message translates to:
  /// **'取消静音'**
  String get unmute;

  /// No description provided for @mute.
  ///
  /// In zh, this message translates to:
  /// **'静音'**
  String get mute;

  /// No description provided for @disableSystemTray.
  ///
  /// In zh, this message translates to:
  /// **'停用系统托盘'**
  String get disableSystemTray;

  /// No description provided for @restoreWindow.
  ///
  /// In zh, this message translates to:
  /// **'还原窗口'**
  String get restoreWindow;

  /// No description provided for @hideWindow.
  ///
  /// In zh, this message translates to:
  /// **'隐藏窗口'**
  String get hideWindow;

  /// No description provided for @onboardingAndroidBatteryTitle.
  ///
  /// In zh, this message translates to:
  /// **'后台播放防误杀设置'**
  String get onboardingAndroidBatteryTitle;

  /// No description provided for @onboardingAndroidBatteryDescription.
  ///
  /// In zh, this message translates to:
  /// **'由于安卓系统的电池管理策略非常严格，为了防止音乐在后台播放时被系统强制关闭，建议将 Vynody 的电池使用限制设置为「无限制」（Unrestricted）。'**
  String get onboardingAndroidBatteryDescription;

  /// No description provided for @onboardingAndroidBatteryStep1.
  ///
  /// In zh, this message translates to:
  /// **'1. 点击下方的「去设置」按钮。'**
  String get onboardingAndroidBatteryStep1;

  /// No description provided for @onboardingAndroidBatteryStep2.
  ///
  /// In zh, this message translates to:
  /// **'2. 在系统弹窗中允许忽略电池优化，或者跳转到电池设置页面。'**
  String get onboardingAndroidBatteryStep2;

  /// No description provided for @onboardingAndroidBatteryStep3.
  ///
  /// In zh, this message translates to:
  /// **'3. 如果跳转至设置列表，选择「无限制」或「允许后台活动 / 不限制电池使用」。'**
  String get onboardingAndroidBatteryStep3;

  /// No description provided for @onboardingAndroidBatteryButton.
  ///
  /// In zh, this message translates to:
  /// **'去设置'**
  String get onboardingAndroidBatteryButton;

  /// No description provided for @onboardingAndroidBatteryStatusOptimized.
  ///
  /// In zh, this message translates to:
  /// **'当前状态：已限制（可能导致后台播放中断）'**
  String get onboardingAndroidBatteryStatusOptimized;

  /// No description provided for @onboardingAndroidBatteryStatusUnrestricted.
  ///
  /// In zh, this message translates to:
  /// **'当前状态：无限制（推荐，后台播放已保护）'**
  String get onboardingAndroidBatteryStatusUnrestricted;

  /// No description provided for @onboardingAndroidMediaTitle.
  ///
  /// In zh, this message translates to:
  /// **'访问手机音乐库'**
  String get onboardingAndroidMediaTitle;

  /// No description provided for @onboardingAndroidMediaDescription.
  ///
  /// In zh, this message translates to:
  /// **'授权后，Vynody 可直接读取系统媒体库中的所有音乐，无需手动选择文件夹。不授权也可以手动导入指定文件夹中的音乐。'**
  String get onboardingAndroidMediaDescription;

  /// No description provided for @onboardingAndroidMediaStep1.
  ///
  /// In zh, this message translates to:
  /// **'1. 即开即用：直接显示手机里已有的全部音乐'**
  String get onboardingAndroidMediaStep1;

  /// No description provided for @onboardingAndroidMediaStep2.
  ///
  /// In zh, this message translates to:
  /// **'2. 自动发现：新下载或传入的音乐自动出现在乐库中'**
  String get onboardingAndroidMediaStep2;

  /// No description provided for @onboardingAndroidMediaStep3.
  ///
  /// In zh, this message translates to:
  /// **'3. 隐私安全：仅在本地读取音频文件，不会自动上传你的音乐库（使用 AI 歌词等云端服务除外）'**
  String get onboardingAndroidMediaStep3;

  /// No description provided for @onboardingAndroidMediaButton.
  ///
  /// In zh, this message translates to:
  /// **'授权访问音乐库'**
  String get onboardingAndroidMediaButton;

  /// No description provided for @onboardingAndroidMediaStatusGranted.
  ///
  /// In zh, this message translates to:
  /// **'当前状态：已授权（推荐）'**
  String get onboardingAndroidMediaStatusGranted;

  /// No description provided for @onboardingAndroidMediaStatusNotGranted.
  ///
  /// In zh, this message translates to:
  /// **'当前状态：未授权（可稍后手动导入文件夹）'**
  String get onboardingAndroidMediaStatusNotGranted;

  /// No description provided for @exitApp.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get exitApp;

  /// No description provided for @showScanProgressToastSetting.
  ///
  /// In zh, this message translates to:
  /// **'显示扫描状态提示'**
  String get showScanProgressToastSetting;

  /// No description provided for @showScanProgressToastSettingDescription.
  ///
  /// In zh, this message translates to:
  /// **'在添加文件夹并进行文件扫描时，在顶部显示实时的扫描进度提示'**
  String get showScanProgressToastSettingDescription;

  /// No description provided for @openPlaybackOnDirectorySongTap.
  ///
  /// In zh, this message translates to:
  /// **'点击歌曲后跳转到播放页'**
  String get openPlaybackOnDirectorySongTap;

  /// No description provided for @openPlaybackOnDirectorySongTapDescription.
  ///
  /// In zh, this message translates to:
  /// **'在目录页点击歌曲播放时，自动跳转至全屏播放界面'**
  String get openPlaybackOnDirectorySongTapDescription;

  /// No description provided for @defaultToLyricsModeOnPlaybackOpen.
  ///
  /// In zh, this message translates to:
  /// **'进入播放页默认显示歌词'**
  String get defaultToLyricsModeOnPlaybackOpen;

  /// No description provided for @defaultToLyricsModeOnPlaybackOpenDescription.
  ///
  /// In zh, this message translates to:
  /// **'打开全屏播放界面时，默认自动切至歌词显示模式'**
  String get defaultToLyricsModeOnPlaybackOpenDescription;

  /// No description provided for @tapCoverToEnterLyricsMode.
  ///
  /// In zh, this message translates to:
  /// **'点击封面可以进入歌词模式'**
  String get tapCoverToEnterLyricsMode;

  /// No description provided for @longPressLyricsPanelToOpenMenu.
  ///
  /// In zh, this message translates to:
  /// **'长按歌词面板可以调出菜单'**
  String get longPressLyricsPanelToOpenMenu;

  /// No description provided for @gotIt.
  ///
  /// In zh, this message translates to:
  /// **'我知道了'**
  String get gotIt;

  /// No description provided for @scanToastHiddenHint.
  ///
  /// In zh, this message translates to:
  /// **'扫描状态提示已隐藏，可在“设置 - 界面”中重新打开'**
  String get scanToastHiddenHint;

  /// No description provided for @doubleSpeedPlayingSwipeUpToLock.
  ///
  /// In zh, this message translates to:
  /// **'快进播放中... 往上滑动锁定'**
  String get doubleSpeedPlayingSwipeUpToLock;

  /// No description provided for @doubleSpeedLockedSwipeDownToUnlock.
  ///
  /// In zh, this message translates to:
  /// **'已锁定快进播放。长按并向下滑动解锁'**
  String get doubleSpeedLockedSwipeDownToUnlock;

  /// No description provided for @doubleSpeedUnlocked.
  ///
  /// In zh, this message translates to:
  /// **'已解除快进锁定'**
  String get doubleSpeedUnlocked;

  /// No description provided for @lyricsImportExportHeader.
  ///
  /// In zh, this message translates to:
  /// **'导入与导出'**
  String get lyricsImportExportHeader;

  /// No description provided for @exportAction.
  ///
  /// In zh, this message translates to:
  /// **'导出'**
  String get exportAction;

  /// No description provided for @importAction.
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get importAction;

  /// No description provided for @exportLyricsLabel.
  ///
  /// In zh, this message translates to:
  /// **'导出歌词备份'**
  String get exportLyricsLabel;

  /// No description provided for @exportLyricsDescription.
  ///
  /// In zh, this message translates to:
  /// **'将所有缓存与调整过的歌词导出为 JSON 文件'**
  String get exportLyricsDescription;

  /// No description provided for @importLyricsLabel.
  ///
  /// In zh, this message translates to:
  /// **'导入歌词备份'**
  String get importLyricsLabel;

  /// No description provided for @importLyricsDescription.
  ///
  /// In zh, this message translates to:
  /// **'从导出的 JSON 文件导入歌词缓存'**
  String get importLyricsDescription;

  /// No description provided for @exportSuccess.
  ///
  /// In zh, this message translates to:
  /// **'成功导出 {count} 条歌词'**
  String exportSuccess(int count);

  /// No description provided for @exportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败: {error}'**
  String exportFailed(String error);

  /// No description provided for @importSuccess.
  ///
  /// In zh, this message translates to:
  /// **'导入完成！成功导入 {count} 条歌词。'**
  String importSuccess(int count);

  /// No description provided for @importFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败: {error}'**
  String importFailed(String error);

  /// No description provided for @importConflictsTitle.
  ///
  /// In zh, this message translates to:
  /// **'导入冲突'**
  String get importConflictsTitle;

  /// No description provided for @importConflictsMessage.
  ///
  /// In zh, this message translates to:
  /// **'在备份中发现了 {conflictCount} 条冲突的歌词（已有内容但与导入的不一致），请选择处理方式：'**
  String importConflictsMessage(int conflictCount);

  /// No description provided for @overwriteAll.
  ///
  /// In zh, this message translates to:
  /// **'全部覆盖'**
  String get overwriteAll;

  /// No description provided for @skipAllConflicts.
  ///
  /// In zh, this message translates to:
  /// **'跳过冲突'**
  String get skipAllConflicts;

  /// No description provided for @decideOneByOne.
  ///
  /// In zh, this message translates to:
  /// **'逐条确认'**
  String get decideOneByOne;

  /// No description provided for @conflictResolutionTitle.
  ///
  /// In zh, this message translates to:
  /// **'解决冲突 ({current}/{total})'**
  String conflictResolutionTitle(int current, int total);

  /// No description provided for @conflictExistingLabel.
  ///
  /// In zh, this message translates to:
  /// **'现有歌词'**
  String get conflictExistingLabel;

  /// No description provided for @conflictImportedLabel.
  ///
  /// In zh, this message translates to:
  /// **'导入歌词'**
  String get conflictImportedLabel;

  /// No description provided for @conflictSourceLabel.
  ///
  /// In zh, this message translates to:
  /// **'来源: {source}'**
  String conflictSourceLabel(String source);

  /// No description provided for @conflictTimeLabel.
  ///
  /// In zh, this message translates to:
  /// **'时间: {time}'**
  String conflictTimeLabel(String time);

  /// No description provided for @overwriteThis.
  ///
  /// In zh, this message translates to:
  /// **'覆盖'**
  String get overwriteThis;

  /// No description provided for @skipThis.
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get skipThis;

  /// No description provided for @overwriteRemaining.
  ///
  /// In zh, this message translates to:
  /// **'覆盖后续所有'**
  String get overwriteRemaining;

  /// No description provided for @skipRemaining.
  ///
  /// In zh, this message translates to:
  /// **'跳过后续所有'**
  String get skipRemaining;

  /// No description provided for @invalidBackupFile.
  ///
  /// In zh, this message translates to:
  /// **'无效的备份文件'**
  String get invalidBackupFile;

  /// No description provided for @exportLogs.
  ///
  /// In zh, this message translates to:
  /// **'导出日志'**
  String get exportLogs;

  /// No description provided for @exportLogsSuccess.
  ///
  /// In zh, this message translates to:
  /// **'日志已成功导出'**
  String get exportLogsSuccess;

  /// No description provided for @exportLogsFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出日志失败'**
  String get exportLogsFailed;

  /// No description provided for @noLogFileFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到日志文件'**
  String get noLogFileFound;

  /// No description provided for @uiDisplayScale.
  ///
  /// In zh, this message translates to:
  /// **'界面显示缩放'**
  String get uiDisplayScale;

  /// No description provided for @uiDisplayScaleDescription.
  ///
  /// In zh, this message translates to:
  /// **'全局调整所有界面组件与文字大小，适配车机大屏'**
  String get uiDisplayScaleDescription;

  /// No description provided for @uiDisplayScaleDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'界面显示缩放 / 车机模式'**
  String get uiDisplayScaleDialogTitle;

  /// No description provided for @uiDisplayScaleCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前缩放: {percent}%'**
  String uiDisplayScaleCurrent(int percent);

  /// No description provided for @audioSettings.
  ///
  /// In zh, this message translates to:
  /// **'音频'**
  String get audioSettings;

  /// No description provided for @audioSettingsDescription.
  ///
  /// In zh, this message translates to:
  /// **'管理音频播放、均衡器频段与播放速度相关配置'**
  String get audioSettingsDescription;

  /// No description provided for @equalizerBandCount.
  ///
  /// In zh, this message translates to:
  /// **'均衡器频段数量'**
  String get equalizerBandCount;

  /// No description provided for @equalizerBandCountDescription.
  ///
  /// In zh, this message translates to:
  /// **'设置均衡器面板显示的频段数量，高频段模式将自动开启平滑横向滚动'**
  String get equalizerBandCountDescription;

  /// No description provided for @bandsCountOption.
  ///
  /// In zh, this message translates to:
  /// **'{count} 段'**
  String bandsCountOption(int count);

  /// No description provided for @enableFadeEffect.
  ///
  /// In zh, this message translates to:
  /// **'音频淡入淡出'**
  String get enableFadeEffect;

  /// No description provided for @enableFadeEffectDescription.
  ///
  /// In zh, this message translates to:
  /// **'在切歌、播放/暂停时启用平滑淡入淡出和交叉叠化过渡'**
  String get enableFadeEffectDescription;

  /// No description provided for @buttonLayoutSettings.
  ///
  /// In zh, this message translates to:
  /// **'按钮排序'**
  String get buttonLayoutSettings;

  /// No description provided for @playbackButtonLayoutTitle.
  ///
  /// In zh, this message translates to:
  /// **'播放页按钮布局'**
  String get playbackButtonLayoutTitle;

  /// No description provided for @playbackButtonLayoutDescription.
  ///
  /// In zh, this message translates to:
  /// **'自定义播放页 7 按钮行与 5 按钮行的按键显示与排列顺序'**
  String get playbackButtonLayoutDescription;

  /// No description provided for @topButtonsRowTitle.
  ///
  /// In zh, this message translates to:
  /// **'7按钮行排序'**
  String get topButtonsRowTitle;

  /// No description provided for @mainButtonsRowTitle.
  ///
  /// In zh, this message translates to:
  /// **'5按钮行左右侧按钮'**
  String get mainButtonsRowTitle;

  /// No description provided for @mainControlsLeftButton.
  ///
  /// In zh, this message translates to:
  /// **'左侧按钮'**
  String get mainControlsLeftButton;

  /// No description provided for @mainControlsRightButton.
  ///
  /// In zh, this message translates to:
  /// **'右侧按钮'**
  String get mainControlsRightButton;

  /// No description provided for @lyricsHeaderRightButtonTitle.
  ///
  /// In zh, this message translates to:
  /// **'歌词标题栏收起时右侧按钮'**
  String get lyricsHeaderRightButtonTitle;

  /// No description provided for @resetButtonOrder.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认布局'**
  String get resetButtonOrder;

  /// No description provided for @btnMore.
  ///
  /// In zh, this message translates to:
  /// **'更多菜单'**
  String get btnMore;

  /// No description provided for @btnFavorite.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get btnFavorite;

  /// No description provided for @btnPlaylistMode.
  ///
  /// In zh, this message translates to:
  /// **'播放模式'**
  String get btnPlaylistMode;

  /// No description provided for @btnShuffle.
  ///
  /// In zh, this message translates to:
  /// **'随机播放'**
  String get btnShuffle;

  /// No description provided for @btnTagCompletion.
  ///
  /// In zh, this message translates to:
  /// **'标签自动补全'**
  String get btnTagCompletion;

  /// No description provided for @btnSleepTimer.
  ///
  /// In zh, this message translates to:
  /// **'定时关闭'**
  String get btnSleepTimer;

  /// No description provided for @btnEqualizer.
  ///
  /// In zh, this message translates to:
  /// **'音效'**
  String get btnEqualizer;

  /// No description provided for @btnVisualizer.
  ///
  /// In zh, this message translates to:
  /// **'律动/频谱'**
  String get btnVisualizer;

  /// No description provided for @btnVolume.
  ///
  /// In zh, this message translates to:
  /// **'音量'**
  String get btnVolume;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
