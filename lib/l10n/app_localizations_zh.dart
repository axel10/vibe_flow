// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Vynody';

  @override
  String get alwaysOnTop => '置顶';

  @override
  String get systemMediaLibrary => '系统媒体库';

  @override
  String get scanningDirectory => '正在扫描目录...';

  @override
  String filesPreprocessed(Object count) {
    return '预处理 $count ';
  }

  @override
  String filesDiscovered(Object count) {
    return '已发现 $count ';
  }

  @override
  String filesFullyProcessed(Object count) {
    return '完整处理 $count ';
  }

  @override
  String get directoryAddedSuccess => '目录添加成功';

  @override
  String get directoryAddedNoMusic => '目录已添加，但未发现可播放音频文件';

  @override
  String get scanDirectory => '扫描目录';

  @override
  String get sort => '排序';

  @override
  String get addRootDirectory => '添加根目录';

  @override
  String get goBack => '返回上一层';

  @override
  String get noMediaLibraryPermission => '未获得媒体库访问权限';

  @override
  String get grantPermission => '给予权限';

  @override
  String get needPermissionToScan => '需授予权限以扫描本地音乐';

  @override
  String get rebuildTagDatabase => '重建标签数据库';

  @override
  String get rebuildDatabase => '重建数据库';

  @override
  String get confirmRebuildDatabase =>
      '确定要手动刷新所有歌曲的标签信息吗？这可能需要一些时间来重新加载封面和元数据。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get rebuildingDatabase => '正在重建歌曲标签数据库...';

  @override
  String get sortBy => '排序方式';

  @override
  String get sortScope => '作用域';

  @override
  String get sortOrder => '排序顺序';

  @override
  String get title => '标题';

  @override
  String get fileName => '文件名';

  @override
  String get trackNumber => '轨道号';

  @override
  String get ascending => '升序';

  @override
  String get descending => '降序';

  @override
  String get currentFolderScope => '当前目录';

  @override
  String get globalScope => '全局';

  @override
  String get visualizerSettings => '播放页设置';

  @override
  String get algorithm => '频谱';

  @override
  String get appearance => '外观';

  @override
  String get spectrumAppearanceGroup => '频谱外观';

  @override
  String get spectrumAdvancedOptions => '频谱高级选项';

  @override
  String get resetAlgorithm => '重置算法';

  @override
  String get resetAppearance => '重置外观';

  @override
  String get smoothing => '平滑系数 (Smoothing)';

  @override
  String get gravity => '重力系数 (Gravity)';

  @override
  String get logScale => '对数缩放 (Log Scale)';

  @override
  String get contrast => '对比度 (Contrast)';

  @override
  String get normalization => '归一化 (Normalization)';

  @override
  String get multiplier => '增益 (Multiplier)';

  @override
  String get skipHighFrequency => '跳过高频';

  @override
  String get frequencyGroups => '频率分组 (Frequency Groups)';

  @override
  String get aggregationMode => '聚合模式 (Aggregation Mode)';

  @override
  String get opacity => '透明度 (Opacity)';

  @override
  String get enableGradient => '启用渐变色';

  @override
  String get startColor => '起始颜色';

  @override
  String get endColor => '结束颜色';

  @override
  String get gradientRangeStop1 => '渐变范围 Stop 1';

  @override
  String get gradientRangeStop2 => '渐变范围 Stop 2';

  @override
  String get gradientRepeatMode => '渐变重复模式 (TileMode)';

  @override
  String get color => '颜色';

  @override
  String get followCoverColor => '跟随封面变色';

  @override
  String get selectColor => '选择颜色';

  @override
  String get volume => '音量';

  @override
  String get clearQueue => '清空队列';

  @override
  String get confirmClearQueue => '确定要清空当前队列吗？';

  @override
  String get queueCleared => '队列已清空';

  @override
  String get locateCurrentSong => '定位当前播放';

  @override
  String get songNotInScannedFolders => '当前歌曲不在扫描的目录中';

  @override
  String get queue => '队列';

  @override
  String get queueEmpty => '队列为空';

  @override
  String selectedSongs(int count) {
    return '已选择 $count 首';
  }

  @override
  String get unknownArtist => '未知艺术家';

  @override
  String deletedSongs(int count) {
    return '已删除 $count 首歌曲';
  }

  @override
  String get delete => '删除';

  @override
  String get createPlaylist => '创建播放列表';

  @override
  String get playlistName => '播放列表名称';

  @override
  String get enterPlaylistName => '请输入播放列表名称';

  @override
  String get playlistNameExists => '播放列表名称已存在';

  @override
  String get renamePlaylist => '重命名播放列表';

  @override
  String get deletePlaylist => '删除播放列表';

  @override
  String confirmDeletePlaylist(String name) {
    return '确定要删除播放列表\"$name\"吗？';
  }

  @override
  String get addToPlaylist => '添加到播放列表';

  @override
  String get selectAll => '全选';

  @override
  String get addToQueue => '添加到队列';

  @override
  String get addedToQueue => '已添加到队列';

  @override
  String songCount(int count) {
    return '$count 首歌曲';
  }

  @override
  String addedToPlaylist(int count, String playlist) {
    return '已添加 $count 首歌曲到$playlist';
  }

  @override
  String get createNewList => '新建列表';

  @override
  String createdPlaylist(String name, int count) {
    return '已创建播放列表\"$name\"并添加 $count 首歌曲';
  }

  @override
  String get rename => '重命名';

  @override
  String get playlist => '播放列表';

  @override
  String get mostPlayed => '最多播放';

  @override
  String get recentlyAdded => '最近添加';

  @override
  String get albums => '专辑';

  @override
  String get artists => '艺术家';

  @override
  String get mostPlayedDescription => '按有效播放次数排序';

  @override
  String get recentlyAddedDescription => '按进入媒体库的时间排序';

  @override
  String get allTime => '全部时间';

  @override
  String get pastWeek => '过去一周';

  @override
  String get pastMonth => '过去一个月';

  @override
  String get past90Days => '过去三个月';

  @override
  String get noPlayHistory => '还没有播放记录';

  @override
  String get noPlayHistoryInRange => '这个时间范围内还没有播放记录';

  @override
  String get noRecentlyAddedSongs => '媒体库中还没有歌曲';

  @override
  String get noRecentlyAddedInRange => '这个时间范围内没有新添加的歌曲';

  @override
  String get addedOn => '添加时间';

  @override
  String get lastPlayed => '最近播放';

  @override
  String playCountLabel(int count) {
    return '$count 次';
  }

  @override
  String get playAll => '播放全部';

  @override
  String get shufflePlay => '随机播放';

  @override
  String get noAlbums => '还没有可显示的专辑';

  @override
  String get noArtists => '还没有可显示的艺术家';

  @override
  String get searchAlbums => '搜索专辑或艺术家';

  @override
  String get searchArtists => '搜索艺术家';

  @override
  String get albumSort => '排序';

  @override
  String get sortArtistAsc => '艺术家 A-Z';

  @override
  String get sortTitleAsc => '专辑名 A-Z';

  @override
  String get sortTrackCount => '歌曲数量';

  @override
  String get sortDuration => '总时长';

  @override
  String get sortRecentAdded => '最近添加';

  @override
  String get sortAscending => '升序';

  @override
  String get sortDescending => '降序';

  @override
  String get playNext => '下一首播放';

  @override
  String get addToFavorites => '加入收藏';

  @override
  String get removeFromFavorites => '取消收藏';

  @override
  String get viewAlbumDetails => '查看专辑详情';

  @override
  String get viewArtistDetails => '查看艺术家详情';

  @override
  String get openFileLocation => '打开文件所在位置';

  @override
  String get copyAlbumTitle => '复制专辑名';

  @override
  String get copyArtistName => '复制艺术家名';

  @override
  String albumCount(int count) {
    return '$count 张专辑';
  }

  @override
  String get emptyList => '列表为空';

  @override
  String get dragToAddMusic => '拖入文件或文件夹以添加音乐';

  @override
  String get unknownAlbum => '未知专辑';

  @override
  String get managePlaylists => '管理播放列表';

  @override
  String get createNewPlaylist => '创建新播放列表';

  @override
  String get defaultList => '默认列表';

  @override
  String get playbackMode => '播放模式';

  @override
  String get playbackOptions => '播放选项';

  @override
  String get setVisualizerDisplay => '设置频谱显示';

  @override
  String get noPlaybackContent => '当前没有播放内容';

  @override
  String get file => '文件';

  @override
  String get play => '播放';

  @override
  String get list => '媒体库';

  @override
  String get queueTab => '队列';

  @override
  String get more => '更多';

  @override
  String get settings => '设置';

  @override
  String get themeMode => '主题';

  @override
  String get themeModeSystem => '跟随系统';

  @override
  String get themeModeLight => '亮色';

  @override
  String get themeModeDark => '暗色';

  @override
  String get immersiveTabBar => '沉浸式标签栏';

  @override
  String get immersiveTabBarDescription => '鼠标移动时显示导航栏，3 秒无操作后隐藏';

  @override
  String get collapseButtonsInLandscapeLyrics => '进入横屏歌词模式后收起按钮';

  @override
  String get collapseButtonsInLandscapeLyricsDescription =>
      '进入横屏歌词模式时收起 7 按钮行、标题左对齐并在右侧显示快捷按钮';

  @override
  String get sampleStride => '采样步长';

  @override
  String get sampleStrideDescription => '值越大扫描越快但波形精度越低 (默认: 4)';

  @override
  String get waveformSegments => '波形分段';

  @override
  String get waveformSegmentsDescription => '要显示的波形柱数量 (默认: 80)';

  @override
  String get showDeveloperOptions => '显示开发人员选项';

  @override
  String get playbackBackground => '播放页背景';

  @override
  String get playbackRadialGradient => '中心暗色渐变';

  @override
  String get blurIntensity => '模糊强度';

  @override
  String get blurredArtwork => '模糊封面 (默认)';

  @override
  String get dynamicMesh => '动态流变';

  @override
  String get solidColor => '纯色';

  @override
  String get customImage => '自定义图片';

  @override
  String get presetColors => '预设颜色';

  @override
  String get customColor => '自定义颜色';

  @override
  String get uploadImage => '选择图片';

  @override
  String get normalOpacity => '常规暗色层不透明度';

  @override
  String get lyricsOpacity => '歌词暗色层不透明度';

  @override
  String get chooseImageError => '选择图片失败';

  @override
  String get noImageSelected => '未选择图片';

  @override
  String get unknown => '未知';

  @override
  String get playlistModeSingle => '单曲播放';

  @override
  String get playlistModeSingleLoop => '单曲循环';

  @override
  String get playlistModeQueue => '播放列表';

  @override
  String get playlistModeQueueLoop => '列表循环';

  @override
  String get playlistModeAutoQueueLoop => '自动列表循环';

  @override
  String get visualizer => '可视化';

  @override
  String get previous => '上一首';

  @override
  String get next => '下一首';

  @override
  String get pause => '暂停';

  @override
  String get autoMode => '自动模式';

  @override
  String get advancedOptions => '高级选项';

  @override
  String get spectrumQuantity => '频谱数量';

  @override
  String get speed => '速度';

  @override
  String get quantityHigh => '多';

  @override
  String get quantityMedium => '中';

  @override
  String get quantityLow => '少';

  @override
  String get speedFast => '快';

  @override
  String get speedMedium => '中';

  @override
  String get speedSlow => '慢';

  @override
  String get portraitFrequencyGroups => '竖屏频谱数量';

  @override
  String get landscapeFrequencyGroups => '横屏频谱数量';

  @override
  String get portraitGap => '竖屏频谱间距';

  @override
  String get landscapeGap => '横屏频谱间距';

  @override
  String get enableWaveformProgressBar => '启用波形进度条';

  @override
  String get enableWaveformProgressBarDescription => '使用整首歌的波形图代替标准滑块';

  @override
  String get waveformLongPressSeekSpeed => '长按波形快进速度';

  @override
  String get waveformLongPressSeekSpeedDescription => '长按波形进度条右侧时快进的播放速度（×）';

  @override
  String get enableWaveformLongPressSeek => '启用长按波形快进';

  @override
  String get enableWaveformLongPressSeekDescription => '长按波形进度条右侧区域启用快进播放';

  @override
  String get randomMode => '随机模式';

  @override
  String get randomHistory => '随机历史';

  @override
  String get randomRange => '随机范围';

  @override
  String get randomMethod => '随机方式';

  @override
  String get currentQueue => '当前队列';

  @override
  String get globalRange => '全局 (包含所有列表歌曲)';

  @override
  String get completeRandom => '完全随机';

  @override
  String get shuffleRandom => '洗牌随机';

  @override
  String get randomQueue => '随机队列';

  @override
  String get notSelected => '未选择音乐';

  @override
  String get saveTagsToFile => '保存标签到文件';

  @override
  String get saveCurrentTagsToFile => '保存当前歌曲标签到文件';

  @override
  String get saveQueueTagsToFile => '保存队列中所有标签到文件';

  @override
  String get tagsSaved => '标签保存成功';

  @override
  String tagsSavedCount(Object count) {
    return '标签已保存 ($count 首)';
  }

  @override
  String get tagsSaveFailed => '保存标签失败';

  @override
  String tagsSaveFailedCount(Object count) {
    return '$count 首保存失败';
  }

  @override
  String unsupportedFormat(Object count) {
    return '$count 首歌曲格式不支持保存标签 (OGG/Opus)';
  }

  @override
  String get unsupportedFormatSingle => '此格式 (OGG/Opus) 不支持保存标签';

  @override
  String get savingTags => '正在保存标签...';

  @override
  String get noModifiedTagsToSave => '没有需要保存的已修改标签';

  @override
  String get clearPlaylist => '清空列表';

  @override
  String get copyTitle => '复制标题';

  @override
  String get transcodeAction => '转码';

  @override
  String get transcodeSectionTitle => '音频转码';

  @override
  String get transcodeSectionDescription => '设置默认输出格式和质量预设。';

  @override
  String get transcodeDefaultFormat => '默认输出格式';

  @override
  String get transcodeDefaultQuality => '默认质量预设';

  @override
  String get transcodeTitle => '音频转码';

  @override
  String transcodeSongCount(int count) {
    return '$count 首歌曲';
  }

  @override
  String transcodeCompletedCount(int count) {
    return '已完成 $count 个转码任务';
  }

  @override
  String transcodeCompletedWithFailures(int success, int total, int failed) {
    return '已完成 $success/$total 个转码任务，失败 $failed 个';
  }

  @override
  String get transcodeFailedGeneric => '转码失败';

  @override
  String get transcodePreparing => '正在准备转码...';

  @override
  String transcodeProgress(int current, int total) {
    return '正在转码 $current/$total';
  }

  @override
  String get transcoding => '转码中...';

  @override
  String get startTranscode => '开始转码';

  @override
  String transcodeEngine(Object engine) {
    return '引擎：$engine';
  }

  @override
  String get transcodeUsingSystemFfmpeg => '使用系统 PATH 中的 ffmpeg。';

  @override
  String transcodeUsingCustomFfmpeg(Object path) {
    return '使用自定义 ffmpeg：$path';
  }

  @override
  String get transcodeFormat => '输出格式';

  @override
  String get transcodeQualityPreset => '质量预设';

  @override
  String get transcodeQualityLow => '低';

  @override
  String get transcodeQualityMedium => '中';

  @override
  String get transcodeQualityHigh => '高';

  @override
  String get transcodeQualityExtreme => '最高';

  @override
  String get transcodeLosslessPresetHint => '当前无损格式不使用质量档位和码率控制模式。';

  @override
  String get transcodeAdvancedOptions => '高级选项';

  @override
  String get transcodeAdvancedCustomized => '高级参数已被手动修改';

  @override
  String get transcodeAdvancedFollowingPreset => '高级参数跟随当前预设';

  @override
  String get transcodeLosslessAdvancedHint => '当前无损格式仅保留与源文件相关的高级选项。';

  @override
  String get transcodeBitRateInvalid => '请输入有效的比特率';

  @override
  String get transcodeBitRate => '比特率';

  @override
  String get transcodeBitRateMode => '码率控制模式';

  @override
  String get transcodeEncodingEngine => '编码引擎';

  @override
  String get transcodeSystemEncoder => 'Media3 (系统)';

  @override
  String get transcodeFfmpegRustEncoder => 'FFmpeg (Rust)';

  @override
  String get transcodeAacEncoder => 'AAC 编码器';

  @override
  String get transcodeSampleRate => '采样率';

  @override
  String get transcodeChannels => '声道';

  @override
  String get transcodeResetToPreset => '重置为当前预设';

  @override
  String get transcodeResetLosslessOptions => '重置无损选项';

  @override
  String get transcodeOutputDirectory => '输出目录';

  @override
  String get transcodeOutputPreview => '预览';

  @override
  String get transcodeChooseDirectory => '选择目录';

  @override
  String get transcodeUseSourceDirectory => '使用源文件目录';

  @override
  String get transcodeKeepSource => '保持源文件';

  @override
  String get transcodeMono => '单声道';

  @override
  String get transcodeStereo => '双声道';

  @override
  String get openFolderLocation => '打开文件夹所在位置';

  @override
  String get songTagsSavedToSourceFileAndApp => '歌曲标签已保存到源文件和 App';

  @override
  String get songTagsSavedToApp => '歌曲标签已保存到 App';

  @override
  String get durationZero => '0:00';

  @override
  String get generateLyrics => '生成歌词';

  @override
  String get generateTimeline => '生成时间轴';

  @override
  String get queueGenerateLyrics => '排队生成';

  @override
  String get pauseAutoScroll => '暂停自动滚动';

  @override
  String get resumeAutoScroll => '恢复自动滚动';

  @override
  String get translateLyrics => '翻译歌词';

  @override
  String get clearLyricsCache => '清除当前歌词缓存';

  @override
  String get clearTranslationCache => '清除当前翻译缓存';

  @override
  String get requery => '重新查询';

  @override
  String get sleepTimerTitle => '睡眠定时器';

  @override
  String get sleepTimerDescription => '选择倒计时，时间到后会暂停播放。';

  @override
  String get sleepTimerRunningTitle => '睡眠定时器运行中';

  @override
  String get sleepTimerRunningDescription => '倒计时结束后会自动暂停当前播放。';

  @override
  String get sleepTimerStopAfterCurrentSong => '播放完最后一首歌曲后停止';

  @override
  String get remainingTime => '剩余时间';

  @override
  String get startCountdown => '开始倒计时';

  @override
  String get end => '结束';

  @override
  String get equalizer => '均衡器';

  @override
  String get equalizerEnabledStatus => '已启用高保真调节';

  @override
  String get equalizerDisabledStatus => '已禁用';

  @override
  String get effects => '特效';

  @override
  String get playbackSpeed => '播放速度';

  @override
  String get normal => '正常';

  @override
  String get bassBoost => '低音增强';

  @override
  String get preampGain => '前置增益';

  @override
  String get reset => '重置';

  @override
  String get close => '关闭';

  @override
  String get timelineAdjustmentTitle => '手动调整时间轴';

  @override
  String get timelineAdjustmentDescription => '向右拖动会让歌词整体延后，向左拖动会让歌词整体提前。';

  @override
  String timelineOffsetEarlier(Object seconds) {
    return '提前 $seconds 秒';
  }

  @override
  String timelineOffsetLater(Object seconds) {
    return '延后 $seconds 秒';
  }

  @override
  String get timelineOffsetCurrent => '当前偏移：0.0 秒';

  @override
  String get enterAcoustidApiKeyTitle => '填写 AcoustID API Key';

  @override
  String get acoustidApiKeyDescription => '用于音频指纹识别。留空后会恢复使用应用内置的默认 key。';

  @override
  String get acoustidApiKeyHint => '粘贴你的 AcoustID API Key';

  @override
  String get apiKey => 'API Key';

  @override
  String get save => '保存';

  @override
  String get enterLyricsTitle => '填写歌词';

  @override
  String get lyricsInputHint => '在这里粘贴或输入歌词，支持多行文本';

  @override
  String get enterGoogleAiStudioApiKeyTitle => '填写 Google AI Studio API Key';

  @override
  String get googleAiStudioApiKeyDescription =>
      '用于 Google AI Studio 的歌词生成、时间轴生成和翻译。';

  @override
  String get pasteGoogleAiStudioApiKey => '粘贴 Google AI Studio API Key';

  @override
  String get enterOpenRouterApiKeyTitle => '填写 OpenRouter API Key';

  @override
  String get openRouterApiKeyDescription =>
      '用于 OpenRouter 的歌词生成和时间轴生成，翻译始终走 Gemini。';

  @override
  String get pasteOpenRouterApiKey => '粘贴 OpenRouter API Key';

  @override
  String get enterGeminiApiKeyTitle => '填写 Gemini API Key';

  @override
  String get geminiApiKeyDescription => '用于歌词翻译。';

  @override
  String get pasteGeminiApiKey => '粘贴 Gemini API Key';

  @override
  String get testConnection => '测试连接';

  @override
  String get enterApiKey => '请输入 API key。';

  @override
  String get testingConnection => '正在测试连接...';

  @override
  String get getKey => '获取key';

  @override
  String get editSongTagsTitle => '编辑歌曲标签';

  @override
  String get changeArtwork => '更换封面';

  @override
  String get clearArtwork => '清除封面';

  @override
  String get editSongTagsDescription => '修改后可以只保存到 App，也可以同步写回源文件。';

  @override
  String get artistLabel => '艺术家';

  @override
  String get albumLabel => '专辑';

  @override
  String get trackNumberLabel => '曲目号';

  @override
  String get trackNumberMustBeInteger => '曲目号必须是整数';

  @override
  String get leaveBlankKeepsCurrentValue => '留空则清空该项';

  @override
  String get currentFileFormatCannotWriteBack => '当前文件格式不支持写回源文件，只能保存到 App。';

  @override
  String get leaveBlankDoesNotClearOriginalValue => '提示：留空会清空对应标签的值。';

  @override
  String get saveToApp => '保存到 App';

  @override
  String get saveToSourceFileAndApp => '保存到源文件和 App';

  @override
  String get saveToSourceFileFailed => '保存到源文件失败，请确认文件格式支持写入且文件未被占用';

  @override
  String get fileOccupiedByOtherApp => '文件被其他 App 占用，无法写入';

  @override
  String get saveFailed => '保存失败，请稍后重试';

  @override
  String apiKeySaved(Object provider) {
    return '$provider API Key 已保存';
  }

  @override
  String get apiKeySavedAcoustid => 'AcoustID API Key 已保存';

  @override
  String get generalSectionTitle => '界面';

  @override
  String get generalSectionDescription => '这些选项会影响页面和播放界面的整体显示方式。';

  @override
  String get interfaceLanguage => '界面语言';

  @override
  String get interfaceLanguageDescription => '选择软件的界面显示语言。';

  @override
  String get scanSectionTitle => '扫描';

  @override
  String get scanSectionDescription => '这些选项会控制媒体库扫描如何处理音频文件。';

  @override
  String get skipShortAudioDuringScan => '扫描时跳过短音频';

  @override
  String get skipShortAudioDuringScanDescription => '短于阈值的音频不会加入媒体库。';

  @override
  String get shortAudioScanThreshold => '短音频阈值';

  @override
  String get shortAudioScanThresholdDescription => '短于该时长的文件会被跳过。';

  @override
  String shortAudioScanThresholdValue(Object seconds) {
    return '$seconds 秒';
  }

  @override
  String get shortcutSettingsTitle => '自定义快捷键';

  @override
  String get shortcutSettingsDescription => '点击后可以为播放器操作重新录制快捷键并保存。';

  @override
  String get edit => '编辑';

  @override
  String get lyricsSectionTitle => '歌词';

  @override
  String get lyricsSectionDescription => '这里的配置只影响歌词生成和时间轴生成。';

  @override
  String get lyricsTranslationTargetLanguageLabel => '翻译目标语言';

  @override
  String get lyricsTranslationTargetLanguageDescription => '默认跟随系统语言，也可以单独指定。';

  @override
  String get lyricsSaveMethodLabel => '歌词保存位置';

  @override
  String get lyricsSaveMethodDescription => '选择将歌词写入文件时的保存位置。';

  @override
  String get lyricsSaveMethodOriginal => '原处';

  @override
  String get lyricsSaveMethodEmbedded => '内嵌';

  @override
  String get lyricsSaveMethodLrcFile => 'LRC文件';

  @override
  String get lyricsStyleLabel => '歌词面板样式';

  @override
  String get lyricsStyleDescription => '选择歌词面板的展示和交互样式。';

  @override
  String get lyricsStyleTraditional => '传统滚动';

  @override
  String get lyricsStyleApple => '逐行聚焦';

  @override
  String get resumeLyricsSync => '恢复歌词同步';

  @override
  String get followSystemLanguage => '跟随系统';

  @override
  String get autoSwitchLyricsProvider => '自动切换歌词供应商';

  @override
  String get autoSwitchLyricsProviderEnabledDesc =>
      '开启后会先请求 Google AI Studio；主模型和备用模型都因 429 或 5xx 失败时，再自动切到 OpenRouter 继续请求。';

  @override
  String get autoSwitchLyricsProviderDisabledDesc =>
      '请先同时填写 Google AI Studio 和 OpenRouter 的 API Key，才可以开启自动切换。';

  @override
  String get lyricsAiProviderTitle => '歌词生成 AI 提供方';

  @override
  String get lyricsAiProviderDescription =>
      '这里只影响歌词生成和时间轴生成。翻译始终走 Google AI Studio。';

  @override
  String get googleAiStudioApiKeySaved => 'Google AI Studio API Key 已保存';

  @override
  String get googleAiStudioApiKeyMissing =>
      '当前未保存 Google AI Studio key，歌词生成和时间轴生成会先弹窗提示。';

  @override
  String get openRouterApiKeySaved => 'OpenRouter API Key 已保存';

  @override
  String get openRouterApiKeyMissing =>
      '当前未保存 OpenRouter key，歌词生成和时间轴生成会先弹窗提示。';

  @override
  String get apiKeySavedStatus => '已保存';

  @override
  String get apiKeyMissingStatus => '未填写';

  @override
  String get platformApiKeysSectionTitle => '平台 API Key';

  @override
  String get fill => '填写';

  @override
  String get modify => '修改';

  @override
  String get geminiModelsSectionTitle => '选择模型';

  @override
  String get geminiModelsSectionDescription =>
      '这些模型会用于 Google AI Studio 的歌词生成、时间轴生成以及歌词翻译。';

  @override
  String get primaryModelLabel => '主模型';

  @override
  String get backupModelLabel => '备用模型';

  @override
  String get translationModelLabel => '翻译模型';

  @override
  String get fetching => '获取中...';

  @override
  String get fetchModelList => '获取模型列表';

  @override
  String get restoreDefault => '恢复默认';

  @override
  String get acoustidSectionTitle => '听歌识曲';

  @override
  String get acoustidApiKeyTitle => 'AcoustID API Key';

  @override
  String get acoustidApiKeyHelp => 'AcoustID 用于听歌识曲，建议使用你自己的 API Key。';

  @override
  String get acoustidApiKeySaved => 'AcoustID API Key 已保存';

  @override
  String get acoustidApiKeyDefault => '当前使用应用内置的默认 key，建议申请你自己的 key 后替换。';

  @override
  String get applyForApiKey =>
      '申请 API key: https://acoustid.org/new-application';

  @override
  String get queueTabBarFavoriteAdded => '已加入收藏';

  @override
  String get queueTabBarFavoriteRemoved => '已取消收藏';

  @override
  String get tagCompletion => '歌曲标签补全';

  @override
  String get tagCompletionDescription => '根据 AcoustID 和 MusicBrainz 结果匹配标签';

  @override
  String get goToSettings => '去设置页';

  @override
  String get searchReleaseTitles => '搜索 release 标题';

  @override
  String get closeSearch => '关闭搜索';

  @override
  String get refreshResults => '刷新结果';

  @override
  String get filterMusicBrainzReleaseTitle => '过滤 MusicBrainz release 标题';

  @override
  String get clearSearch => '清空搜索';

  @override
  String get localTitle => '本地标题';

  @override
  String get queryConditions => '查询条件';

  @override
  String get musicBrainzLoading => '正在查询 MusicBrainz';

  @override
  String get musicBrainzLoadingWithResults => '现有结果会先保留在面板里';

  @override
  String get musicBrainzLoadingHint => '请稍候';

  @override
  String get musicBrainzQueryFailed => 'MusicBrainz 查询失败';

  @override
  String get musicBrainzNetworkErrorHint =>
      'MusicBrainz 请求失败，通常是网络连接不稳定、超时或被服务端拒绝。可以稍后重试。';

  @override
  String get musicBrainzFilteredEmptyHint => '当前过滤条件下没有包含该关键词的 release 标题。';

  @override
  String get musicBrainzEmptyHint =>
      'MusicBrainz 没有返回可用结果。可以放宽标题、艺人或专辑条件后再试一次。';

  @override
  String get musicBrainzEmptyMoreCompleteHint => '可以稍后重试，或者确认当前歌曲标题/艺人信息是否更完整。';

  @override
  String get retry => '重试';

  @override
  String get noMatchingRelease => '没有找到匹配的 release';

  @override
  String get noMatchingResults => '没有找到匹配结果';

  @override
  String get networkConnectionFailed => '网络连接失败';

  @override
  String get searchAgain => '重新搜索';

  @override
  String get acoustidRecognitionRecords => 'AcoustID 识别记录';

  @override
  String get musicBrainzRecordings => 'MusicBrainz 录音';

  @override
  String get noExpandableReleaseGroups => '没有可展开的发行版分组';

  @override
  String get noExpandableReleases => '没有可展开的发行版';

  @override
  String get noMatchingResultHint => '可以稍后重试，或者确认当前歌曲标题/艺人信息是否更完整。';

  @override
  String releaseCountLabel(int count) {
    return '$count 个发行版';
  }

  @override
  String recordingCountLabel(int count) {
    return '$count 条录音';
  }

  @override
  String trackCountShort(int count) {
    return '$count 首';
  }

  @override
  String scoreLabel(int score) {
    return '评分 $score';
  }

  @override
  String matchScoreLabel(int score) {
    return '匹配度 $score%';
  }

  @override
  String get editQueryCondition => '编辑查询条件';

  @override
  String get enterNewQueryText => '输入新的查询文字';

  @override
  String get durationLabel => '时长';

  @override
  String get customShortcuts => '自定义快捷键';

  @override
  String get pressShortcutCombo => '请按下组合键';

  @override
  String get clickToRecord => '点击录制';

  @override
  String get searchingLyrics => '正在查找歌词';

  @override
  String get noLyrics => '暂无歌词';

  @override
  String get providerLabel => '提供商';

  @override
  String get modelLabel => '模型';

  @override
  String get unspecified => '未指定';

  @override
  String targetTimeLabel(String duration) {
    return '目标时间 $duration';
  }

  @override
  String get songDeletedSkipped => '歌曲已删除，已跳过';

  @override
  String get songDeleted => '歌曲已删除';

  @override
  String get lyricsTaskUploading => '上传中';

  @override
  String get lyricsTaskWaiting => '等待就绪';

  @override
  String get lyricsTaskRequesting => '请求中';

  @override
  String get lyricsTaskGenerating => '生成中';

  @override
  String get lyricsTaskRetrying => '重试中';

  @override
  String get lyricsTaskProcessing => '正在处理';

  @override
  String get unknownModel => '未知模型';

  @override
  String selectedFolders(int count) {
    return '已选中 $count 个目录';
  }

  @override
  String foldersDeleted(int count) {
    return '已删除 $count 个目录';
  }

  @override
  String get persistentAccessDenied => '无法保存该目录的访问权限，请重新选择一次';

  @override
  String get folderAddFailed => '目录添加失败';

  @override
  String get sleepTimer => '睡眠定时器';

  @override
  String sleepTimerRemaining(Object duration) {
    return '睡眠定时器 $duration';
  }

  @override
  String get unknownArtistOrAlbum => '未知';

  @override
  String get pressAgainToExit => '再按一次退出应用';

  @override
  String get tagCompletionSuccessWithCover => '标签已补全并保存，封面已下载到临时目录';

  @override
  String get tagCompletionSuccess => '标签已补全并保存';

  @override
  String get selectOnlineLyrics => '选择在线歌词';

  @override
  String get increaseLyricsFont => '增大歌词文字';

  @override
  String get decreaseLyricsFont => '减小歌词文字';

  @override
  String get restoreDefaultSize => '恢复默认大小';

  @override
  String get adjustLyricsFont => '调整文字大小';

  @override
  String get searchingOnlineLyrics => '正在查询在线歌词';

  @override
  String get onlineLyricsResults => '在线歌词结果';

  @override
  String get untitledLyrics => '未命名歌词';

  @override
  String get hasTimeline => '带时间轴';

  @override
  String get viewLyricsDetails => '查看歌词详情';

  @override
  String get lyricsDetails => '歌词详情';

  @override
  String get lyricsContent => '歌词内容';

  @override
  String get noLyricsContent => '无歌词内容';

  @override
  String get queryContentLabel => '内容';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String dropAddedSongs(int addedCount) {
    return '已添加 $addedCount 首歌曲';
  }

  @override
  String dropAddedSongsWithExisting(int addedCount, int existingCount) {
    return '已添加 $addedCount 首歌曲，$existingCount 首已存在';
  }

  @override
  String get copyCover => '复制封面到剪贴板';

  @override
  String get copyCoverSuccess => '已成功复制封面';

  @override
  String get searchLyricsPlaceholder => '输入歌名、歌手或歌词进行搜索';

  @override
  String get share => '共享';

  @override
  String get windowsSettingsTitle => 'Windows 专属设置';

  @override
  String get fileAssociationTitle => '文件打开方式关联';

  @override
  String get fileAssociationDescription =>
      '将常见的音乐格式（mp3, flac, wav 等）关联到此应用，支持双击直接打开播放。';

  @override
  String get associateButton => '一键关联';

  @override
  String get disassociateButton => '取消关联';

  @override
  String get associationSuccess =>
      '关联成功！若双击文件未生效，请在 Windows 系统设置的【默认应用】中选择 Vynody。';

  @override
  String get disassociationSuccess => '已成功清除文件关联。';

  @override
  String associationFailed(Object error) {
    return '关联失败：$error';
  }

  @override
  String get onboardingTitle => '欢迎使用 Vynody';

  @override
  String get onboardingSubtitle => '只需几个简单步骤，即可开启你的音乐之旅。';

  @override
  String get onboardingStepFileAssociation => '关联文件打开方式';

  @override
  String get onboardingFileAssociationDesc =>
      '将常见的音乐格式（mp3, flac, wav 等）与 Vynody 关联，在文件管理器中双击即可直接播放。';

  @override
  String get onboardingFileAssociationTip =>
      '关联后，系统可能会弹出选择默认打开程序的对话框。请务必在列表中选择「Vynody」并设为始终使用。';

  @override
  String get onboardingStepRootDirectory => '添加音乐根目录';

  @override
  String get onboardingRootDirectoryDesc =>
      '选择存储音乐文件的文件夹。Vynody 会自动扫描并建立你的本地音乐库。';

  @override
  String get onboardingAndroidPermissionTip =>
      '注意：Android 系统在导入与扫描本地歌曲时需要授予媒体库访问权限。点击【选择文件夹】时将触发权限请求，请予以允许。';

  @override
  String get onboardingSelectDirectory => '选择文件夹';

  @override
  String get onboardingSuccessTitle => '一切准备就绪！';

  @override
  String get onboardingSuccessDesc => '已成功添加媒体库。让我们开始享受音乐吧！';

  @override
  String get onboardingStartButton => '进入 Vynody';

  @override
  String get onboardingSkip => '稍后设置';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingBack => '上一步';

  @override
  String get resetOnboarding => '重置新手引导';

  @override
  String get resetOnboardingDesc => '清除首次启动引导状态，下次启动应用时重新显示新手引导。';

  @override
  String get songProperties => '歌曲属性';

  @override
  String get failedToLoadDetails => '无法获取详细信息';

  @override
  String get noPropertiesAvailable => '暂无歌曲详细属性';

  @override
  String get detailFilePath => '文件路径';

  @override
  String get detailFormat => '格式';

  @override
  String get detailCodec => '编码';

  @override
  String get detailDuration => '时长';

  @override
  String get detailFileSize => '文件大小';

  @override
  String get detailBitrate => '比特率';

  @override
  String get detailSampleRate => '采样率';

  @override
  String get detailChannels => '声道数';

  @override
  String get detailBitDepth => '采样深度';

  @override
  String get detailMono => '单声道 (Mono)';

  @override
  String get detailStereo => '立体声 (Stereo)';

  @override
  String detailChannelsCount(int count) {
    return '$count 声道';
  }

  @override
  String get localNetworkPermissionDeniedTitle => '局域网访问受限';

  @override
  String get localNetworkPermissionDeniedMessage =>
      '未检测到可用的局域网 IP 地址，或局域网访问权限被拒绝。\n\n请按照以下步骤操作：\n1. 确保您的设备已连接到 Wi-Fi 或局域网。\n2. 确保在系统设置中允许本应用访问局域网：\n   - iOS/macOS: 请前往系统的「设置 > 隐私与安全性 > 局域网」，开启「Vynody」的开关。\n   - Windows: 请确保已连接到网络，并检查 Windows 防火墙设置是否允许「Vynody」通过。';

  @override
  String get localNetworkPermissionWindowsMessage =>
      '未检测到可用的局域网 IP 地址。\n\n请按照以下步骤操作：\n1. 确保您的设备已连接到局域网（Wi-Fi 或以太网）。\n2. 如果已连接但仍提示此错误，请检查 Windows 防火墙设置，确保允许「Vynody」通过防火墙访问网络。';

  @override
  String get openSettingsButton => '前往设置';

  @override
  String get closeButton => '关闭';

  @override
  String get copyTranslationResults => '复制翻译结果';

  @override
  String get writeLyricsToFile => '将歌词写入文件';

  @override
  String get selectLyricSource => '选择歌词来源';

  @override
  String get regenerateLyrics => '重新生成歌词';

  @override
  String get regenerateLyricsConfirmation => '将清空当前歌词并重新生成，是否继续？';

  @override
  String get regenerateTimeline => '重新生成时间轴';

  @override
  String get regenerateTimelineConfirmation => '将清空当前时间轴并重新生成，是否继续？';

  @override
  String get retranslateLyrics => '重新翻译歌词';

  @override
  String get retranslateLyricsConfirmation => '将清空当前翻译并重新翻译，是否继续？';

  @override
  String get translationCopiedToClipboard => '已复制翻译结果到剪贴板';

  @override
  String get writingLyrics => '正在写入歌词...';

  @override
  String get lyricsWrittenToFile => '歌词写入文件成功';

  @override
  String get writeLyricsFailed => '写入歌词失败';

  @override
  String get externalLrcFile => '同名外置LRC文件';

  @override
  String get embeddedLyrics => '音频内嵌歌词';

  @override
  String get manuallyAdjustedLyrics => '手动修改的歌词';

  @override
  String get lrclibOnlineLyrics => 'LrcLib在线歌词';

  @override
  String get aiGeneratedLyrics => 'AI生成的歌词';

  @override
  String get matchScore => '匹配度';

  @override
  String get untitledRelease => '未命名发行版';

  @override
  String get localSongFileNotFoundForGeneration => '本地歌曲文件不存在，无法生成歌词。';

  @override
  String get localSongFileNotFoundForTimeline => '本地歌曲文件不存在，无法生成时间轴。';

  @override
  String get noLyricsForTimelineGeneration => '没有可用歌词，无法生成时间轴。';

  @override
  String get noLyricsAvailableForTranslation => '没有可用于翻译的歌词。';

  @override
  String get noCurrentSongAvailable => '没有可用的当前歌曲。';

  @override
  String get invalidTargetLanguage => '目标语言无效。';

  @override
  String get songAlreadyQueuedForTranslation => '当前歌曲的歌词任务已在排队或翻译中。';

  @override
  String get songAlreadyQueuedForGeneration => '当前歌曲的歌词任务已在排队或生成中。';

  @override
  String get songNoLongerExistsForTranslation => '当前歌曲已不存在，无法翻译歌词。';

  @override
  String get generationFailed => '生成失败。';

  @override
  String get generatingLyrics => '正在生成歌词';

  @override
  String get generatingTimeline => '正在生成时间轴';

  @override
  String get regeneratingLyrics => '正在重新生成歌词';

  @override
  String get translatingLyrics => '正在翻译歌词';

  @override
  String get transcodingSongFile => '正在转码歌曲文件';

  @override
  String get uploadingSongFile => '正在上传歌曲文件';

  @override
  String get fileUploadedWaitingForReadiness => '文件已上传，正在等待文件就绪';

  @override
  String get waitingForFileReadiness => '正在等待文件就绪';

  @override
  String get requestingModelResponse => '正在请求模型响应';

  @override
  String retryingTaskKindGeneration(Object taskKind) {
    return '正在重试生成$taskKind';
  }

  @override
  String get retrying => '正在重试';

  @override
  String get processing => '正在处理';

  @override
  String get timeline => '时间轴';

  @override
  String get lyrics => '歌词';

  @override
  String lyricGenerationError(Object error) {
    return '生成歌词时发生错误：$error';
  }

  @override
  String timelineGenerationError(Object error) {
    return '生成时间轴时发生错误：$error';
  }

  @override
  String get unknownGenerationError => '生成歌词时发生未知错误。';

  @override
  String get unknownTimelineGenerationError => '生成时间轴时发生未知错误。';

  @override
  String get unknownTranslationError => '翻译歌词时发生未知错误。';

  @override
  String get unknownError => '未知错误';

  @override
  String get modelRefusedToGenerateLyrics => '模型拒绝生成歌词。';

  @override
  String get modelRefusedToGenerateTimeline => '模型拒绝生成时间轴。';

  @override
  String get doubaoPreUploadTranscodingFailed => '豆包上传前音频转码失败。';

  @override
  String get doubaoTempTranscodeNotInTempDir => '豆包临时转码文件未生成在临时目录。';

  @override
  String get doubaoEmptyStreamingResponse => '豆包返回了空流响应。';

  @override
  String get doubaoEmptyResponse => '豆包返回了空响应。';

  @override
  String get geminiEmptyStreamingResponse => 'Gemini 返回了空流响应。';

  @override
  String get geminiEmptyResponse => 'Gemini 返回了空响应。';

  @override
  String get openRouterEmptyStreamingResponse => 'OpenRouter 返回了空流响应。';

  @override
  String get openRouterEmptyResponse => 'OpenRouter 返回了空响应。';

  @override
  String get deepseekEmptyStreamingResponse => 'DeepSeek 返回了空流响应。';

  @override
  String get deepseekEmptyResponse => 'DeepSeek 返回了空响应。';

  @override
  String get customProviderEmptyStreamingResponse => '自定义供应商返回了空流响应。';

  @override
  String get customProviderEmptyResponse => '自定义供应商返回了空响应。';

  @override
  String get fileUploadFailed => '文件上传失败，请重试。';

  @override
  String get uploadedFileNotReady => '上传后的文件未能就绪，请稍后重试。';

  @override
  String get audioTranscodingFailed => '音频转码失败。';

  @override
  String get tempTranscodeNotInTempDir => '临时转码文件未生成在临时目录。';

  @override
  String get networkRequestFailedCheckProxy => '网络请求失败，请检查网络以及代理状态。';

  @override
  String get quotaExhaustedToday => '今天额度已用完，请等待明天额度恢复再试';

  @override
  String get googleAiHeavyLoad => '谷歌AI服务遭遇大量请求，暂时不可用';

  @override
  String lyricsGenerationFailedWithError(Object error) {
    return '生成歌词失败：$error';
  }

  @override
  String missingApiKeyForAction(Object action, Object providerName) {
    return '未找到 $providerName API Key，无法$action。';
  }

  @override
  String get googleServerFlaky => 'Google服务器开小差了，重试一下或许会成功哦';

  @override
  String get translateLyricsAction => '翻译歌词';

  @override
  String get generateLyricsAction => '生成歌词';

  @override
  String get generateTimelineAction => '生成时间轴';

  @override
  String get deepseekOnlyTranslation => 'DeepSeek 仅支持歌词翻译。';

  @override
  String get customProviderOnlyTranslation => '自定义供应商仅支持歌词翻译。';

  @override
  String get customProviderNoBaseUrl => '未配置自定义供应商的 Base URL。';

  @override
  String get pleaseEnterApiKey => '请输入 API key。';

  @override
  String get connectionSuccessVerificationPassed => '连接成功，已通过验证。';

  @override
  String connectionSuccessDetectedModels(Object count) {
    return '连接成功，检测到 $count 个模型。';
  }

  @override
  String testFailedWithStatus(Object message, Object statusCode) {
    return '测试失败（$statusCode）：$message';
  }

  @override
  String get testFailedCheckNetworkOrApiKey => '测试失败，请检查网络或 API key。';

  @override
  String testFailedStatusCheckApiKey(Object statusCode) {
    return '测试失败（$statusCode），请检查 API key 是否有效。';
  }

  @override
  String get enterGoogleAiStudioApiKeyFirst => '请先填写 Google AI Studio API Key。';

  @override
  String get enterDoubaoApiKeyFirst => '请先填写豆包 API Key。';

  @override
  String get enterDeepseekApiKeyFirst => '请先填写 DeepSeek API Key。';

  @override
  String get enterCustomApiKeyAndBaseUrl => '请先填写自定义 API Key 和 Base URL。';

  @override
  String fetchedCountModels(Object count) {
    return '已获取 $count 个模型。';
  }

  @override
  String requestFailedWithStatus(Object message, Object statusCode) {
    return '请求失败（$statusCode）：$message';
  }

  @override
  String get requestFailedCheckNetwork => '请求失败，请检查网络。';

  @override
  String requestFailedStatus(Object statusCode) {
    return '请求失败（$statusCode）。';
  }

  @override
  String get doubao => '豆包';

  @override
  String get custom => '自定义';

  @override
  String get noModelSelected => '未选择模型';

  @override
  String get acoustidRequestFailed => 'AcoustID 请求失败';

  @override
  String acoustidRequestReturnedStatus(Object statusCode) {
    return 'AcoustID 请求返回 $statusCode。请申请你自己的 AcoustID API key 并填入设置页。';
  }

  @override
  String get writeTagDatabaseFailed => '写入标签数据库失败';

  @override
  String get playPause => '播放 / 暂停';

  @override
  String get nextTrack => '下一首';

  @override
  String get previousTrack => '上一首';

  @override
  String get volumeUp => '音量增加';

  @override
  String get volumeDown => '音量减少';

  @override
  String get toggleMute => '静音切换';

  @override
  String get seekForward5s => '快进 5 秒';

  @override
  String get seekBackward5s => '后退 5 秒';

  @override
  String get toggleFullScreen => '切换全屏';

  @override
  String get playPauseDescription => '控制当前播放状态。';

  @override
  String get nextDescription => '切换到下一首歌曲。';

  @override
  String get previousDescription => '切换到上一首歌曲。';

  @override
  String get volumeUpDescription => '每次增加 5% 音量。';

  @override
  String get volumeDownDescription => '每次减少 5% 音量。';

  @override
  String get toggleMuteDescription => '切换静音。';

  @override
  String get seekForward5sDescription => '向前快进 5 秒。';

  @override
  String get seekBackward5sDescription => '向后快退 5 秒。';

  @override
  String get toggleFullScreenDescription => '在窗口模式和全屏模式之间切换。';

  @override
  String get unknownKey => '未知按键';

  @override
  String get removeFromQueue => '从队列中移除';

  @override
  String get removeFromPlaylist => '从歌单中移除';

  @override
  String get alreadyLatestVersion => '当前已经是最新版本。';

  @override
  String get updateAvailable => '发现新版本';

  @override
  String newVersionAvailable(Object version) {
    return '检测到新版本 v$version，前往 GitHub Release 页面下载更新。';
  }

  @override
  String get openRelease => '前往 Release';

  @override
  String get checkUpdateFailedNetwork => '检查更新失败，可能是网络问题或 GitHub 限流。';

  @override
  String get tags => '标签';

  @override
  String get about => '关于';

  @override
  String get rebuildIndex => '重建索引';

  @override
  String get rebuildIndexDescription => '清空除外部来源以外的所有歌曲记录并重新扫描所有根目录。';

  @override
  String get rebuildIndexConfirmation =>
      '确认清空除外部来源以外的所有歌曲记录并重新扫描所有根目录吗？此操作需要一些时间。';

  @override
  String get rebuildIndexStarted => '重建索引已启动';

  @override
  String get rebuild => '重建';

  @override
  String get advanced => '高级';

  @override
  String get advancedOptionsDescription => '更偏调试和行为控制的选项。';

  @override
  String get showDeveloperOptionsDescription => '显示更多偏调试用途的高级项。';

  @override
  String get onboardingReset => '已重置新手引导状态，下次启动时生效。';

  @override
  String get tagsSectionDescription => '关于音频文件元数据和自动补全的配置。';

  @override
  String get autoSaveToSourceFile => '自动写入源文件';

  @override
  String get autoSaveToSourceFileDescription => '补全或更新歌曲标签时，默认同步写入物理音频文件。';

  @override
  String get aboutSectionDescription => '版本信息、项目链接和相关资料。';

  @override
  String get checkForUpdates => '检查更新';

  @override
  String get lyricsGenerationModel => '歌词生成模型';

  @override
  String get lyricsGenerationModelDescription =>
      '用于 AI 听歌生成歌词，以及给现有歌词生成/修正时间轴。';

  @override
  String get lyricsTranslationModel => '歌词翻译模型';

  @override
  String get lyricsTranslationModelDescription => '用于把歌词翻译到目标语言。';

  @override
  String get onlyForLyricTranslation => '仅用于歌词翻译';

  @override
  String get fillApiKeyFirstEnablesModels => '请先填写至少一个 API Key，模型选择才会启用。';

  @override
  String get customApiProvider => '自定义 API 供应商';

  @override
  String get clearedGoogleAiStudioApiKey => '已清空 Google AI Studio API Key';

  @override
  String get clearedOpenRouterApiKey => '已清空 OpenRouter API Key';

  @override
  String get clearedDoubaoApiKey => '已清空豆包 API Key';

  @override
  String get clearedDeepseekApiKey => '已清空 DeepSeek API Key';

  @override
  String get clearedCustomProviderConfig => '已清空自定义供应商配置';

  @override
  String get savedDoubaoApiKey => '已保存豆包 API Key';

  @override
  String get savedDeepseekApiKey => '已保存 DeepSeek API Key';

  @override
  String get savedCustomProviderConfig => '已保存自定义供应商配置';

  @override
  String get noMatchingFoldersOrSongs => '未找到匹配的文件夹或歌曲';

  @override
  String get searching => '正在搜索...';

  @override
  String get listView => '列表视图';

  @override
  String get gridView => '网格视图';

  @override
  String get hybridView => '混合视图';

  @override
  String songsCountFormat(Object count) {
    return '$count 首歌曲';
  }

  @override
  String get searchInFolderAndSubfolders => '在当前目录及子目录下搜索...';

  @override
  String get shuffle => '随机播放';

  @override
  String get search => '搜索';

  @override
  String get selectFolders => '选择目录';

  @override
  String get removeDirectory => '移除目录';

  @override
  String removeRootDirectoryConfirmation(Object name) {
    return '确定要移除根目录 \"$name\" 吗？此操作不会删除磁盘上的物理文件。';
  }

  @override
  String get deselectAll => '取消全选';

  @override
  String get favorites => '收藏';

  @override
  String get aggregationPeak => '峰值';

  @override
  String get aggregationMean => '平均值';

  @override
  String get aggregationRms => '均方根';

  @override
  String get filesToTranscode => '待转码文件';

  @override
  String get chooseAndroidOutputDirectoryFirst => '请先选择一个 Android 输出目录。';

  @override
  String currentSongProgressPercent(Object percent) {
    return '当前歌曲 $percent%';
  }

  @override
  String overallProgressPercent(Object percent) {
    return '总体 $percent%';
  }

  @override
  String get pleaseChooseOutputDirectory => '请先选择一个输出目录。';

  @override
  String selectedArtistsCount(Object count) {
    return '已选择 $count 位艺术家';
  }

  @override
  String selectedAlbumsCount(Object count) {
    return '已选择 $count 张专辑';
  }

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get traditionalChinese => '繁体中文';

  @override
  String get chineseLanguage => '中文';

  @override
  String get englishLanguage => '英文';

  @override
  String get japaneseLanguage => '日文';

  @override
  String get koreanLanguage => '韩文';

  @override
  String get frenchLanguage => '法文';

  @override
  String get germanLanguage => '德文';

  @override
  String get spanishLanguage => '西班牙文';

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
  String get portugueseLanguage => '葡萄牙文';

  @override
  String get russianLanguage => '俄文';

  @override
  String get systemLanguage => '系统语言';

  @override
  String get targetLanguage => '目标语言';

  @override
  String get whatAreAiLyrics => '什么是 AI 歌词？';

  @override
  String get whatIsAiLyricTranslation => '什么是 AI 歌词翻译？';

  @override
  String get aiLyricsIntroGeneration => 'AI 可以根据歌曲内容生成歌词，并自动匹配时间轴。';

  @override
  String get aiLyricsIntroTranslation => 'AI 可以把歌词翻译成你熟悉的语言，方便理解歌曲内容。';

  @override
  String get whyNeedApiKey => '为什么需要 API Key？';

  @override
  String get apiKeyExplanation =>
      'API Key 相当于你在 AI 服务商那里的访问凭证。应用会用它直接向服务商发起请求，完成歌词生成、时间轴调整或翻译。';

  @override
  String get apiKeyLocalOnly => 'API Key 只保存在你的本地设备，不会上传到 Vynody 开发者服务器。';

  @override
  String get chooseAnAiProvider => '选择一个 AI 服务商：';

  @override
  String get googleProviderPros => 'Google 官方通道，Gemini 模型能力强，免费额度较多。';

  @override
  String get googleProviderCons =>
      '中国大陆直连受限，需要稳定的 VPN/代理。请求人数较多时可能报 429，遇到 429 请切换到其他渠道。';

  @override
  String get openRouterProviderPros => '海外大模型聚合平台，可使用多个模型，也有部分免费模型。';

  @override
  String get openRouterProviderCons => '充值需要支付手续费，网页只有英文。';

  @override
  String get doubaoProviderPros => '字节跳动出品，国内访问快，中文效果好。新用户每个模型有 50 万免费 token。';

  @override
  String get doubaoProviderCons => '注册步骤相对繁琐，需要实名认证。';

  @override
  String get deepseekProviderPros => '中文理解好，价格便宜，适合歌词翻译。';

  @override
  String get deepseekProviderCons => '仅支持文本输入。如需歌词生成、时间轴调整，需要填入其他渠道 API Key。';

  @override
  String get highlights => '【特点】';

  @override
  String get notes => '【注意事项】';

  @override
  String enterProviderApiKey(Object provider) {
    return '请输入 $provider 的 API Key：';
  }

  @override
  String get pasteYourApiKey => '在此粘贴你的 API Key';

  @override
  String get getApiKey => '获取 API Key';

  @override
  String get testConnectionButton => '测试连接';

  @override
  String get enableAiLyricGeneration => '启用 AI 歌词生成';

  @override
  String get enableAiLyricTranslation => '启用 AI 歌词翻译';

  @override
  String get notNow => '暂不启用';

  @override
  String get startSetup => '开始配置';

  @override
  String get chooseAiProvider => '选择 AI 服务商';

  @override
  String get backStep => '上一步';

  @override
  String get continueAction => '继续';

  @override
  String get nextStep => '下一步';

  @override
  String get configureApiKey => '配置 API Key';

  @override
  String get saveAndFinish => '保存并完成';

  @override
  String get testing => '正在测试...';

  @override
  String get noteTitle => '提示';

  @override
  String get deepseekTextInputOnlyNote =>
      'DeepSeek 仅支持文本输入。如需歌词生成、时间轴调整，需要填入其他渠道 API Key。';

  @override
  String retryAttemptOfMax(Object attempt, Object maxRetry) {
    return '重试第 $attempt 次 / 共 $maxRetry 次';
  }

  @override
  String generatingTaskKind(Object taskKind) {
    return '正在生成$taskKind';
  }

  @override
  String connectionTestException(Object error) {
    return '连接测试异常：$error';
  }

  @override
  String get testingConnectionProgress => '正在测试连接...';

  @override
  String get clear => '清空';

  @override
  String get enterDoubaoApiKey => '输入豆包 API Key';

  @override
  String get doubaoApiKeyDescription => '请输入火山方舟 / 豆包的 API Key，用于歌词生成和翻译。';

  @override
  String get enterDeepseekApiKey => '输入 DeepSeek API Key';

  @override
  String get deepseekApiKeyDescription => '请输入 DeepSeek 的 API Key，仅用于歌词翻译。';

  @override
  String get pleaseEnterApiKeyHint => '请输入 API Key';

  @override
  String get platform => '平台';

  @override
  String get showRecommendedOnly => '仅显示推荐模型';

  @override
  String get noAvailableChannels => '暂无可用渠道';

  @override
  String get noMatchingModels => '没有找到匹配的模型';

  @override
  String get leaveEmpty => '留空';

  @override
  String get leaveEmptyFallbackDescription => '不设置备用模型时可选择此项。';

  @override
  String get modelSearchHint => '输入模型名、ID';

  @override
  String sendFilesFailed(Object error) {
    return '发送文件失败: $error';
  }

  @override
  String get scanningFolderMusic => '正在扫描文件夹中的音乐文件...';

  @override
  String scanFolderFailed(Object error) {
    return '扫描文件夹失败: $error';
  }

  @override
  String get noMusicFilesFound => '未在此文件夹中找到支持的音乐文件';

  @override
  String sendFolderFailed(Object error) {
    return '发送文件夹失败: $error';
  }

  @override
  String get lanSharingStartFailed => '局域网共享启动失败，请检查本地网络权限是否已开启';

  @override
  String syncingLyricsToDevice(Object deviceName) {
    return '正在向 $deviceName 同步歌词...';
  }

  @override
  String syncLyricsSuccess(Object matched, Object overwritten, Object skipped) {
    return '同步成功: 匹配 $matched 首, 更新 $overwritten 首, 忽略 $skipped 首';
  }

  @override
  String syncLyricsFailed(Object error) {
    return '同步歌词失败: $error';
  }

  @override
  String syncingLyricsFromDevice(Object deviceName) {
    return '正在从 $deviceName 同步歌词...';
  }

  @override
  String get transferInProgressDoNotLeave => '正在传输文件，请勿离开共享页';

  @override
  String get lanSharingTitle => '局域网文件共享';

  @override
  String get lanSharingEnabledStatus => '局域网共享已开启';

  @override
  String get lanSharingDisabledStatus => '局域网共享未开启';

  @override
  String lanSharingRunningStatus(Object ip, Object port) {
    return '本机 IP: $ip（端口: $port）';
  }

  @override
  String get lanSharingDefaultOffHint => '默认关闭，开启后会请求局域网权限';

  @override
  String get receiveDirectoryNotSetWarning => '未设置接收文件保存目录时将无法接收文件，建议先设置。';

  @override
  String receiveDirectoryUpdated(Object path) {
    return '接收目录已更新为: $path';
  }

  @override
  String get receiveDirectoryTitle => '接收文件保存目录';

  @override
  String get webShareTitle => '浏览器网页传输 (Web Share)';

  @override
  String get webShareDescription => '同一局域网的手机/电脑可通过浏览器打开下方链接，直接向本设备上传或下载音乐：';

  @override
  String get linkCopiedToClipboard => '链接已复制到剪贴板';

  @override
  String get nearbyDevices => '附近的设备';

  @override
  String get searchingDevices => '正在寻找局域网内其他设备...';

  @override
  String get startSharingToFindDevices => '开启共享后开始寻找设备';

  @override
  String get deviceOnline => '在线';

  @override
  String get deviceOffline => '已断开';

  @override
  String get sendMusicFiles => '发送音乐文件';

  @override
  String get sendFolder => '发送文件夹';

  @override
  String get syncLyricsToDeviceAction => '同步歌词至该设备';

  @override
  String get syncLyricsFromDeviceAction => '从该设备同步歌词';

  @override
  String loadDevicesError(Object error) {
    return '加载设备出错: $error';
  }

  @override
  String incomingFilesFormat(Object name1, Object name2, Object count) {
    return '$name1、$name2 等共 $count 个文件';
  }

  @override
  String get incomingTransferRequestTitle => '收到文件共享请求';

  @override
  String incomingTransferFrom(Object senderName) {
    return '来自 \"$senderName\" 的发送请求：';
  }

  @override
  String fileSizeMb(Object sizeMb) {
    return '文件大小: $sizeMb MB';
  }

  @override
  String get receiveFileHint => '提示：接收后文件将自动保存至本地音乐文件夹并加入媒体库。';

  @override
  String get reject => '拒绝';

  @override
  String get accept => '接收';

  @override
  String sendCompleted(Object fileName) {
    return '\"$fileName\" 发送完毕';
  }

  @override
  String receiveCompleted(int count) {
    return '成功接收了 $count 首歌曲';
  }

  @override
  String transferCancelledWithReason(Object direction, Object reason) {
    return '$direction已取消（$reason）';
  }

  @override
  String transferFailedFormat(Object direction, Object fileName) {
    return '$direction \"$fileName\" 失败';
  }

  @override
  String sendingToDevice(Object deviceName) {
    return '正在发送到 $deviceName';
  }

  @override
  String receivingFromDevice(Object deviceName) {
    return '正在从 $deviceName 接收';
  }

  @override
  String progressFormat(Object percent) {
    return '进度: $percent%';
  }

  @override
  String get currentlyTransferring => '当前正在传输';

  @override
  String get fileConflictTitle => '文件冲突';

  @override
  String get fileConflictMessage => '目标设备已存在同名文件：';

  @override
  String get fileConflictChooseAction => '请选择您要执行的操作：';

  @override
  String get skipAction => '跳过';

  @override
  String get overwriteAction => '覆盖';

  @override
  String get skipAllAction => '全部跳过';

  @override
  String get overwriteAllAction => '全部覆盖';

  @override
  String get sendDirection => '发送';

  @override
  String get receiveDirection => '接收';

  @override
  String get fileAssociationEnabled => '已开启关联';

  @override
  String get fileAssociationDisabled => '未开启关联';

  @override
  String get windowsAutoRepairShortcut => '自动修复开始菜单快捷方式';

  @override
  String get windowsAutoRepairShortcutDescription =>
      '每次启动时自动检查并创建开始菜单快捷方式以正确显示媒体控制项名称与图标';

  @override
  String get confirmDisableShortcutRepair => '确定关闭此功能吗？';

  @override
  String get confirmDisableShortcutRepairContent =>
      '如果缺少开始菜单快捷方式，Windows 媒体控制中心（音量调节弹窗）将会把软件显示为\"未知应用\"，并且无法展示应用图标。是否确定关闭此功能？';

  @override
  String get confirmDisable => '确定关闭';

  @override
  String get enableSystemTray => '启用系统托盘';

  @override
  String get enableSystemTrayDescription => '在系统任务栏托盘中显示图标，方便快速控制播放';

  @override
  String get closeToTray => '点击关闭按钮时最小化到后台';

  @override
  String get closeToTrayDescription => '关闭主界面时保持后台播放，不直接退出程序';

  @override
  String get closeWindowActionTitle => '点击关闭按钮时';

  @override
  String get closeWindowActionDescription => '选择点击主界面关闭按钮时的操作';

  @override
  String get closeWindowActionAsk => '每次询问';

  @override
  String get closeWindowActionMinimize => '最小化到系统托盘';

  @override
  String get closeWindowActionExit => '完全退出应用';

  @override
  String get closeWindowActionRemember => '记住我的选择，不再提示';

  @override
  String get closeWindowActionTrayDisabledTip => '（需先启用系统托盘）';

  @override
  String get closeWindowDialogTitle => '关闭应用确认';

  @override
  String get closeWindowDialogContent => '请选择点击关闭按钮时的操作：';

  @override
  String get googleAiStudioApiKey => 'Google AI Studio API Key';

  @override
  String get openRouterApiKey => 'OpenRouter API Key';

  @override
  String get doubaoApiKey => '豆包 API Key';

  @override
  String get deepseekApiKey => 'DeepSeek API Key';

  @override
  String get unexpectedResponseFormat => '意外的响应格式。';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get openaiCompatibleEndpoint => '兼容 OpenAI 的 API 端点';

  @override
  String onboardingAddedDirectoriesCount(Object count) {
    return '已添加的目录（$count）：';
  }

  @override
  String get gnomeDisksOpenFailed => '无法自动打开磁盘管理器，请在应用菜单中手动搜索并打开「磁盘 (Disks)」';

  @override
  String get gnomeDisksNotInstalled => '系统未安装 gnome-disks，请手动打开系统磁盘管理工具进行配置。';

  @override
  String get linuxMountGuideTitle => '配置硬盘自动挂载';

  @override
  String get linuxMountGuideDescription =>
      'Linux默认设置下不会挂载外置分区，如果没有设置启动时挂载分区则每次重启时外置分区的路径可能发生变化，从而导致播放器访问不到音乐目录。为了避免这种情况，请将存放音乐的分区设置成启动时自动挂载。';

  @override
  String get linuxMountGuideWarning =>
      '注意：如果您的音乐位于需要挂载才能使用的外置/内部硬盘分区内，务必将该分区设置为「开机自动挂载」。否则，每次重启系统后可能会出现找不到音乐目录，或者需要输入密码授权才能访问的问题。';

  @override
  String get linuxMountGuideStep1 => '1. 打开系统的「磁盘 (Disks)」管理器';

  @override
  String get linuxMountGuideStep2 => '2. 选中包含音乐的分区，点击 ⚙️ 齿轮图标（附加分区选项）';

  @override
  String get linuxMountGuideStep3 =>
      '3. 选择\"编辑挂载选项\"，关闭\"用户会话默认值\"并勾选\"系统启动时挂载\"';

  @override
  String get linuxMountGuideOpenButton => '打开磁盘管理器 (Disks)';

  @override
  String get unmute => '取消静音';

  @override
  String get mute => '静音';

  @override
  String get disableSystemTray => '停用系统托盘';

  @override
  String get onboardingAndroidBatteryTitle => '后台播放防误杀设置';

  @override
  String get onboardingAndroidBatteryDescription =>
      '由于安卓系统的电池管理策略非常严格，为了防止音乐在后台播放时被系统强制关闭，建议将 Vynody 的电池使用限制设置为「无限制」（Unrestricted）。';

  @override
  String get onboardingAndroidBatteryStep1 => '1. 点击下方的「去设置」按钮。';

  @override
  String get onboardingAndroidBatteryStep2 => '2. 在系统弹窗中允许忽略电池优化，或者跳转到电池设置页面。';

  @override
  String get onboardingAndroidBatteryStep3 =>
      '3. 如果跳转至设置列表，选择「无限制」或「允许后台活动 / 不限制电池使用」。';

  @override
  String get onboardingAndroidBatteryButton => '去设置';

  @override
  String get onboardingAndroidBatteryStatusOptimized => '当前状态：已限制（可能导致后台播放中断）';

  @override
  String get onboardingAndroidBatteryStatusUnrestricted =>
      '当前状态：无限制（推荐，后台播放已保护）';

  @override
  String get onboardingAndroidMediaTitle => '访问手机音乐库';

  @override
  String get onboardingAndroidMediaDescription =>
      '授权后，Vynody 可直接读取系统媒体库中的所有音乐，无需手动选择文件夹。不授权也可以手动导入指定文件夹中的音乐。';

  @override
  String get onboardingAndroidMediaStep1 => '1. 即开即用：直接显示手机里已有的全部音乐';

  @override
  String get onboardingAndroidMediaStep2 => '2. 自动发现：新下载或传入的音乐自动出现在乐库中';

  @override
  String get onboardingAndroidMediaStep3 => '3. 隐私安全：仅读取本地音频文件，不会上传任何数据';

  @override
  String get onboardingAndroidMediaButton => '授权访问音乐库';

  @override
  String get onboardingAndroidMediaStatusGranted => '当前状态：已授权（推荐）';

  @override
  String get onboardingAndroidMediaStatusNotGranted => '当前状态：未授权（可稍后手动导入文件夹）';

  @override
  String get exitApp => '退出';

  @override
  String get showScanProgressToastSetting => '显示扫描状态提示';

  @override
  String get showScanProgressToastSettingDescription =>
      '在添加文件夹并进行文件扫描时，在顶部显示实时的扫描进度提示';

  @override
  String get openPlaybackOnDirectorySongTap => '点击歌曲后跳转到播放页';

  @override
  String get openPlaybackOnDirectorySongTapDescription =>
      '在目录页点击歌曲播放时，自动跳转至全屏播放界面';

  @override
  String get tapCoverToEnterLyricsMode => '点击封面可以进入歌词模式';

  @override
  String get longPressLyricsPanelToOpenMenu => '长按歌词面板可以调出菜单';

  @override
  String get gotIt => '我知道了';

  @override
  String get scanToastHiddenHint => '扫描状态提示已隐藏，可在“设置 - 界面”中重新打开';

  @override
  String get doubleSpeedPlayingSwipeUpToLock => '快进播放中... 往上滑动锁定';

  @override
  String get doubleSpeedLockedSwipeDownToUnlock => '已锁定快进播放。长按并向下滑动解锁';

  @override
  String get doubleSpeedUnlocked => '已解除快进锁定';

  @override
  String get lyricsImportExportHeader => '导入与导出';

  @override
  String get exportAction => '导出';

  @override
  String get importAction => '导入';

  @override
  String get exportLyricsLabel => '导出歌词备份';

  @override
  String get exportLyricsDescription => '将所有缓存与调整过的歌词导出为 JSON 文件';

  @override
  String get importLyricsLabel => '导入歌词备份';

  @override
  String get importLyricsDescription => '从导出的 JSON 文件导入歌词缓存';

  @override
  String exportSuccess(int count) {
    return '成功导出 $count 条歌词';
  }

  @override
  String exportFailed(String error) {
    return '导出失败: $error';
  }

  @override
  String importSuccess(int count) {
    return '导入完成！成功导入 $count 条歌词。';
  }

  @override
  String importFailed(String error) {
    return '导入失败: $error';
  }

  @override
  String get importConflictsTitle => '导入冲突';

  @override
  String importConflictsMessage(int conflictCount) {
    return '在备份中发现了 $conflictCount 条冲突的歌词（已有内容但与导入的不一致），请选择处理方式：';
  }

  @override
  String get overwriteAll => '全部覆盖';

  @override
  String get skipAllConflicts => '跳过冲突';

  @override
  String get decideOneByOne => '逐条确认';

  @override
  String conflictResolutionTitle(int current, int total) {
    return '解决冲突 ($current/$total)';
  }

  @override
  String get conflictExistingLabel => '现有歌词';

  @override
  String get conflictImportedLabel => '导入歌词';

  @override
  String conflictSourceLabel(String source) {
    return '来源: $source';
  }

  @override
  String conflictTimeLabel(String time) {
    return '时间: $time';
  }

  @override
  String get overwriteThis => '覆盖';

  @override
  String get skipThis => '跳过';

  @override
  String get overwriteRemaining => '覆盖后续所有';

  @override
  String get skipRemaining => '跳过后续所有';

  @override
  String get invalidBackupFile => '无效的备份文件';

  @override
  String get exportLogs => '导出日志';

  @override
  String get exportLogsSuccess => '日志已成功导出';

  @override
  String get exportLogsFailed => '导出日志失败';

  @override
  String get noLogFileFound => '未找到日志文件';

  @override
  String get uiDisplayScale => '界面显示缩放';

  @override
  String get uiDisplayScaleDescription => '全局调整所有界面组件与文字大小，适配车机大屏';

  @override
  String get uiDisplayScaleDialogTitle => '界面显示缩放 / 车机模式';

  @override
  String uiDisplayScaleCurrent(int percent) {
    return '当前缩放: $percent%';
  }

  @override
  String get audioSettings => '音频设置';

  @override
  String get audioSettingsDescription => '管理音频播放、均衡器频段与播放速度相关配置';

  @override
  String get equalizerBandCount => '均衡器频段数量';

  @override
  String get equalizerBandCountDescription => '设置均衡器面板显示的频段数量，高频段模式将自动开启平滑横向滚动';

  @override
  String bandsCountOption(int count) {
    return '$count 段';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'Vynody';

  @override
  String get alwaysOnTop => '置頂';

  @override
  String get systemMediaLibrary => '系統媒體庫';

  @override
  String get scanningDirectory => '正在掃描目錄...';

  @override
  String filesPreprocessed(Object count) {
    return '已預處理 $count';
  }

  @override
  String filesDiscovered(Object count) {
    return '已發現 $count';
  }

  @override
  String filesFullyProcessed(Object count) {
    return '已完整處理 $count';
  }

  @override
  String get directoryAddedSuccess => '目錄新增成功';

  @override
  String get directoryAddedNoMusic => '目錄已新增，但未發現可播放的音訊檔案';

  @override
  String get scanDirectory => '掃描目錄';

  @override
  String get sort => '排序';

  @override
  String get addRootDirectory => '新增根目錄';

  @override
  String get goBack => '返回上一層';

  @override
  String get noMediaLibraryPermission => '未取得媒體庫存取權限';

  @override
  String get grantPermission => '授予權限';

  @override
  String get needPermissionToScan => '需授予權限以掃描本地音樂';

  @override
  String get rebuildTagDatabase => '重建標籤資料庫';

  @override
  String get rebuildDatabase => '重建資料庫';

  @override
  String get confirmRebuildDatabase =>
      '確定要手動重新整理所有歌曲的標籤資訊嗎？這可能需要一些時間來重新載入封面和中繼資料。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確定';

  @override
  String get rebuildingDatabase => '正在重建歌曲標籤資料庫...';

  @override
  String get sortBy => '排序方式';

  @override
  String get sortScope => '作用範圍';

  @override
  String get sortOrder => '排序順序';

  @override
  String get title => '標題';

  @override
  String get fileName => '檔案名稱';

  @override
  String get trackNumber => '曲目號碼';

  @override
  String get ascending => '遞增';

  @override
  String get descending => '遞減';

  @override
  String get currentFolderScope => '目前目錄';

  @override
  String get globalScope => '全域';

  @override
  String get visualizerSettings => '播放頁設定';

  @override
  String get algorithm => '頻譜';

  @override
  String get appearance => '外觀';

  @override
  String get spectrumAppearanceGroup => '頻譜外觀';

  @override
  String get spectrumAdvancedOptions => '頻譜進階選項';

  @override
  String get resetAlgorithm => '重設演算法';

  @override
  String get resetAppearance => '重設外觀';

  @override
  String get smoothing => '平滑係數 (Smoothing)';

  @override
  String get gravity => '重力係數 (Gravity)';

  @override
  String get logScale => '對數縮放 (Log Scale)';

  @override
  String get contrast => '對比度 (Contrast)';

  @override
  String get normalization => '正規化 (Normalization)';

  @override
  String get multiplier => '增益 (Multiplier)';

  @override
  String get skipHighFrequency => '略過高頻';

  @override
  String get frequencyGroups => '頻率分組 (Frequency Groups)';

  @override
  String get aggregationMode => '聚合模式 (Aggregation Mode)';

  @override
  String get opacity => '不透明度 (Opacity)';

  @override
  String get enableGradient => '啟用漸層色';

  @override
  String get startColor => '起始顏色';

  @override
  String get endColor => '結束顏色';

  @override
  String get gradientRangeStop1 => '漸層範圍 Stop 1';

  @override
  String get gradientRangeStop2 => '漸層範圍 Stop 2';

  @override
  String get gradientRepeatMode => '漸層重複模式 (TileMode)';

  @override
  String get color => '顏色';

  @override
  String get followCoverColor => '跟隨封面變色';

  @override
  String get selectColor => '選擇顏色';

  @override
  String get volume => '音量';

  @override
  String get clearQueue => '清空佇列';

  @override
  String get confirmClearQueue => '確定要清空目前的佇列嗎？';

  @override
  String get queueCleared => '佇列已清空';

  @override
  String get locateCurrentSong => '定位目前播放';

  @override
  String get songNotInScannedFolders => '目前歌曲不在掃描的目錄中';

  @override
  String get queue => '佇列';

  @override
  String get queueEmpty => '佇列為空';

  @override
  String selectedSongs(int count) {
    return '已選擇 $count 首';
  }

  @override
  String get unknownArtist => '未知藝術家';

  @override
  String deletedSongs(int count) {
    return '已刪除 $count 首歌曲';
  }

  @override
  String get delete => '刪除';

  @override
  String get createPlaylist => '建立播放清單';

  @override
  String get playlistName => '播放清單名稱';

  @override
  String get enterPlaylistName => '請輸入播放清單名稱';

  @override
  String get playlistNameExists => '播放清單名稱已存在';

  @override
  String get renamePlaylist => '重新命名播放清單';

  @override
  String get deletePlaylist => '刪除播放清單';

  @override
  String confirmDeletePlaylist(String name) {
    return '確定要刪除播放清單「$name」嗎？';
  }

  @override
  String get addToPlaylist => '新增到播放清單';

  @override
  String get selectAll => '全選';

  @override
  String get addToQueue => '新增到佇列';

  @override
  String get addedToQueue => '已新增到佇列';

  @override
  String songCount(int count) {
    return '$count 首歌曲';
  }

  @override
  String addedToPlaylist(int count, String playlist) {
    return '已新增 $count 首歌曲到 $playlist';
  }

  @override
  String get createNewList => '新增清單';

  @override
  String createdPlaylist(String name, int count) {
    return '已建立播放清單「$name」並新增 $count 首歌曲';
  }

  @override
  String get rename => '重新命名';

  @override
  String get playlist => '播放清單';

  @override
  String get mostPlayed => '最多播放';

  @override
  String get recentlyAdded => '最近新增';

  @override
  String get albums => '專輯';

  @override
  String get artists => '藝術家';

  @override
  String get mostPlayedDescription => '依有效播放次數排序';

  @override
  String get recentlyAddedDescription => '依進入媒體庫的時間排序';

  @override
  String get allTime => '所有時間';

  @override
  String get pastWeek => '過去一週';

  @override
  String get pastMonth => '過去一個月';

  @override
  String get past90Days => '過去三個月';

  @override
  String get noPlayHistory => '還沒有播放記錄';

  @override
  String get noPlayHistoryInRange => '這個時間範圍內還沒有播放記錄';

  @override
  String get noRecentlyAddedSongs => '媒體庫中還沒有歌曲';

  @override
  String get noRecentlyAddedInRange => '這個時間範圍內沒有新新增的歌曲';

  @override
  String get addedOn => '新增時間';

  @override
  String get lastPlayed => '最近播放';

  @override
  String playCountLabel(int count) {
    return '$count 次';
  }

  @override
  String get playAll => '播放全部';

  @override
  String get shufflePlay => '隨機播放';

  @override
  String get noAlbums => '還沒有可顯示的專輯';

  @override
  String get noArtists => '還沒有可顯示的藝術家';

  @override
  String get searchAlbums => '搜尋專輯或藝術家';

  @override
  String get searchArtists => '搜尋藝術家';

  @override
  String get albumSort => '排序';

  @override
  String get sortArtistAsc => '藝術家 A-Z';

  @override
  String get sortTitleAsc => '專輯名稱 A-Z';

  @override
  String get sortTrackCount => '歌曲數量';

  @override
  String get sortDuration => '總時長';

  @override
  String get sortRecentAdded => '最近新增';

  @override
  String get sortAscending => '遞增';

  @override
  String get sortDescending => '遞減';

  @override
  String get playNext => '下一首播放';

  @override
  String get addToFavorites => '加入收藏';

  @override
  String get removeFromFavorites => '取消收藏';

  @override
  String get viewAlbumDetails => '檢視專輯詳情';

  @override
  String get viewArtistDetails => '檢視藝術家詳情';

  @override
  String get openFileLocation => '開啟檔案所在位置';

  @override
  String get copyAlbumTitle => '複製專輯名稱';

  @override
  String get copyArtistName => '複製藝術家名稱';

  @override
  String albumCount(int count) {
    return '$count 張專輯';
  }

  @override
  String get emptyList => '清單為空';

  @override
  String get dragToAddMusic => '拖入檔案或資料夾以新增音樂';

  @override
  String get unknownAlbum => '未知專輯';

  @override
  String get managePlaylists => '管理播放清單';

  @override
  String get createNewPlaylist => '建立新的播放清單';

  @override
  String get defaultList => '預設清單';

  @override
  String get playbackMode => '播放模式';

  @override
  String get playbackOptions => '播放選項';

  @override
  String get setVisualizerDisplay => '設定頻譜顯示';

  @override
  String get noPlaybackContent => '目前沒有播放內容';

  @override
  String get file => '檔案';

  @override
  String get play => '播放';

  @override
  String get list => '媒體庫';

  @override
  String get queueTab => '佇列';

  @override
  String get more => '更多';

  @override
  String get settings => '設定';

  @override
  String get themeMode => '主題';

  @override
  String get themeModeSystem => '跟隨系統';

  @override
  String get themeModeLight => '亮色';

  @override
  String get themeModeDark => '暗色';

  @override
  String get immersiveTabBar => '沉浸式標籤列';

  @override
  String get immersiveTabBarDescription => '滑鼠移動時顯示導覽列，3 秒無操作後隱藏';

  @override
  String get collapseButtonsInLandscapeLyrics => '進入橫屏歌詞模式後收起按鈕';

  @override
  String get collapseButtonsInLandscapeLyricsDescription =>
      '進入橫屏歌詞模式時收起 7 按鈕列、標題左對齊並在右側顯示快捷按鈕';

  @override
  String get sampleStride => '取樣步長';

  @override
  String get sampleStrideDescription => '值越大掃描越快但波形精度越低（預設：4）';

  @override
  String get waveformSegments => '波形分段';

  @override
  String get waveformSegmentsDescription => '要顯示的波形柱數量（預設：80）';

  @override
  String get showDeveloperOptions => '顯示開發人員選項';

  @override
  String get playbackBackground => '播放頁背景';

  @override
  String get playbackRadialGradient => '中心暗色漸層';

  @override
  String get blurIntensity => '模糊強度';

  @override
  String get blurredArtwork => '模糊封面（預設）';

  @override
  String get dynamicMesh => '動態流變';

  @override
  String get solidColor => '純色';

  @override
  String get customImage => '自訂圖片';

  @override
  String get presetColors => '預設顏色';

  @override
  String get customColor => '自訂顏色';

  @override
  String get uploadImage => '選擇圖片';

  @override
  String get normalOpacity => '一般暗色層不透明度';

  @override
  String get lyricsOpacity => '歌詞暗色層不透明度';

  @override
  String get chooseImageError => '選擇圖片失敗';

  @override
  String get noImageSelected => '未選擇圖片';

  @override
  String get unknown => '未知';

  @override
  String get playlistModeSingle => '單曲播放';

  @override
  String get playlistModeSingleLoop => '單曲循環';

  @override
  String get playlistModeQueue => '播放清單';

  @override
  String get playlistModeQueueLoop => '清單循環';

  @override
  String get playlistModeAutoQueueLoop => '自動清單循環';

  @override
  String get visualizer => '視覺化';

  @override
  String get previous => '上一首';

  @override
  String get next => '下一首';

  @override
  String get pause => '暫停';

  @override
  String get autoMode => '自動模式';

  @override
  String get advancedOptions => '進階選項';

  @override
  String get spectrumQuantity => '頻譜數量';

  @override
  String get speed => '速度';

  @override
  String get quantityHigh => '多';

  @override
  String get quantityMedium => '中';

  @override
  String get quantityLow => '少';

  @override
  String get speedFast => '快';

  @override
  String get speedMedium => '中';

  @override
  String get speedSlow => '慢';

  @override
  String get portraitFrequencyGroups => '直向頻譜數量';

  @override
  String get landscapeFrequencyGroups => '橫向頻譜數量';

  @override
  String get portraitGap => '直向頻譜間距';

  @override
  String get landscapeGap => '橫向頻譜間距';

  @override
  String get enableWaveformProgressBar => '啟用波形進度列';

  @override
  String get enableWaveformProgressBarDescription => '使用整首歌曲的波形圖代替標準滑桿';

  @override
  String get waveformLongPressSeekSpeed => '長按波形快進速度';

  @override
  String get waveformLongPressSeekSpeedDescription => '長按波形進度條右側時快進的播放速度（×）';

  @override
  String get enableWaveformLongPressSeek => '啟用長按波形快進';

  @override
  String get enableWaveformLongPressSeekDescription => '長按波形進度條右側區域啟用快進播放';

  @override
  String get randomMode => '隨機模式';

  @override
  String get randomHistory => '隨機歷史';

  @override
  String get randomRange => '隨機範圍';

  @override
  String get randomMethod => '隨機方式';

  @override
  String get currentQueue => '目前佇列';

  @override
  String get globalRange => '全域（包含所有清單歌曲）';

  @override
  String get completeRandom => '完全隨機';

  @override
  String get shuffleRandom => '洗牌隨機';

  @override
  String get randomQueue => '隨機佇列';

  @override
  String get notSelected => '未選擇音樂';

  @override
  String get saveTagsToFile => '儲存標籤至檔案';

  @override
  String get saveCurrentTagsToFile => '儲存目前歌曲標籤至檔案';

  @override
  String get saveQueueTagsToFile => '儲存佇列中所有標籤至檔案';

  @override
  String get tagsSaved => '標籤儲存成功';

  @override
  String tagsSavedCount(Object count) {
    return '標籤已儲存（$count 首）';
  }

  @override
  String get tagsSaveFailed => '儲存標籤失敗';

  @override
  String tagsSaveFailedCount(Object count) {
    return '$count 首儲存失敗';
  }

  @override
  String unsupportedFormat(Object count) {
    return '$count 首歌曲格式不支援儲存標籤（OGG/Opus）';
  }

  @override
  String get unsupportedFormatSingle => '此格式（OGG/Opus）不支援儲存標籤';

  @override
  String get savingTags => '正在儲存標籤...';

  @override
  String get noModifiedTagsToSave => '沒有需要儲存的已修改標籤';

  @override
  String get clearPlaylist => '清空清單';

  @override
  String get copyTitle => '複製標題';

  @override
  String get transcodeAction => '轉碼';

  @override
  String get transcodeSectionTitle => '音訊轉碼';

  @override
  String get transcodeSectionDescription => '設定預設輸出格式與品質預設值。';

  @override
  String get transcodeDefaultFormat => '預設輸出格式';

  @override
  String get transcodeDefaultQuality => '預設品質設定';

  @override
  String get transcodeTitle => '音訊轉碼';

  @override
  String transcodeSongCount(int count) {
    return '$count 首歌曲';
  }

  @override
  String transcodeCompletedCount(int count) {
    return '已完成 $count 個轉碼任務';
  }

  @override
  String transcodeCompletedWithFailures(int success, int total, int failed) {
    return '已完成 $success/$total 個轉碼任務，失敗 $failed 個';
  }

  @override
  String get transcodeFailedGeneric => '轉碼失敗';

  @override
  String get transcodePreparing => '正在準備轉碼...';

  @override
  String transcodeProgress(int current, int total) {
    return '正在轉碼 $current/$total';
  }

  @override
  String get transcoding => '轉碼中...';

  @override
  String get startTranscode => '開始轉碼';

  @override
  String transcodeEngine(Object engine) {
    return '引擎：$engine';
  }

  @override
  String get transcodeUsingSystemFfmpeg => '使用系統 PATH 中的 ffmpeg。';

  @override
  String transcodeUsingCustomFfmpeg(Object path) {
    return '使用自訂 ffmpeg：$path';
  }

  @override
  String get transcodeFormat => '輸出格式';

  @override
  String get transcodeQualityPreset => '品質預設值';

  @override
  String get transcodeQualityLow => '低';

  @override
  String get transcodeQualityMedium => '中';

  @override
  String get transcodeQualityHigh => '高';

  @override
  String get transcodeQualityExtreme => '最高';

  @override
  String get transcodeLosslessPresetHint => '目前的無損格式不使用品質檔位和位元率控制模式。';

  @override
  String get transcodeAdvancedOptions => '進階選項';

  @override
  String get transcodeAdvancedCustomized => '進階參數已被手動修改';

  @override
  String get transcodeAdvancedFollowingPreset => '進階參數跟隨目前預設值';

  @override
  String get transcodeLosslessAdvancedHint => '目前的無損格式僅保留與來源檔案相關的進階選項。';

  @override
  String get transcodeBitRateInvalid => '請輸入有效的位元率';

  @override
  String get transcodeBitRate => '位元率';

  @override
  String get transcodeBitRateMode => '位元率控制模式';

  @override
  String get transcodeEncodingEngine => '編碼引擎';

  @override
  String get transcodeSystemEncoder => 'Media3（系統）';

  @override
  String get transcodeFfmpegRustEncoder => 'FFmpeg（Rust）';

  @override
  String get transcodeAacEncoder => 'AAC 編碼器';

  @override
  String get transcodeSampleRate => '取樣率';

  @override
  String get transcodeChannels => '聲道';

  @override
  String get transcodeResetToPreset => '重設為目前預設值';

  @override
  String get transcodeResetLosslessOptions => '重設無損選項';

  @override
  String get transcodeOutputDirectory => '輸出目錄';

  @override
  String get transcodeOutputPreview => '預覽';

  @override
  String get transcodeChooseDirectory => '選擇目錄';

  @override
  String get transcodeUseSourceDirectory => '使用來源檔案目錄';

  @override
  String get transcodeKeepSource => '保留來源檔案';

  @override
  String get transcodeMono => '單聲道';

  @override
  String get transcodeStereo => '雙聲道';

  @override
  String get openFolderLocation => '開啟資料夾所在位置';

  @override
  String get songTagsSavedToSourceFileAndApp => '歌曲標籤已儲存至來源檔案和 App';

  @override
  String get songTagsSavedToApp => '歌曲標籤已儲存至 App';

  @override
  String get durationZero => '0:00';

  @override
  String get generateLyrics => '生成歌詞';

  @override
  String get generateTimeline => '生成時間軸';

  @override
  String get queueGenerateLyrics => '排隊生成';

  @override
  String get pauseAutoScroll => '暫停自動捲動';

  @override
  String get resumeAutoScroll => '恢復自動捲動';

  @override
  String get translateLyrics => '翻譯歌詞';

  @override
  String get clearLyricsCache => '清除目前歌詞快取';

  @override
  String get clearTranslationCache => '清除目前翻譯快取';

  @override
  String get requery => '重新查詢';

  @override
  String get sleepTimerTitle => '睡眠定時器';

  @override
  String get sleepTimerDescription => '選擇倒數計時，時間到後會暫停播放。';

  @override
  String get sleepTimerRunningTitle => '睡眠定時器執行中';

  @override
  String get sleepTimerRunningDescription => '倒數結束後會自動暫停目前播放。';

  @override
  String get sleepTimerStopAfterCurrentSong => '播放完最後一首歌曲後停止';

  @override
  String get remainingTime => '剩餘時間';

  @override
  String get startCountdown => '開始倒數';

  @override
  String get end => '結束';

  @override
  String get equalizer => '等化器';

  @override
  String get equalizerEnabledStatus => '已啟用高保真調整';

  @override
  String get equalizerDisabledStatus => '已停用';

  @override
  String get effects => '特效';

  @override
  String get playbackSpeed => '播放速度';

  @override
  String get normal => '正常';

  @override
  String get bassBoost => '低音增強';

  @override
  String get preampGain => '前置增益';

  @override
  String get reset => '重設';

  @override
  String get close => '關閉';

  @override
  String get timelineAdjustmentTitle => '手動調整時間軸';

  @override
  String get timelineAdjustmentDescription => '向右拖曳會讓歌詞整體延後，向左拖曳會讓歌詞整體提前。';

  @override
  String timelineOffsetEarlier(Object seconds) {
    return '提前 $seconds 秒';
  }

  @override
  String timelineOffsetLater(Object seconds) {
    return '延後 $seconds 秒';
  }

  @override
  String get timelineOffsetCurrent => '目前偏移：0.0 秒';

  @override
  String get enterAcoustidApiKeyTitle => '填寫 AcoustID API Key';

  @override
  String get acoustidApiKeyDescription => '用於音訊指紋辨識。留空後會恢復使用應用程式內建的預設 key。';

  @override
  String get acoustidApiKeyHint => '貼上你的 AcoustID API Key';

  @override
  String get apiKey => 'API Key';

  @override
  String get save => '儲存';

  @override
  String get enterLyricsTitle => '填寫歌詞';

  @override
  String get lyricsInputHint => '在這裡貼上或輸入歌詞，支援多行文字';

  @override
  String get enterGoogleAiStudioApiKeyTitle => '填寫 Google AI Studio API Key';

  @override
  String get googleAiStudioApiKeyDescription =>
      '用於 Google AI Studio 的歌詞生成、時間軸生成和翻譯。';

  @override
  String get pasteGoogleAiStudioApiKey => '貼上 Google AI Studio API Key';

  @override
  String get enterOpenRouterApiKeyTitle => '填寫 OpenRouter API Key';

  @override
  String get openRouterApiKeyDescription =>
      '用於 OpenRouter 的歌詞生成和時間軸生成，翻譯始終使用 Gemini。';

  @override
  String get pasteOpenRouterApiKey => '貼上 OpenRouter API Key';

  @override
  String get enterGeminiApiKeyTitle => '填寫 Gemini API Key';

  @override
  String get geminiApiKeyDescription => '用於歌詞翻譯。';

  @override
  String get pasteGeminiApiKey => '貼上 Gemini API Key';

  @override
  String get testConnection => '測試連線';

  @override
  String get enterApiKey => '請輸入 API key。';

  @override
  String get testingConnection => '正在測試連線...';

  @override
  String get getKey => '取得 key';

  @override
  String get editSongTagsTitle => '編輯歌曲標籤';

  @override
  String get changeArtwork => '更換封面';

  @override
  String get clearArtwork => '清除封面';

  @override
  String get editSongTagsDescription => '修改後可以只儲存到 App，也可以同步寫回來源檔案。';

  @override
  String get artistLabel => '藝術家';

  @override
  String get albumLabel => '專輯';

  @override
  String get trackNumberLabel => '曲目號碼';

  @override
  String get trackNumberMustBeInteger => '曲目號碼必須是整數';

  @override
  String get leaveBlankKeepsCurrentValue => '留空則清空該項';

  @override
  String get currentFileFormatCannotWriteBack => '目前檔案格式不支援寫回來源檔案，只能儲存到 App。';

  @override
  String get leaveBlankDoesNotClearOriginalValue => '提示：留空會清空對應標籤的值。';

  @override
  String get saveToApp => '儲存到 App';

  @override
  String get saveToSourceFileAndApp => '儲存到來源檔案和 App';

  @override
  String get saveToSourceFileFailed => '儲存到來源檔案失敗，請確認檔案格式支援寫入且檔案未被佔用';

  @override
  String get fileOccupiedByOtherApp => '檔案被其他 App 佔用，無法寫入';

  @override
  String get saveFailed => '儲存失敗，請稍後重試';

  @override
  String apiKeySaved(Object provider) {
    return '$provider API Key 已儲存';
  }

  @override
  String get apiKeySavedAcoustid => 'AcoustID API Key 已儲存';

  @override
  String get generalSectionTitle => '介面';

  @override
  String get generalSectionDescription => '這些選項會影響頁面和播放介面的整體顯示方式。';

  @override
  String get interfaceLanguage => '介面語言';

  @override
  String get interfaceLanguageDescription => '選擇軟體的介面顯示語言。';

  @override
  String get scanSectionTitle => '掃描';

  @override
  String get scanSectionDescription => '這些選項會控制媒體庫掃描如何處理音訊檔案。';

  @override
  String get skipShortAudioDuringScan => '掃描時略過短音訊';

  @override
  String get skipShortAudioDuringScanDescription => '短於閾值的音訊不會加入媒體庫。';

  @override
  String get shortAudioScanThreshold => '短音訊閾值';

  @override
  String get shortAudioScanThresholdDescription => '短於此時長的檔案會被略過。';

  @override
  String shortAudioScanThresholdValue(Object seconds) {
    return '$seconds 秒';
  }

  @override
  String get shortcutSettingsTitle => '自訂快捷鍵';

  @override
  String get shortcutSettingsDescription => '點選後可以為播放器操作重新錄製快捷鍵並儲存。';

  @override
  String get edit => '編輯';

  @override
  String get lyricsSectionTitle => '歌詞';

  @override
  String get lyricsSectionDescription => '這裡的設定只影響歌詞生成和時間軸生成。';

  @override
  String get lyricsTranslationTargetLanguageLabel => '翻譯目標語言';

  @override
  String get lyricsTranslationTargetLanguageDescription => '預設跟隨系統語言，也可以單獨指定。';

  @override
  String get lyricsSaveMethodLabel => '歌詞儲存位置';

  @override
  String get lyricsSaveMethodDescription => '選擇將歌詞寫入檔案時的儲存位置。';

  @override
  String get lyricsSaveMethodOriginal => '原處';

  @override
  String get lyricsSaveMethodEmbedded => '內嵌';

  @override
  String get lyricsSaveMethodLrcFile => 'LRC 檔案';

  @override
  String get lyricsStyleLabel => '歌詞面板樣式';

  @override
  String get lyricsStyleDescription => '選擇歌詞面板的展示和互動樣式。';

  @override
  String get lyricsStyleTraditional => '傳統捲動';

  @override
  String get lyricsStyleApple => '逐行聚焦';

  @override
  String get resumeLyricsSync => '恢復歌詞同步';

  @override
  String get followSystemLanguage => '跟隨系統';

  @override
  String get autoSwitchLyricsProvider => '自動切換歌詞供應商';

  @override
  String get autoSwitchLyricsProviderEnabledDesc =>
      '開啟後會先請求 Google AI Studio；主要模型和備用模型都因 429 或 5xx 失敗時，再自動切換到 OpenRouter 繼續請求。';

  @override
  String get autoSwitchLyricsProviderDisabledDesc =>
      '請先同時填寫 Google AI Studio 和 OpenRouter 的 API Key，才可以開啟自動切換。';

  @override
  String get lyricsAiProviderTitle => '歌詞生成 AI 提供方';

  @override
  String get lyricsAiProviderDescription =>
      '這裡只影響歌詞生成和時間軸生成。翻譯始終使用 Google AI Studio。';

  @override
  String get googleAiStudioApiKeySaved => 'Google AI Studio API Key 已儲存';

  @override
  String get googleAiStudioApiKeyMissing =>
      '目前未儲存 Google AI Studio key，歌詞生成和時間軸生成會先彈窗提示。';

  @override
  String get openRouterApiKeySaved => 'OpenRouter API Key 已儲存';

  @override
  String get openRouterApiKeyMissing =>
      '目前未儲存 OpenRouter key，歌詞生成和時間軸生成會先彈窗提示。';

  @override
  String get apiKeySavedStatus => '已儲存';

  @override
  String get apiKeyMissingStatus => '未填寫';

  @override
  String get platformApiKeysSectionTitle => '平台 API Key';

  @override
  String get fill => '填寫';

  @override
  String get modify => '修改';

  @override
  String get geminiModelsSectionTitle => '選擇模型';

  @override
  String get geminiModelsSectionDescription =>
      '這些模型會用於 Google AI Studio 的歌詞生成、時間軸生成以及歌詞翻譯。';

  @override
  String get primaryModelLabel => '主要模型';

  @override
  String get backupModelLabel => '備用模型';

  @override
  String get translationModelLabel => '翻譯模型';

  @override
  String get fetching => '取得中...';

  @override
  String get fetchModelList => '取得模型清單';

  @override
  String get restoreDefault => '恢復預設';

  @override
  String get acoustidSectionTitle => '聽歌辨識';

  @override
  String get acoustidApiKeyTitle => 'AcoustID API Key';

  @override
  String get acoustidApiKeyHelp => 'AcoustID 用於聽歌辨識，建議使用你自己的 API Key。';

  @override
  String get acoustidApiKeySaved => 'AcoustID API Key 已儲存';

  @override
  String get acoustidApiKeyDefault => '目前使用應用程式內建的預設 key，建議申請你自己的 key 後替換。';

  @override
  String get applyForApiKey =>
      '申請 API key: https://acoustid.org/new-application';

  @override
  String get queueTabBarFavoriteAdded => '已加入收藏';

  @override
  String get queueTabBarFavoriteRemoved => '已取消收藏';

  @override
  String get tagCompletion => '歌曲標籤補全';

  @override
  String get tagCompletionDescription => '根據 AcoustID 和 MusicBrainz 結果比對標籤';

  @override
  String get goToSettings => '前往設定頁';

  @override
  String get searchReleaseTitles => '搜尋 release 標題';

  @override
  String get closeSearch => '關閉搜尋';

  @override
  String get refreshResults => '重新整理結果';

  @override
  String get filterMusicBrainzReleaseTitle => '篩選 MusicBrainz release 標題';

  @override
  String get clearSearch => '清空搜尋';

  @override
  String get localTitle => '本地標題';

  @override
  String get queryConditions => '查詢條件';

  @override
  String get musicBrainzLoading => '正在查詢 MusicBrainz';

  @override
  String get musicBrainzLoadingWithResults => '現有結果會先保留在面板裡';

  @override
  String get musicBrainzLoadingHint => '請稍候';

  @override
  String get musicBrainzQueryFailed => 'MusicBrainz 查詢失敗';

  @override
  String get musicBrainzNetworkErrorHint =>
      'MusicBrainz 請求失敗，通常是網路連線不穩定、逾時或被伺服器端拒絕。可以稍後重試。';

  @override
  String get musicBrainzFilteredEmptyHint => '目前篩選條件下沒有包含該關鍵字的 release 標題。';

  @override
  String get musicBrainzEmptyHint =>
      'MusicBrainz 沒有傳回可用結果。可以放寬標題、藝人或專輯條件後再試一次。';

  @override
  String get musicBrainzEmptyMoreCompleteHint => '可以稍後重試，或者確認目前歌曲標題／藝人資訊是否更完整。';

  @override
  String get retry => '重試';

  @override
  String get noMatchingRelease => '沒有找到符合的 release';

  @override
  String get noMatchingResults => '沒有找到符合結果';

  @override
  String get networkConnectionFailed => '網路連線失敗';

  @override
  String get searchAgain => '重新搜尋';

  @override
  String get acoustidRecognitionRecords => 'AcoustID 辨識記錄';

  @override
  String get musicBrainzRecordings => 'MusicBrainz 錄音';

  @override
  String get noExpandableReleaseGroups => '沒有可展開的發行版分組';

  @override
  String get noExpandableReleases => '沒有可展開的發行版';

  @override
  String get noMatchingResultHint => '可以稍後重試，或者確認目前歌曲標題／藝人資訊是否更完整。';

  @override
  String releaseCountLabel(int count) {
    return '$count 個發行版';
  }

  @override
  String recordingCountLabel(int count) {
    return '$count 條錄音';
  }

  @override
  String trackCountShort(int count) {
    return '$count 首';
  }

  @override
  String scoreLabel(int score) {
    return '評分 $score';
  }

  @override
  String matchScoreLabel(int score) {
    return '符合度 $score%';
  }

  @override
  String get editQueryCondition => '編輯查詢條件';

  @override
  String get enterNewQueryText => '輸入新的查詢文字';

  @override
  String get durationLabel => '時長';

  @override
  String get customShortcuts => '自訂快捷鍵';

  @override
  String get pressShortcutCombo => '請按下組合鍵';

  @override
  String get clickToRecord => '點選錄製';

  @override
  String get searchingLyrics => '正在尋找歌詞';

  @override
  String get noLyrics => '暫無歌詞';

  @override
  String get providerLabel => '供應商';

  @override
  String get modelLabel => '模型';

  @override
  String get unspecified => '未指定';

  @override
  String targetTimeLabel(String duration) {
    return '目標時間 $duration';
  }

  @override
  String get songDeletedSkipped => '歌曲已刪除，已略過';

  @override
  String get songDeleted => '歌曲已刪除';

  @override
  String get lyricsTaskUploading => '上傳中';

  @override
  String get lyricsTaskWaiting => '等待就緒';

  @override
  String get lyricsTaskRequesting => '請求中';

  @override
  String get lyricsTaskGenerating => '生成中';

  @override
  String get lyricsTaskRetrying => '重試中';

  @override
  String get lyricsTaskProcessing => '正在處理';

  @override
  String get unknownModel => '未知模型';

  @override
  String selectedFolders(int count) {
    return '已選取 $count 個目錄';
  }

  @override
  String foldersDeleted(int count) {
    return '已刪除 $count 個目錄';
  }

  @override
  String get persistentAccessDenied => '無法儲存該目錄的存取權限，請重新選擇一次';

  @override
  String get folderAddFailed => '目錄新增失敗';

  @override
  String get sleepTimer => '睡眠定時器';

  @override
  String sleepTimerRemaining(Object duration) {
    return '睡眠定時器 $duration';
  }

  @override
  String get unknownArtistOrAlbum => '未知';

  @override
  String get pressAgainToExit => '再按一次離開應用程式';

  @override
  String get tagCompletionSuccessWithCover => '標籤已補全並儲存，封面已下載到暫存目錄';

  @override
  String get tagCompletionSuccess => '標籤已補全並儲存';

  @override
  String get selectOnlineLyrics => '選擇線上歌詞';

  @override
  String get increaseLyricsFont => '增大歌詞文字';

  @override
  String get decreaseLyricsFont => '減小歌詞文字';

  @override
  String get restoreDefaultSize => '恢復預設大小';

  @override
  String get adjustLyricsFont => '調整文字大小';

  @override
  String get searchingOnlineLyrics => '正在查詢線上歌詞';

  @override
  String get onlineLyricsResults => '線上歌詞結果';

  @override
  String get untitledLyrics => '未命名歌詞';

  @override
  String get hasTimeline => '附時間軸';

  @override
  String get viewLyricsDetails => '檢視歌詞詳情';

  @override
  String get lyricsDetails => '歌詞詳情';

  @override
  String get lyricsContent => '歌詞內容';

  @override
  String get noLyricsContent => '無歌詞內容';

  @override
  String get queryContentLabel => '內容';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String dropAddedSongs(int addedCount) {
    return '已新增 $addedCount 首歌曲';
  }

  @override
  String dropAddedSongsWithExisting(int addedCount, int existingCount) {
    return '已新增 $addedCount 首歌曲，$existingCount 首已存在';
  }

  @override
  String get copyCover => '複製封面到剪貼簿';

  @override
  String get copyCoverSuccess => '已成功複製封面';

  @override
  String get searchLyricsPlaceholder => '輸入歌名、歌手或歌詞進行搜尋';

  @override
  String get share => '共用';

  @override
  String get windowsSettingsTitle => 'Windows 專屬設定';

  @override
  String get fileAssociationTitle => '檔案開啟方式關聯';

  @override
  String get fileAssociationDescription =>
      '將常見的音樂格式（mp3、flac、wav 等）關聯到此應用程式，支援按兩下直接開啟播放。';

  @override
  String get associateButton => '一鍵關聯';

  @override
  String get disassociateButton => '移除關聯';

  @override
  String get associationSuccess =>
      '關聯成功！若按兩下檔案未生效，請在 Windows 系統設定的【預設應用程式】中選擇 Vynody。';

  @override
  String get disassociationSuccess => '已成功清除檔案關聯。';

  @override
  String associationFailed(Object error) {
    return '關聯失敗：$error';
  }

  @override
  String get onboardingTitle => '歡迎使用 Vynody';

  @override
  String get onboardingSubtitle => '只需幾個簡單步驟，即可開始你的音樂之旅。';

  @override
  String get onboardingStepFileAssociation => '關聯檔案開啟方式';

  @override
  String get onboardingFileAssociationDesc =>
      '將常見的音樂格式（mp3、flac、wav 等）與 Vynody 關聯，在檔案總管中按兩下即可直接播放。';

  @override
  String get onboardingFileAssociationTip =>
      '關聯後，系統可能會彈出選擇預設開啟程式的對話方塊。請務必在清單中選擇「Vynody」並設為始終使用。';

  @override
  String get onboardingStepRootDirectory => '新增音樂根目錄';

  @override
  String get onboardingRootDirectoryDesc =>
      '選擇存放音樂檔案的資料夾。Vynody 會自動掃描並建立你的本地音樂庫。';

  @override
  String get onboardingAndroidPermissionTip =>
      '注意：Android 系統在匯入與掃描本地歌曲時需要授予媒體庫存取權限。點擊【選擇資料夾】時將觸發權限請求，請予以允許。';

  @override
  String get onboardingSelectDirectory => '選擇資料夾';

  @override
  String get onboardingSuccessTitle => '一切準備就緒！';

  @override
  String get onboardingSuccessDesc => '已成功新增媒體庫。讓我們開始享受音樂吧！';

  @override
  String get onboardingStartButton => '進入 Vynody';

  @override
  String get onboardingSkip => '稍後設定';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingBack => '上一步';

  @override
  String get resetOnboarding => '重設新手引導';

  @override
  String get resetOnboardingDesc => '清除首次啟動引導狀態，下次啟動應用程式時重新顯示新手引導。';

  @override
  String get songProperties => '歌曲屬性';

  @override
  String get failedToLoadDetails => '無法取得詳細資訊';

  @override
  String get noPropertiesAvailable => '暫無歌曲詳細屬性';

  @override
  String get detailFilePath => '檔案路徑';

  @override
  String get detailFormat => '格式';

  @override
  String get detailCodec => '編碼';

  @override
  String get detailDuration => '時長';

  @override
  String get detailFileSize => '檔案大小';

  @override
  String get detailBitrate => '位元率';

  @override
  String get detailSampleRate => '取樣率';

  @override
  String get detailChannels => '聲道數';

  @override
  String get detailBitDepth => '取樣深度';

  @override
  String get detailMono => '單聲道 (Mono)';

  @override
  String get detailStereo => '立體聲 (Stereo)';

  @override
  String detailChannelsCount(int count) {
    return '$count 聲道';
  }

  @override
  String get localNetworkPermissionDeniedTitle => '區域網路存取受限';

  @override
  String get localNetworkPermissionDeniedMessage =>
      '未偵測到可用的區域網路 IP 位址，或區域網路存取權限被拒絕。\n\n請按照以下步驟操作：\n1. 確保您的裝置已連線到 Wi-Fi 或區域網路。\n2. 確保在系統設定中允許本應用程式存取區域網路：\n   - iOS/macOS：請前往系統的「設定 > 隱私權與安全性 > 區域網路」，開啟「Vynody」的開關。\n   - Windows：請確保已連線到網路，並檢查 Windows 防火牆設定是否允許「Vynody」通過。';

  @override
  String get localNetworkPermissionWindowsMessage =>
      '未偵測到可用的區域網路 IP 位址。\n\n請按照以下步驟操作：\n1. 確保您的裝置已連線到區域網路（Wi-Fi 或乙太網路）。\n2. 如果已連線但仍提示此錯誤，請檢查 Windows 防火牆設定，確保允許「Vynody」通過防火牆存取網路。';

  @override
  String get openSettingsButton => '前往設定';

  @override
  String get closeButton => '關閉';

  @override
  String get copyTranslationResults => '複製翻譯結果';

  @override
  String get writeLyricsToFile => '將歌詞寫入檔案';

  @override
  String get selectLyricSource => '選擇歌詞來源';

  @override
  String get regenerateLyrics => '重新生成歌詞';

  @override
  String get regenerateLyricsConfirmation => '將清空目前歌詞並重新生成，是否繼續？';

  @override
  String get regenerateTimeline => '重新生成時間軸';

  @override
  String get regenerateTimelineConfirmation => '將清空目前時間軸並重新生成，是否繼續？';

  @override
  String get retranslateLyrics => '重新翻譯歌詞';

  @override
  String get retranslateLyricsConfirmation => '將清空目前翻譯並重新翻譯，是否繼續？';

  @override
  String get translationCopiedToClipboard => '已複製翻譯結果到剪貼簿';

  @override
  String get writingLyrics => '正在寫入歌詞...';

  @override
  String get lyricsWrittenToFile => '歌詞寫入檔案成功';

  @override
  String get writeLyricsFailed => '寫入歌詞失敗';

  @override
  String get externalLrcFile => '同名外置 LRC 檔案';

  @override
  String get embeddedLyrics => '音訊內嵌歌詞';

  @override
  String get manuallyAdjustedLyrics => '手動修改的歌詞';

  @override
  String get lrclibOnlineLyrics => 'LrcLib 線上歌詞';

  @override
  String get aiGeneratedLyrics => 'AI 生成的歌詞';

  @override
  String get matchScore => '符合度';

  @override
  String get untitledRelease => '未命名發行版';

  @override
  String get localSongFileNotFoundForGeneration => '本機歌曲檔案不存在，無法生成歌詞。';

  @override
  String get localSongFileNotFoundForTimeline => '本機歌曲檔案不存在，無法生成時間軸。';

  @override
  String get noLyricsForTimelineGeneration => '沒有可用歌詞，無法生成時間軸。';

  @override
  String get noLyricsAvailableForTranslation => '沒有可用於翻譯的歌詞。';

  @override
  String get noCurrentSongAvailable => '沒有可用的目前歌曲。';

  @override
  String get invalidTargetLanguage => '目標語言無效。';

  @override
  String get songAlreadyQueuedForTranslation => '目前歌曲的歌詞任務已在排隊或翻譯中。';

  @override
  String get songAlreadyQueuedForGeneration => '目前歌曲的歌詞任務已在排隊或生成中。';

  @override
  String get songNoLongerExistsForTranslation => '目前歌曲已不存在，無法翻譯歌詞。';

  @override
  String get generationFailed => '生成失敗。';

  @override
  String get generatingLyrics => '正在生成歌詞';

  @override
  String get generatingTimeline => '正在生成時間軸';

  @override
  String get regeneratingLyrics => '正在重新生成歌詞';

  @override
  String get translatingLyrics => '正在翻譯歌詞';

  @override
  String get transcodingSongFile => '正在轉碼歌曲檔案';

  @override
  String get uploadingSongFile => '正在上傳歌曲檔案';

  @override
  String get fileUploadedWaitingForReadiness => '檔案已上傳，正在等待檔案就緒';

  @override
  String get waitingForFileReadiness => '正在等待檔案就緒';

  @override
  String get requestingModelResponse => '正在請求模型回應';

  @override
  String retryingTaskKindGeneration(Object taskKind) {
    return '正在重試生成 $taskKind';
  }

  @override
  String get retrying => '正在重試';

  @override
  String get processing => '正在處理';

  @override
  String get timeline => '時間軸';

  @override
  String get lyrics => '歌詞';

  @override
  String lyricGenerationError(Object error) {
    return '生成歌詞時發生錯誤：$error';
  }

  @override
  String timelineGenerationError(Object error) {
    return '生成時間軸時發生錯誤：$error';
  }

  @override
  String get unknownGenerationError => '生成歌詞時發生未知錯誤。';

  @override
  String get unknownTimelineGenerationError => '生成時間軸時發生未知錯誤。';

  @override
  String get unknownTranslationError => '翻譯歌詞時發生未知錯誤。';

  @override
  String get unknownError => '未知錯誤';

  @override
  String get modelRefusedToGenerateLyrics => '模型拒絕生成歌詞。';

  @override
  String get modelRefusedToGenerateTimeline => '模型拒絕生成時間軸。';

  @override
  String get doubaoPreUploadTranscodingFailed => '豆包上傳前音訊轉碼失敗。';

  @override
  String get doubaoTempTranscodeNotInTempDir => '豆包暫存轉碼檔案未產生在暫存目錄。';

  @override
  String get doubaoEmptyStreamingResponse => '豆包傳回了空串流回應。';

  @override
  String get doubaoEmptyResponse => '豆包傳回了空回應。';

  @override
  String get geminiEmptyStreamingResponse => 'Gemini 傳回了空串流回應。';

  @override
  String get geminiEmptyResponse => 'Gemini 傳回了空回應。';

  @override
  String get openRouterEmptyStreamingResponse => 'OpenRouter 傳回了空串流回應。';

  @override
  String get openRouterEmptyResponse => 'OpenRouter 傳回了空回應。';

  @override
  String get deepseekEmptyStreamingResponse => 'DeepSeek 傳回了空串流回應。';

  @override
  String get deepseekEmptyResponse => 'DeepSeek 傳回了空回應。';

  @override
  String get customProviderEmptyStreamingResponse => '自訂供應商傳回了空串流回應。';

  @override
  String get customProviderEmptyResponse => '自訂供應商傳回了空回應。';

  @override
  String get fileUploadFailed => '檔案上傳失敗，請重試。';

  @override
  String get uploadedFileNotReady => '上傳後的檔案未能就緒，請稍後重試。';

  @override
  String get audioTranscodingFailed => '音訊轉碼失敗。';

  @override
  String get tempTranscodeNotInTempDir => '暫存轉碼檔案未產生在暫存目錄。';

  @override
  String get networkRequestFailedCheckProxy => '網路請求失敗，請檢查網路及代理狀態。';

  @override
  String get quotaExhaustedToday => '今日額度已用完，請等待明日額度恢復再試';

  @override
  String get googleAiHeavyLoad => 'Google AI 服務承載大量請求，暫時無法使用';

  @override
  String lyricsGenerationFailedWithError(Object error) {
    return '生成歌詞失敗：$error';
  }

  @override
  String missingApiKeyForAction(Object action, Object providerName) {
    return '找不到 $providerName API Key，無法$action。';
  }

  @override
  String get googleServerFlaky => 'Google 伺服器暫時有點狀況，重試一下或許就會成功';

  @override
  String get translateLyricsAction => '翻譯歌詞';

  @override
  String get generateLyricsAction => '生成歌詞';

  @override
  String get generateTimelineAction => '生成時間軸';

  @override
  String get deepseekOnlyTranslation => 'DeepSeek 僅支援歌詞翻譯。';

  @override
  String get customProviderOnlyTranslation => '自訂供應商僅支援歌詞翻譯。';

  @override
  String get customProviderNoBaseUrl => '未設定自訂供應商的 Base URL。';

  @override
  String get pleaseEnterApiKey => '請輸入 API key。';

  @override
  String get connectionSuccessVerificationPassed => '連線成功，已通過驗證。';

  @override
  String connectionSuccessDetectedModels(Object count) {
    return '連線成功，偵測到 $count 個模型。';
  }

  @override
  String testFailedWithStatus(Object message, Object statusCode) {
    return '測試失敗（$statusCode）：$message';
  }

  @override
  String get testFailedCheckNetworkOrApiKey => '測試失敗，請檢查網路或 API key。';

  @override
  String testFailedStatusCheckApiKey(Object statusCode) {
    return '測試失敗（$statusCode），請檢查 API key 是否有效。';
  }

  @override
  String get enterGoogleAiStudioApiKeyFirst => '請先填寫 Google AI Studio API Key。';

  @override
  String get enterDoubaoApiKeyFirst => '請先填寫豆包 API Key。';

  @override
  String get enterDeepseekApiKeyFirst => '請先填寫 DeepSeek API Key。';

  @override
  String get enterCustomApiKeyAndBaseUrl => '請先填寫自訂 API Key 和 Base URL。';

  @override
  String fetchedCountModels(Object count) {
    return '已取得 $count 個模型。';
  }

  @override
  String requestFailedWithStatus(Object message, Object statusCode) {
    return '請求失敗（$statusCode）：$message';
  }

  @override
  String get requestFailedCheckNetwork => '請求失敗，請檢查網路。';

  @override
  String requestFailedStatus(Object statusCode) {
    return '請求失敗（$statusCode）。';
  }

  @override
  String get doubao => '豆包';

  @override
  String get custom => '自訂';

  @override
  String get noModelSelected => '未選擇模型';

  @override
  String get acoustidRequestFailed => 'AcoustID 請求失敗';

  @override
  String acoustidRequestReturnedStatus(Object statusCode) {
    return 'AcoustID 請求傳回 $statusCode。請申請你自己的 AcoustID API key 並填入設定頁。';
  }

  @override
  String get writeTagDatabaseFailed => '寫入標籤資料庫失敗';

  @override
  String get playPause => '播放／暫停';

  @override
  String get nextTrack => '下一首';

  @override
  String get previousTrack => '上一首';

  @override
  String get volumeUp => '音量增加';

  @override
  String get volumeDown => '音量減少';

  @override
  String get toggleMute => '切換靜音';

  @override
  String get seekForward5s => '快轉 5 秒';

  @override
  String get seekBackward5s => '倒轉 5 秒';

  @override
  String get toggleFullScreen => '切換全螢幕';

  @override
  String get playPauseDescription => '控制目前播放狀態。';

  @override
  String get nextDescription => '切換到下一首歌曲。';

  @override
  String get previousDescription => '切換到上一首歌曲。';

  @override
  String get volumeUpDescription => '每次增加 5% 音量。';

  @override
  String get volumeDownDescription => '每次減少 5% 音量。';

  @override
  String get toggleMuteDescription => '切換靜音。';

  @override
  String get seekForward5sDescription => '向前快轉 5 秒。';

  @override
  String get seekBackward5sDescription => '向後倒轉 5 秒。';

  @override
  String get toggleFullScreenDescription => '在視窗模式和全螢幕模式之間切換。';

  @override
  String get unknownKey => '未知按鍵';

  @override
  String get removeFromQueue => '從佇列中移除';

  @override
  String get removeFromPlaylist => '從歌單中移除';

  @override
  String get alreadyLatestVersion => '目前已經是最新版本。';

  @override
  String get updateAvailable => '發現新版本';

  @override
  String newVersionAvailable(Object version) {
    return '偵測到新版本 v$version，前往 GitHub Release 頁面下載更新。';
  }

  @override
  String get openRelease => '前往 Release';

  @override
  String get checkUpdateFailedNetwork => '檢查更新失敗，可能是網路問題或 GitHub 限流。';

  @override
  String get tags => '標籤';

  @override
  String get about => '關於';

  @override
  String get rebuildIndex => '重建索引';

  @override
  String get rebuildIndexDescription => '清空除外部來源以外的所有歌曲記錄並重新掃描所有根目錄。';

  @override
  String get rebuildIndexConfirmation =>
      '確認清空除外部來源以外的所有歌曲記錄並重新掃描所有根目錄嗎？此操作需要一些時間。';

  @override
  String get rebuildIndexStarted => '重建索引已啟動';

  @override
  String get rebuild => '重建';

  @override
  String get advanced => '進階';

  @override
  String get advancedOptionsDescription => '偏向偵錯和行為控制的選項。';

  @override
  String get showDeveloperOptionsDescription => '顯示更多偏向偵錯用途的進階選項。';

  @override
  String get onboardingReset => '已重設新手引導狀態，下次啟動時生效。';

  @override
  String get tagsSectionDescription => '關於音訊檔案中繼資料和自動補全的設定。';

  @override
  String get autoSaveToSourceFile => '自動寫入來源檔案';

  @override
  String get autoSaveToSourceFileDescription => '補全或更新歌曲標籤時，預設同步寫入實體音訊檔案。';

  @override
  String get aboutSectionDescription => '版本資訊、專案連結和相關資料。';

  @override
  String get checkForUpdates => '檢查更新';

  @override
  String get lyricsGenerationModel => '歌詞生成模型';

  @override
  String get lyricsGenerationModelDescription =>
      '用於 AI 聽歌生成歌詞，以及為現有歌詞生成／修正時間軸。';

  @override
  String get lyricsTranslationModel => '歌詞翻譯模型';

  @override
  String get lyricsTranslationModelDescription => '用於將歌詞翻譯到目標語言。';

  @override
  String get onlyForLyricTranslation => '僅用於歌詞翻譯';

  @override
  String get fillApiKeyFirstEnablesModels => '請先填寫至少一個 API Key，模型選擇才會啟用。';

  @override
  String get customApiProvider => '自訂 API 供應商';

  @override
  String get clearedGoogleAiStudioApiKey => '已清空 Google AI Studio API Key';

  @override
  String get clearedOpenRouterApiKey => '已清空 OpenRouter API Key';

  @override
  String get clearedDoubaoApiKey => '已清空豆包 API Key';

  @override
  String get clearedDeepseekApiKey => '已清空 DeepSeek API Key';

  @override
  String get clearedCustomProviderConfig => '已清空自訂供應商設定';

  @override
  String get savedDoubaoApiKey => '已儲存豆包 API Key';

  @override
  String get savedDeepseekApiKey => '已儲存 DeepSeek API Key';

  @override
  String get savedCustomProviderConfig => '已儲存自訂供應商設定';

  @override
  String get noMatchingFoldersOrSongs => '找不到符合的資料夾或歌曲';

  @override
  String get searching => '正在搜尋...';

  @override
  String get listView => '清單檢視';

  @override
  String get gridView => '格線檢視';

  @override
  String get hybridView => '混合檢視';

  @override
  String songsCountFormat(Object count) {
    return '$count 首歌曲';
  }

  @override
  String get searchInFolderAndSubfolders => '在目前目錄及子目錄下搜尋...';

  @override
  String get shuffle => '隨機播放';

  @override
  String get search => '搜尋';

  @override
  String get selectFolders => '選擇目錄';

  @override
  String get removeDirectory => '移除目錄';

  @override
  String removeRootDirectoryConfirmation(Object name) {
    return '確定要移除根目錄「$name」嗎？此操作不會刪除磁碟上的實體檔案。';
  }

  @override
  String get deselectAll => '取消全選';

  @override
  String get favorites => '收藏';

  @override
  String get aggregationPeak => '峰值';

  @override
  String get aggregationMean => '平均值';

  @override
  String get aggregationRms => '均方根';

  @override
  String get filesToTranscode => '待轉碼檔案';

  @override
  String get chooseAndroidOutputDirectoryFirst => '請先選擇一個 Android 輸出目錄。';

  @override
  String currentSongProgressPercent(Object percent) {
    return '目前歌曲 $percent%';
  }

  @override
  String overallProgressPercent(Object percent) {
    return '整體 $percent%';
  }

  @override
  String get pleaseChooseOutputDirectory => '請先選擇一個輸出目錄。';

  @override
  String selectedArtistsCount(Object count) {
    return '已選擇 $count 位藝術家';
  }

  @override
  String selectedAlbumsCount(Object count) {
    return '已選擇 $count 張專輯';
  }

  @override
  String get simplifiedChinese => '簡體中文';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get chineseLanguage => '中文';

  @override
  String get englishLanguage => '英文';

  @override
  String get japaneseLanguage => '日文';

  @override
  String get koreanLanguage => '韓文';

  @override
  String get frenchLanguage => '法文';

  @override
  String get germanLanguage => '德文';

  @override
  String get spanishLanguage => '西班牙文';

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
  String get portugueseLanguage => '葡萄牙文';

  @override
  String get russianLanguage => '俄文';

  @override
  String get systemLanguage => '系統語言';

  @override
  String get targetLanguage => '目標語言';

  @override
  String get whatAreAiLyrics => '什麼是 AI 歌詞？';

  @override
  String get whatIsAiLyricTranslation => '什麼是 AI 歌詞翻譯？';

  @override
  String get aiLyricsIntroGeneration => 'AI 可以根據歌曲內容生成歌詞，並自動比對時間軸。';

  @override
  String get aiLyricsIntroTranslation => 'AI 可以將歌詞翻譯成你熟悉的語言，方便理解歌曲內容。';

  @override
  String get whyNeedApiKey => '為什麼需要 API Key？';

  @override
  String get apiKeyExplanation =>
      'API Key 相當於你在 AI 服務商那裡的存取憑證。應用程式會用它直接向服務商發起請求，完成歌詞生成、時間軸調整或翻譯。';

  @override
  String get apiKeyLocalOnly => 'API Key 只儲存在你的本機裝置，不會上傳到 Vynody 開發者伺服器。';

  @override
  String get chooseAnAiProvider => '選擇一個 AI 服務商：';

  @override
  String get googleProviderPros => 'Google 官方管道，Gemini 模型能力強，免費額度較多。';

  @override
  String get googleProviderCons =>
      '中國大陸直連受限，需要穩定的 VPN／代理。請求人數較多時可能回報 429，遇到 429 請切換到其他管道。';

  @override
  String get openRouterProviderPros => '海外大模型聚合平台，可使用多個模型，也有部分免費模型。';

  @override
  String get openRouterProviderCons => '儲值需支付手續費，網頁只有英文。';

  @override
  String get doubaoProviderPros =>
      '字節跳動出品，國內存取快速，中文效果好。新使用者每個模型有 50 萬免費 token。';

  @override
  String get doubaoProviderCons => '註冊步驟相對繁瑣，需要實名認證。';

  @override
  String get deepseekProviderPros => '中文理解好，價格便宜，適合歌詞翻譯。';

  @override
  String get deepseekProviderCons => '僅支援文字輸入。如需歌詞生成、時間軸調整，需要填入其他管道 API Key。';

  @override
  String get highlights => '【特點】';

  @override
  String get notes => '【注意事項】';

  @override
  String enterProviderApiKey(Object provider) {
    return '請輸入 $provider 的 API Key：';
  }

  @override
  String get pasteYourApiKey => '在此貼上你的 API Key';

  @override
  String get getApiKey => '取得 API Key';

  @override
  String get testConnectionButton => '測試連線';

  @override
  String get enableAiLyricGeneration => '啟用 AI 歌詞生成';

  @override
  String get enableAiLyricTranslation => '啟用 AI 歌詞翻譯';

  @override
  String get notNow => '暫不啟用';

  @override
  String get startSetup => '開始設定';

  @override
  String get chooseAiProvider => '選擇 AI 服務商';

  @override
  String get backStep => '上一步';

  @override
  String get continueAction => '繼續';

  @override
  String get nextStep => '下一步';

  @override
  String get configureApiKey => '設定 API Key';

  @override
  String get saveAndFinish => '儲存並完成';

  @override
  String get testing => '正在測試...';

  @override
  String get noteTitle => '提示';

  @override
  String get deepseekTextInputOnlyNote =>
      'DeepSeek 僅支援文字輸入。如需歌詞生成、時間軸調整，需要填入其他管道 API Key。';

  @override
  String retryAttemptOfMax(Object attempt, Object maxRetry) {
    return '重試第 $attempt 次／共 $maxRetry 次';
  }

  @override
  String generatingTaskKind(Object taskKind) {
    return '正在生成 $taskKind';
  }

  @override
  String connectionTestException(Object error) {
    return '連線測試異常：$error';
  }

  @override
  String get testingConnectionProgress => '正在測試連線...';

  @override
  String get clear => '清空';

  @override
  String get enterDoubaoApiKey => '輸入豆包 API Key';

  @override
  String get doubaoApiKeyDescription => '請輸入火山方舟／豆包的 API Key，用於歌詞生成和翻譯。';

  @override
  String get enterDeepseekApiKey => '輸入 DeepSeek API Key';

  @override
  String get deepseekApiKeyDescription => '請輸入 DeepSeek 的 API Key，僅用於歌詞翻譯。';

  @override
  String get pleaseEnterApiKeyHint => '請輸入 API Key';

  @override
  String get platform => '平台';

  @override
  String get showRecommendedOnly => '僅顯示推薦模型';

  @override
  String get noAvailableChannels => '暫無可用管道';

  @override
  String get noMatchingModels => '找不到符合的模型';

  @override
  String get leaveEmpty => '留空';

  @override
  String get leaveEmptyFallbackDescription => '不設定備用模型時可選擇此項。';

  @override
  String get modelSearchHint => '輸入模型名稱、ID';

  @override
  String sendFilesFailed(Object error) {
    return '傳送檔案失敗: $error';
  }

  @override
  String get scanningFolderMusic => '正在掃描資料夾中的音樂檔案...';

  @override
  String scanFolderFailed(Object error) {
    return '掃描資料夾失敗: $error';
  }

  @override
  String get noMusicFilesFound => '未在此資料夾中找到支援的音樂檔案';

  @override
  String sendFolderFailed(Object error) {
    return '傳送資料夾失敗: $error';
  }

  @override
  String get lanSharingStartFailed => '區域網路共用啟動失敗，請檢查本機網路權限是否已開啟';

  @override
  String syncingLyricsToDevice(Object deviceName) {
    return '正在向 $deviceName 同步歌詞...';
  }

  @override
  String syncLyricsSuccess(Object matched, Object overwritten, Object skipped) {
    return '同步成功: 符合 $matched 首、更新 $overwritten 首、忽略 $skipped 首';
  }

  @override
  String syncLyricsFailed(Object error) {
    return '同步歌詞失敗: $error';
  }

  @override
  String syncingLyricsFromDevice(Object deviceName) {
    return '正在從 $deviceName 同步歌詞...';
  }

  @override
  String get transferInProgressDoNotLeave => '正在傳輸檔案，請勿離開共用頁面';

  @override
  String get lanSharingTitle => '區域網路檔案共用';

  @override
  String get lanSharingEnabledStatus => '區域網路共用已開啟';

  @override
  String get lanSharingDisabledStatus => '區域網路共用未開啟';

  @override
  String lanSharingRunningStatus(Object ip, Object port) {
    return '本機 IP: $ip（連接埠: $port）';
  }

  @override
  String get lanSharingDefaultOffHint => '預設關閉，開啟後會請求區域網路權限';

  @override
  String get receiveDirectoryNotSetWarning => '未設定接收檔案儲存目錄時將無法接收檔案，建議先設定。';

  @override
  String receiveDirectoryUpdated(Object path) {
    return '接收目錄已更新為: $path';
  }

  @override
  String get receiveDirectoryTitle => '接收檔案儲存目錄';

  @override
  String get webShareTitle => '瀏覽器網頁傳輸 (Web Share)';

  @override
  String get webShareDescription => '同一區域網路的手機／電腦可透過瀏覽器開啟下方連結，直接向本裝置上傳或下載音樂：';

  @override
  String get linkCopiedToClipboard => '連結已複製到剪貼簿';

  @override
  String get nearbyDevices => '附近的裝置';

  @override
  String get searchingDevices => '正在尋找區域網路內其他裝置...';

  @override
  String get startSharingToFindDevices => '開啟共用後開始尋找裝置';

  @override
  String get deviceOnline => '線上';

  @override
  String get deviceOffline => '已中斷';

  @override
  String get sendMusicFiles => '傳送音樂檔案';

  @override
  String get sendFolder => '傳送資料夾';

  @override
  String get syncLyricsToDeviceAction => '同步歌詞至該裝置';

  @override
  String get syncLyricsFromDeviceAction => '從該裝置同步歌詞';

  @override
  String loadDevicesError(Object error) {
    return '載入裝置時出錯: $error';
  }

  @override
  String incomingFilesFormat(Object name1, Object name2, Object count) {
    return '$name1、$name2 等共 $count 個檔案';
  }

  @override
  String get incomingTransferRequestTitle => '收到檔案共用請求';

  @override
  String incomingTransferFrom(Object senderName) {
    return '來自「$senderName」的傳送請求：';
  }

  @override
  String fileSizeMb(Object sizeMb) {
    return '檔案大小: $sizeMb MB';
  }

  @override
  String get receiveFileHint => '提示：接收後檔案將自動儲存至本機音樂資料夾並加入媒體庫。';

  @override
  String get reject => '拒絕';

  @override
  String get accept => '接收';

  @override
  String sendCompleted(Object fileName) {
    return '「$fileName」傳送完畢';
  }

  @override
  String receiveCompleted(int count) {
    return '成功接收了 $count 首歌曲';
  }

  @override
  String transferCancelledWithReason(Object direction, Object reason) {
    return '$direction已取消（$reason）';
  }

  @override
  String transferFailedFormat(Object direction, Object fileName) {
    return '$direction「$fileName」失敗';
  }

  @override
  String sendingToDevice(Object deviceName) {
    return '正在傳送到 $deviceName';
  }

  @override
  String receivingFromDevice(Object deviceName) {
    return '正在從 $deviceName 接收';
  }

  @override
  String progressFormat(Object percent) {
    return '進度: $percent%';
  }

  @override
  String get currentlyTransferring => '目前正在傳輸';

  @override
  String get fileConflictTitle => '檔案衝突';

  @override
  String get fileConflictMessage => '目標裝置已存在同名檔案：';

  @override
  String get fileConflictChooseAction => '請選擇您要執行的操作：';

  @override
  String get skipAction => '略過';

  @override
  String get overwriteAction => '覆寫';

  @override
  String get skipAllAction => '全部略過';

  @override
  String get overwriteAllAction => '全部覆寫';

  @override
  String get sendDirection => '傳送';

  @override
  String get receiveDirection => '接收';

  @override
  String get fileAssociationEnabled => '已開啟關聯';

  @override
  String get fileAssociationDisabled => '未開啟關聯';

  @override
  String get windowsAutoRepairShortcut => '自動修復開始功能表捷徑';

  @override
  String get windowsAutoRepairShortcutDescription =>
      '每次啟動時自動檢查並建立開始功能表捷徑，以正確顯示媒體控制項名稱與圖示';

  @override
  String get confirmDisableShortcutRepair => '確定關閉此功能嗎？';

  @override
  String get confirmDisableShortcutRepairContent =>
      '如果缺少開始功能表捷徑，Windows 媒體控制中心（音量調整彈窗）將會把軟體顯示為「未知應用程式」，並且無法展示應用程式圖示。是否確定關閉此功能？';

  @override
  String get confirmDisable => '確定關閉';

  @override
  String get enableSystemTray => '啟用系統匣';

  @override
  String get enableSystemTrayDescription => '在系統工作列匣中顯示圖示，方便快速控制播放';

  @override
  String get googleAiStudioApiKey => 'Google AI Studio API Key';

  @override
  String get openRouterApiKey => 'OpenRouter API Key';

  @override
  String get doubaoApiKey => '豆包 API Key';

  @override
  String get deepseekApiKey => 'DeepSeek API Key';

  @override
  String get unexpectedResponseFormat => '非預期的回應格式。';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get openaiCompatibleEndpoint => '相容 OpenAI 的 API 端點';

  @override
  String onboardingAddedDirectoriesCount(Object count) {
    return '已新增的目錄（$count）：';
  }

  @override
  String get gnomeDisksOpenFailed => '無法自動開啟磁碟管理員，請在應用程式選單中手動搜尋並開啟「磁碟 (Disks)」';

  @override
  String get gnomeDisksNotInstalled => '系統未安裝 gnome-disks，請手動開啟系統磁碟管理工具進行設定。';

  @override
  String get linuxMountGuideTitle => '設定硬碟自動掛載';

  @override
  String get linuxMountGuideDescription =>
      'Linux 預設設定下不會掛載外接分割區，如果沒有設定啟動時掛載分割區則每次重新啟動時外接分割區的路徑可能發生變化，從而導致播放器存取不到音樂目錄。為了避免這種情況，請將存放音樂的分割區設定為啟動時自動掛載。';

  @override
  String get linuxMountGuideWarning =>
      '注意：如果您的音樂位於需要掛載才能使用的外接／內部硬碟分割區內，請務必將該分割區設定為「開機自動掛載」。否則，每次重新啟動系統後可能會出現找不到音樂目錄，或者需要輸入密碼授權才能存取的問題。';

  @override
  String get linuxMountGuideStep1 => '1. 開啟系統的「磁碟 (Disks)」管理員';

  @override
  String get linuxMountGuideStep2 => '2. 選取包含音樂的分割區，點選 ⚙️ 齒輪圖示（附加分割區選項）';

  @override
  String get linuxMountGuideStep3 => '3. 選擇「編輯掛載選項」，關閉「使用者工作階段預設值」並勾選「系統啟動時掛載」';

  @override
  String get linuxMountGuideOpenButton => '開啟磁碟管理員 (Disks)';

  @override
  String get unmute => '取消靜音';

  @override
  String get mute => '靜音';

  @override
  String get disableSystemTray => '停用系統匣';

  @override
  String get onboardingAndroidBatteryTitle => '背景播放防誤殺設定';

  @override
  String get onboardingAndroidBatteryDescription =>
      '由於 Android 系統的電池管理策略非常嚴格，為了防止音樂在背景播放時被系統強制關閉，建議將 Vynody 的電池使用限制設定為「無限制」（Unrestricted）。';

  @override
  String get onboardingAndroidBatteryStep1 => '1. 點選下方的「前往設定」按鈕。';

  @override
  String get onboardingAndroidBatteryStep2 => '2. 在系統彈窗中允許忽略電池最佳化，或者跳轉到電池設定頁面。';

  @override
  String get onboardingAndroidBatteryStep3 =>
      '3. 如果跳轉至設定清單，選擇「無限制」或「允許背景活動／不限制電池使用」。';

  @override
  String get onboardingAndroidBatteryButton => '前往設定';

  @override
  String get onboardingAndroidBatteryStatusOptimized => '目前狀態：已限制（可能導致背景播放中斷）';

  @override
  String get onboardingAndroidBatteryStatusUnrestricted =>
      '目前狀態：無限制（建議，背景播放已保護）';

  @override
  String get exitApp => '離開';

  @override
  String get showScanProgressToastSetting => '顯示掃描狀態提示';

  @override
  String get showScanProgressToastSettingDescription =>
      '在新增資料夾並進行檔案掃描時，在頂部顯示即時的掃描進度提示';

  @override
  String get openPlaybackOnDirectorySongTap => '點擊歌曲後跳轉到播放頁';

  @override
  String get openPlaybackOnDirectorySongTapDescription =>
      '在目錄頁點擊歌曲播放時，自動跳轉至全螢幕播放介面';

  @override
  String get tapCoverToEnterLyricsMode => '點選封面可以進入歌詞模式';

  @override
  String get longPressLyricsPanelToOpenMenu => '長按歌詞面板可以調出選單';

  @override
  String get gotIt => '我知道了';

  @override
  String get scanToastHiddenHint => '掃描狀態提示已隱藏，可在「設定 - 介面」中重新開啟';

  @override
  String get doubleSpeedPlayingSwipeUpToLock => '快進播放中... 往上滑動鎖定';

  @override
  String get doubleSpeedLockedSwipeDownToUnlock => '已鎖定快進播放。長按並向下滑動解鎖';

  @override
  String get doubleSpeedUnlocked => '已解除快進鎖定';

  @override
  String get lyricsImportExportHeader => '匯入與匯出';

  @override
  String get exportAction => '匯出';

  @override
  String get importAction => '匯入';

  @override
  String get exportLyricsLabel => '匯出歌詞備份';

  @override
  String get exportLyricsDescription => '將所有快取和已調整的歌詞匯出為 JSON 檔案';

  @override
  String get importLyricsLabel => '匯入歌詞備份';

  @override
  String get importLyricsDescription => '從匯出的 JSON 檔案匯入歌詞快取';

  @override
  String exportSuccess(int count) {
    return '成功匯出 $count 首歌詞。';
  }

  @override
  String exportFailed(String error) {
    return '匯出失敗：$error';
  }

  @override
  String importSuccess(int count) {
    return '匯入完成！成功匯入 $count 首歌詞。';
  }

  @override
  String importFailed(String error) {
    return '匯入失敗：$error';
  }

  @override
  String get importConflictsTitle => '匯入衝突';

  @override
  String importConflictsMessage(int conflictCount) {
    return '備份中發現 $conflictCount 首歌詞存在衝突（本地存在但內容不同）。請選擇處理方式：';
  }

  @override
  String get overwriteAll => '全部覆寫';

  @override
  String get skipAllConflicts => '跳過衝突';

  @override
  String get decideOneByOne => '逐一決定';

  @override
  String conflictResolutionTitle(int current, int total) {
    return '解決衝突（$current/$total）';
  }

  @override
  String get conflictExistingLabel => '現有歌詞';

  @override
  String get conflictImportedLabel => '匯入歌詞';

  @override
  String conflictSourceLabel(String source) {
    return '來源：$source';
  }

  @override
  String conflictTimeLabel(String time) {
    return '時間：$time';
  }

  @override
  String get overwriteThis => '覆寫';

  @override
  String get skipThis => '跳過';

  @override
  String get overwriteRemaining => '覆寫所有剩餘項目';

  @override
  String get skipRemaining => '跳過所有剩餘項目';

  @override
  String get invalidBackupFile => '無效的備份檔案';

  @override
  String get exportLogs => '匯出日誌';

  @override
  String get exportLogsSuccess => '日誌已成功匯出';

  @override
  String get exportLogsFailed => '匯出日誌失敗';

  @override
  String get noLogFileFound => '未找到日誌檔案';
}
