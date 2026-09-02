// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Vynody';

  @override
  String get alwaysOnTop => '常に最前面';

  @override
  String get systemMediaLibrary => 'システムメディアライブラリ';

  @override
  String get scanningDirectory => 'ディレクトリをスキャン中...';

  @override
  String filesPreprocessed(Object count) {
    return '前処理済み $count';
  }

  @override
  String filesDiscovered(Object count) {
    return '発見 $count';
  }

  @override
  String filesFullyProcessed(Object count) {
    return '完全処理 $count';
  }

  @override
  String get directoryAddedSuccess => 'ディレクトリを追加しました';

  @override
  String get directoryAddedNoMusic =>
      'ディレクトリを追加しましたが、再生可能なオーディオファイルが見つかりませんでした';

  @override
  String get scanDirectory => 'ディレクトリをスキャン';

  @override
  String get sort => '並び替え';

  @override
  String get addRootDirectory => 'ルートディレクトリを追加';

  @override
  String get goBack => '戻る';

  @override
  String get noMediaLibraryPermission => 'メディアライブラリへのアクセス権限がありません';

  @override
  String get grantPermission => '権限を付与';

  @override
  String get needPermissionToScan => 'ローカル音楽をスキャンするには権限が必要です';

  @override
  String get rebuildTagDatabase => 'タグデータベースを再構築';

  @override
  String get rebuildDatabase => 'データベースを再構築';

  @override
  String get confirmRebuildDatabase =>
      'すべての楽曲タグ情報を手動で更新してもよろしいですか？カバーとメタデータの再読み込みに時間がかかる場合があります。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get rebuildingDatabase => '楽曲タグデータベースを再構築中...';

  @override
  String get sortBy => '並び替え基準';

  @override
  String get sortScope => '範囲';

  @override
  String get sortOrder => '並び順';

  @override
  String get title => 'タイトル';

  @override
  String get fileName => 'ファイル名';

  @override
  String get trackNumber => 'トラック番号';

  @override
  String get ascending => '昇順';

  @override
  String get descending => '降順';

  @override
  String get currentFolderScope => '現在のフォルダ';

  @override
  String get globalScope => '全体';

  @override
  String get visualizerSettings => '再生ページ設定';

  @override
  String get algorithm => 'スペクトラム';

  @override
  String get appearance => '外観';

  @override
  String get spectrumAppearanceGroup => 'スペクトラムの外観';

  @override
  String get spectrumAdvancedOptions => 'スペクトラムの詳細オプション';

  @override
  String get resetAlgorithm => 'アルゴリズムをリセット';

  @override
  String get resetAppearance => '外観をリセット';

  @override
  String get smoothing => 'スムージング';

  @override
  String get gravity => 'グラビティ';

  @override
  String get logScale => 'ログスケール';

  @override
  String get contrast => 'コントラスト';

  @override
  String get normalization => '正規化';

  @override
  String get multiplier => 'マルチプライヤ';

  @override
  String get skipHighFrequency => '高周波をスキップ';

  @override
  String get frequencyGroups => '周波数グループ';

  @override
  String get aggregationMode => '集約モード';

  @override
  String get opacity => '不透明度';

  @override
  String get enableGradient => 'グラデーションを有効化';

  @override
  String get startColor => '開始色';

  @override
  String get endColor => '終了色';

  @override
  String get gradientRangeStop1 => 'グラデーション範囲ストップ1';

  @override
  String get gradientRangeStop2 => 'グラデーション範囲ストップ2';

  @override
  String get gradientRepeatMode => 'グラデーションの繰り返しモード';

  @override
  String get color => '色';

  @override
  String get followCoverColor => 'カバー色に合わせる';

  @override
  String get selectColor => '色を選択';

  @override
  String get volume => '音量';

  @override
  String get clearQueue => 'キューをクリア';

  @override
  String get confirmClearQueue => '現在のキューをクリアしてもよろしいですか？';

  @override
  String get queueCleared => 'キューをクリアしました';

  @override
  String get locateCurrentSong => '現在の曲を探す';

  @override
  String get songNotInScannedFolders => '現在の曲はスキャンされたディレクトリにありません';

  @override
  String get queue => 'キュー';

  @override
  String get queueEmpty => 'キューは空です';

  @override
  String selectedSongs(int count) {
    return '$count曲選択中';
  }

  @override
  String get unknownArtist => '不明なアーティスト';

  @override
  String deletedSongs(int count) {
    return '$count曲を削除しました';
  }

  @override
  String get delete => '削除';

  @override
  String get createPlaylist => 'プレイリストを作成';

  @override
  String get playlistName => 'プレイリスト名';

  @override
  String get enterPlaylistName => 'プレイリスト名を入力';

  @override
  String get playlistNameExists => 'プレイリスト名は既に存在します';

  @override
  String get renamePlaylist => 'プレイリスト名を変更';

  @override
  String get deletePlaylist => 'プレイリストを削除';

  @override
  String confirmDeletePlaylist(String name) {
    return 'プレイリスト\"$name\"を削除してもよろしいですか？';
  }

  @override
  String get deletePlaylists => 'プレイリストを削除';

  @override
  String confirmDeletePlaylists(int count) {
    return '選択した $count 個のプレイリストを削除してもよろしいですか？';
  }

  @override
  String playlistsDeleted(int count) {
    return '$count 個のプレイリストを削除しました';
  }

  @override
  String selectedPlaylistsCount(int count) {
    return '$count 個のプレイリストを選択中';
  }

  @override
  String get batchDelete => '一括削除';

  @override
  String get addToPlaylist => 'プレイリストに追加';

  @override
  String get selectAll => 'すべて選択';

  @override
  String get addToQueue => 'キューに追加';

  @override
  String get addedToQueue => 'キューに追加しました';

  @override
  String songCount(int count) {
    return '$count曲';
  }

  @override
  String addedToPlaylist(int count, String playlist) {
    return '$count曲を$playlistに追加しました';
  }

  @override
  String get createNewList => '新規リストを作成';

  @override
  String createdPlaylist(String name, int count) {
    return 'プレイリスト\"$name\"を作成し、$count曲を追加しました';
  }

  @override
  String get rename => '名前を変更';

  @override
  String get playlist => 'プレイリスト';

  @override
  String get mostPlayed => '最も再生された';

  @override
  String get recentlyPlayed => '最近再生した曲';

  @override
  String get recentlyAdded => '最近追加';

  @override
  String get albums => 'アルバム';

  @override
  String get artists => 'アーティスト';

  @override
  String get mostPlayedDescription => '再生完了回数でランク付け';

  @override
  String get recentlyPlayedDescription => '最近の再生時間で並べ替え（ライブラリ外のファイルを含む）';

  @override
  String get recentlyAddedDescription => 'ライブラリに追加された日時順';

  @override
  String get allTime => '全期間';

  @override
  String get pastWeek => '過去1週間';

  @override
  String get pastMonth => '過去1ヶ月';

  @override
  String get past90Days => '過去90日間';

  @override
  String get noPlayHistory => '再生履歴はまだありません';

  @override
  String get noPlayHistoryInRange => 'この期間の再生履歴はありません';

  @override
  String get noRecentlyPlayedSongs => '再生履歴はありません';

  @override
  String get noRecentlyPlayedInRange => '指定された期間内に再生履歴はありません';

  @override
  String get noRecentlyAddedSongs => 'ライブラリに曲がまだありません';

  @override
  String get noRecentlyAddedInRange => 'この期間に追加された曲はありません';

  @override
  String get addedOn => '追加日';

  @override
  String get externalSourceTag => '外部';

  @override
  String get lastPlayed => '最終再生';

  @override
  String playCountLabel(int count) {
    return '$count回';
  }

  @override
  String get playAll => 'すべて再生';

  @override
  String get shufflePlay => 'シャッフル再生';

  @override
  String get noAlbums => 'アルバムが見つかりません';

  @override
  String get noArtists => 'アーティストが見つかりません';

  @override
  String get searchAlbums => 'アルバムまたはアーティストを検索';

  @override
  String get searchArtists => 'アーティストを検索';

  @override
  String get albumSort => '並び替え';

  @override
  String get sortArtistAsc => 'アーティスト名 昇順';

  @override
  String get sortTitleAsc => 'アルバムタイトル 昇順';

  @override
  String get sortTrackCount => '曲数';

  @override
  String get sortDuration => '合計時間';

  @override
  String get sortRecentAdded => '最近追加';

  @override
  String get sortAscending => '昇順';

  @override
  String get sortDescending => '降順';

  @override
  String get playNext => '次に再生';

  @override
  String get addToFavorites => 'お気に入りに追加';

  @override
  String get removeFromFavorites => 'お気に入りから削除';

  @override
  String get viewAlbumDetails => 'アルバムの詳細を表示';

  @override
  String get viewArtistDetails => 'アーティストの詳細を表示';

  @override
  String get openFileLocation => 'ファイルの場所を開く';

  @override
  String get copyAlbumTitle => 'アルバムタイトルをコピー';

  @override
  String get copyArtistName => 'アーティスト名をコピー';

  @override
  String albumCount(int count) {
    return '$count枚のアルバム';
  }

  @override
  String get emptyList => 'リストは空です';

  @override
  String get dragToAddMusic => 'ファイルまたはフォルダをドラッグして音楽を追加';

  @override
  String get unknownAlbum => '不明なアルバム';

  @override
  String get managePlaylists => 'プレイリストを管理';

  @override
  String get createNewPlaylist => '新しいプレイリストを作成';

  @override
  String get defaultList => 'デフォルトリスト';

  @override
  String get playbackMode => '再生モード';

  @override
  String get playbackOptions => '再生オプション';

  @override
  String get setVisualizerDisplay => 'ビジュアライザ表示を設定';

  @override
  String get noPlaybackContent => '再生コンテンツがありません';

  @override
  String get file => 'ファイル';

  @override
  String get play => '再生';

  @override
  String get list => 'ライブラリ';

  @override
  String get queueTab => 'キュー';

  @override
  String get more => 'その他';

  @override
  String get settings => '設定';

  @override
  String get themeMode => 'テーマ';

  @override
  String get themeModeSystem => 'システムに従う';

  @override
  String get themeModeLight => 'ライト';

  @override
  String get themeModeDark => 'ダーク';

  @override
  String get themeColor => 'テーマカラー';

  @override
  String get customThemeColor => 'カスタムテーマカラー';

  @override
  String get themeColorMikuTeal => '初音ミクグリーン';

  @override
  String get themeColorClassicBlue => 'クラシックブルー';

  @override
  String get themeColorIrisPurple => 'アイリスパープル';

  @override
  String get themeColorViolet => 'バイオレット';

  @override
  String get themeColorSakuraPink => 'サクラピンク';

  @override
  String get themeColorCoralOrange => 'コーラルオレンジ';

  @override
  String get themeColorAmberGold => 'アンバーゴールド';

  @override
  String get themeColorForestGreen => 'フォレストグリーン';

  @override
  String get themeColorAuroraCyan => 'オーロラシアン';

  @override
  String get themeColorCrimsonRed => 'クリムゾンレッド';

  @override
  String get themeColorSlateGrey => 'スレートグレー';

  @override
  String get immersiveTabBar => '没入型タブバー';

  @override
  String get immersiveTabBarDescription => 'マウス移動時にナビゲーションバーを表示し、3秒無操作で非表示';

  @override
  String get collapseButtonsInLandscapeLyrics => '横画面歌詞モードでボタンを折りたたむ';

  @override
  String get collapseButtonsInLandscapeLyricsDescription =>
      '横画面歌詞モードで7つのボタン行を折りたたみ、タイトルを左揃えにして右側にアクションボタンを追加します';

  @override
  String get sampleStride => 'サンプルストライド';

  @override
  String get sampleStrideDescription => '値が大きいとスキャンは速いが波形精度が低下（デフォルト: 4）';

  @override
  String get waveformSegments => '波形セグメント数';

  @override
  String get waveformSegmentsDescription => '表示する波形バーの数（デフォルト: 80）';

  @override
  String get showDeveloperOptions => '開発者オプションを表示';

  @override
  String get playbackBackground => '再生背景';

  @override
  String get playbackRadialGradient => '中央ダークグラデーション';

  @override
  String get blurIntensity => 'ブラー強度';

  @override
  String get blurredArtwork => 'ブラーアートワーク（デフォルト）';

  @override
  String get dynamicMesh => 'ダイナミックメッシュ';

  @override
  String get solidColor => '単色';

  @override
  String get customImage => 'カスタム画像';

  @override
  String get presetColors => 'プリセット色';

  @override
  String get customColor => 'カスタム色';

  @override
  String get uploadImage => '画像を選択';

  @override
  String get normalOpacity => '通常時暗色レイヤーの不透明度';

  @override
  String get lyricsOpacity => '歌詞表示時暗色レイヤーの不透明度';

  @override
  String get chooseImageError => '画像の選択に失敗しました';

  @override
  String get noImageSelected => '画像が選択されていません';

  @override
  String get unknown => '不明';

  @override
  String get playlistModeSingle => '単曲';

  @override
  String get playlistModeSingleLoop => '単曲ループ';

  @override
  String get playlistModeQueue => 'キュー';

  @override
  String get playlistModeQueueLoop => 'キュー繰り返し';

  @override
  String get playlistModeAutoQueueLoop => '自動キュー繰り返し';

  @override
  String get visualizer => 'ビジュアライザ';

  @override
  String get previous => '前へ';

  @override
  String get next => '次へ';

  @override
  String get pause => '一時停止';

  @override
  String get autoMode => 'オートモード';

  @override
  String get advancedOptions => '詳細オプション';

  @override
  String get spectrumQuantity => 'スペクトラム数';

  @override
  String get speed => '速度';

  @override
  String get quantityHigh => '高';

  @override
  String get quantityMedium => '中';

  @override
  String get quantityLow => '低';

  @override
  String get speedFast => '速い';

  @override
  String get speedMedium => '中';

  @override
  String get speedSlow => '遅い';

  @override
  String get portraitFrequencyGroups => '縦画面の周波数グループ数';

  @override
  String get landscapeFrequencyGroups => '横画面の周波数グループ数';

  @override
  String get portraitGap => '縦画面のギャップ';

  @override
  String get landscapeGap => '横画面のギャップ';

  @override
  String get enableWaveformProgressBar => '波形プログレスバーを有効化';

  @override
  String get enableWaveformProgressBarDescription => '標準スライダーの代わりに全曲波形を使用';

  @override
  String get waveformLongPressSeekSpeed => '波形長押し早送り速度';

  @override
  String get waveformLongPressSeekSpeedDescription =>
      '波形プログレスバーの右側を長押しした時の早送り再生速度（×）';

  @override
  String get enableWaveformLongPressSeek => '波形長押し早送りを有効化';

  @override
  String get enableWaveformLongPressSeekDescription =>
      '波形プログレスバーの右側を長押しして早送り再生を有効にします';

  @override
  String get clearWaveformCache => '全曲波形キャッシュをクリア';

  @override
  String get clearWaveformCacheDescription => 'データベース内の波形キャッシュを削除して再計算します';

  @override
  String get waveformCacheCleared => '波形キャッシュをクリアしました';

  @override
  String get storageAndCache => 'ストレージとキャッシュ';

  @override
  String get remoteAudioCache => 'リモート音声キャッシュ';

  @override
  String get remoteAudioCacheDescription =>
      'Navidrome および WebDAV の再生とプリフェッチ用のローカルキャッシュ';

  @override
  String get remoteCacheLimit => 'リモートキャッシュ上限';

  @override
  String get remotePrefetchCount => 'リモート曲の事前読み込み数';

  @override
  String get remotePrefetchCountDescription =>
      'スムーズな再生のために再生キューの後続曲を事前にダウンロードします';

  @override
  String get clearRemoteCache => 'リモートキャッシュをクリア';

  @override
  String get remoteCacheCleared => 'リモートキャッシュをクリアしました';

  @override
  String get unlimited => '無制限';

  @override
  String get off => 'オフ';

  @override
  String get randomMode => 'ランダムモード';

  @override
  String get randomHistory => 'ランダム履歴';

  @override
  String get randomRange => 'ランダム範囲';

  @override
  String get randomMethod => 'ランダム方式';

  @override
  String get currentQueue => '現在のキュー';

  @override
  String get globalRange => '全体（全プレイリスト）';

  @override
  String get completeRandom => '完全ランダム';

  @override
  String get shuffleRandom => 'シャッフルランダム';

  @override
  String get randomQueue => 'ランダムキュー';

  @override
  String get notSelected => '音楽が選択されていません';

  @override
  String get saveTagsToFile => 'タグをファイルに保存';

  @override
  String get saveCurrentTagsToFile => '現在の曲のタグをファイルに保存';

  @override
  String get saveQueueTagsToFile => 'キューの全タグをファイルに保存';

  @override
  String get tagsSaved => 'タグを保存しました';

  @override
  String tagsSavedCount(Object count) {
    return 'タグを保存しました（$count曲）';
  }

  @override
  String get tagsSaveFailed => 'タグの保存に失敗しました';

  @override
  String tagsSaveFailedCount(Object count) {
    return '$count曲の保存に失敗しました';
  }

  @override
  String unsupportedFormat(Object count) {
    return '$count曲は未対応フォーマットです（OGG/Opusは保存不可）';
  }

  @override
  String get unsupportedFormatSingle => 'このフォーマット（OGG/Opus）はタグの保存に対応していません';

  @override
  String get savingTags => 'タグを保存中...';

  @override
  String get noModifiedTagsToSave => '保存する変更済みタグはありません';

  @override
  String get clearPlaylist => 'リストをクリア';

  @override
  String get copyTitle => 'タイトルをコピー';

  @override
  String get transcodeAction => 'トランスコード';

  @override
  String get transcodeSectionTitle => 'オーディオトランスコード';

  @override
  String get transcodeSectionDescription => 'オーディオ変換のデフォルト出力形式と品質プリセットを設定します。';

  @override
  String get transcodeDefaultFormat => 'デフォルト出力形式';

  @override
  String get transcodeDefaultQuality => 'デフォルト品質プリセット';

  @override
  String get transcodeTitle => 'オーディオトランスコード';

  @override
  String transcodeSongCount(int count) {
    return '$count曲';
  }

  @override
  String transcodeCompletedCount(int count) {
    return '$countファイルをトランスコードしました';
  }

  @override
  String transcodeCompletedWithFailures(int success, int total, int failed) {
    return '$success/$totalファイルをトランスコード完了、$failed失敗';
  }

  @override
  String get transcodeFailedGeneric => 'トランスコードに失敗しました';

  @override
  String get transcodePreparing => 'トランスコードを準備中...';

  @override
  String transcodeProgress(int current, int total) {
    return 'トランスコード中 $current/$total';
  }

  @override
  String get transcoding => 'トランスコード中...';

  @override
  String get startTranscode => 'トランスコード開始';

  @override
  String transcodeEngine(Object engine) {
    return 'エンジン: $engine';
  }

  @override
  String get transcodeUsingSystemFfmpeg => 'システムのPATHからffmpegを使用しています。';

  @override
  String transcodeUsingCustomFfmpeg(Object path) {
    return 'カスタムffmpegを使用: $path';
  }

  @override
  String get transcodeFormat => '出力形式';

  @override
  String get transcodeQualityPreset => '品質プリセット';

  @override
  String get transcodeQualityLow => '低';

  @override
  String get transcodeQualityMedium => '中';

  @override
  String get transcodeQualityHigh => '高';

  @override
  String get transcodeQualityExtreme => '最高';

  @override
  String get transcodeLosslessPresetHint => 'このロスレス形式では品質段階やビットレートモードは使用しません。';

  @override
  String get transcodeAdvancedOptions => '詳細オプション';

  @override
  String get transcodeAdvancedCustomized => '詳細パラメータがカスタマイズされました';

  @override
  String get transcodeAdvancedFollowingPreset => '詳細パラメータは現在のプリセットに従います';

  @override
  String get transcodeLosslessAdvancedHint => 'このロスレス形式ではソース保持オプションのみ利用可能です。';

  @override
  String get transcodeBitRateInvalid => '有効なビットレートを入力してください';

  @override
  String get transcodeBitRate => 'ビットレート';

  @override
  String get transcodeBitRateMode => 'ビットレートモード';

  @override
  String get transcodeEncodingEngine => 'エンコーディングエンジン';

  @override
  String get transcodeSystemEncoder => 'Media3（システム）';

  @override
  String get transcodeFfmpegRustEncoder => 'FFmpeg（Rust）';

  @override
  String get transcodeAacEncoder => 'AACエンコーダ';

  @override
  String get transcodeSampleRate => 'サンプルレート';

  @override
  String get transcodeChannels => 'チャンネル';

  @override
  String get transcodeResetToPreset => '現在のプリセットにリセット';

  @override
  String get transcodeResetLosslessOptions => 'ロスレスオプションをリセット';

  @override
  String get transcodeOutputDirectory => '出力ディレクトリ';

  @override
  String get transcodeOutputPreview => 'プレビュー';

  @override
  String get transcodeChooseDirectory => 'ディレクトリを選択';

  @override
  String get transcodeUseSourceDirectory => 'ソースディレクトリを使用';

  @override
  String get transcodeKeepSource => 'ソースを保持';

  @override
  String get transcodeMono => 'モノラル';

  @override
  String get transcodeStereo => 'ステレオ';

  @override
  String get openFolderLocation => 'フォルダの場所を開く';

  @override
  String get songTagsSavedToSourceFileAndApp => '楽曲タグをソースファイルとアプリに保存しました';

  @override
  String get songTagsSavedToApp => '楽曲タグをアプリに保存しました';

  @override
  String get durationZero => '0:00';

  @override
  String get generateLyrics => '歌詞を生成';

  @override
  String get generateTimeline => 'タイムラインを生成';

  @override
  String get queueGenerateLyrics => '歌詞生成をキューに入れる';

  @override
  String get pauseAutoScroll => '自動スクロールを一時停止';

  @override
  String get resumeAutoScroll => '自動スクロールを再開';

  @override
  String get returnToCurrentLine => '現在の行に戻る';

  @override
  String get translateLyrics => '歌詞を翻訳';

  @override
  String get clearLyricsCache => '現在の歌詞キャッシュをクリア';

  @override
  String get clearTranslationCache => '現在の翻訳キャッシュをクリア';

  @override
  String get requery => '再クエリ';

  @override
  String get sleepTimerTitle => 'スリープタイマー';

  @override
  String get sleepTimerDescription => 'カウントダウンを選択すると、時間経過後に再生が一時停止します。';

  @override
  String get sleepTimerRunningTitle => 'スリープタイマー動作中';

  @override
  String get sleepTimerRunningDescription => 'カウントダウン終了時に自動的に再生を一時停止します。';

  @override
  String get sleepTimerStopAfterCurrentSong => '最後の曲の終了後に停止';

  @override
  String get remainingTime => '残り時間';

  @override
  String get startCountdown => 'カウントダウン開始';

  @override
  String get end => '終了';

  @override
  String get equalizer => 'イコライザ';

  @override
  String get equalizerEnabledStatus => '高忠実度調整が有効です';

  @override
  String get equalizerDisabledStatus => '無効';

  @override
  String get eqPresetFlat => 'フラット';

  @override
  String get eqPresetPop => 'ポップ';

  @override
  String get eqPresetRock => 'ロック';

  @override
  String get eqPresetVocal => 'ボーカル';

  @override
  String get eqPresetBassBoost => '低音強調';

  @override
  String get eqPresetElectronic => 'エレクトロニック';

  @override
  String get eqPresetJazz => 'ジャズ';

  @override
  String get eqPresetClassical => 'クラシック';

  @override
  String get eqPresetAcoustic => 'アコースティック';

  @override
  String get eqPresetDance => 'ダンス';

  @override
  String get eqPresetHifi => 'Hi-Fi';

  @override
  String get eqPresets => 'イコライザープリセット';

  @override
  String get customPresets => 'カスタムプリセット';

  @override
  String get builtInPresets => '内蔵プリセット';

  @override
  String get saveAsPreset => 'プリセットとして保存';

  @override
  String get saveCurrentAsPreset => '現在の設定を新規プリセットとして保存';

  @override
  String get enterPresetName => 'プリセット名を入力';

  @override
  String get presetName => 'プリセット名';

  @override
  String get presetNameAlreadyExists => 'このプリセット名は既に存在します';

  @override
  String get presetNameCannotBeEmpty => 'プリセット名を入力してください';

  @override
  String get presetSaved => 'プリセットを保存しました';

  @override
  String get updatePreset => 'プリセットを更新';

  @override
  String get presetUpdated => 'プリセットを更新しました';

  @override
  String get renamePreset => 'プリセット名を変更';

  @override
  String get presetRenamed => 'プリセット名を変更しました';

  @override
  String get saveAsNewPreset => '新規プリセットとして保存';

  @override
  String get updateWithCurrentSettings => '現在の設定で上書き';

  @override
  String get modified => '変更あり';

  @override
  String get deletePreset => 'プリセットを削除';

  @override
  String get deletePresetConfirm => 'このプリセットを削除してもよろしいですか？';

  @override
  String get custom => 'カスタム';

  @override
  String get noCustomPresets => 'カスタムプリセットはありません';

  @override
  String get savePresetPrompt => '現在のEQゲイン、バスブースト、プリアンプゲインを保存します';

  @override
  String get effects => 'エフェクト';

  @override
  String get playbackSpeed => '再生速度';

  @override
  String get playbackSpeedLimit5x => '5倍速上限';

  @override
  String get normal => '通常';

  @override
  String get bassBoost => 'バスブースト';

  @override
  String get preampGain => 'プリアンプゲイン';

  @override
  String get reset => 'リセット';

  @override
  String get close => '閉じる';

  @override
  String get timelineAdjustmentTitle => 'タイムライン調整';

  @override
  String get timelineAdjustmentDescription => '右にドラッグすると歌詞が遅れ、左にドラッグすると早くなります。';

  @override
  String timelineOffsetEarlier(Object seconds) {
    return '$seconds秒早い';
  }

  @override
  String timelineOffsetLater(Object seconds) {
    return '$seconds秒遅い';
  }

  @override
  String get timelineOffsetCurrent => '現在のオフセット: 0.0秒';

  @override
  String get enterAcoustidApiKeyTitle => 'AcoustID APIキーを入力';

  @override
  String get acoustidApiKeyDescription =>
      '音声フィンガープリントに使用されます。空白のままにすると内蔵のデフォルトキーが復元されます。';

  @override
  String get acoustidApiKeyHint => 'AcoustID APIキーを貼り付け';

  @override
  String get apiKey => 'APIキー';

  @override
  String get save => '保存';

  @override
  String get enterLyricsTitle => '歌詞を入力';

  @override
  String get lyricsInputHint => 'ここに歌詞を貼り付けるか入力してください。複数行テキストに対応しています。';

  @override
  String get enterGoogleAiStudioApiKeyTitle => 'Google AI Studio APIキーを入力';

  @override
  String get googleAiStudioApiKeyDescription =>
      'Google AI Studioでの歌詞生成、タイムライン生成、翻訳に使用されます。';

  @override
  String get pasteGoogleAiStudioApiKey => 'Google AI Studio APIキーを貼り付け';

  @override
  String get enterOpenRouterApiKeyTitle => 'OpenRouter APIキーを入力';

  @override
  String get openRouterApiKeyDescription =>
      'OpenRouterでの歌詞生成、タイムライン生成、歌詞翻訳に使用されます。';

  @override
  String get pasteOpenRouterApiKey => 'OpenRouter APIキーを貼り付け';

  @override
  String get enterGeminiApiKeyTitle => 'Gemini APIキーを入力';

  @override
  String get geminiApiKeyDescription => '歌詞の翻訳に使用されます。';

  @override
  String get pasteGeminiApiKey => 'Gemini APIキーを貼り付け';

  @override
  String get testConnection => '接続テスト';

  @override
  String get enterApiKey => 'APIキーを入力してください。';

  @override
  String get testingConnection => '接続をテスト中...';

  @override
  String get getKey => 'キーを取得';

  @override
  String get editSongTagsTitle => '楽曲タグを編集';

  @override
  String get changeArtwork => 'カバーを変更';

  @override
  String get clearArtwork => 'カバーをクリア';

  @override
  String get editSongTagsDescription =>
      '変更内容はアプリ内のみに保存するか、ソースファイルにも書き戻すことができます。';

  @override
  String get artistLabel => 'アーティスト';

  @override
  String get albumArtistLabel => 'アルバムアーティスト';

  @override
  String get albumLabel => 'アルバム';

  @override
  String get trackNumberLabel => 'トラック番号';

  @override
  String get trackNumberMustBeInteger => 'トラック番号は整数である必要があります';

  @override
  String get leaveBlankKeepsCurrentValue => '空白にするとこのフィールドをクリアします';

  @override
  String get currentFileFormatCannotWriteBack =>
      'このファイル形式はソースファイルへの書き戻しをサポートしていません。変更はアプリ内のみ保存できます。';

  @override
  String get leaveBlankDoesNotClearOriginalValue =>
      'ヒント: フィールドを空白にするとその値がクリアされます。';

  @override
  String get saveToApp => 'アプリに保存';

  @override
  String get saveToSourceFileAndApp => 'ソースファイルとアプリに保存';

  @override
  String get saveToSourceFileFailed =>
      'ソースファイルへの保存に失敗しました。ファイル形式が書き込みに対応していること、ファイルが使用中でないことを確認してください。';

  @override
  String get fileOccupiedByOtherApp => 'ファイルが別のアプリに使用されているため書き込めません';

  @override
  String get saveFailed => '保存に失敗しました。後でもう一度お試しください。';

  @override
  String apiKeySaved(Object provider) {
    return '$provider APIキーを保存しました';
  }

  @override
  String get apiKeySavedAcoustid => 'AcoustID APIキーを保存しました';

  @override
  String get generalSectionTitle => '画面と動作';

  @override
  String get generalSectionDescription =>
      '外観、再生インタラクション、およびウィンドウとシステムの動作を設定します。';

  @override
  String get uiAppearanceGroup => '外観と表示';

  @override
  String get playbackBehaviorGroup => '再生とインタラクション';

  @override
  String get systemWindowBehaviorGroup => 'ウィンドウとシステム動作';

  @override
  String get interfaceLanguage => 'インターフェース言語';

  @override
  String get interfaceLanguageDescription => 'アプリケーションの表示言語を選択します。';

  @override
  String get scanSectionTitle => 'スキャン';

  @override
  String get scanSectionDescription =>
      'これらのオプションはライブラリスキャンがオーディオファイルを処理する方法を制御します。';

  @override
  String get skipShortAudioDuringScan => 'スキャン中に短い音声をスキップ';

  @override
  String get skipShortAudioDuringScanDescription => 'しきい値より短い音声はライブラリに追加されません。';

  @override
  String get shortAudioScanThreshold => '短い音声のしきい値';

  @override
  String get shortAudioScanThresholdDescription => 'この時間より短いファイルはスキップされます。';

  @override
  String shortAudioScanThresholdValue(Object seconds) {
    return '$seconds秒';
  }

  @override
  String get shortcutSettingsTitle => 'カスタムショートカット';

  @override
  String get shortcutSettingsDescription =>
      'クリックしてプレイヤー操作のショートカットキーを再設定して保存します。';

  @override
  String get edit => '編集';

  @override
  String get lyricsSectionTitle => '歌詞';

  @override
  String get lyricsSectionDescription => 'これらの設定は歌詞生成とタイムライン生成にのみ影響します。';

  @override
  String get lyricsTranslationTargetLanguageLabel => '翻訳対象言語';

  @override
  String get lyricsTranslationTargetLanguageDescription =>
      'デフォルトではシステム言語に従います。手動で選択も可能です。';

  @override
  String get lyricsSaveMethodLabel => '歌詞の保存場所';

  @override
  String get lyricsSaveMethodDescription => 'ファイル書き込み時の歌詞の保存場所を選択します。';

  @override
  String get lyricsSaveMethodOriginal => '元の場所';

  @override
  String get lyricsSaveMethodEmbedded => '埋め込み';

  @override
  String get lyricsSaveMethodLrcFile => 'LRCファイル';

  @override
  String get lyricsStyleLabel => '歌詞スタイル';

  @override
  String get lyricsStyleDescription => '歌詞パネルの表示スタイルを選択します。';

  @override
  String get lyricsStyleTraditional => 'デフォルト';

  @override
  String get lyricsStyleApple => '行ごとフォーカス';

  @override
  String get resumeLyricsSync => '歌詞の同期を再開';

  @override
  String get followSystemLanguage => 'システムに従う';

  @override
  String get autoSwitchLyricsProvider => '歌詞プロバイダを自動切替';

  @override
  String get autoSwitchLyricsProviderEnabledDesc =>
      '最初にGoogle AI Studioを試します。プライマリとフォールバックの両モデルが429または5xxエラーで失敗した場合、自動的にOpenRouterに切り替えて試行を継続します。';

  @override
  String get autoSwitchLyricsProviderDisabledDesc =>
      '自動切替を有効にするには、Google AI StudioとOpenRouterの両方のAPIキーが必要です。';

  @override
  String get lyricsAiProviderTitle => '歌詞AIプロバイダ';

  @override
  String get lyricsAiProviderDescription =>
      '歌詞生成とタイムライン生成にのみ影響します。翻訳は常にGoogle AI Studioを使用します。';

  @override
  String get googleAiStudioApiKeySaved => 'Google AI Studio APIキーを保存しました';

  @override
  String get googleAiStudioApiKeyMissing =>
      'Google AI Studio APIキーがまだ保存されていません。歌詞生成とタイムライン生成時に最初にプロンプトが表示されます。';

  @override
  String get openRouterApiKeySaved => 'OpenRouter APIキーを保存しました';

  @override
  String get openRouterApiKeyMissing =>
      'OpenRouter APIキーがまだ保存されていません。歌詞生成とタイムライン生成時に最初にプロンプトが表示されます。';

  @override
  String get apiKeySavedStatus => '保存済み';

  @override
  String get apiKeyMissingStatus => '未入力';

  @override
  String get platformApiKeysSectionTitle => 'プラットフォームAPIキー';

  @override
  String get fill => '入力';

  @override
  String get modify => '変更';

  @override
  String get geminiModelsSectionTitle => 'モデルを選択';

  @override
  String get geminiModelsSectionDescription =>
      'これらのモデルはGoogle AI Studioでの歌詞生成、タイムライン生成、歌詞翻訳に使用されます。';

  @override
  String get primaryModelLabel => 'プライマリモデル';

  @override
  String get backupModelLabel => 'フォールバックモデル';

  @override
  String get translationModelLabel => '翻訳モデル';

  @override
  String get fetching => '取得中...';

  @override
  String get fetchModelList => 'モデル一覧を取得';

  @override
  String get restoreDefault => 'デフォルトに戻す';

  @override
  String get acoustidSectionTitle => 'フィンガープリンティング';

  @override
  String get acoustidApiKeyTitle => 'AcoustID APIキー';

  @override
  String get acoustidApiKeyHelp =>
      'AcoustIDは音声フィンガープリントに使用されます。ご自身のAPIキーの使用をお勧めします。';

  @override
  String get acoustidApiKeySaved => 'AcoustID APIキーを保存しました';

  @override
  String get acoustidApiKeyDefault =>
      '現在内蔵のデフォルトキーを使用中です。ご自身のキーに置き換えることをお勧めします。';

  @override
  String get applyForApiKey => 'APIキーを申請: https://acoustid.org/new-application';

  @override
  String get queueTabBarFavoriteAdded => 'お気に入りに追加しました';

  @override
  String get queueTabBarFavoriteRemoved => 'お気に入りから削除しました';

  @override
  String get tagCompletion => 'タグ補完';

  @override
  String get tagCompletionDescription => 'AcoustIDとMusicBrainzの結果でタグを一致させます';

  @override
  String get goToSettings => '設定へ';

  @override
  String get searchReleaseTitles => 'リリースタイトルを検索';

  @override
  String get closeSearch => '検索を閉じる';

  @override
  String get refreshResults => '結果を更新';

  @override
  String get filterMusicBrainzReleaseTitle => 'MusicBrainzリリースタイトルをフィルタ';

  @override
  String get clearSearch => '検索をクリア';

  @override
  String get localTitle => 'ローカルタイトル';

  @override
  String get queryConditions => 'クエリ条件';

  @override
  String get musicBrainzLoading => 'MusicBrainzを読み込み中';

  @override
  String get musicBrainzLoadingWithResults => '既存の結果はパネルに残ります';

  @override
  String get musicBrainzLoadingHint => 'お待ちください';

  @override
  String get musicBrainzQueryFailed => 'MusicBrainzクエリが失敗しました';

  @override
  String get musicBrainzNetworkErrorHint =>
      'リクエストに失敗しました。通常はネットワークの不安定さ、タイムアウト、またはサーバー拒否が原因です。後で再試行してください。';

  @override
  String get musicBrainzFilteredEmptyHint =>
      '現在のフィルタ条件では、そのキーワードを含むリリースタイトルは見つかりませんでした。';

  @override
  String get musicBrainzEmptyHint =>
      'MusicBrainzは利用可能な結果を返しませんでした。タイトル、アーティスト、またはアルバムのフィルタを緩めてみてください。';

  @override
  String get musicBrainzEmptyMoreCompleteHint =>
      '後で再試行するか、現在のタイトルまたはアーティスト情報がより完全であることを確認してください。';

  @override
  String get retry => '再試行';

  @override
  String get noMatchingRelease => '一致するリリースが見つかりません';

  @override
  String get noMatchingResults => '一致する結果がありません';

  @override
  String get networkConnectionFailed => 'ネットワーク接続に失敗しました';

  @override
  String get searchAgain => 'もう一度検索';

  @override
  String get acoustidRecognitionRecords => 'AcoustID認識レコード';

  @override
  String get musicBrainzRecordings => 'MusicBrainzレコーディング';

  @override
  String get noExpandableReleaseGroups => '展開可能なリリースグループがありません';

  @override
  String get noExpandableReleases => '展開可能なリリースがありません';

  @override
  String get noMatchingResultHint =>
      '後で再試行するか、現在のタイトルまたはアーティスト情報がより完全であることを確認してください。';

  @override
  String releaseCountLabel(int count) {
    return '$count件のリリース';
  }

  @override
  String recordingCountLabel(int count) {
    return '$count件のレコーディング';
  }

  @override
  String trackCountShort(int count) {
    return '$countトラック';
  }

  @override
  String scoreLabel(int score) {
    return 'スコア $score';
  }

  @override
  String matchScoreLabel(int score) {
    return '一致 $score%';
  }

  @override
  String get editQueryCondition => 'クエリ条件を編集';

  @override
  String get enterNewQueryText => '新しいクエリテキストを入力';

  @override
  String get durationLabel => '再生時間';

  @override
  String get customShortcuts => 'カスタムショートカット';

  @override
  String get pressShortcutCombo => 'ショートカットキーを押してください';

  @override
  String get clickToRecord => 'クリックして設定';

  @override
  String get searchingLyrics => '歌詞を検索中';

  @override
  String get noLyrics => '歌詞はまだありません';

  @override
  String get providerLabel => 'プロバイダ';

  @override
  String get modelLabel => 'モデル';

  @override
  String get unspecified => '未指定';

  @override
  String targetTimeLabel(String duration) {
    return 'ターゲット時間 $duration';
  }

  @override
  String get songDeletedSkipped => '曲が削除されたためスキップしました';

  @override
  String get songDeleted => '曲が削除されました';

  @override
  String get lyricsTaskUploading => 'アップロード中';

  @override
  String get lyricsTaskWaiting => '待機中';

  @override
  String get lyricsTaskRequesting => 'リクエスト中';

  @override
  String get lyricsTaskGenerating => '生成中';

  @override
  String get lyricsTaskRetrying => '再試行中';

  @override
  String get lyricsTaskProcessing => '処理中';

  @override
  String get unknownModel => '不明なモデル';

  @override
  String selectedFolders(int count) {
    return '$countフォルダ選択中';
  }

  @override
  String foldersDeleted(int count) {
    return '$countフォルダを削除しました';
  }

  @override
  String get persistentAccessDenied => 'そのフォルダへのアクセスを保存できませんでした。もう一度選択してください。';

  @override
  String get folderAddFailed => 'フォルダの追加に失敗しました';

  @override
  String get sleepTimer => 'スリープタイマー';

  @override
  String sleepTimerRemaining(Object duration) {
    return 'スリープタイマー $duration';
  }

  @override
  String get unknownArtistOrAlbum => '不明';

  @override
  String get pressAgainToExit => 'もう一度押すと終了します';

  @override
  String get tagCompletionSuccessWithCover =>
      'タグを補完して保存しました。カバーは一時ディレクトリにダウンロードされました';

  @override
  String get tagCompletionSuccess => 'タグを補完して保存しました';

  @override
  String get selectOnlineLyrics => 'オンライン歌詞を選択';

  @override
  String get increaseLyricsFont => '歌詞フォントを拡大';

  @override
  String get decreaseLyricsFont => '歌詞フォントを縮小';

  @override
  String get restoreDefaultSize => 'デフォルトサイズに戻す';

  @override
  String get adjustLyricsFont => '文字サイズを調整';

  @override
  String get searchingOnlineLyrics => 'オンライン歌詞を検索中';

  @override
  String get onlineLyricsResults => 'オンライン歌詞の結果';

  @override
  String get untitledLyrics => '無題の歌詞';

  @override
  String get hasTimeline => 'タイムラインあり';

  @override
  String get viewLyricsDetails => '歌詞の詳細を表示';

  @override
  String get lyricsDetails => '歌詞の詳細';

  @override
  String get lyricsContent => '歌詞の内容';

  @override
  String get noLyricsContent => '歌詞の内容がありません';

  @override
  String get queryContentLabel => '内容';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String dropAddedSongs(int addedCount) {
    return '$addedCount曲追加しました';
  }

  @override
  String dropAddedSongsWithExisting(int addedCount, int existingCount) {
    return '$addedCount曲追加、$existingCount曲は既に存在しました';
  }

  @override
  String get copyCover => 'カバーをクリップボードにコピー';

  @override
  String get copyCoverSuccess => 'カバーをクリップボードにコピーしました';

  @override
  String get searchLyricsPlaceholder => '曲名、アーティスト、または歌詞を入力して検索';

  @override
  String get share => '共有';

  @override
  String get windowsSettingsTitle => 'Windows設定';

  @override
  String get fileAssociationTitle => 'ファイル関連付け';

  @override
  String get fileAssociationDescription =>
      '一般的な音楽形式（mp3, flac, wavなど）をこのアプリに関連付けて、ダブルクリックで開けるようにします。';

  @override
  String get associateButton => '関連付ける';

  @override
  String get disassociateButton => '解除';

  @override
  String get associationSuccess =>
      '関連付けに成功しました！ダブルクリックが機能しない場合は、Windowsのデフォルトアプリ設定でVynodyを選択してください。';

  @override
  String get disassociationSuccess => 'ファイル関連付けを正常に解除しました。';

  @override
  String associationFailed(Object error) {
    return '関連付けに失敗しました: $error';
  }

  @override
  String get onboardingTitle => 'Vynodyへようこそ';

  @override
  String get onboardingSubtitle => 'いくつかの簡単なステップで音楽の旅を始めましょう。';

  @override
  String get onboardingStepFileAssociation => 'ファイルタイプを関連付ける';

  @override
  String get onboardingFileAssociationDesc =>
      '一般的な音楽形式（mp3, flac, wavなど）をVynodyに関連付けて、ファイルエクスプローラーでダブルクリックするだけで音楽を再生できます。';

  @override
  String get onboardingFileAssociationTip =>
      '関連付け後、システムが「開くアプリの選択」メニューを表示する場合があります。リストから「Vynody」を選択し、「常にこのアプリを使う」にチェックを入れてください。';

  @override
  String get onboardingStepRootDirectory => '音楽ルートディレクトリを追加';

  @override
  String get onboardingRootDirectoryDesc =>
      '音楽ファイルが保存されているフォルダを選択してください。Vynodyが自動的にスキャンしてあなたの音楽ライブラリを構築します。';

  @override
  String get onboardingAndroidPermissionTip =>
      '注意：Androidでローカル曲のインポートとスキャンを行うには、メディアライブラリのアクセス権限が必要です。【フォルダを選択】をタップすると権限が要求されますので、許可してください。';

  @override
  String get onboardingSelectDirectory => 'フォルダを選択';

  @override
  String get onboardingSuccessTitle => '準備完了！';

  @override
  String get onboardingSuccessDesc => 'メディアライブラリを追加しました。音楽をお楽しみください！';

  @override
  String get onboardingStartButton => '始める';

  @override
  String get onboardingSkip => '後で設定';

  @override
  String get onboardingNext => '次へ';

  @override
  String get onboardingBack => '戻る';

  @override
  String get resetOnboarding => 'オンボーディングをリセット';

  @override
  String get resetOnboardingDesc => 'オンボーディング状態をクリアします。次回起動時にウェルカムガイドが再表示されます。';

  @override
  String get songProperties => '楽曲のプロパティ';

  @override
  String get failedToLoadDetails => '詳細の読み込みに失敗しました';

  @override
  String get remoteAudioNotCachedHint =>
      'この曲はクラウド上にあり、ローカルにキャッシュされていません。再生またはダウンロードすると完全な音声パラメータを表示できます。';

  @override
  String get noPropertiesAvailable => '楽曲の詳細プロパティがありません';

  @override
  String get detailFilePath => 'ファイルパス';

  @override
  String get detailFormat => '形式';

  @override
  String get detailCodec => 'コーデック';

  @override
  String get detailDuration => '再生時間';

  @override
  String get detailFileSize => 'ファイルサイズ';

  @override
  String get detailBitrate => 'ビットレート';

  @override
  String get detailSampleRate => 'サンプルレート';

  @override
  String get detailChannels => 'チャンネル';

  @override
  String get detailBitDepth => 'ビット深度';

  @override
  String get detailMono => 'モノラル';

  @override
  String get detailStereo => 'ステレオ';

  @override
  String detailChannelsCount(int count) {
    return '$countチャンネル';
  }

  @override
  String get localNetworkPermissionDeniedTitle => 'ローカルネットワークアクセスが制限されています';

  @override
  String get localNetworkPermissionDeniedMessage =>
      '利用可能なローカルネットワークIPアドレスが検出されなかったか、ローカルネットワーク権限が拒否されました。\n\n以下をご確認ください:\n1. デバイスがWi-Fiまたはローカルネットワークに接続されていることを確認してください。\n2. システム設定でアプリのローカルネットワークアクセスが許可されていることを確認してください:\n   - iOS/macOS: システム設定 > プライバシーとセキュリティ > ローカルネットワーク でVynodyのスイッチをオンにしてください。\n   - Windows: ネットワークに接続していることを確認し、WindowsファイアウォールがVynodyのネットワークアクセスを許可していることを確認してください。';

  @override
  String get localNetworkPermissionWindowsMessage =>
      '利用可能なローカルネットワークIPアドレスが検出されませんでした。\n\n以下をご確認ください:\n1. デバイスがローカルネットワーク（Wi-Fiまたはイーサネット）に接続されていることを確認してください。\n2. 接続済みでもエラーが続く場合は、Windowsファイアウォール設定でVynodyがファイアウォールを通過できるようにしてください。';

  @override
  String get openSettingsButton => '設定を開く';

  @override
  String get closeButton => '閉じる';

  @override
  String get copyTranslationResults => '翻訳結果をコピー';

  @override
  String get writeLyricsToFile => '歌詞をファイルに書き込む';

  @override
  String get selectLyricSource => '歌詞ソースを選択';

  @override
  String get regenerateLyrics => '歌詞を再生成';

  @override
  String get regenerateLyricsConfirmation => '現在の歌詞をクリアして再生成します。続行しますか？';

  @override
  String get regenerateTimeline => 'タイムラインを再生成';

  @override
  String get regenerateTimelineConfirmation => '現在のタイムラインをクリアして再生成します。続行しますか？';

  @override
  String get retranslateLyrics => '歌詞を再翻訳';

  @override
  String get retranslateLyricsConfirmation => '現在の翻訳をクリアして再翻訳します。続行しますか？';

  @override
  String get translationCopiedToClipboard => '翻訳結果をクリップボードにコピーしました';

  @override
  String get writingLyrics => '歌詞を書き込み中...';

  @override
  String get lyricsWrittenToFile => '歌詞をファイルに書き込みました';

  @override
  String get writeLyricsFailed => '歌詞の書き込みに失敗しました';

  @override
  String get externalLrcFile => '外部LRCファイル';

  @override
  String get embeddedLyrics => '埋め込み歌詞';

  @override
  String get manuallyAdjustedLyrics => '手動調整済み歌詞';

  @override
  String get lrclibOnlineLyrics => 'LrcLibオンライン歌詞';

  @override
  String get aiGeneratedLyrics => 'AI生成歌詞';

  @override
  String get matchScore => '一致';

  @override
  String get untitledRelease => '無題のリリース';

  @override
  String get localSongFileNotFoundForGeneration =>
      'ローカル曲ファイルが存在しないため、歌詞を生成できません。';

  @override
  String get localSongFileNotFoundForTimeline =>
      'ローカル曲ファイルが存在しないため、タイムラインを生成できません。';

  @override
  String get noLyricsForTimelineGeneration => 'タイムライン生成に利用可能な歌詞がありません。';

  @override
  String get noLyricsAvailableForTranslation => '翻訳に利用可能な歌詞がありません。';

  @override
  String get noCurrentSongAvailable => '現在の曲がありません。';

  @override
  String get invalidTargetLanguage => '対象言語が無効です。';

  @override
  String get songAlreadyQueuedForTranslation => '現在の曲は既に翻訳キューに入っています。';

  @override
  String get songAlreadyQueuedForGeneration => '現在の曲は既に歌詞生成キューに入っています。';

  @override
  String get songNoLongerExistsForTranslation => '現在の曲はもう存在しないため、歌詞を翻訳できません。';

  @override
  String get generationFailed => '生成に失敗しました。';

  @override
  String get generatingLyrics => '歌詞を生成中';

  @override
  String get generatingTimeline => 'タイムラインを生成中';

  @override
  String get regeneratingLyrics => '歌詞を再生成中';

  @override
  String get translatingLyrics => '歌詞を翻訳中';

  @override
  String get transcodingSongFile => '曲ファイルをトランスコード中';

  @override
  String get uploadingSongFile => '曲ファイルをアップロード中';

  @override
  String get fileUploadedWaitingForReadiness => 'ファイルをアップロードしました。準備が整うのを待っています';

  @override
  String get waitingForFileReadiness => 'ファイルの準備が整うのを待っています';

  @override
  String get requestingModelResponse => 'モデルの応答をリクエスト中';

  @override
  String retryingTaskKindGeneration(Object taskKind) {
    return '$taskKindの生成を再試行中';
  }

  @override
  String get retrying => '再試行中';

  @override
  String get processing => '処理中';

  @override
  String get timeline => 'タイムライン';

  @override
  String get lyrics => '歌詞';

  @override
  String lyricGenerationError(Object error) {
    return '歌詞生成中にエラーが発生しました: $error';
  }

  @override
  String timelineGenerationError(Object error) {
    return 'タイムライン生成中にエラーが発生しました: $error';
  }

  @override
  String get unknownGenerationError => '歌詞生成中に不明なエラーが発生しました。';

  @override
  String get unknownTimelineGenerationError => 'タイムライン生成中に不明なエラーが発生しました。';

  @override
  String get unknownTranslationError => '歌詞翻訳中に不明なエラーが発生しました。';

  @override
  String get unknownError => '不明なエラー';

  @override
  String get modelRefusedToGenerateLyrics => 'モデルが歌詞の生成を拒否しました。';

  @override
  String get modelRefusedToGenerateTimeline => 'モデルがタイムラインの生成を拒否しました。';

  @override
  String get doubaoPreUploadTranscodingFailed =>
      'Doubaoアップロード前の音声トランスコードに失敗しました。';

  @override
  String get doubaoTempTranscodeNotInTempDir =>
      '一時トランスコードファイルがテンポラリディレクトリに作成されませんでした。';

  @override
  String get doubaoEmptyStreamingResponse => 'Doubaoが空のストリーミングレスポンスを返しました。';

  @override
  String get doubaoEmptyResponse => 'Doubaoが空のレスポンスを返しました。';

  @override
  String get geminiEmptyStreamingResponse => 'Geminiが空のストリーミングレスポンスを返しました。';

  @override
  String get geminiEmptyResponse => 'Geminiが空のレスポンスを返しました。';

  @override
  String get openRouterEmptyStreamingResponse =>
      'OpenRouterが空のストリーミングレスポンスを返しました。';

  @override
  String get openRouterEmptyResponse => 'OpenRouterが空のレスポンスを返しました。';

  @override
  String get deepseekEmptyStreamingResponse => 'DeepSeekが空のストリーミングレスポンスを返しました。';

  @override
  String get deepseekEmptyResponse => 'DeepSeekが空のレスポンスを返しました。';

  @override
  String get customProviderEmptyStreamingResponse =>
      'カスタムプロバイダが空のストリーミングレスポンスを返しました。';

  @override
  String get customProviderEmptyResponse => 'カスタムプロバイダが空のレスポンスを返しました。';

  @override
  String get fileUploadFailed => 'ファイルのアップロードに失敗しました。もう一度お試しください。';

  @override
  String get uploadedFileNotReady => 'アップロードしたファイルが準備できませんでした。後でもう一度お試しください。';

  @override
  String get audioTranscodingFailed => 'オーディオのトランスコードに失敗しました。';

  @override
  String get tempTranscodeNotInTempDir =>
      '一時トランスコードファイルがテンポラリディレクトリに作成されませんでした。';

  @override
  String get networkRequestFailedCheckProxy =>
      'ネットワークリクエストに失敗しました。ネットワークとプロキシ設定を確認してください。';

  @override
  String get quotaExhaustedToday => '本日の割り当てを使い切りました。明日リセットされてから再試行してください。';

  @override
  String get googleAiHeavyLoad => 'Google AIは高負荷のため一時的に利用できません。';

  @override
  String lyricsGenerationFailedWithError(Object error) {
    return '歌詞生成に失敗しました: $error';
  }

  @override
  String missingApiKeyForAction(Object action, Object providerName) {
    return '$providerNameのAPIキーが見つからないため、$actionは利用できません。';
  }

  @override
  String locationNotSupportedForModel(String modelName) {
    return '現在の地域では $modelName はサポートされていません';
  }

  @override
  String get googleServerFlaky => 'Googleの調子が良くないようです。再試行すると成功する場合があります。';

  @override
  String get translateLyricsAction => '歌詞を翻訳';

  @override
  String get generateLyricsAction => '歌詞を生成';

  @override
  String get generateTimelineAction => 'タイムラインを生成';

  @override
  String get deepseekOnlyTranslation => 'DeepSeekは歌詞の翻訳にのみ利用可能です。';

  @override
  String get customProviderOnlyTranslation => 'カスタムプロバイダは歌詞の翻訳にのみ利用可能です。';

  @override
  String get customProviderNoBaseUrl => 'カスタムプロバイダのベースURLが設定されていません。';

  @override
  String get pleaseEnterApiKey => 'APIキーを入力してください。';

  @override
  String get connectionSuccessVerificationPassed => '接続成功、検証に合格しました。';

  @override
  String connectionSuccessDetectedModels(Object count) {
    return '接続成功、$count個のモデルを検出しました。';
  }

  @override
  String testFailedWithStatus(Object message, Object statusCode) {
    return 'テスト失敗（$statusCode）: $message';
  }

  @override
  String get testFailedCheckNetworkOrApiKey =>
      'テストに失敗しました。ネットワークまたはAPIキーを確認してください。';

  @override
  String testFailedStatusCheckApiKey(Object statusCode) {
    return 'テスト失敗（$statusCode）。APIキーが有効かどうか確認してください。';
  }

  @override
  String get enterGoogleAiStudioApiKeyFirst =>
      '最初にGoogle AI Studio APIキーを入力してください。';

  @override
  String get enterDoubaoApiKeyFirst => '最初にDoubao APIキーを入力してください。';

  @override
  String get enterDeepseekApiKeyFirst => '最初にDeepSeek APIキーを入力してください。';

  @override
  String get enterCustomApiKeyAndBaseUrl => '最初にカスタムAPIキーとベースURLを入力してください。';

  @override
  String fetchedCountModels(Object count) {
    return '$count個のモデルを取得しました。';
  }

  @override
  String requestFailedWithStatus(Object message, Object statusCode) {
    return 'リクエスト失敗（$statusCode）: $message';
  }

  @override
  String get requestFailedCheckNetwork => 'リクエストに失敗しました。ネットワークを確認してください。';

  @override
  String requestFailedStatus(Object statusCode) {
    return 'リクエストに失敗しました（$statusCode）。';
  }

  @override
  String get doubao => 'Doubao';

  @override
  String get noModelSelected => 'モデルが選択されていません';

  @override
  String get acoustidRequestFailed => 'AcoustIDリクエストに失敗しました';

  @override
  String acoustidRequestReturnedStatus(Object statusCode) {
    return 'AcoustIDリクエストが$statusCodeを返しました。ご自身のAcoustID APIキーを申請して設定で入力してください。';
  }

  @override
  String get writeTagDatabaseFailed => 'タグデータベースの書き込みに失敗しました';

  @override
  String get playPause => '再生/一時停止';

  @override
  String get nextTrack => '次の曲';

  @override
  String get previousTrack => '前の曲';

  @override
  String get volumeUp => '音量上げる';

  @override
  String get volumeDown => '音量下げる';

  @override
  String get toggleMute => 'ミュート切替';

  @override
  String get seekForward5s => '5秒進む';

  @override
  String get seekBackward5s => '5秒戻る';

  @override
  String get toggleFullScreen => '全画面切替';

  @override
  String get playPauseDescription => '現在の再生状態を制御します。';

  @override
  String get nextDescription => '次の曲にスキップします。';

  @override
  String get previousDescription => '前の曲に戻ります。';

  @override
  String get volumeUpDescription => '音量を5%ずつ上げます。';

  @override
  String get volumeDownDescription => '音量を5%ずつ下げます。';

  @override
  String get toggleMuteDescription => 'ミュートを切り替えます。';

  @override
  String get seekForward5sDescription => '5秒早送りします。';

  @override
  String get seekBackward5sDescription => '5秒巻き戻しします。';

  @override
  String get toggleFullScreenDescription => 'ウィンドウモードと全画面を切り替えます。';

  @override
  String get unknownKey => '不明なキー';

  @override
  String get removeFromQueue => 'キューから削除';

  @override
  String get removeFromPlaylist => 'プレイリストから削除';

  @override
  String get alreadyLatestVersion => '既に最新バージョンです。';

  @override
  String get updateAvailable => 'アップデートがあります';

  @override
  String newVersionAvailable(Object version) {
    return '新しいバージョンv$versionが利用可能です。GitHubのリリースページからダウンロードしてください。';
  }

  @override
  String get openRelease => 'リリースを開く';

  @override
  String get checkUpdateFailedNetwork =>
      'アップデートの確認に失敗しました。ネットワークの問題かGitHubのレート制限の可能性があります。';

  @override
  String get tags => 'タグ';

  @override
  String get about => '詳細情報';

  @override
  String get rebuildIndex => 'インデックスを再構築';

  @override
  String get rebuildIndexDescription =>
      'すべての曲レコード（外部ソースを除く）をクリアし、すべてのルートディレクトリを再スキャンします。';

  @override
  String get rebuildIndexConfirmation =>
      'すべての曲レコード（外部ソースを除く）をクリアし、すべてのルートディレクトリを再スキャンしてもよろしいですか？この処理には時間がかかる場合があります。';

  @override
  String get rebuildIndexStarted => 'インデックスの再構築を開始しました';

  @override
  String get rebuild => '再構築';

  @override
  String get advanced => '詳細';

  @override
  String get advancedOptionsDescription => 'デバッグと動作調整のためのオプション。';

  @override
  String get showDeveloperOptionsDescription => 'デバッグ用のより詳細なオプションを表示します。';

  @override
  String get onboardingReset => 'オンボーディングがリセットされました。次回起動時に反映されます。';

  @override
  String get tagsSectionDescription => 'オーディオファイルのメタデータと自動補完を設定します。';

  @override
  String get autoSaveToSourceFile => 'ソースファイルに自動保存';

  @override
  String get autoSaveToSourceFileDescription => 'タグ補完時に自動的に物理オーディオファイルに書き戻します。';

  @override
  String get aboutSectionDescription => 'バージョン情報、プロジェクトリンク、関連情報。';

  @override
  String get checkForUpdates => 'アップデートを確認';

  @override
  String get storeUpdateNotice =>
      'このアプリの更新は Microsoft Store で管理されています。最新バージョンの確認は Microsoft Store で行えます。';

  @override
  String get openMicrosoftStore => 'Microsoft Store を開く';

  @override
  String get appStoreUpdateNotice =>
      'このアプリの更新は App Store によって管理されています。App Store で最新バージョンを確認してください。';

  @override
  String get openAppStore => 'App Store へ';

  @override
  String get lyricsGenerationModel => '歌詞生成モデル';

  @override
  String get lyricsGenerationModelDescription =>
      'AIによる歌詞生成とタイムライン生成/修正に使用されます。';

  @override
  String get lyricsTranslationModel => '歌詞翻訳モデル';

  @override
  String get lyricsTranslationModelDescription => '歌詞を対象言語に翻訳するために使用されます。';

  @override
  String get onlyForLyricTranslation => '歌詞翻訳のみ';

  @override
  String get fillApiKeyFirstEnablesModels =>
      '少なくとも1つのAPIキーを入力してモデル選択を有効にしてください。';

  @override
  String get customApiProvider => 'カスタムAPIプロバイダ';

  @override
  String get clearedGoogleAiStudioApiKey => 'Google AI Studio APIキーをクリアしました';

  @override
  String get clearedOpenRouterApiKey => 'OpenRouter APIキーをクリアしました';

  @override
  String get clearedDoubaoApiKey => 'Doubao APIキーをクリアしました';

  @override
  String get clearedDeepseekApiKey => 'DeepSeek APIキーをクリアしました';

  @override
  String get clearedCustomProviderConfig => 'カスタムプロバイダ設定をクリアしました';

  @override
  String get savedDoubaoApiKey => 'Doubao APIキーを保存しました';

  @override
  String get savedDeepseekApiKey => 'DeepSeek APIキーを保存しました';

  @override
  String get savedCustomProviderConfig => 'カスタムプロバイダ設定を保存しました';

  @override
  String get noMatchingFoldersOrSongs => '一致するフォルダまたは曲が見つかりません';

  @override
  String get searching => '検索中...';

  @override
  String get listView => 'リスト表示';

  @override
  String get gridView => 'グリッド表示';

  @override
  String get hybridView => 'ハイブリッド表示';

  @override
  String songsCountFormat(Object count) {
    return '$count曲';
  }

  @override
  String get searchInFolderAndSubfolders => 'フォルダとサブフォルダを検索...';

  @override
  String get shuffle => 'シャッフル';

  @override
  String get search => '検索';

  @override
  String get selectFolders => 'フォルダを選択';

  @override
  String get removeDirectory => 'ディレクトリを削除';

  @override
  String removeRootDirectoryConfirmation(Object name) {
    return 'ルートディレクトリ\"$name\"を削除してもよろしいですか？ディスク上の物理ファイルは削除されません。';
  }

  @override
  String get deselectAll => 'すべて選択解除';

  @override
  String get favorites => 'お気に入り';

  @override
  String get aggregationPeak => 'ピーク';

  @override
  String get aggregationMean => '平均';

  @override
  String get aggregationRms => 'RMS';

  @override
  String get filesToTranscode => 'トランスコードするファイル';

  @override
  String get chooseAndroidOutputDirectoryFirst =>
      '最初にAndroidの出力ディレクトリを選択してください。';

  @override
  String currentSongProgressPercent(Object percent) {
    return '現在の曲 $percent%';
  }

  @override
  String overallProgressPercent(Object percent) {
    return '全体 $percent%';
  }

  @override
  String get pleaseChooseOutputDirectory => '出力ディレクトリを選択してください。';

  @override
  String selectedArtistsCount(Object count) {
    return '$count人のアーティストを選択中';
  }

  @override
  String selectedAlbumsCount(Object count) {
    return '$count枚のアルバムを選択中';
  }

  @override
  String get simplifiedChinese => '簡体字中国語';

  @override
  String get traditionalChinese => '繁体字中国語';

  @override
  String get chineseLanguage => '中国語';

  @override
  String get englishLanguage => '英語';

  @override
  String get japaneseLanguage => '日本語';

  @override
  String get koreanLanguage => '韓国語';

  @override
  String get frenchLanguage => 'フランス語';

  @override
  String get germanLanguage => 'ドイツ語';

  @override
  String get spanishLanguage => 'スペイン語';

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
  String get portugueseLanguage => 'ポルトガル語';

  @override
  String get russianLanguage => 'ロシア語';

  @override
  String get systemLanguage => 'システム言語';

  @override
  String get targetLanguage => '対象言語';

  @override
  String get whatAreAiLyrics => 'AI歌詞とは？';

  @override
  String get whatIsAiLyricTranslation => 'AI歌詞翻訳とは？';

  @override
  String get aiLyricsIntroGeneration => 'AIは曲から歌詞を生成し、タイムラインに合わせることができます。';

  @override
  String get aiLyricsIntroTranslation => 'AIは歌詞を好きな言語に翻訳して、曲をより理解しやすくします。';

  @override
  String get whyNeedApiKey => 'なぜAPIキーが必要ですか？';

  @override
  String get apiKeyExplanation =>
      'APIキーはAIプロバイダへのアクセス資格情報です。アプリはこれを使用して歌詞生成、タイムライン調整、翻訳のリクエストを直接送信します。';

  @override
  String get apiKeyLocalOnly =>
      'あなたのAPIキーはこのデバイスにのみ保存され、Vynody開発者サーバーにアップロードされることはありません。';

  @override
  String get chooseAnAiProvider => 'AIプロバイダを選択:';

  @override
  String get googleProviderPros => 'Google公式チャンネルで、強力なGeminiモデルと豊富な無料枠があります。';

  @override
  String get googleProviderCons =>
      '高トラフィック時に429エラーが発生することがあります。その場合は別のプロバイダに切り替えてください。';

  @override
  String get openRouterProviderPros =>
      '多くのプロバイダといくつかの無料モデルにアクセスできるモデルアグリゲータです。';

  @override
  String get openRouterProviderCons => 'チャージに手数料が含まれる場合があり、ウェブサイトは英語のみです。';

  @override
  String get doubaoProviderPros =>
      'ByteDance製、中国語テキストに強い。新規ユーザーはモデルあたり50万トークンの無料枠を取得できます。';

  @override
  String get doubaoProviderCons => '登録が比較的面倒で、本人確認が必要です。';

  @override
  String get deepseekProviderPros => '中国語の理解度が高く、低価格で歌詞翻訳に適しています。';

  @override
  String get deepseekProviderCons =>
      'テキスト入力のみ。歌詞生成とタイムライン調整には別のプロバイダのAPIキーが必要です。';

  @override
  String get highlights => 'ハイライト';

  @override
  String get notes => 'メモ';

  @override
  String enterProviderApiKey(Object provider) {
    return '$provider APIキーを入力:';
  }

  @override
  String get pasteYourApiKey => 'APIキーをここに貼り付け';

  @override
  String get getApiKey => 'APIキーを取得';

  @override
  String get testConnectionButton => '接続テスト';

  @override
  String get enableAiLyricGeneration => 'AI歌詞生成を有効化';

  @override
  String get enableAiLyricTranslation => 'AI歌詞翻訳を有効化';

  @override
  String get notNow => '今はしない';

  @override
  String get startSetup => 'セットアップを開始';

  @override
  String get chooseAiProvider => 'AIプロバイダを選択';

  @override
  String get backStep => '戻る';

  @override
  String get continueAction => '続ける';

  @override
  String get nextStep => '次へ';

  @override
  String get configureApiKey => 'APIキーを設定';

  @override
  String get saveAndFinish => '保存して完了';

  @override
  String get testing => 'テスト中...';

  @override
  String get noteTitle => '注意';

  @override
  String get deepseekTextInputOnlyNote =>
      'DeepSeekはテキスト入力のみをサポートしています。歌詞生成とタイムライン調整には別のプロバイダのAPIキーが必要です。';

  @override
  String retryAttemptOfMax(Object attempt, Object maxRetry) {
    return '再試行 $attempt/$maxRetry';
  }

  @override
  String generatingTaskKind(Object taskKind) {
    return '$taskKindを生成中';
  }

  @override
  String connectionTestException(Object error) {
    return '接続テストエラー: $error';
  }

  @override
  String get testingConnectionProgress => '接続をテスト中...';

  @override
  String get clear => 'クリア';

  @override
  String get enterDoubaoApiKey => 'Doubao APIキーを入力';

  @override
  String get doubaoApiKeyDescription =>
      '歌詞生成と翻訳のためのVolcano/Doubao APIキーを入力してください。';

  @override
  String get enterDeepseekApiKey => 'DeepSeek APIキーを入力';

  @override
  String get deepseekApiKeyDescription => '歌詞翻訳のみのためのDeepSeek APIキーを入力してください。';

  @override
  String get pleaseEnterApiKeyHint => 'APIキーを入力してください';

  @override
  String get platform => 'プラットフォーム';

  @override
  String get showRecommendedOnly => '推奨のみ表示';

  @override
  String get noAvailableChannels => '利用可能なチャンネルがありません';

  @override
  String get noMatchingModels => '一致するモデルが見つかりません';

  @override
  String get leaveEmpty => '空のままにする';

  @override
  String get leaveEmptyFallbackDescription => 'バックアップモデルを設定しない場合はこれを選択します。';

  @override
  String get modelSearchHint => 'モデル名、IDを入力';

  @override
  String sendFilesFailed(Object error) {
    return 'ファイルの送信に失敗しました: $error';
  }

  @override
  String get scanningFolderMusic => 'フォルダ内の音楽ファイルをスキャン中...';

  @override
  String scanFolderFailed(Object error) {
    return 'フォルダのスキャンに失敗しました: $error';
  }

  @override
  String get noMusicFilesFound => 'このフォルダにサポートされている音楽ファイルが見つかりません';

  @override
  String sendFolderFailed(Object error) {
    return 'フォルダの送信に失敗しました: $error';
  }

  @override
  String get lanSharingStartFailed => 'LAN共有の開始に失敗しました。ローカルネットワーク権限を確認してください。';

  @override
  String syncingLyricsToDevice(Object deviceName) {
    return '$deviceName に歌詞を同期中...';
  }

  @override
  String syncLyricsSuccess(Object matched, Object overwritten, Object skipped) {
    return '同期完了: 一致 $matched、更新 $overwritten、スキップ $skipped';
  }

  @override
  String syncLyricsFailed(Object error) {
    return '歌詞の同期に失敗しました: $error';
  }

  @override
  String syncingLyricsFromDevice(Object deviceName) {
    return '$deviceName から歌詞を同期中...';
  }

  @override
  String get transferInProgressDoNotLeave => '転送中です。共有ページから移動しないでください';

  @override
  String get lanSharingTitle => 'LAN接続';

  @override
  String get lanSharingEnabledStatus => 'LAN共有が有効です';

  @override
  String get lanSharingDisabledStatus => 'LAN共有が無効です';

  @override
  String lanSharingRunningStatus(Object ip, Object port) {
    return 'ローカルIP: $ip（ポート: $port）';
  }

  @override
  String get lanSharingDefaultOffHint =>
      'デフォルトでは無効です。有効にするとローカルネットワーク権限を要求します。';

  @override
  String get receiveDirectoryNotSetWarning =>
      'Androidでファイルを受信するには、まず受信ディレクトリを選択する必要があります。タップして設定してください。';

  @override
  String get receiveDirectoryNoWritePermission =>
      '現在の保存先ディレクトリへの書き込み権限がありません。再設定してください。';

  @override
  String get restoreDefaultDirectory => 'デフォルトディレクトリに戻す';

  @override
  String get chooseOtherDirectory => '他のディレクトリを選択';

  @override
  String get receiveDirectoryRestoredDefault => 'デフォルトの受信ディレクトリに復元しました';

  @override
  String receiveDirectoryUpdated(Object path) {
    return '受信ディレクトリが更新されました: $path';
  }

  @override
  String get receiveDirectoryTitle => '受信ディレクトリ';

  @override
  String get linkCopiedToClipboard => 'リンクをクリップボードにコピーしました';

  @override
  String get nearbyDevices => '近くのデバイス';

  @override
  String get searchingDevices => 'LAN上の他のデバイスを検索中...';

  @override
  String get startSharingToFindDevices => '共有を有効にしてデバイスを検出';

  @override
  String get deviceOnline => 'オンライン';

  @override
  String get deviceOffline => 'オフライン';

  @override
  String get sendMusicFiles => '音楽ファイルを送信';

  @override
  String get sendFolder => 'フォルダを送信';

  @override
  String get syncLyricsToDeviceAction => 'デバイスに歌詞を同期';

  @override
  String get syncLyricsFromDeviceAction => 'デバイスから歌詞を同期';

  @override
  String loadDevicesError(Object error) {
    return 'デバイスの読み込みに失敗しました: $error';
  }

  @override
  String incomingFilesFormat(Object name1, Object name2, Object count) {
    return '$name1、$name2 など全 $count ファイル';
  }

  @override
  String get incomingTransferRequestTitle => 'ファイル転送リクエストを受信';

  @override
  String incomingTransferFrom(Object senderName) {
    return '\"$senderName\" からの送信リクエスト：';
  }

  @override
  String fileSizeMb(Object sizeMb) {
    return 'ファイルサイズ: $sizeMb MB';
  }

  @override
  String get receiveFileHint => '受信したファイルは音楽フォルダに保存され、ライブラリに追加されます。';

  @override
  String get reject => '拒否';

  @override
  String get accept => '受け入れる';

  @override
  String get incomingLyricsExportTitle => '歌詞エクスポート要求';

  @override
  String incomingLyricsExportFrom(Object senderName) {
    return 'デバイス \"$senderName\" が歌詞ライブラリの読み取りとエクスポートを要求しています。';
  }

  @override
  String get incomingLyricsImportTitle => '歌詞インポート要求';

  @override
  String incomingLyricsImportFrom(Object senderName, Object count) {
    return 'デバイス \"$senderName\" が $count 曲の歌詞のインポートを要求しています。';
  }

  @override
  String get lyricsRequestRejected => 'リモートデバイスが歌詞の同期要求を拒否しました。';

  @override
  String sendCompleted(Object fileName) {
    return '\"$fileName\" を送信しました';
  }

  @override
  String receiveCompleted(int count) {
    return '$count曲を受信しました';
  }

  @override
  String transferCancelledWithReason(Object direction, Object reason) {
    return '$directionキャンセル（$reason）';
  }

  @override
  String transferFailedFormat(Object direction, Object fileName) {
    return '$direction \"$fileName\" 失敗';
  }

  @override
  String sendingToDevice(Object deviceName) {
    return '$deviceName に送信中';
  }

  @override
  String receivingFromDevice(Object deviceName) {
    return '$deviceName から受信中';
  }

  @override
  String progressFormat(Object percent) {
    return '進捗: $percent%';
  }

  @override
  String get currentlyTransferring => '現在転送中';

  @override
  String get fileConflictTitle => 'ファイル競合';

  @override
  String get fileConflictMessage => '対象デバイスに同じ名前のファイルが既に存在します：';

  @override
  String get fileConflictChooseAction => '実行する操作を選択してください：';

  @override
  String get skipAction => 'スキップ';

  @override
  String get overwriteAction => '上書き';

  @override
  String get skipAllAction => 'すべてスキップ';

  @override
  String get overwriteAllAction => 'すべて上書き';

  @override
  String get sendDirection => '送信';

  @override
  String get receiveDirection => '受信';

  @override
  String get fileAssociationEnabled => '関連付け済み';

  @override
  String get fileAssociationDisabled => '未関連付け';

  @override
  String get windowsAutoRepairShortcut => 'スタートメニューのショートカットを自動修復';

  @override
  String get windowsAutoRepairShortcutDescription =>
      '起動時にスタートメニューのショートカットを自動的に確認・作成し、メディアコントロールの名前とアイコンを正しく表示します';

  @override
  String get confirmDisableShortcutRepair => 'この機能を無効にしますか？';

  @override
  String get confirmDisableShortcutRepairContent =>
      'スタートメニューのショートカットがない場合、Windowsのメディアコントロールにアプリが「不明」と表示され、アイコンが表示されなくなる可能性があります。本当に無効にしますか？';

  @override
  String get confirmDisable => '無効にする';

  @override
  String get enableSystemTray => 'システムトレイを有効にする';

  @override
  String get enableSystemTrayDescription => 'システムトレイにアイコンを表示し、再生をすばやく操作できます';

  @override
  String get closeToTray => '閉じるときにバックグラウンドに最小化';

  @override
  String get closeToTrayDescription => 'メインウィンドウを閉じてもアプリを終了せずバックグラウンド再生を継続';

  @override
  String get closeWindowActionTitle => 'ウィンドウを閉じるとき';

  @override
  String get closeWindowActionDescription => 'メインウィンドウの閉じるボタンを押したときの動作を選択';

  @override
  String get closeWindowActionAsk => '毎回確認';

  @override
  String get closeWindowActionMinimize => 'システムトレイに最小化';

  @override
  String get closeWindowActionExit => 'アプリを完全に終了';

  @override
  String get closeWindowActionRemember => '選択を記憶し、次回から表示しない';

  @override
  String get closeWindowActionTrayDisabledTip => '（先にシステムトレイを有効にする必要があります）';

  @override
  String get closeWindowDialogTitle => 'アプリ終了の確認';

  @override
  String get closeWindowDialogContent => '閉じるボタンを押したときの動作を選択してください：';

  @override
  String get googleAiStudioApiKey => 'Google AI Studio API Key';

  @override
  String get openRouterApiKey => 'OpenRouter API Key';

  @override
  String get doubaoApiKey => 'Doubao API Key';

  @override
  String get deepseekApiKey => 'DeepSeek API Key';

  @override
  String get unexpectedResponseFormat => '予期しない応答形式です。';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get openaiCompatibleEndpoint => 'OpenAI互換のAPIエンドポイント';

  @override
  String onboardingAddedDirectoriesCount(Object count) {
    return '追加されたディレクトリ（$count）：';
  }

  @override
  String get gnomeDisksOpenFailed =>
      'ディスクユーティリティを自動的に開けませんでした。アプリケーションメニューから手動で「Disks」を開いてください。';

  @override
  String get gnomeDisksNotInstalled =>
      'gnome-disksがインストールされていません。システムのディスクユーティリティを開いて設定してください。';

  @override
  String get linuxMountGuideTitle => 'ディスクの自動マウントを設定';

  @override
  String get linuxMountGuideDescription =>
      'Linuxではデフォルトで外部パーティションがマウントされません。起動時にマウントする設定を行わないと、再起動のたびに外部パーティションのパスが変わり、プレーヤーが音楽ディレクトリにアクセスできなくなる可能性があります。これを防ぐため、音楽を保存しているパーティションを起動時に自動マウントするよう設定してください。';

  @override
  String get linuxMountGuideWarning =>
      '注意：音楽がマウントの必要な外付けまたは内蔵パーティションにある場合は、必ず「起動時に自動マウント」するように設定してください。そうしないと、再起動後に音楽ディレクトリが見つからなくなったり、アクセスするためにパスワードの入力が必要になったりする可能性があります。';

  @override
  String get linuxMountGuideStep1 => '1. システムの「Disks」ユーティリティを開く';

  @override
  String get linuxMountGuideStep2 =>
      '2. 音楽パーティションを選択し、⚙️ 歯車アイコンをクリック（追加のパーティションオプション）';

  @override
  String get linuxMountGuideStep3 =>
      '3. 「マウントオプションの編集」を選択し、「ユーザーセッションのデフォルト」をオフにして「システム起動時にマウント」にチェックを入れる';

  @override
  String get linuxMountGuideOpenButton => 'ディスクマネージャー（Disks）を開く';

  @override
  String get unmute => 'ミュート解除';

  @override
  String get mute => 'ミュート';

  @override
  String get disableSystemTray => 'システムトレイを无効にする';

  @override
  String get restoreWindow => 'ウィンドウを元に戻す';

  @override
  String get hideWindow => 'ウィンドウを非表示';

  @override
  String get onboardingAndroidBatteryTitle => 'バックグラウンド再生の保護';

  @override
  String get onboardingAndroidBatteryDescription =>
      'Androidの厳格なバッテリー最適化ポリシーにより、バックグラウンドでの音楽再生が強制終了されるのを防ぐため、Vynodyのバッテリー制限を「制限なし」（Unrestricted）に設定することをお勧めします。';

  @override
  String get onboardingAndroidBatteryStep1 => '1. 下の「設定へ」ボタンをタップします。';

  @override
  String get onboardingAndroidBatteryStep2 =>
      '2. システムダイアログでバッテリー最適化の無視を許可するか、バッテリー設定に移動します。';

  @override
  String get onboardingAndroidBatteryStep3 =>
      '3. 設定画面に移動した場合は、「制限なし」を選択してください。';

  @override
  String get onboardingAndroidBatteryButton => '設定へ';

  @override
  String get onboardingAndroidBatteryStatusOptimized =>
      '現在の状態：制限あり（バックグラウンド再生が停止する可能性があります）';

  @override
  String get onboardingAndroidBatteryStatusUnrestricted =>
      '現在の状態：制限なし（推奨、バックグラウンド再生保護済み）';

  @override
  String get onboardingAndroidMediaTitle => '音楽ライブラリへのアクセス';

  @override
  String get onboardingAndroidMediaDescription =>
      '許可すると、Vynodyはフォルダーを手動で選択することなく、端末のメディアライブラリからすべての音楽を直接読み込みます。許可しなくてもフォルダーから手動で音楽をインポートできます。';

  @override
  String get onboardingAndroidMediaStep1 => '1. すぐに使える：スマートフォン内にある全楽曲を即座に表示';

  @override
  String get onboardingAndroidMediaStep2 => '2. 自動検出：新しく追加された楽曲がライブラリに自動で反映';

  @override
  String get onboardingAndroidMediaStep3 =>
      '3. プライバシー安全：ローカル音声ファイルのみを読み込み、ライブラリを自動送信しません（AI歌詞などのクラウド機能を除く）';

  @override
  String get onboardingAndroidMediaButton => '音楽ライブラリへのアクセスを許可';

  @override
  String get onboardingAndroidMediaStatusGranted => '現在のステータス：許可済み（推奨）';

  @override
  String get onboardingAndroidMediaStatusNotGranted =>
      '現在のステータス：未許可（後から手動でフォルダーをインポート可能）';

  @override
  String get exitApp => '終了';

  @override
  String get showScanProgressToastSetting => 'スキャン状態トーストを表示';

  @override
  String get showScanProgressToastSettingDescription =>
      'フォルダのスキャン時に画面上部にリアルタイムのスキャン進行状況を表示します。';

  @override
  String get openPlaybackOnDirectorySongTap => '曲をタップした時に再生ページに移動';

  @override
  String get openPlaybackOnDirectorySongTapDescription =>
      'フォルダビューで曲をタップして再生した時、自動的に再生ページに移動します。';

  @override
  String get defaultToLyricsModeOnPlaybackOpen => '再生ページで歌詞モードをデフォルトにする';

  @override
  String get defaultToLyricsModeOnPlaybackOpenDescription =>
      '再生ページを開いた時、自動的に歌詞表示モードにします。';

  @override
  String get tapCoverToEnterLyricsMode => 'カバーをタップして歌詞モードに入る';

  @override
  String get longPressLyricsPanelToOpenMenu => '歌詞パネルを長押ししてメニューを表示';

  @override
  String get gotIt => '了解';

  @override
  String get scanToastHiddenHint =>
      'スキャン状態トーストが非表示になりました。「設定 - インターフェース」で再有効化できます。';

  @override
  String get doubleSpeedPlayingSwipeUpToLock => '早送り中... 上にスワイプしてロック';

  @override
  String get doubleSpeedLockedSwipeDownToUnlock => '早送りロック済み。長押しして下にスワイプで解除';

  @override
  String get doubleSpeedUnlocked => '早送りロックを解除しました';

  @override
  String get lyricsImportExportHeader => 'インポートとエクスポート';

  @override
  String get exportAction => 'エクスポート';

  @override
  String get importAction => 'インポート';

  @override
  String get exportLyricsLabel => '歌詞バックアップをエクスポート';

  @override
  String get exportLyricsDescription => 'すべてのキャッシュおよび調整済みの歌詞をJSONファイルにエクスポート';

  @override
  String get importLyricsLabel => '歌詞バックアップをインポート';

  @override
  String get importLyricsDescription => 'エクスポートされたJSONファイルから歌詞キャッシュをインポート';

  @override
  String get importLyrics => '歌詞をインポート';

  @override
  String get importLyricsSuccess => '歌詞をインポートしました';

  @override
  String get importLyricsFailed => '歌詞のインポートに失敗しました';

  @override
  String get emptyLyricsFile => '歌詞ファイルが空です';

  @override
  String exportSuccess(int count) {
    return '$count件の歌詞をエクスポートしました。';
  }

  @override
  String exportFailed(String error) {
    return 'エクスポートに失敗しました: $error';
  }

  @override
  String importSuccess(int count) {
    return 'インポート完了！$count件の歌詞をインポートしました。';
  }

  @override
  String importFailed(String error) {
    return 'インポートに失敗しました: $error';
  }

  @override
  String get importConflictsTitle => 'インポートの競合';

  @override
  String importConflictsMessage(int conflictCount) {
    return 'バックアップに $conflictCount 件の競合する歌詞が見つかりました（ローカルに存在しますが内容が異なります）。処理方法を選択してください:';
  }

  @override
  String get overwriteAll => 'すべて上書き';

  @override
  String get skipAllConflicts => '競合をスキップ';

  @override
  String get decideOneByOne => '1つずつ決定';

  @override
  String conflictResolutionTitle(int current, int total) {
    return '競合を解決（$current/$total）';
  }

  @override
  String get conflictExistingLabel => '既存の歌詞';

  @override
  String get conflictImportedLabel => 'インポートされた歌詞';

  @override
  String conflictSourceLabel(String source) {
    return 'ソース: $source';
  }

  @override
  String conflictTimeLabel(String time) {
    return '時間: $time';
  }

  @override
  String get overwriteThis => '上書き';

  @override
  String get skipThis => 'スキップ';

  @override
  String get overwriteRemaining => '残りをすべて上書き';

  @override
  String get skipRemaining => '残りをすべてスキップ';

  @override
  String get invalidBackupFile => '無効なバックアップファイル';

  @override
  String get exportLogs => 'ログをエクスポート';

  @override
  String get exportLogsSuccess => 'ログのエクスポートに成功しました';

  @override
  String get exportLogsFailed => 'ログのエクスポートに失敗しました';

  @override
  String get noLogFileFound => 'ログファイルが見つかりません';

  @override
  String get uiDisplayScale => 'UI表示スケール';

  @override
  String get uiDisplayScaleDescription =>
      '車載ディスプレイなどに合わせて、UIコンポーネントと文字のサイズを全域調整';

  @override
  String get uiDisplayScaleDialogTitle => 'UI表示スケール / 車載モード';

  @override
  String uiDisplayScaleCurrent(int percent) {
    return '現在のスケール: $percent%';
  }

  @override
  String get audioSettings => 'オーディオ設定';

  @override
  String get audioSettingsDescription => '音声再生、イコライザーバンド、再生速度の設定を管理';

  @override
  String get equalizerBandCount => 'イコライザーバンド数';

  @override
  String get equalizerBandCountDescription =>
      'イコライザーパネルに表示するバンド数を設定。高バンドモードではスムーズな横スクロールが自動有効化されます。';

  @override
  String bandsCountOption(int count) {
    return '$count バンド';
  }

  @override
  String get enableFadeEffect => 'オーディオフェード効果';

  @override
  String get enableFadeEffectDescription =>
      '曲の切り替え、再生/一時停止時にスムーズなフェードイン/アウトとクロスフェード有効化';

  @override
  String get buttonLayoutSettings => 'ボタンレイアウト';

  @override
  String get playbackButtonLayoutTitle => '再生ページのボタンレイアウト';

  @override
  String get playbackButtonLayoutDescription =>
      '再生ページの 7 ボタン行と 5 ボタン行の表示および並び順をカスタマイズ';

  @override
  String get topButtonsRowTitle => '7ボタン行の並び順';

  @override
  String get mainButtonsRowTitle => '5ボタン行の左右ボタン';

  @override
  String get mainControlsLeftButton => '左側ボタン';

  @override
  String get mainControlsRightButton => '右側ボタン';

  @override
  String get lyricsHeaderRightButtonTitle => '歌詞タイトルバー折りたたみ時の右側ボタン';

  @override
  String get resetButtonOrder => 'デフォルトレイアウトに戻す';

  @override
  String get btnMore => '詳細メニュー';

  @override
  String get btnFavorite => 'お気に入り';

  @override
  String get btnPlaylistMode => '再生モード';

  @override
  String get btnShuffle => 'シャッフル';

  @override
  String get btnTagCompletion => 'タグ自動補完';

  @override
  String get btnSleepTimer => 'スリープタイマー';

  @override
  String get btnEqualizer => 'イコライザー';

  @override
  String get btnVisualizer => 'ビジュアライザー';

  @override
  String get btnVolume => '音量';

  @override
  String get remoteControlAction => 'リモート操作';

  @override
  String get remoteControlRequestTitle => 'リモート操作リクエスト';

  @override
  String remoteControlRequestFrom(String name) {
    return 'デバイス「$name」が本機の再生制御を要求しています';
  }

  @override
  String get remotePinPairHint => '操作側のデバイスで以下のペアリングPINコードを入力してください：';

  @override
  String get remotePinExpiresIn => 'PINコード有効期限：';

  @override
  String get allowDirectly => '直接許可';

  @override
  String get enterRemotePinTitle => 'デバイスのペアリング';

  @override
  String enterRemotePinPrompt(String name) {
    return 'デバイス「$name」の画面に表示されている4桁のPINコードを入力してください：';
  }

  @override
  String get remotePinInvalid => 'PINコードが無効または期限切れです。もう一度お試しください';

  @override
  String remotePinCooldown(int seconds) {
    return 'PINコードが違います。$seconds秒後にお試しください';
  }

  @override
  String remotePinAttemptsRemaining(int count) {
    return '(残り$count回試行可能)';
  }

  @override
  String get remotePinTooManyAttempts => '試行回数が上限を超えました。ペアリングが無効になりました';

  @override
  String get remoteConnected => '接続済み';

  @override
  String get remoteConnecting => '接続中...';

  @override
  String get remoteDisconnect => '切断';

  @override
  String get remoteConnectFailed => 'リモート接続に失敗しました';

  @override
  String controlledByRemoteDevices(String devices) {
    return '次のデバイスからリモート操作されています: $devices';
  }

  @override
  String get trustedDevicesTitle => '信頼済みのリモートデバイス';

  @override
  String get manageTrustedDevicesTitle => '信頼済みリモートデバイスの管理';

  @override
  String get removeTrustedDevice => '信頼を解除';

  @override
  String get noMusicPlaying => '現在再生していません';

  @override
  String get previousSong => '前の曲';

  @override
  String get nextSong => '次の曲';

  @override
  String get shufflePlayback => 'シャッフル再生';

  @override
  String get allowRemoteControlTitle => 'リモート操作を許可';

  @override
  String get allowRemoteControlSubtitle =>
      'ペアリング後、LAN内の他のデバイスによる本機の音楽再生操作を許可します';

  @override
  String get remoteControlDisabledOnHost => '相手のデバイスでリモート操作が無効になっています';

  @override
  String get trustThisDevice => 'このデバイスを信頼し、次回から自動的に接続を許可する';

  @override
  String get remoteRequestRejected => '相手のデバイスに接続要求が拒否されました';

  @override
  String get turkishLanguage => 'トルコ語';

  @override
  String get nativeLanguageTr => 'Türkçe';

  @override
  String trustedDevicesCount(int count) {
    return '$count台のデバイスを信頼済み';
  }

  @override
  String get noTrustedDevices => '信頼済みのデバイスはありません';

  @override
  String get noTrustedDevicesHint => 'ペアリング時に「このデバイスを信頼する」をチェックするとここに表示されます';

  @override
  String pairedAtFormat(String time) {
    return 'ペアリング日時: $time';
  }

  @override
  String transferCancelled(String direction) {
    return '$directionキャンセル';
  }

  @override
  String get audioFiles => '音声ファイル';

  @override
  String get remotePairCancelledByClient => '相手のデバイスによってペアリング要求がキャンセルされました';

  @override
  String get proFeatureAiLyricsTitle => 'AI歌詞と翻訳';

  @override
  String get proFeatureAiLyricsDesc => 'AIによる歌詞生成、タイムライン同期、および多言語翻訳';

  @override
  String get proFeatureTagCompletionTitle => '楽曲メタデータ自動補完';

  @override
  String get proFeatureTagCompletionDesc =>
      'MusicBrainzを利用した楽曲タグおよびアルバム情報の自動補完';

  @override
  String get proFeatureEqualizerTitle => 'マルチバンドEQ＆再生速度 (EQ)';

  @override
  String get proFeatureEqualizerDesc =>
      'プロ仕様の周波数調整、0.5x〜5.0x再生速度、プリアンプゲインとカスタムサウンド';

  @override
  String get proFeatureCustomThemeColorTitle => 'フルスペクトルテーマと高度な配色';

  @override
  String get proFeatureCustomThemeColorDesc =>
      '自由なカラーピッカーパレットと限定プレミアムプリセットテーマカラーを解放';

  @override
  String get proFeatureFftVisualizerTitle => 'リアルタイム音声FFTスペクトラム';

  @override
  String get proFeatureFftVisualizerDesc =>
      'クラシックバー、スムーズウェーブ、フローティングキャップ、ラジアルハロー、ネオンマトリックス、ミラーウェーブなど6種類のスペクトラムと全画面アンビエントモード';

  @override
  String get proFeatureWaveformBarTitle => '動的オーディオ波形プログレスバー';

  @override
  String get proFeatureWaveformBarDesc => '音声波形をリアルタイム抽出し、滑らかな操作が可能なプログレスバー';

  @override
  String get proFeatureLanSharingTitle => 'LAN音楽ファイル共有';

  @override
  String get proFeatureLanSharingDesc => 'ローカルネットワーク内でのデバイス間高速楽曲ファイル共有と転送';

  @override
  String get proFeatureRemoteControlTitle => 'マルチデバイスリモート操作';

  @override
  String get proFeatureRemoteControlDesc =>
      'スマホ、タブレット、PC間でシームレスに連携するワイヤレスリモート操作';

  @override
  String get proFeatureTranscoderTitle => '音声一括変換ツール';

  @override
  String get proFeatureTranscoderDesc => 'ロスレス形式の高速変換・圧縮とポータブルデバイス向け一括エクスポート';

  @override
  String get proFeatureDynamicMeshBackgroundTitle => '流体メッシュ動的背景';

  @override
  String get proFeatureDynamicMeshBackgroundDesc =>
      'アートワークの色から生成される流体グラデーションアニメーションと速度調整';

  @override
  String get proFeatureCustomImageBackgroundTitle => 'カスタム再生背景壁紙';

  @override
  String get proFeatureCustomImageBackgroundDesc =>
      'お好みの画像や写真をインポートして再生画面の背景に設定';

  @override
  String get proCommunityUnlocked => 'コミュニティ版：すべてのPro機能が無制限で永久解放されています';

  @override
  String proTrialActive(int days) {
    return '無料トライアル適用中（残り $days 日）';
  }

  @override
  String get proTrialExpired => '無料トライアル期間が終了しました。Proにアップグレードしてください';

  @override
  String get proPermanentlyActivated => 'すべてのPro機能が永久アクティベート済みです';

  @override
  String proStatusTrialTitle(int days) {
    return 'ライセンス状態：$days日間の無料トライアル中';
  }

  @override
  String get proStatusTrialExpiredTitle => 'ライセンス状態：トライアル終了（一部機能制限）';

  @override
  String get proStatusActivatedTitle => 'ライセンス状態：Vynody Pro有効化済み';

  @override
  String proSettingsTrialRemaining(int days) {
    return '残り $days 日間のトライアル';
  }

  @override
  String get proSettingsUpgradePrompt => 'アップグレードしてAI歌詞、FFTスペクトラム、Pro機能を解放';

  @override
  String get proSettingsLifetimeNotice => 'すべてのPro機能と今後のアップデートを利用可能';

  @override
  String get proSettingsUpgrade => 'アップグレード';

  @override
  String get proSettingsView => '確認';

  @override
  String get connectingToStore => 'ストアに接続中...';

  @override
  String get buyFullVersionWindowsTrial => 'Microsoft Storeで完全版を購入';

  @override
  String get buyFullVersionWindows => 'Microsoft Storeで完全版を購入';

  @override
  String unlockProLifetimeWithPrice(String price) {
    return '$price でPro全機能を永久解放';
  }

  @override
  String get buyProTrialEarly => 'Pro永久ライセンスを購入';

  @override
  String get upgradeToProNow => '今すぐProにアップグレード';

  @override
  String get iUnderstand => '了解';

  @override
  String get restorePurchases => '購入履歴を復元';

  @override
  String get restoringPurchases => '購入履歴を復元中...';

  @override
  String get sharingProDescription =>
      'LAN相互接続はVynody Pro限定の高度な機能です。同じローカルネットワーク内で高速な楽曲転送、ライブラリ同期、ワイヤレスリモート操作が可能になります。';

  @override
  String get sharingHighlightSpeedTitle => '高速LAN転送';

  @override
  String get sharingHighlightSpeedDesc =>
      'Wi-Fi LAN内のP2P高速転送。データ通信量ゼロ、無圧縮でロスレス音源とプレイリストを転送。';

  @override
  String get sharingHighlightSyncTitle => 'ライブラリと歌詞の同期';

  @override
  String get sharingHighlightSyncDesc =>
      'ダウンロード済み歌詞や楽曲をワンクリックで転送し、複数端末の音楽ライブラリを同期。';

  @override
  String get sharingHighlightRemoteTitle => 'クロスプラットフォーム遠隔操作';

  @override
  String get sharingHighlightRemoteDesc =>
      'スマホ、タブレット、PCがシームレスに連携。いつでもワイヤレスで再生・選曲・音量調整。';

  @override
  String get sharingHighlightSecurityTitle => 'エンドツーエンドTLS暗号化';

  @override
  String get sharingHighlightSecurityDesc =>
      'LAN通信全体をTLS証明書で暗号化し、デバイス認証を行うことで安全なプライベート転送を確保。';

  @override
  String get upgradeToProToUnlock => 'Vynody Proにアップグレードして解放';

  @override
  String get proOneTimePurchaseNotice => '1回の購入で、このプラットフォーム上のすべてのPro機能を永久解放';

  @override
  String get proOneTimePurchaseNoticeApple =>
      '1回の購入で、Appleプラットフォーム（iPhone / iPad / Mac）の全Pro機能を永久解放';

  @override
  String get proUniversalPurchaseNoticeApple =>
      '一度の購入で、iPhone・iPad・Macすべてで利用可能';

  @override
  String get iapPurchaseSuccess => 'Vynody Proの購入が完了しました！ご支援ありがとうございます！';

  @override
  String get iapRestoreSuccess => 'Vynody Proの購入履歴を正常に復元しました！';

  @override
  String iapPurchaseCancelledOrFailed(String message) {
    return '購入が完了しなかったかキャンセルされました: $message';
  }

  @override
  String get tabLanSharing => 'LAN共有 & リモコン';

  @override
  String get tabCloudServers => 'クラウドメディア';

  @override
  String get addRemoteServer => 'メディアサーバーを追加';

  @override
  String get editRemoteServer => 'メディアサーバーを編集';

  @override
  String get serverName => 'サーバー名';

  @override
  String get serverNameAlreadyExists => 'サーバー名が既に存在します。別の名前を使用してください。';

  @override
  String get serverType => 'サーバータイプ';

  @override
  String get serverUrl => 'サーバーURL';

  @override
  String get serverUsername => 'ユーザー名';

  @override
  String get serverPassword => 'パスワード / トークン';

  @override
  String get customPath => 'カスタムパス (オプション)';

  @override
  String get maxBitRate => 'トランスコードビットレート制限 (kbps)';

  @override
  String get ignoreSsl => 'SSL証明書エラーを無視';

  @override
  String get connectionSuccess => '接続に成功しました';

  @override
  String get connectionFailed => '接続に失敗しました';

  @override
  String get noRemoteServers => '追加されたメディアサーバーはありません';

  @override
  String get noRemoteServersDesc =>
      'Navidrome (Subsonic) や WebDAV サーバーを追加して、プライベートクラウド音楽を楽しめます';

  @override
  String get browseServer => '参照';

  @override
  String get manageServer => '管理';

  @override
  String get deleteServerConfirm => 'このメディアサーバー接続を削除してもよろしいですか？';

  @override
  String get remoteSongCannotEditTags => 'リモート曲のタグは変更できません';

  @override
  String get addToServerPlaylist => 'サーバープレイリストに追加';

  @override
  String get addToLocalPlaylist => 'ローカルプレイリストに追加';

  @override
  String get serverPlaylists => 'サーバープレイリスト';

  @override
  String get localPlaylists => 'ローカルプレイリスト';

  @override
  String get createNewServerPlaylist => 'サーバープレイリストを作成';

  @override
  String get downloadSong => '曲をダウンロード';

  @override
  String get downloadAlbum => 'アルバム全体をダウンロード';

  @override
  String get downloadArtist => 'アーティストの全曲をダウンロード';

  @override
  String downloadStarted(Object title) {
    return 'ダウンロード中: $title';
  }

  @override
  String downloadCompleted(Object title) {
    return 'ローカルライブラリに保存しました: $title';
  }

  @override
  String downloadFailed(Object error) {
    return 'ダウンロードに失敗しました: $error';
  }

  @override
  String get alreadyDownloaded => 'この曲は既にローカルライブラリに存在します';

  @override
  String get starItem => 'サーバーのお気に入りに追加';

  @override
  String get unstarItem => 'サーバーのお気に入りから削除';

  @override
  String get starredSuccess => 'サーバーのお気に入りに追加しました';

  @override
  String get unstarredSuccess => 'サーバーのお気に入りから削除しました';

  @override
  String batchDownloadStarted(Object count) {
    return 'バックグラウンドで $count 曲をダウンロード中...';
  }

  @override
  String batchDownloadCompleted(Object count) {
    return '$count 曲をローカルライブラリにダウンロードしました';
  }

  @override
  String get viewAlbum => 'アルバムを表示';

  @override
  String get viewArtist => 'アーティストを表示';

  @override
  String get downloadManager => 'ダウンロード管理';

  @override
  String get downloadingTab => 'ダウンロード中';

  @override
  String get completedTab => '完了';

  @override
  String get pauseAll => 'すべて一時停止';

  @override
  String get resumeAll => 'すべて再開';

  @override
  String get cancelAll => 'すべてキャンセル';

  @override
  String get clearCompleted => '履歴をクリア';

  @override
  String get noActiveDownloads => '進行中のダウンロードはありません';

  @override
  String get noCompletedDownloads => '完了したダウンロードはありません';

  @override
  String get viewDownloadProgress => '進捗を確認';

  @override
  String get addedToDownloadQueue => 'ダウンロードキューに追加しました';

  @override
  String batchAddedToDownloadQueue(Object count) {
    return '$count 曲をダウンロードキューに追加しました';
  }

  @override
  String get downloadFolder => 'ダウンロード保存先';

  @override
  String get downloadAllAudio => 'フォルダ内の全音声をダウンロード';

  @override
  String get starredSongs => 'お気に入りの曲';

  @override
  String get starredSongsDesc => 'Navidrome サーバーでスター付きの曲';

  @override
  String get starredArtists => 'お気に入りアーティスト';

  @override
  String get shuffleAlbumOrder => 'アルバム順序をシャッフル';

  @override
  String get threeDView => '3D ビュー';

  @override
  String receiveFailed(Object fileName) {
    return '「$fileName」の受信に失敗しました';
  }

  @override
  String get quickPresets => 'クイックプリセット';

  @override
  String get presetStandard => '100% 標準';

  @override
  String get presetModerate => '125% 中間';

  @override
  String get presetCarRecommended => '135% 車載推奨';

  @override
  String get presetLarge => '150% 大';

  @override
  String get safFallbackScanningNotice =>
      '（メディア権限が付与されていないため、SAF互換スキャンを使用しています。処理が遅くなる場合があります）';

  @override
  String get justNow => 'たった今';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes分前';
  }

  @override
  String todayTime(Object time) {
    return '今日 $time';
  }

  @override
  String yesterdayTime(Object time) {
    return '昨日 $time';
  }

  @override
  String get playlists => 'プレイリスト';

  @override
  String get songs => '曲';

  @override
  String createdPlaylistSuccess(String name) {
    return 'プレイリストを作成しました: $name';
  }

  @override
  String get loadingAlbumTracks => 'アルバムの曲を読み込み中...';

  @override
  String get loadingArtistTracks => 'アーティストの曲を読み込み中...';

  @override
  String get loadingFolderAudio => 'フォルダの音声を読み込み中...';

  @override
  String get noAudioFilesInFolder => 'このフォルダ内に音声ファイルがありません';

  @override
  String failedToLoadFolder(String error) {
    return 'フォルダの読み込みに失敗しました: $error';
  }

  @override
  String get starFailed => 'お気に入り登録に失敗しました';

  @override
  String playAlbumFailed(String error) {
    return 'アルバムの再生に失敗しました: $error';
  }

  @override
  String get sortAllAZ => 'すべて (A-Z)';

  @override
  String get sortRecentlyPlayed => '最近再生した曲';

  @override
  String get sortMostPlayed => '最も再生された曲';

  @override
  String get sortStarred => 'お気に入り';

  @override
  String get sortRandom => 'シャッフル';

  @override
  String get filterAlbums => 'アルバムを絞り込み...';

  @override
  String get filterArtists => 'アーティストを絞り込み...';

  @override
  String get searchPlaylists => 'プレイリストを検索...';

  @override
  String get searchRemoteHint => '曲、アルバム、アーティストを検索...';

  @override
  String errorLoadingAlbums(String error) {
    return 'アルバムの読み込みに失敗しました: $error';
  }

  @override
  String get noAlbumsOnServer => 'サーバーにアルバムが見つかりません';

  @override
  String get noMatchingAlbums => '一致するアルバムがありません';

  @override
  String get playAlbum => 'アルバムを再生';

  @override
  String get shuffleAlbum => 'アルバムをシャッフル再生';

  @override
  String errorLoadingArtists(String error) {
    return 'アーティストの読み込みに失敗しました: $error';
  }

  @override
  String get noArtistsFound => 'アーティストが見つかりません';

  @override
  String get noMatchingArtists => '一致するアーティストがありません';

  @override
  String get noArtistSelected => 'アーティストが選択されていません';

  @override
  String errorLoadingPlaylists(String error) {
    return 'プレイリストの読み込みに失敗しました: $error';
  }

  @override
  String get noPlaylistsFound => 'プレイリストが見つかりません';

  @override
  String get noMatchingPlaylists => '一致するプレイリストがありません';

  @override
  String get noPlaylistSelected => 'プレイリストが選択されていません';

  @override
  String get typeToSearch => '入力して検索を開始';

  @override
  String get albumNotFound => 'アルバムの詳細が見つかりません';

  @override
  String playingTracksCount(int count) {
    return '$count 曲を再生中';
  }

  @override
  String get artistNotFound => 'サーバーにアーティストの詳細が見つかりません';

  @override
  String get noTracksForArtist => 'このアーティストの曲が見つかりません';

  @override
  String get noAlbumsForArtist => 'このアーティストのアルバムが見つかりません';

  @override
  String get playlistNotFound => 'サーバーにプレイリストの詳細が見つかりません';

  @override
  String removedFromPlaylistSuccess(String title) {
    return 'プレイリストから「$title」を削除しました';
  }

  @override
  String get removeTrackFailed => '曲の削除に失敗しました';

  @override
  String get playlistDeleted => 'プレイリストを削除しました';

  @override
  String get deletePlaylistFailed => 'プレイリストの削除に失敗しました';

  @override
  String byAuthor(String author) {
    return '作成者: $author';
  }

  @override
  String get downloadAllTracks => 'すべてダウンロード';

  @override
  String get downloadFailedGeneric => 'ダウンロード失敗';

  @override
  String downloadPaused(String progress) {
    return '一時停止中 ($progress%)';
  }

  @override
  String get waitingInQueue => '待機中...';

  @override
  String get downloadCancelled => 'キャンセル済み';

  @override
  String fileNotFoundAtPath(String path) {
    return 'ファイルが見つかりません: $path';
  }

  @override
  String addedTracksToPlaylistSuccess(int count, String name) {
    return '「$name」に $count 曲を追加しました';
  }

  @override
  String get addToPlaylistFailed => 'プレイリストへの追加に失敗しました';

  @override
  String errorAddingToPlaylist(String error) {
    return 'プレイリスト追加エラー: $error';
  }

  @override
  String createdPlaylistWithTracksSuccess(String name, int count) {
    return 'プレイリスト「$name」を作成し、$count 曲を追加しました';
  }

  @override
  String get createServerPlaylistFailed => 'サーバープレイリストの作成に失敗しました';

  @override
  String errorCreatingPlaylist(String error) {
    return 'プレイリスト作成エラー: $error';
  }

  @override
  String get noServerPlaylistsFound => 'サーバープレイリストが見つかりません';

  @override
  String get download => 'ダウンロード';

  @override
  String get resume => '再開';

  @override
  String get remove => '削除';

  @override
  String get refresh => '更新';

  @override
  String get copyFilePath => 'ファイルパスをコピー';

  @override
  String get openFolder => 'フォルダーを開く';

  @override
  String get copyFolderName => 'フォルダー名をコピー';

  @override
  String get copyFolderPath => 'フォルダーパスをコピー';

  @override
  String errorWithMessage(String error) {
    return 'エラー: $error';
  }

  @override
  String get importPlaylist => 'プレイリストをインポート';

  @override
  String get exportPlaylist => 'プレイリストをエクスポート';

  @override
  String get exportPlaylistAsM3u => 'M3Uとしてエクスポート';

  @override
  String importPlaylistSuccess(String name, int count) {
    return 'プレイリスト「$name」をインポートしました（$count曲）';
  }

  @override
  String get exportPlaylistSuccess => 'プレイリストをエクスポートしました';

  @override
  String importPlaylistFailed(String error) {
    return 'プレイリストのインポートに失敗しました: $error';
  }

  @override
  String exportPlaylistFailed(String error) {
    return 'プレイリストのエクスポートに失敗しました: $error';
  }

  @override
  String get noSongsInPlaylist => 'プレイリストに曲がありません';

  @override
  String get sendPlaylistsToDeviceAction => 'デバイスにプレイリストを送信';

  @override
  String get pullPlaylistsFromDeviceAction => 'デバイスからプレイリストを取得';

  @override
  String get selectPlaylistsToSend => '送信するプレイリストを選択';

  @override
  String sendPlaylistsSuccess(int count) {
    return '$count 個のプレイリストを送信しました';
  }

  @override
  String receivePlaylistsSuccess(int count) {
    return '$count 個のプレイリストを受信しました';
  }

  @override
  String pullPlaylistsSuccess(int count) {
    return '$count 個のプレイリストをインポートしました';
  }

  @override
  String sendPlaylistsFailed(String error) {
    return 'プレイリストの送信に失敗しました: $error';
  }

  @override
  String pullPlaylistsFailed(String error) {
    return 'プレイリストの取得に失敗しました: $error';
  }

  @override
  String syncingPlaylistsToDevice(String device) {
    return '「$device」へプレイリストを送信中...';
  }

  @override
  String syncingPlaylistsFromDevice(String device) {
    return '「$device」からプレイリストを取得中...';
  }

  @override
  String get incomingPlaylistImportTitle => 'プレイリスト共有リクエストを受信';

  @override
  String get incomingPlaylistExportTitle => 'プレイリストエクスポートリクエストを受信';

  @override
  String incomingPlaylistImportFrom(
    String senderName,
    int count,
    int songsCount,
  ) {
    return 'デバイス「$senderName」から $count 個のプレイリスト（計 $songsCount 曲）が送信されようとしています。';
  }

  @override
  String incomingPlaylistExportFrom(String senderName) {
    return 'デバイス「$senderName」があなたのプレイリストの読み取りと同期をリクエストしています。';
  }

  @override
  String get noPlaylistsAvailable => '利用可能なプレイリストがありません';

  @override
  String get playlistRequestRejected => 'プレイリストリクエストは相手に拒否されました';

  @override
  String get windowsAudioOutputTitle => '音频输出模式 (Windows)';

  @override
  String get windowsAudioOutputDescription =>
      '选择共享输出或 WASAPI 独占输出模式（独占模式可绕过 Windows 系统混音器，实现高保真 Bit-Perfect 点对点播放）。';

  @override
  String get audioOutputModeShared => '标准共享模式 (Shared)';

  @override
  String get audioOutputModeExclusive =>
      'WASAPI 独占模式 (Exclusive / Bit-Perfect)';

  @override
  String get audioOutputDeviceTitle => '音频输出设备';

  @override
  String get audioOutputDeviceDefault => '系统默认音频设备';

  @override
  String get wasapiBitPerfectTitle => '自动切换采样率 (Bit-Perfect)';

  @override
  String get wasapiBitPerfectDescription =>
      '跟随音源文件的原生采样率和声道动态配置 DAC 硬件输出，避免重采样失真。';

  @override
  String get wasapiReleaseOnPauseTitle => '暂停时释放独占占用';

  @override
  String get wasapiReleaseOnPauseDescription => '播放暂停时临时释放音频设备，允许其他应用程序发声。';

  @override
  String get activeHardwareFormatTitle => '当前硬件输出规格';

  @override
  String get activeHardwareFormatDescription => 'DAC 实际工作采样率与位深';

  @override
  String get activeHardwareBitPerfectBadge => 'Bit-Perfect 点对点直通';

  @override
  String get exclusiveModeTitle => '独占模式';

  @override
  String get exclusiveModeTooltip => 'WASAPI 独占模式已启用（已独占音频输出设备）';
}
