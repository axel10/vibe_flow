// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Vynody';

  @override
  String get alwaysOnTop => 'Her Zaman Üstte';

  @override
  String get systemMediaLibrary => 'Sistem Medya Kitaplığı';

  @override
  String get scanningDirectory => 'Dizin taranıyor...';

  @override
  String filesPreprocessed(Object count) {
    return '$count ön işlendi';
  }

  @override
  String filesDiscovered(Object count) {
    return '$count bulundu';
  }

  @override
  String filesFullyProcessed(Object count) {
    return '$count tamamen işlendi';
  }

  @override
  String get directoryAddedSuccess => 'Dizin başarıyla eklendi';

  @override
  String get directoryAddedNoMusic =>
      'Dizin eklendi, ancak çalınabilir ses dosyası bulunamadı';

  @override
  String get scanDirectory => 'Dizini Tara';

  @override
  String get sort => 'Sırala';

  @override
  String get addRootDirectory => 'Kök Dizin Ekle';

  @override
  String get goBack => 'Geri Dön';

  @override
  String get noMediaLibraryPermission => 'Medya kitaplığı erişim izni yok';

  @override
  String get grantPermission => 'İzin Ver';

  @override
  String get needPermissionToScan =>
      'Yerel müzikleri taramak için izin gerekli';

  @override
  String get rebuildTagDatabase => 'Etiket Veritabanını Yeniden Oluştur';

  @override
  String get rebuildDatabase => 'Veritabanını Yeniden Oluştur';

  @override
  String get confirmRebuildDatabase =>
      'Tüm şarkıların etiket bilgilerini manuel olarak yenilemek istediğinizden emin misiniz? Kapakların ve meta verilerin yeniden yüklenmesi biraz zaman alabilir.';

  @override
  String get cancel => 'İptal';

  @override
  String get confirm => 'Tamam';

  @override
  String get rebuildingDatabase =>
      'Şarkı etiket veritabanı yeniden oluşturuluyor...';

  @override
  String get sortBy => 'Sıralama Ölçütü';

  @override
  String get sortScope => 'Kapsam';

  @override
  String get sortOrder => 'Sıralama Düzeni';

  @override
  String get title => 'Başlık';

  @override
  String get fileName => 'Dosya Adı';

  @override
  String get trackNumber => 'Parça Numarası';

  @override
  String get ascending => 'Artan';

  @override
  String get descending => 'Azalan';

  @override
  String get currentFolderScope => 'Geçerli Klasör';

  @override
  String get globalScope => 'Genel';

  @override
  String get visualizerSettings => 'Çalma Sayfası Ayarları';

  @override
  String get algorithm => 'Spektrum';

  @override
  String get appearance => 'Görünüm';

  @override
  String get spectrumAppearanceGroup => 'Spektrum Görünümü';

  @override
  String get spectrumAdvancedOptions => 'Gelişmiş Spektrum Seçenekleri';

  @override
  String get resetAlgorithm => 'Algoritmayı Sıfırla';

  @override
  String get resetAppearance => 'Görünümü Sıfırla';

  @override
  String get smoothing => 'Yumuşatma (Smoothing)';

  @override
  String get gravity => 'Yerçekimi (Gravity)';

  @override
  String get logScale => 'Logaritmik Ölçek (Log Scale)';

  @override
  String get contrast => 'Kontrast (Contrast)';

  @override
  String get normalization => 'Normalizasyon (Normalization)';

  @override
  String get multiplier => 'Kazanç Çarpanı (Multiplier)';

  @override
  String get skipHighFrequency => 'Yüksek Frekansları Atla';

  @override
  String get frequencyGroups => 'Frekans Grupları (Frequency Groups)';

  @override
  String get aggregationMode => 'Toplama Modu (Aggregation Mode)';

  @override
  String get opacity => 'Opaklık (Opacity)';

  @override
  String get enableGradient => 'Degradeleri Etkinleştir';

  @override
  String get startColor => 'Başlangıç Rengi';

  @override
  String get endColor => 'Bitiş Rengi';

  @override
  String get gradientRangeStop1 => 'Degrade Aralığı Stop 1';

  @override
  String get gradientRangeStop2 => 'Degrade Aralığı Stop 2';

  @override
  String get gradientRepeatMode => 'Degrade Tekrar Modu (TileMode)';

  @override
  String get color => 'Renk';

  @override
  String get followCoverColor => 'Kapak Rengine Uyarla';

  @override
  String get selectColor => 'Renk Seç';

  @override
  String get volume => 'Ses Düzeyi';

  @override
  String get clearQueue => 'Sırayı Temizle';

  @override
  String get confirmClearQueue =>
      'Geçerli sırayı temizlemek istediğinizden emin misiniz?';

  @override
  String get queueCleared => 'Sıra temizlendi';

  @override
  String get locateCurrentSong => 'Şu An Çalanı Bul';

  @override
  String get songNotInScannedFolders =>
      'Şu an çalan şarkı taranan dizinlerde yok';

  @override
  String get queue => 'Sıra';

  @override
  String get queueEmpty => 'Sıra boş';

  @override
  String selectedSongs(int count) {
    return '$count şarkı seçildi';
  }

  @override
  String get unknownArtist => 'Bilinmeyen Sanatçı';

  @override
  String deletedSongs(int count) {
    return '$count şarkı silindi';
  }

  @override
  String get delete => 'Sil';

  @override
  String get createPlaylist => 'Çalma Listesi Oluştur';

  @override
  String get playlistName => 'Çalma Listesi Adı';

  @override
  String get enterPlaylistName => 'Çalma listesi adı girin';

  @override
  String get playlistNameExists => 'Çalma listesi adı zaten mevcut';

  @override
  String get renamePlaylist => 'Çalma Listesini Yeniden Adlandır';

  @override
  String get deletePlaylist => 'Çalma Listesini Sil';

  @override
  String confirmDeletePlaylist(String name) {
    return '\"$name\" çalma listesini silmek istediğinizden emin misiniz?';
  }

  @override
  String get addToPlaylist => 'Çalma Listesine Ekle';

  @override
  String get selectAll => 'Tümünü Seç';

  @override
  String get addToQueue => 'Sıraya Ekle';

  @override
  String get addedToQueue => 'Sıraya eklendi';

  @override
  String songCount(int count) {
    return '$count şarkı';
  }

  @override
  String addedToPlaylist(int count, String playlist) {
    return '$count şarkı \"$playlist\" listesine eklendi';
  }

  @override
  String get createNewList => 'Yeni Liste Oluştur';

  @override
  String createdPlaylist(String name, int count) {
    return '\"$name\" oluşturuldu ve $count şarkı eklendi';
  }

  @override
  String get rename => 'Yeniden Adlandır';

  @override
  String get playlist => 'Çalma Listesi';

  @override
  String get mostPlayed => 'En Çok Çalınanlar';

  @override
  String get recentlyPlayed => 'Son Çalınanlar';

  @override
  String get recentlyAdded => 'Son Eklenenler';

  @override
  String get albums => 'Albümler';

  @override
  String get artists => 'Sanatçılar';

  @override
  String get mostPlayedDescription => 'Tamamlanan çalma sayısına göre';

  @override
  String get recentlyPlayedDescription =>
      'Harici dosyalar dahil en son çalınma zamanına göre';

  @override
  String get recentlyAddedDescription => 'Kitaplığa eklenme zamanına göre';

  @override
  String get allTime => 'Tüm Zamanlar';

  @override
  String get pastWeek => 'Geçen Hafta';

  @override
  String get pastMonth => 'Geçen Ay';

  @override
  String get past90Days => 'Son 90 Gün';

  @override
  String get noPlayHistory => 'Henüz çalma geçmişi yok';

  @override
  String get noPlayHistoryInRange => 'Bu zaman aralığında çalma geçmişi yok';

  @override
  String get noRecentlyPlayedSongs => 'Henüz çalma geçmişi yok';

  @override
  String get noRecentlyPlayedInRange => 'Bu zaman aralığında çalma geçmişi yok';

  @override
  String get noRecentlyAddedSongs => 'Kitaplıkta henüz şarkı yok';

  @override
  String get noRecentlyAddedInRange => 'Bu zaman aralığında eklenen şarkı yok';

  @override
  String get addedOn => 'Eklenme Tarihi';

  @override
  String get externalSourceTag => 'Harici';

  @override
  String get lastPlayed => 'Son Çalma';

  @override
  String playCountLabel(int count) {
    return '$count kez';
  }

  @override
  String get playAll => 'Tümünü Çal';

  @override
  String get shufflePlay => 'Karışık Çal';

  @override
  String get noAlbums => 'Henüz görüntülenecek albüm yok';

  @override
  String get noArtists => 'Henüz görüntülenecek sanatçı yok';

  @override
  String get searchAlbums => 'Albüm veya sanatçı ara';

  @override
  String get searchArtists => 'Sanatçı ara';

  @override
  String get albumSort => 'Sırala';

  @override
  String get sortArtistAsc => 'Sanatçı A-Z';

  @override
  String get sortTitleAsc => 'Albüm Adı A-Z';

  @override
  String get sortTrackCount => 'Şarkı Sayısı';

  @override
  String get sortDuration => 'Toplam Süre';

  @override
  String get sortRecentAdded => 'Son Eklenenler';

  @override
  String get sortAscending => 'Artan';

  @override
  String get sortDescending => 'Azalan';

  @override
  String get playNext => 'Sonrakini Çal';

  @override
  String get addToFavorites => 'Favorilere Ekle';

  @override
  String get removeFromFavorites => 'Favorilerden Kaldır';

  @override
  String get viewAlbumDetails => 'Albüm Ayrıntılarını Görüntüle';

  @override
  String get viewArtistDetails => 'Sanatçı Ayrıntılarını Görüntüle';

  @override
  String get openFileLocation => 'Dosya Konumunu Aç';

  @override
  String get copyAlbumTitle => 'Albüm Adını Kopyala';

  @override
  String get copyArtistName => 'Sanatçı Adını Kopyala';

  @override
  String albumCount(int count) {
    return '$count albüm';
  }

  @override
  String get emptyList => 'Liste boş';

  @override
  String get dragToAddMusic =>
      'Müzik eklemek için dosya veya klasörleri buraya sürükleyin';

  @override
  String get unknownAlbum => 'Bilinmeyen Albüm';

  @override
  String get managePlaylists => 'Çalma Listelerini Yönet';

  @override
  String get createNewPlaylist => 'Yeni Çalma Listesi Oluştur';

  @override
  String get defaultList => 'Varsayılan Liste';

  @override
  String get playbackMode => 'Çalma Modu';

  @override
  String get playbackOptions => 'Oynatma Seçenekleri';

  @override
  String get setVisualizerDisplay => 'Spektrum Görünümünü Ayarla';

  @override
  String get noPlaybackContent => 'Şu anda çalan içerik yok';

  @override
  String get file => 'Dosya';

  @override
  String get play => 'Çal';

  @override
  String get list => 'Kitaplık';

  @override
  String get queueTab => 'Sıra';

  @override
  String get more => 'Daha Fazla';

  @override
  String get settings => 'Ayarlar';

  @override
  String get themeMode => 'Tema Modu';

  @override
  String get themeModeSystem => 'Sistem';

  @override
  String get themeModeLight => 'Açık';

  @override
  String get themeModeDark => 'Koyu';

  @override
  String get themeColor => 'Tema Rengi';

  @override
  String get customThemeColor => 'Özel Tema Rengi';

  @override
  String get themeColorMikuTeal => 'Miku Camgöbeği';

  @override
  String get themeColorClassicBlue => 'Klasik Mavi';

  @override
  String get themeColorIrisPurple => 'İris Moru';

  @override
  String get themeColorViolet => 'Menekşe Moru';

  @override
  String get themeColorSakuraPink => 'Sakura Pembesi';

  @override
  String get themeColorCoralOrange => 'Mercan Turuncusu';

  @override
  String get themeColorAmberGold => 'Kehribar Sarısı';

  @override
  String get themeColorForestGreen => 'Orman Yeşili';

  @override
  String get themeColorAuroraCyan => 'Kutup Camgöbeği';

  @override
  String get themeColorCrimsonRed => 'Kızıl Kırmızı';

  @override
  String get themeColorSlateGrey => 'Arduvaz Grisi';

  @override
  String get immersiveTabBar => 'Sürükleyici Sekme Çubuğu';

  @override
  String get immersiveTabBarDescription =>
      'Fare hareket ettiğinde gezinti çubuğunu göster, 3 saniye hareketsizlikten sonra gizle';

  @override
  String get collapseButtonsInLandscapeLyrics =>
      'Yatay şarkı sözü modunda düğmeleri daralt';

  @override
  String get collapseButtonsInLandscapeLyricsDescription =>
      'Yatay sözler modunda 7 düğmeli satırı daralt, başlığı sola hizala ve sağda işlem düğmelerini göster';

  @override
  String get sampleStride => 'Örnekleme Adımı';

  @override
  String get sampleStrideDescription =>
      'Daha büyük değerler daha hızlı tarar ancak dalga formu hassasiyetini düşürür (varsayılan: 4)';

  @override
  String get waveformSegments => 'Dalga Formu Dilimleri';

  @override
  String get waveformSegmentsDescription =>
      'Görüntülenecek dalga formu çubuklarının sayısı (varsayılan: 80)';

  @override
  String get showDeveloperOptions => 'Geliştirici Seçeneklerini Göster';

  @override
  String get playbackBackground => 'Oynatma Arka Planı';

  @override
  String get playbackRadialGradient => 'Merkez Koyu Degrade';

  @override
  String get blurIntensity => 'Bulanıklık Yoğunluğu';

  @override
  String get blurredArtwork => 'Bulanık Kapak Resmi (Varsayılan)';

  @override
  String get dynamicMesh => 'Dinamik Akışkan Gradyan';

  @override
  String get solidColor => 'Düz Renk';

  @override
  String get customImage => 'Özel Resim';

  @override
  String get presetColors => 'Önceden Tanımlı Renkler';

  @override
  String get customColor => 'Özel Renk';

  @override
  String get uploadImage => 'Resim Seç';

  @override
  String get normalOpacity => 'Normal Koyu Katman Opaklığı';

  @override
  String get lyricsOpacity => 'Şarkı Sözü Koyu Katman Opaklığı';

  @override
  String get chooseImageError => 'Resim seçilemedi';

  @override
  String get noImageSelected => 'Resim seçilmedi';

  @override
  String get unknown => 'Bilinmeyen';

  @override
  String get playlistModeSingle => 'Tek Parça';

  @override
  String get playlistModeSingleLoop => 'Tek Parça Tekrar';

  @override
  String get playlistModeQueue => 'Çalma Sırası';

  @override
  String get playlistModeQueueLoop => 'Sıra Tekrarı';

  @override
  String get playlistModeAutoQueueLoop => 'Otomatik Sıra Tekrarı';

  @override
  String get visualizer => 'Görselleştirici';

  @override
  String get previous => 'Önceki';

  @override
  String get next => 'Sonraki';

  @override
  String get pause => 'Duraklat';

  @override
  String get autoMode => 'Otomatik Mod';

  @override
  String get advancedOptions => 'Gelişmiş Seçenekler';

  @override
  String get spectrumQuantity => 'Spektrum Çubuk Sayısı';

  @override
  String get speed => 'Hız';

  @override
  String get quantityHigh => 'Yüksek';

  @override
  String get quantityMedium => 'Orta';

  @override
  String get quantityLow => 'Düşük';

  @override
  String get speedFast => 'Hızlı';

  @override
  String get speedMedium => 'Orta';

  @override
  String get speedSlow => 'Yavaş';

  @override
  String get portraitFrequencyGroups => 'Dikey Frekans Grupları';

  @override
  String get landscapeFrequencyGroups => 'Yatay Frekans Grupları';

  @override
  String get portraitGap => 'Dikey Aralık';

  @override
  String get landscapeGap => 'Yatay Aralık';

  @override
  String get enableWaveformProgressBar =>
      'Dalga Formu İlerleme Çubuğunu Etkinleştir';

  @override
  String get enableWaveformProgressBarDescription =>
      'Klasik ilerleme çubuğu yerine parçanın gerçek dalga formunu göster';

  @override
  String get waveformLongPressSeekSpeed =>
      'Dalga Formu Uzun Basarak Sarma Hızı';

  @override
  String get waveformLongPressSeekSpeedDescription =>
      'Dalga formuna uzun basıldığında sarma hızını ayarlar';

  @override
  String get enableWaveformLongPressSeek =>
      'Dalga Formuna Uzun Basarak Sarmayı Etkinleştir';

  @override
  String get enableWaveformLongPressSeekDescription =>
      'Dalga formuna basılı tutarak hızlı ileri/geri sarın';

  @override
  String get randomMode => 'Rastgele Modu';

  @override
  String get randomHistory => 'Rastgele Çalma Geçmişi';

  @override
  String get randomRange => 'Rastgele Kapsamı';

  @override
  String get randomMethod => 'Rastgele Çalma Yöntemi';

  @override
  String get currentQueue => 'Geçerli Sıra';

  @override
  String get globalRange => 'Genel Kitaplık';

  @override
  String get completeRandom => 'Tamamen Rastgele';

  @override
  String get shuffleRandom => 'Karışık Rastgele';

  @override
  String get randomQueue => 'Rastgele Sıra';

  @override
  String get notSelected => 'Seçilmedi';

  @override
  String get saveTagsToFile => 'Etiketleri Dosyaya Kaydet';

  @override
  String get saveCurrentTagsToFile => 'Geçerli Etiketleri Dosyaya Kaydet';

  @override
  String get saveQueueTagsToFile => 'Sıradaki Etiketleri Dosyaya Kaydet';

  @override
  String get tagsSaved => 'Etiketler kaydedildi';

  @override
  String tagsSavedCount(Object count) {
    return 'Etiketler kaydedildi ($count şarkı)';
  }

  @override
  String get tagsSaveFailed => 'Etiketler kaydedilemedi';

  @override
  String tagsSaveFailedCount(Object count) {
    return '$count şarkı kaydedilemedi';
  }

  @override
  String unsupportedFormat(Object count) {
    return '$count şarkı etiket kaydetmeyi desteklemiyor (OGG/Opus)';
  }

  @override
  String get unsupportedFormatSingle =>
      'Bu ses formatı etiket kaydetmeyi desteklemiyor (OGG/Opus)';

  @override
  String get savingTags => 'Etiketler kaydediliyor...';

  @override
  String get noModifiedTagsToSave => 'Kaydedilecek değiştirilmiş etiket yok';

  @override
  String get clearPlaylist => 'Çalma Listesini Temizle';

  @override
  String get copyTitle => 'Başlığı Kopyala';

  @override
  String get transcodeAction => 'Dönüştür';

  @override
  String get transcodeSectionTitle => 'Ses Dönüştürme';

  @override
  String get transcodeSectionDescription =>
      'Ses formatı dönüştürme ve FFmpeg motoru ayarlarını yapılandırın.';

  @override
  String get transcodeDefaultFormat => 'Varsayılan Format';

  @override
  String get transcodeDefaultQuality => 'Varsayılan Kalite';

  @override
  String get transcodeTitle => 'Ses Dönüştürme';

  @override
  String transcodeSongCount(int count) {
    return '$count şarkı';
  }

  @override
  String transcodeCompletedCount(int count) {
    return '$count dosya dönüştürüldü';
  }

  @override
  String transcodeCompletedWithFailures(int success, int total, int failed) {
    return '$success / $total dosya dönüştürüldü, $failed başarısız';
  }

  @override
  String get transcodeFailedGeneric => 'Dönüştürme başarısız oldu';

  @override
  String get transcodePreparing => 'Hazırlanıyor...';

  @override
  String transcodeProgress(int current, int total) {
    return 'Dönüştürülüyor: $current / $total';
  }

  @override
  String get transcoding => 'Dönüştürülüyor...';

  @override
  String get startTranscode => 'Dönüştürmeyi Başlat';

  @override
  String transcodeEngine(Object engine) {
    return 'Motor: $engine';
  }

  @override
  String get transcodeUsingSystemFfmpeg => 'Sistem FFmpeg kullanılıyor';

  @override
  String transcodeUsingCustomFfmpeg(Object path) {
    return 'Özel FFmpeg kullanılıyor: $path';
  }

  @override
  String get transcodeFormat => 'Format';

  @override
  String get transcodeQualityPreset => 'Kalite Önayarı';

  @override
  String get transcodeQualityLow => 'Düşük (128 kbps)';

  @override
  String get transcodeQualityMedium => 'Orta (192 kbps)';

  @override
  String get transcodeQualityHigh => 'Yüksek (320 kbps)';

  @override
  String get transcodeQualityExtreme => 'En Yüksek Kalite';

  @override
  String get transcodeLosslessPresetHint =>
      'Kayıpsız formatlar (FLAC/WAV) orijinal ses kalitesini korur.';

  @override
  String get transcodeAdvancedOptions => 'Gelişmiş Dönüştürme Seçenekleri';

  @override
  String get transcodeAdvancedCustomized => 'Özel Parametreler';

  @override
  String get transcodeAdvancedFollowingPreset => 'Önayarı Takip Ediyor';

  @override
  String get transcodeLosslessAdvancedHint =>
      'Kayıpsız formatlarda bit hızı ayarı gerekmez.';

  @override
  String get transcodeBitRateInvalid => 'Geçersiz bit hızı değeri';

  @override
  String get transcodeBitRate => 'Bit Hızı';

  @override
  String get transcodeBitRateMode => 'Bit Hızı Modu (CBR/VBR)';

  @override
  String get transcodeEncodingEngine => 'Kodlama Motoru';

  @override
  String get transcodeSystemEncoder => 'Sistem Kodlayıcısı';

  @override
  String get transcodeFfmpegRustEncoder => 'Rust Native FFmpeg';

  @override
  String get transcodeAacEncoder => 'AAC Kodlayıcı';

  @override
  String get transcodeSampleRate => 'Örnekleme Hızı';

  @override
  String get transcodeChannels => 'Kanallar';

  @override
  String get transcodeResetToPreset => 'Önayara Sıfırla';

  @override
  String get transcodeResetLosslessOptions => 'Kayıpsız Seçenekleri Sıfırla';

  @override
  String get transcodeOutputDirectory => 'Çıktı Dizini';

  @override
  String get transcodeOutputPreview => 'Çıktı Önizlemesi';

  @override
  String get transcodeChooseDirectory => 'Dizin Seçin';

  @override
  String get transcodeUseSourceDirectory => 'Kaynak Dizinini Kullan';

  @override
  String get transcodeKeepSource => 'Kaynak Dosyayı Koru';

  @override
  String get transcodeMono => 'Mono (Tek Kanal)';

  @override
  String get transcodeStereo => 'Stereo (Çift Kanal)';

  @override
  String get openFolderLocation => 'Klasör Konumunu Aç';

  @override
  String get songTagsSavedToSourceFileAndApp =>
      'Etiketler kaynak dosyaya ve uygulamaya kaydedildi';

  @override
  String get songTagsSavedToApp => 'Etiketler uygulamaya kaydedildi';

  @override
  String get durationZero => '0:00';

  @override
  String get generateLyrics => 'Söz Oluştur';

  @override
  String get generateTimeline => 'Zaman Çizelgesi Oluştur';

  @override
  String get queueGenerateLyrics => 'Sıradaki İçin Söz Oluştur';

  @override
  String get pauseAutoScroll => 'Otomatik Kaydırmayı Duraklat';

  @override
  String get resumeAutoScroll => 'Otomatik Kaydırmayı Sürdür';

  @override
  String get translateLyrics => 'Sözleri Çevir';

  @override
  String get clearLyricsCache => 'Söz Önbelleğini Temizle';

  @override
  String get clearTranslationCache => 'Çeviri Önbelleğini Temizle';

  @override
  String get requery => 'Yeniden Sorgula';

  @override
  String get sleepTimerTitle => 'Uyku Zamanlayıcısı';

  @override
  String get sleepTimerDescription =>
      'Belirli bir süre sonra oynatmayı durdurun.';

  @override
  String get sleepTimerRunningTitle => 'Uyku Zamanlayıcısı Çalışıyor';

  @override
  String get sleepTimerRunningDescription =>
      'Kalan süre dolduğunda oynatma otomatik olarak duracaktır.';

  @override
  String get sleepTimerStopAfterCurrentSong => 'Geçerli Şarkı Bitince Durdur';

  @override
  String get remainingTime => 'Kalan Süre';

  @override
  String get startCountdown => 'Geri Sayımı Başlat';

  @override
  String get end => 'Bitir';

  @override
  String get equalizer => 'Ekolayzer';

  @override
  String get equalizerEnabledStatus => 'Ekolayzer etkinleştirildi';

  @override
  String get equalizerDisabledStatus => 'Ekolayzer devre dışı bırakıldı';

  @override
  String get effects => 'Efektler';

  @override
  String get playbackSpeed => 'Oynatma Hızı';

  @override
  String get normal => 'Normal';

  @override
  String get bassBoost => 'Bas Güçlendirme';

  @override
  String get preampGain => 'Ön Kazanç';

  @override
  String get reset => 'Sıfırla';

  @override
  String get close => 'Kapat';

  @override
  String get timelineAdjustmentTitle => 'Zaman Çizelgesi Ayarı';

  @override
  String get timelineAdjustmentDescription =>
      'Şarkı sözlerinin zamanlamasını milisaniye cinsinden kaydırın.';

  @override
  String timelineOffsetEarlier(Object seconds) {
    return '${seconds}s ileri';
  }

  @override
  String timelineOffsetLater(Object seconds) {
    return '${seconds}s geri';
  }

  @override
  String get timelineOffsetCurrent => 'Mevcut kayma: 0.0s';

  @override
  String get enterAcoustidApiKeyTitle => 'AcoustID API Anahtarını Girin';

  @override
  String get acoustidApiKeyDescription =>
      'Ses parmak izi alma için kullanılır. Boş bırakırsanız yerleşik varsayılan anahtar kullanılır.';

  @override
  String get acoustidApiKeyHint => 'AcoustID API Anahtarınızı yapıştırın';

  @override
  String get apiKey => 'API Anahtarı';

  @override
  String get save => 'Kaydet';

  @override
  String get enterLyricsTitle => 'Şarkı Sözlerini Girin';

  @override
  String get lyricsInputHint =>
      'Şarkı sözlerini buraya yapıştırın veya yazın. Çok satırlı metin desteklenir.';

  @override
  String get enterGoogleAiStudioApiKeyTitle =>
      'Google AI Studio API Anahtarını Girin';

  @override
  String get googleAiStudioApiKeyDescription =>
      'Google AI Studio\'da söz oluşturma, zaman çizelgesi hizalama ve çeviri için kullanılır.';

  @override
  String get pasteGoogleAiStudioApiKey =>
      'Google AI Studio API Anahtarını yapıştırın';

  @override
  String get enterOpenRouterApiKeyTitle => 'OpenRouter API Anahtarını Girin';

  @override
  String get openRouterApiKeyDescription =>
      'OpenRouter\'da söz oluşturma, zaman çizelgesi hizalama ve söz çevirisi için kullanılır.';

  @override
  String get pasteOpenRouterApiKey => 'OpenRouter API Anahtarını yapıştırın';

  @override
  String get enterGeminiApiKeyTitle => 'Gemini API Anahtarını Girin';

  @override
  String get geminiApiKeyDescription => 'Şarkı sözü çevirisi için kullanılır.';

  @override
  String get pasteGeminiApiKey => 'Gemini API Anahtarını yapıştırın';

  @override
  String get testConnection => 'Bağlantıyı Test Et';

  @override
  String get enterApiKey => 'API anahtarınızı girin';

  @override
  String get testingConnection => 'Bağlantı test ediliyor...';

  @override
  String get getKey => 'Anahtar al';

  @override
  String get editSongTagsTitle => 'Şarkı Etiketlerini Düzenle';

  @override
  String get changeArtwork => 'Kapağı Değiştir';

  @override
  String get clearArtwork => 'Kapağı Temizle';

  @override
  String get editSongTagsDescription =>
      'Değişiklikleri yalnızca uygulamaya kaydedebilir veya kaynak ses dosyasına da yazabilirsiniz.';

  @override
  String get artistLabel => 'Sanatçı';

  @override
  String get albumLabel => 'Albüm';

  @override
  String get trackNumberLabel => 'Parça Numarası';

  @override
  String get trackNumberMustBeInteger =>
      'Parça numarası bir tam sayı olmalıdır';

  @override
  String get leaveBlankKeepsCurrentValue =>
      'Bu alanı temizlemek için boş bırakın';

  @override
  String get currentFileFormatCannotWriteBack =>
      'Bu dosya formatı kaynak dosyaya yazmayı desteklemiyor. Değişiklikler yalnızca uygulamaya kaydedilir.';

  @override
  String get leaveBlankDoesNotClearOriginalValue =>
      'İpucu: Bir alanı boş bırakmak değerini temizler.';

  @override
  String get saveToApp => 'Uygulamaya Kaydet';

  @override
  String get saveToSourceFileAndApp => 'Kaynak Dosyaya ve Uygulamaya Kaydet';

  @override
  String get saveToSourceFileFailed =>
      'Kaynak dosyaya kaydedilemedi. Dosya formatının yazmayı desteklediğinden ve kullanımda olmadığından emin olun.';

  @override
  String get fileOccupiedByOtherApp =>
      'Dosya başka bir uygulama tarafından kullanılıyor ve yazılamıyor';

  @override
  String get saveFailed =>
      'Kaydetme başarısız oldu. Lütfen daha sonra tekrar deneyin.';

  @override
  String apiKeySaved(Object provider) {
    return '$provider API anahtarı kaydedildi';
  }

  @override
  String get apiKeySavedAcoustid => 'AcoustID API anahtarı kaydedildi';

  @override
  String get generalSectionTitle => 'Arayüz ve Davranış';

  @override
  String get generalSectionDescription =>
      'Görünüm, oynatma etkileşimleri ve pencere sistemi davranışlarını yapılandırın.';

  @override
  String get uiAppearanceGroup => 'Görünüm ve Ekran';

  @override
  String get playbackBehaviorGroup => 'Oynatma ve Etkileşim';

  @override
  String get systemWindowBehaviorGroup => 'Pencere ve Sistem Davranışı';

  @override
  String get interfaceLanguage => 'Arayüz Dili';

  @override
  String get interfaceLanguageDescription => 'Uygulama dilini değiştirin';

  @override
  String get scanSectionTitle => 'Tarama';

  @override
  String get scanSectionDescription =>
      'Bu seçenekler kitaplık taramasının ses dosyalarını nasıl ele alacağını denetler.';

  @override
  String get skipShortAudioDuringScan => 'Tarama sırasında kısa sesleri atla';

  @override
  String get skipShortAudioDuringScanDescription =>
      'Eşik değerinden kısa sesler kitaplığa eklenmez.';

  @override
  String get shortAudioScanThreshold => 'Kısa Ses Dosyalarını Filtrele';

  @override
  String get shortAudioScanThresholdDescription =>
      'Belirtilen süreden kısa ses dosyalarını atla';

  @override
  String shortAudioScanThresholdValue(Object seconds) {
    return '$seconds sn';
  }

  @override
  String get shortcutSettingsTitle => 'Kısayol Ayarları';

  @override
  String get shortcutSettingsDescription =>
      'Oynatıcı eylemleri için kısayolları yeniden atamak ve kaydetmek için tıklayın.';

  @override
  String get edit => 'Düzenle';

  @override
  String get lyricsSectionTitle => 'Şarkı Sözleri';

  @override
  String get lyricsSectionDescription =>
      'Bu ayarlar yalnızca söz oluşturma ve zaman çizelgesi hizalamayı etkiler.';

  @override
  String get lyricsTranslationTargetLanguageLabel => 'Çeviri hedef dili';

  @override
  String get lyricsTranslationTargetLanguageDescription =>
      'Varsayılan olarak sistem dilini kullanır veya manuel olarak seçebilirsiniz.';

  @override
  String get lyricsSaveMethodLabel => 'Şarkı Sözü Depolama Yeri';

  @override
  String get lyricsSaveMethodDescription =>
      'Dosyaya yazarken sözlerin nereye kaydedileceğini seçin.';

  @override
  String get lyricsSaveMethodOriginal => 'Kaynak Gibi';

  @override
  String get lyricsSaveMethodEmbedded => 'Gömülü';

  @override
  String get lyricsSaveMethodLrcFile => 'LRC Dosyası';

  @override
  String get lyricsStyleLabel => 'Şarkı Sözü Panel Stili';

  @override
  String get lyricsStyleDescription =>
      'Şarkı sözü paneli için görüntüleme ve etkileşim stilini seçin.';

  @override
  String get lyricsStyleTraditional => 'Geleneksel';

  @override
  String get lyricsStyleApple => 'Satır Satır Odaklı';

  @override
  String get resumeLyricsSync => 'Eşitlemeyi Sürdür';

  @override
  String get followSystemLanguage => 'Sistem Dilini Takip Et';

  @override
  String get autoSwitchLyricsProvider =>
      'Şarkı sözü sağlayıcısını otomatik değiştir';

  @override
  String get autoSwitchLyricsProviderEnabledDesc =>
      'Önce Google AI Studio denenir. Birincil ve yedek modeller 429 veya 5xx hatası verirse uygulama otomatik olarak OpenRouter\'a geçer.';

  @override
  String get autoSwitchLyricsProviderDisabledDesc =>
      'Otomatik geçişi etkinleştirmeden önce hem Google AI Studio hem de OpenRouter için API anahtarları gereklidir.';

  @override
  String get lyricsAiProviderTitle => 'Şarkı Sözü AI Sağlayıcısı';

  @override
  String get lyricsAiProviderDescription =>
      'Bu yalnızca söz oluşturma ve zaman çizelgesi hizalamayı etkiler. Çeviri her zaman Google AI Studio kullanır.';

  @override
  String get googleAiStudioApiKeySaved =>
      'Google AI Studio API anahtarı kaydedildi';

  @override
  String get googleAiStudioApiKeyMissing =>
      'Henüz Google AI Studio API anahtarı kaydedilmedi. Söz ve zaman çizelgesi oluşturma sizden anahtar isteyecektir.';

  @override
  String get openRouterApiKeySaved => 'OpenRouter API anahtarı kaydedildi';

  @override
  String get openRouterApiKeyMissing =>
      'Henüz OpenRouter API anahtarı kaydedilmedi. Söz ve zaman çizelgesi oluşturma sizden anahtar isteyecektir.';

  @override
  String get apiKeySavedStatus => 'Kaydedildi';

  @override
  String get apiKeyMissingStatus => 'Doldurulmadı';

  @override
  String get platformApiKeysSectionTitle => 'Platform API Anahtarları';

  @override
  String get fill => 'Doldur';

  @override
  String get modify => 'Değiştir';

  @override
  String get geminiModelsSectionTitle => 'Model Seç';

  @override
  String get geminiModelsSectionDescription =>
      'Bu modeller Google AI Studio\'da söz oluşturma, zaman çizelgesi hizalama ve çeviri için kullanılır.';

  @override
  String get primaryModelLabel => 'Birincil model';

  @override
  String get backupModelLabel => 'Yedek model';

  @override
  String get translationModelLabel => 'Çeviri modeli';

  @override
  String get fetching => 'Getiriliyor...';

  @override
  String get fetchModelList => 'Model listesini getir';

  @override
  String get restoreDefault => 'Varsayılana dön';

  @override
  String get acoustidSectionTitle => 'Parmak İzi Alma';

  @override
  String get acoustidApiKeyTitle => 'AcoustID API Anahtarı';

  @override
  String get acoustidApiKeyHelp =>
      'AcoustID ses parmak izi alma için kullanılır. Kendi API anahtarınızı kullanmanızı öneririz.';

  @override
  String get acoustidApiKeySaved => 'AcoustID API anahtarı kaydedildi';

  @override
  String get acoustidApiKeyDefault =>
      'Şu anda yerleşik varsayılan anahtar kullanılıyor. Kendi anahtarınızla değiştirmenizi öneririz.';

  @override
  String get applyForApiKey =>
      'API anahtarı edinin: https://acoustid.org/new-application';

  @override
  String get queueTabBarFavoriteAdded => 'Favorilere eklendi';

  @override
  String get queueTabBarFavoriteRemoved => 'Favorilerden kaldırıldı';

  @override
  String get tagCompletion => 'Etiket tamamlama';

  @override
  String get tagCompletionDescription =>
      'Etiketleri AcoustID ve MusicBrainz sonuçlarıyla eşleştirin';

  @override
  String get goToSettings => 'Ayarlara Git';

  @override
  String get searchReleaseTitles => 'Yayın başlıklarını ara';

  @override
  String get closeSearch => 'Aramayı kapat';

  @override
  String get refreshResults => 'Sonuçları yenile';

  @override
  String get filterMusicBrainzReleaseTitle =>
      'MusicBrainz yayın başlıklarını filtrele';

  @override
  String get clearSearch => 'Aramayı temizle';

  @override
  String get localTitle => 'Yerel başlık';

  @override
  String get queryConditions => 'Sorgu koşulları';

  @override
  String get musicBrainzLoading => 'MusicBrainz yükleniyor';

  @override
  String get musicBrainzLoadingWithResults =>
      'Mevcut sonuçlar panelde kalacaktır';

  @override
  String get musicBrainzLoadingHint => 'Lütfen bekleyin';

  @override
  String get musicBrainzQueryFailed => 'MusicBrainz sorgusu başarısız';

  @override
  String get musicBrainzNetworkErrorHint =>
      'İstek başarısız oldu; genellikle kararsız ağ, zaman aşımı veya sunucu reddinden kaynaklanır. Daha sonra tekrar deneyin.';

  @override
  String get musicBrainzFilteredEmptyHint =>
      'Geçerli filtreler altında bu anahtar kelimeyi içeren yayın başlığı bulunamadı.';

  @override
  String get musicBrainzEmptyHint =>
      'MusicBrainz kullanılabilir sonuç döndürmedi. Başlık, sanatçı veya albüm filtrelerini gevşetmeyi deneyin.';

  @override
  String get musicBrainzEmptyMoreCompleteHint =>
      'Daha sonra tekrar deneyin veya mevcut başlık/sanatçı bilgisinin eksiksiz olduğunu doğrulayın.';

  @override
  String get retry => 'Yeniden Dene';

  @override
  String get noMatchingRelease => 'Eşleşen yayın sürümü bulunamadı';

  @override
  String get noMatchingResults => 'Eşleşen sonuç bulunamadı';

  @override
  String get networkConnectionFailed => 'Ağ bağlantısı başarısız oldu';

  @override
  String get searchAgain => 'Tekrar ara';

  @override
  String get acoustidRecognitionRecords => 'AcoustID tanıma kayıtları';

  @override
  String get musicBrainzRecordings => 'MusicBrainz kayıtları';

  @override
  String get noExpandableReleaseGroups => 'Genişletilebilir yayın grubu yok';

  @override
  String get noExpandableReleases => 'Genişletilebilir yayın sürümü yok';

  @override
  String get noMatchingResultHint =>
      'Daha sonra tekrar deneyebilir veya şarkı başlığı/sanatçı bilgisinin doğruluğunu kontrol edebilirsiniz.';

  @override
  String releaseCountLabel(int count) {
    return '$count yayın sürümü';
  }

  @override
  String recordingCountLabel(int count) {
    return '$count kayıt';
  }

  @override
  String trackCountShort(int count) {
    return '$count parça';
  }

  @override
  String scoreLabel(int score) {
    return 'Skor: $score';
  }

  @override
  String matchScoreLabel(int score) {
    return 'Eşleşme %$score';
  }

  @override
  String get editQueryCondition => 'Sorgu Koşulunu Düzenle';

  @override
  String get enterNewQueryText => 'Yeni sorgu metnini girin';

  @override
  String get durationLabel => 'Süre';

  @override
  String get customShortcuts => 'Özel Kısayollar';

  @override
  String get pressShortcutCombo => 'Lütfen kısayol tuş kombinasyonuna basın';

  @override
  String get clickToRecord => 'Kaydetmek için tıklayın';

  @override
  String get searchingLyrics => 'Şarkı sözleri aranıyor...';

  @override
  String get noLyrics => 'Şarkı sözü bulunamadı';

  @override
  String get providerLabel => 'Sağlayıcı';

  @override
  String get modelLabel => 'Model';

  @override
  String get unspecified => 'Belirtilmemiş';

  @override
  String targetTimeLabel(String duration) {
    return 'Hedef süre: $duration';
  }

  @override
  String get songDeletedSkipped => 'Şarkı silindi, atlandı';

  @override
  String get songDeleted => 'Şarkı silindi';

  @override
  String get lyricsTaskUploading => 'Yükleniyor';

  @override
  String get lyricsTaskWaiting => 'Hazır olması bekleniyor';

  @override
  String get lyricsTaskRequesting => 'İstek gönderiliyor';

  @override
  String get lyricsTaskGenerating => 'Oluşturuluyor';

  @override
  String get lyricsTaskRetrying => 'Yeniden deneniyor';

  @override
  String get lyricsTaskProcessing => 'İşleniyor';

  @override
  String get unknownModel => 'Bilinmeyen model';

  @override
  String selectedFolders(int count) {
    return '$count klasör seçildi';
  }

  @override
  String foldersDeleted(int count) {
    return '$count klasör silindi';
  }

  @override
  String get persistentAccessDenied => 'Kalıcı klasör erişim izni reddedildi.';

  @override
  String get folderAddFailed => 'Klasör ekleme başarısız oldu.';

  @override
  String get sleepTimer => 'Uyku Zamanlayıcısı';

  @override
  String sleepTimerRemaining(Object duration) {
    return 'Uyku zamanlayıcısı: $duration';
  }

  @override
  String get unknownArtistOrAlbum => 'Bilinmeyen';

  @override
  String get pressAgainToExit => 'Çıkmak için tekrar basın';

  @override
  String get tagCompletionSuccessWithCover =>
      'Etiketler tamamlandı ve kaydedildi, kapak resmi geçici dizine indirildi';

  @override
  String get tagCompletionSuccess => 'Etiketler tamamlandı ve kaydedildi';

  @override
  String get selectOnlineLyrics => 'Çevrimiçi söz seçin';

  @override
  String get increaseLyricsFont => 'Söz yazı boyutunu artır';

  @override
  String get decreaseLyricsFont => 'Söz yazı boyutunu azalt';

  @override
  String get restoreDefaultSize => 'Varsayılan Boyuta Sıfırla';

  @override
  String get adjustLyricsFont => 'Söz Yazı Tipini Ayarla';

  @override
  String get searchingOnlineLyrics => 'Çevrimiçi sözler aranıyor...';

  @override
  String get onlineLyricsResults => 'Çevrimiçi Söz Sonuçları';

  @override
  String get untitledLyrics => 'Başlıksız sözler';

  @override
  String get hasTimeline => 'Zaman çizgili';

  @override
  String get viewLyricsDetails => 'Söz ayrıntılarını görüntüle';

  @override
  String get lyricsDetails => 'Şarkı Sözü Ayrıntıları';

  @override
  String get lyricsContent => 'Şarkı Sözü İçeriği';

  @override
  String get noLyricsContent => 'Söz içeriği yok';

  @override
  String get queryContentLabel => 'İçerik';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String dropAddedSongs(int addedCount) {
    return '$addedCount şarkı eklendi';
  }

  @override
  String dropAddedSongsWithExisting(int addedCount, int existingCount) {
    return '$addedCount şarkı eklendi, $existingCount zaten mevcuttu';
  }

  @override
  String get copyCover => 'Kapağı Panoya Kopyala';

  @override
  String get copyCoverSuccess => 'Kapak resmi panoya kopyalandı';

  @override
  String get searchLyricsPlaceholder =>
      'Aramak için şarkı adı, sanatçı veya söz girin';

  @override
  String get share => 'Paylaş';

  @override
  String get windowsSettingsTitle => 'Windows Özel Ayarları';

  @override
  String get fileAssociationTitle => 'Dosya İlişkilendirmesi';

  @override
  String get fileAssociationDescription =>
      'Yaygın müzik formatlarını (mp3, flac, wav vb.) bu uygulamayla ilişkilendirerek çift tıklamayla açın.';

  @override
  String get associateButton => 'İlişkilendir';

  @override
  String get disassociateButton => 'İlişkilendirmeyi Kaldır';

  @override
  String get associationSuccess =>
      'İlişkilendirme başarılı! Çift tıklama çalışmazsa Windows Varsayılan Uygulamalar ayarlarından Vynody\'yi seçin.';

  @override
  String get disassociationSuccess =>
      'Dosya ilişkilendirmesi başarıyla kaldırıldı.';

  @override
  String associationFailed(Object error) {
    return 'İlişkilendirme başarısız: $error';
  }

  @override
  String get onboardingTitle => 'Hoş Geldiniz';

  @override
  String get onboardingSubtitle =>
      'Müzik yolculuğunuza başlamak için birkaç basit adım.';

  @override
  String get onboardingStepFileAssociation => 'Dosya Türlerini İlişkilendir';

  @override
  String get onboardingFileAssociationDesc =>
      'Yaygın müzik formatlarını (mp3, flac, wav vb.) Vynody ile ilişkilendirerek dosya yöneticisinden çift tıklamayla doğrudan çalın.';

  @override
  String get onboardingFileAssociationTip =>
      'İlişkilendirmenin ardından sistem \'Birlikte aç\' menüsü gösterebilir. Listeden \'Vynody\'yi seçtiğinizden ve \'Her zaman bu uygulamayı kullan\'ı işaretlediğinizden emin olun.';

  @override
  String get onboardingStepRootDirectory => 'Müzik Kök Dizinini Ekle';

  @override
  String get onboardingRootDirectoryDesc =>
      'Müzik dosyalarınızın saklandığı klasörü seçin. Vynody yerel müzik kitaplığınızı otomatik olarak tarayacak ve oluşturacaktır.';

  @override
  String get onboardingAndroidPermissionTip =>
      'Not: Android\'de yerel müzikleri içe aktarmak ve taramak için medya kitaplığı erişim izni vermeniz gerekir. [Klasör Seç] düğmesine bastığınızda izin istenecektir, lütfen izin verin.';

  @override
  String get onboardingSelectDirectory => 'Klasör Seç';

  @override
  String get onboardingSuccessTitle => 'Her Şey Hazır!';

  @override
  String get onboardingSuccessDesc =>
      'Medya kitaplığınız başarıyla eklendi. Müziğin keyfini çıkarmaya başlayalım!';

  @override
  String get onboardingStartButton => 'Vynody\'ye Başla';

  @override
  String get onboardingSkip => 'Daha Sonra Kur';

  @override
  String get onboardingNext => 'İleri';

  @override
  String get onboardingBack => 'Geri';

  @override
  String get resetOnboarding => 'Başlangıç Rehberini Sıfırla';

  @override
  String get resetOnboardingDesc =>
      'İlk açılış rehberi durumunu sıfırlar. Uygulama bir sonraki başlatmada başlangıç rehberini tekrar gösterir.';

  @override
  String get songProperties => 'Şarkı Özellikleri';

  @override
  String get failedToLoadDetails => 'Ayrıntılar alınamadı';

  @override
  String get noPropertiesAvailable => 'Ayrıntılı şarkı özelliği bulunamadı';

  @override
  String get detailFilePath => 'Dosya Yolu';

  @override
  String get detailFormat => 'Format';

  @override
  String get detailCodec => 'Kod Çözücü (Codec)';

  @override
  String get detailDuration => 'Süre';

  @override
  String get detailFileSize => 'Dosya Boyutu';

  @override
  String get detailBitrate => 'Bit Hızı';

  @override
  String get detailSampleRate => 'Örnekleme Hızı';

  @override
  String get detailChannels => 'Kanal Sayısı';

  @override
  String get detailBitDepth => 'Örnekleme Derinliği';

  @override
  String get detailMono => 'Tek Kanal (Mono)';

  @override
  String get detailStereo => 'Çift Kanal (Stereo)';

  @override
  String detailChannelsCount(int count) {
    return '$count Kanal';
  }

  @override
  String get localNetworkPermissionDeniedTitle => 'Yerel Ağ Erişimi Kısıtlandı';

  @override
  String get localNetworkPermissionDeniedMessage =>
      'Yerel IP adresi bulunamadı veya yerel ağ erişim izni reddedildi.\n\nLütfen şunları kontrol edin:\n1. Cihazınızın Wi-Fi veya yerel bir ağa bağlı olduğundan emin olun.\n2. Sistem ayarlarında uygulamanın yerel ağa erişmesine izin verildiğinden emin olun:\n   - iOS/macOS: Ayarlar > Gizlilik ve Güvenlik > Yerel Ağ bölümüne gidin ve Vynody\'yi etkinleştirin.\n   - Windows: Bağlı olduğunuzdan emin olun ve Windows Güvenlik Duvarı\'nın Vynody\'ye izin verdiğini kontrol edin.';

  @override
  String get localNetworkPermissionWindowsMessage =>
      'Yerel IP adresi algılanamadı.\n\nKontrol edin:\n1. Yerel ağ bağlantısı.\n2. Vynody\'ye izin vermek için Windows Güvenlik Duvarı\'nı kontrol edin.';

  @override
  String get openSettingsButton => 'Ayarları Aç';

  @override
  String get closeButton => 'Kapat';

  @override
  String get copyTranslationResults => 'Çeviri sonuçlarını kopyala';

  @override
  String get writeLyricsToFile => 'Sözleri dosyaya yaz';

  @override
  String get selectLyricSource => 'Söz kaynağını seçin';

  @override
  String get regenerateLyrics => 'Şarkı Sözlerini Yeniden Oluştur';

  @override
  String get regenerateLyricsConfirmation =>
      'Mevcut sözler temizlenecek ve yeniden oluşturulacaktır. Devam edilsin mi?';

  @override
  String get regenerateTimeline => 'Zaman Çizelgesini Yeniden Oluştur';

  @override
  String get regenerateTimelineConfirmation =>
      'Mevcut zaman çizelgesi temizlenecek ve yeniden oluşturulacaktır. Devam edilsin mi?';

  @override
  String get retranslateLyrics => 'Şarkı Sözlerini Yeniden Çevir';

  @override
  String get retranslateLyricsConfirmation =>
      'Mevcut çeviri temizlenecek ve yeniden çevrilecektir. Devam edilsin mi?';

  @override
  String get translationCopiedToClipboard =>
      'Çeviri sonuçları panoya kopyalandı';

  @override
  String get writingLyrics => 'Sözler yazılıyor...';

  @override
  String get lyricsWrittenToFile => 'Şarkı sözleri dosyaya başarıyla yazıldı';

  @override
  String get writeLyricsFailed => 'Sözler dosyaya yazılamadı';

  @override
  String get externalLrcFile => 'Aynı isimli harici LRC dosyası';

  @override
  String get embeddedLyrics => 'Gömülü Şarkı Sözleri';

  @override
  String get manuallyAdjustedLyrics => 'Manuel olarak düzenlenen sözler';

  @override
  String get lrclibOnlineLyrics => 'LrcLib çevrimiçi sözleri';

  @override
  String get aiGeneratedLyrics => 'AI ile oluşturulan sözler';

  @override
  String get matchScore => 'Eşleşme Skoru';

  @override
  String get untitledRelease => 'Başlıksız Yayın';

  @override
  String get localSongFileNotFoundForGeneration =>
      'Yerel şarkı dosyası bulunamadı, söz oluşturulamıyor.';

  @override
  String get localSongFileNotFoundForTimeline =>
      'Yerel şarkı dosyası bulunamadı, zaman çizelgesi oluşturulamıyor.';

  @override
  String get noLyricsForTimelineGeneration =>
      'Kullanılabilir söz yok, zaman çizelgesi oluşturulamıyor.';

  @override
  String get noLyricsAvailableForTranslation =>
      'Çeviri için uygun şarkı sözü bulunamadı.';

  @override
  String get noCurrentSongAvailable => 'Şu anda çalınan şarkı yok.';

  @override
  String get invalidTargetLanguage => 'Hedef dil geçersiz.';

  @override
  String get songAlreadyQueuedForTranslation =>
      'Geçerli şarkının söz çevirisi zaten kuyrukta veya işleniyor.';

  @override
  String get songAlreadyQueuedForGeneration =>
      'Geçerli şarkının söz oluşturma görevi zaten kuyrukta veya işleniyor.';

  @override
  String get songNoLongerExistsForTranslation =>
      'Geçerli şarkı artık mevcut değil, sözler çevrilemiyor.';

  @override
  String get generationFailed => 'Oluşturma başarısız oldu.';

  @override
  String get generatingLyrics => 'AI şarkı sözlerini oluşturuyor...';

  @override
  String get generatingTimeline => 'AI zaman çizelgesini oluşturuyor...';

  @override
  String get regeneratingLyrics => 'Şarkı sözleri yeniden oluşturuluyor';

  @override
  String get translatingLyrics => 'AI şarkı sözlerini çeviriyor...';

  @override
  String get transcodingSongFile => 'Şarkı dosyası dönüştürülüyor';

  @override
  String get uploadingSongFile => 'Şarkı dosyası yükleniyor';

  @override
  String get fileUploadedWaitingForReadiness =>
      'Dosya yüklendi, hazır olması bekleniyor';

  @override
  String get waitingForFileReadiness => 'Dosyanın hazır olması bekleniyor';

  @override
  String get requestingModelResponse => 'Model yanıtı isteniyor';

  @override
  String retryingTaskKindGeneration(Object taskKind) {
    return '$taskKind oluşturma yeniden deneniyor';
  }

  @override
  String get retrying => 'Yeniden deneniyor';

  @override
  String get processing => 'İşleniyor';

  @override
  String get timeline => 'zaman çizelgesi';

  @override
  String get lyrics => 'Şarkı Sözleri';

  @override
  String lyricGenerationError(Object error) {
    return 'Söz oluşturulurken hata: $error';
  }

  @override
  String timelineGenerationError(Object error) {
    return 'Zaman çizelgesi oluşturulurken hata: $error';
  }

  @override
  String get unknownGenerationError =>
      'Sözler oluşturulurken bilinmeyen bir hata meydana geldi.';

  @override
  String get unknownTimelineGenerationError =>
      'Zaman çizelgesi oluşturulurken bilinmeyen bir hata meydana geldi.';

  @override
  String get unknownTranslationError =>
      'Sözler çevrilirken bilinmeyen bir hata meydana geldi.';

  @override
  String get unknownError => 'Bilinmeyen hata';

  @override
  String get modelRefusedToGenerateLyrics =>
      'Model sözleri oluşturmayı reddetti.';

  @override
  String get modelRefusedToGenerateTimeline =>
      'Model zaman çizelgesini oluşturmayı reddetti.';

  @override
  String get doubaoPreUploadTranscodingFailed =>
      'Doubao yüklemesi öncesinde ses dönüştürme başarısız oldu.';

  @override
  String get doubaoTempTranscodeNotInTempDir =>
      'Geçici dönüştürülen dosya geçici dizinde oluşturulamadı.';

  @override
  String get doubaoEmptyStreamingResponse =>
      'Doubao boş bir akış yanıtı döndürdü.';

  @override
  String get doubaoEmptyResponse => 'Doubao boş bir yanıt döndürdü.';

  @override
  String get geminiEmptyStreamingResponse =>
      'Gemini boş bir akış yanıtı döndürdü.';

  @override
  String get geminiEmptyResponse => 'Gemini boş bir yanıt döndürdü.';

  @override
  String get openRouterEmptyStreamingResponse =>
      'OpenRouter boş bir akış yanıtı döndürdü.';

  @override
  String get openRouterEmptyResponse => 'OpenRouter boş bir yanıt döndürdü.';

  @override
  String get deepseekEmptyStreamingResponse =>
      'DeepSeek boş bir akış yanıtı döndürdü.';

  @override
  String get deepseekEmptyResponse => 'DeepSeek boş bir yanıt döndürdü.';

  @override
  String get customProviderEmptyStreamingResponse =>
      'Özel sağlayıcı boş bir akış yanıtı döndürdü.';

  @override
  String get customProviderEmptyResponse =>
      'Özel sağlayıcı boş bir yanıt döndürdü.';

  @override
  String get fileUploadFailed => 'Dosya yüklenemedi. Lütfen tekrar deneyin.';

  @override
  String get uploadedFileNotReady =>
      'Yüklenen dosya henüz hazır değil. Lütfen biraz sonra tekrar deneyin.';

  @override
  String get audioTranscodingFailed => 'Ses dönüştürme işlemi başarısız oldu.';

  @override
  String get tempTranscodeNotInTempDir =>
      'Geçici dönüştürülen dosya geçici dizinde bulunamadı.';

  @override
  String get networkRequestFailedCheckProxy =>
      'Ağ isteği başarısız oldu. Lütfen ağ ve vekil sunucu (proxy) ayarlarınızı kontrol edin.';

  @override
  String get quotaExhaustedToday =>
      'Bugünkü kota tükendi. Lütfen yarın sıfırlandıktan sonra tekrar deneyin.';

  @override
  String get googleAiHeavyLoad =>
      'Google AI sunucularında yoğunluk var ve geçici olarak kullanılamıyor.';

  @override
  String lyricsGenerationFailedWithError(Object error) {
    return 'Söz oluşturma başarısız: $error';
  }

  @override
  String missingApiKeyForAction(Object action, Object providerName) {
    return '$providerName API anahtarı bulunamadı, $action kullanılamaz.';
  }

  @override
  String locationNotSupportedForModel(String modelName) {
    return 'Konumunuz $modelName için desteklenmiyor';
  }

  @override
  String get googleServerFlaky =>
      'Google sunucuları şu anda yanıt vermekte zorlanıyor. Lütfen tekrar deneyin.';

  @override
  String get translateLyricsAction => 'şarkı sözlerini çevir';

  @override
  String get generateLyricsAction => 'şarkı sözü oluştur';

  @override
  String get generateTimelineAction => 'zaman çizelgesi oluştur';

  @override
  String get deepseekOnlyTranslation =>
      'DeepSeek yalnızca şarkı sözü çevirisi için kullanılabilir.';

  @override
  String get customProviderOnlyTranslation =>
      'Özel sağlayıcı yalnızca şarkı sözü çevirisi için kullanılabilir.';

  @override
  String get customProviderNoBaseUrl =>
      'Özel sağlayıcı API Base URL adresi yapılandırılmamış.';

  @override
  String get pleaseEnterApiKey => 'Lütfen bir API anahtarı girin.';

  @override
  String get connectionSuccessVerificationPassed =>
      'Bağlantı başarılı, doğrulama geçti.';

  @override
  String connectionSuccessDetectedModels(Object count) {
    return 'Bağlantı başarılı, $count model algılandı.';
  }

  @override
  String testFailedWithStatus(Object message, Object statusCode) {
    return 'Test başarısız ($statusCode): $message';
  }

  @override
  String get testFailedCheckNetworkOrApiKey =>
      'Test başarısız oldu. Lütfen ağ bağlantınızı veya API anahtarınızı kontrol edin.';

  @override
  String testFailedStatusCheckApiKey(Object statusCode) {
    return 'Test başarısız ($statusCode). Lütfen API anahtarının geçerli olduğunu kontrol edin.';
  }

  @override
  String get enterGoogleAiStudioApiKeyFirst =>
      'Lütfen önce bir Google AI Studio API anahtarı girin.';

  @override
  String get enterDoubaoApiKeyFirst =>
      'Lütfen önce bir Doubao API anahtarı girin.';

  @override
  String get enterDeepseekApiKeyFirst =>
      'Lütfen önce bir DeepSeek API anahtarı girin.';

  @override
  String get enterCustomApiKeyAndBaseUrl =>
      'Lütfen önce özel API anahtarını ve Base URL adresini girin.';

  @override
  String fetchedCountModels(Object count) {
    return '$count model başarıyla getirildi.';
  }

  @override
  String requestFailedWithStatus(Object message, Object statusCode) {
    return 'İstek başarısız ($statusCode): $message';
  }

  @override
  String get requestFailedCheckNetwork =>
      'İstek başarısız oldu. Ağ bağlantınızı kontrol edin.';

  @override
  String requestFailedStatus(Object statusCode) {
    return 'İstek başarısız ($statusCode).';
  }

  @override
  String get doubao => 'Doubao';

  @override
  String get custom => 'Özel';

  @override
  String get noModelSelected => 'Model seçilmedi';

  @override
  String get acoustidRequestFailed => 'AcoustID isteği başarısız oldu';

  @override
  String acoustidRequestReturnedStatus(Object statusCode) {
    return 'AcoustID isteği $statusCode kodu döndürdü. Lütfen kendi AcoustID API anahtarınızı alın ve ayarlara girin.';
  }

  @override
  String get writeTagDatabaseFailed => 'Etiket veritabanına yazılamadı';

  @override
  String get playPause => 'Çal / Duraklat';

  @override
  String get nextTrack => 'Sonraki';

  @override
  String get previousTrack => 'Önceki';

  @override
  String get volumeUp => 'Sesi Artır';

  @override
  String get volumeDown => 'Sesi Azalt';

  @override
  String get toggleMute => 'Sesi Aç/Kapat';

  @override
  String get seekForward5s => '5s İleri Al';

  @override
  String get seekBackward5s => '5s Geri Al';

  @override
  String get toggleFullScreen => 'Tam Ekranı Aç/Kapat';

  @override
  String get playPauseDescription => 'Geçerli oynatma durumunu kontrol eder.';

  @override
  String get nextDescription => 'Sonraki şarkıya geçer.';

  @override
  String get previousDescription => 'Önceki şarkıya döner.';

  @override
  String get volumeUpDescription => 'Ses düzeyini her seferinde %5 artırır.';

  @override
  String get volumeDownDescription => 'Ses düzeyini her seferinde %5 azaltır.';

  @override
  String get toggleMuteDescription => 'Sesi tamamen kapatır veya açar.';

  @override
  String get seekForward5sDescription => 'Oynatmayı 5 saniye ileri sarar.';

  @override
  String get seekBackward5sDescription => 'Oynatmayı 5 saniye geri sarar.';

  @override
  String get toggleFullScreenDescription =>
      'Pencereli mod ile tam ekran modu arasında geçiş yapar.';

  @override
  String get unknownKey => 'Bilinmeyen tuş';

  @override
  String get removeFromQueue => 'Sıradan Kaldır';

  @override
  String get removeFromPlaylist => 'Çalma Listesinden Kaldır';

  @override
  String get alreadyLatestVersion => 'Zaten en güncel sürümü kullanıyorsunuz.';

  @override
  String get updateAvailable => 'Güncelleme Mevcut';

  @override
  String newVersionAvailable(Object version) {
    return 'Yeni sürüm v$version mevcut. GitHub Release sayfasından indirin.';
  }

  @override
  String get openRelease => 'Yayın Sayfasını Aç';

  @override
  String get checkUpdateFailedNetwork =>
      'Güncellemeler denetlenemedi. Ağ sorunu veya GitHub hız sınırı olabilir.';

  @override
  String get tags => 'Etiketler';

  @override
  String get about => 'Hakkında';

  @override
  String get rebuildIndex => 'Dizini Yeniden Oluştur';

  @override
  String get rebuildIndexDescription =>
      'Harici kaynaklar hariç tüm şarkı kayıtlarını temizler ve tüm kök dizinleri yeniden tarar.';

  @override
  String get rebuildIndexConfirmation =>
      'Harici kaynaklar hariç tüm şarkı kayıtlarını temizlemek ve tüm kök dizinleri yeniden taramak istediğinizden emin misiniz? Bu işlem biraz zaman alabilir.';

  @override
  String get rebuildIndexStarted => 'Dizini yeniden oluşturma başlatıldı';

  @override
  String get rebuild => 'Yeniden Oluştur';

  @override
  String get advanced => 'Gelişmiş';

  @override
  String get advancedOptionsDescription =>
      'Hata ayıklama ve davranış ayarlama seçenekleri.';

  @override
  String get showDeveloperOptionsDescription =>
      'Hata ayıklamaya yönelik gelişmiş seçenekleri gösterir.';

  @override
  String get onboardingReset =>
      'Başlangıç kurulumu sıfırlandı. Bir sonraki başlatmada geçerli olacaktır.';

  @override
  String get tagsSectionDescription =>
      'Ses dosyası meta verilerini ve otomatik tamamlamayı yapılandırın.';

  @override
  String get autoSaveToSourceFile => 'Kaynak Dosyaya Otomatik Kaydet';

  @override
  String get autoSaveToSourceFileDescription =>
      'Tamamlandığında etiketleri otomatik olarak fiziksel ses dosyasına geri yazar.';

  @override
  String get aboutSectionDescription =>
      'Sürüm bilgisi, proje bağlantıları ve ilgili ayrıntılar.';

  @override
  String get checkForUpdates => 'Güncellemeleri Denetle';

  @override
  String get storeUpdateNotice =>
      'Bu uygulamanın güncellemeleri Microsoft Store tarafından yönetilmektedir. En son sürümü Microsoft Store\'dan kontrol edebilirsiniz.';

  @override
  String get openMicrosoftStore => 'Microsoft Store\'a Git';

  @override
  String get appStoreUpdateNotice =>
      'Bu uygulamanın güncellemeleri App Store tarafından yönetilmektedir. En son sürümü App Store\'dan kontrol edebilirsiniz.';

  @override
  String get openAppStore => 'App Store\'a Git';

  @override
  String get lyricsGenerationModel => 'Şarkı Sözü Oluşturma Modeli';

  @override
  String get lyricsGenerationModelDescription =>
      'AI ile söz oluşturma ve zaman çizelgesi hizalama için kullanılır.';

  @override
  String get lyricsTranslationModel => 'Şarkı Sözü Çeviri Modeli';

  @override
  String get lyricsTranslationModelDescription =>
      'Şarkı sözlerini hedef dile çevirmek için kullanılır.';

  @override
  String get onlyForLyricTranslation => 'Yalnızca şarkı sözü çevirisi için';

  @override
  String get fillApiKeyFirstEnablesModels =>
      'Model seçimini etkinleştirmek için lütfen en az bir API anahtarı girin.';

  @override
  String get customApiProvider => 'Özel API Sağlayıcı';

  @override
  String get clearedGoogleAiStudioApiKey =>
      'Google AI Studio API anahtarı temizlendi';

  @override
  String get clearedOpenRouterApiKey => 'OpenRouter API anahtarı temizlendi';

  @override
  String get clearedDoubaoApiKey => 'Doubao API anahtarı temizlendi';

  @override
  String get clearedDeepseekApiKey => 'DeepSeek API anahtarı temizlendi';

  @override
  String get clearedCustomProviderConfig =>
      'Özel sağlayıcı yapılandırması temizlendi';

  @override
  String get savedDoubaoApiKey => 'Doubao API anahtarı kaydedildi';

  @override
  String get savedDeepseekApiKey => 'DeepSeek API anahtarı kaydedildi';

  @override
  String get savedCustomProviderConfig =>
      'Özel sağlayıcı yapılandırması kaydedildi';

  @override
  String get noMatchingFoldersOrSongs => 'Eşleşen klasör veya şarkı bulunamadı';

  @override
  String get searching => 'Aranıyor...';

  @override
  String get listView => 'Liste Görünümü';

  @override
  String get gridView => 'Izgara Görünümü';

  @override
  String get hybridView => 'Karma Görünüm';

  @override
  String songsCountFormat(Object count) {
    return '$count şarkı';
  }

  @override
  String get searchInFolderAndSubfolders => 'Klasör ve alt klasörlerde ara...';

  @override
  String get shuffle => 'Karışık Çal';

  @override
  String get search => 'Ara';

  @override
  String get selectFolders => 'Klasörleri Seç';

  @override
  String get removeDirectory => 'Dizini Kaldır';

  @override
  String removeRootDirectoryConfirmation(Object name) {
    return '\"$name\" kök dizinini kaldırmak istediğinizden emin misiniz? Bu işlem diskteki fiziksel dosyaları silmez.';
  }

  @override
  String get deselectAll => 'Seçimi Kaldır';

  @override
  String get favorites => 'Favoriler';

  @override
  String get aggregationPeak => 'Tepe Değer (Peak)';

  @override
  String get aggregationMean => 'Ortalama (Mean)';

  @override
  String get aggregationRms => 'RMS';

  @override
  String get filesToTranscode => 'Dönüştürülecek Dosyalar';

  @override
  String get chooseAndroidOutputDirectoryFirst =>
      'Lütfen önce bir Android çıktı dizini seçin.';

  @override
  String currentSongProgressPercent(Object percent) {
    return 'Geçerli şarkı %$percent';
  }

  @override
  String overallProgressPercent(Object percent) {
    return 'Genel %$percent';
  }

  @override
  String get pleaseChooseOutputDirectory =>
      'Lütfen önce bir çıktı dizini seçin.';

  @override
  String selectedArtistsCount(Object count) {
    return '$count sanatçı seçildi';
  }

  @override
  String selectedAlbumsCount(Object count) {
    return '$count albüm seçildi';
  }

  @override
  String get simplifiedChinese => 'Basitleştirilmiş Çince';

  @override
  String get traditionalChinese => 'Geleneksel Çince';

  @override
  String get chineseLanguage => 'Çince';

  @override
  String get englishLanguage => 'İngilizce';

  @override
  String get japaneseLanguage => 'Japonca';

  @override
  String get koreanLanguage => 'Korece';

  @override
  String get frenchLanguage => 'Fransızca';

  @override
  String get germanLanguage => 'Almanca';

  @override
  String get spanishLanguage => 'İspanyolca';

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
  String get portugueseLanguage => 'Portekizce';

  @override
  String get russianLanguage => 'Rusça';

  @override
  String get systemLanguage => 'Sistem Dili';

  @override
  String get targetLanguage => 'Hedef Dil';

  @override
  String get whatAreAiLyrics => 'AI Şarkı Sözleri Nedir?';

  @override
  String get whatIsAiLyricTranslation => 'AI Şarkı Sözü Çevirisi Nedir?';

  @override
  String get aiLyricsIntroGeneration =>
      'AI, şarkı içeriğine göre sözleri oluşturabilir ve zaman çizelgesiyle otomatik eşleştirebilir.';

  @override
  String get aiLyricsIntroTranslation =>
      'AI, şarkı sözlerini anlamanızı kolaylaştırmak için bildiğiniz bir dile çevirebilir.';

  @override
  String get whyNeedApiKey => 'Neden bir API anahtarına ihtiyacım var?';

  @override
  String get apiKeyExplanation =>
      'AI modellerini kullanabilmek için ilgili sağlayıcının (OpenRouter, DeepSeek vb.) API anahtarı gereklidir. Anahtarınız yerel olarak saklanır.';

  @override
  String get apiKeyLocalOnly =>
      'API anahtarınız yalnızca cihazınızda yerel olarak saklanır ve asla harici sunuculara gönderilmez.';

  @override
  String get chooseAnAiProvider => 'Bir AI sağlayıcısı seçin:';

  @override
  String get googleProviderPros =>
      'Güçlü Gemini modelleri ve cömert ücretsiz kotalar sunan resmi Google kanalı.';

  @override
  String get googleProviderCons =>
      'Yüksek trafik zaman zaman 429 hatasına neden olabilir. Bu durumda başka bir sağlayıcıya geçebilirsiniz.';

  @override
  String get openRouterProviderPros =>
      'Birçok sağlayıcıya ve bazı ücretsiz modellere erişim sunan bir model toplayıcı.';

  @override
  String get openRouterProviderCons =>
      'Bakiye yüklemeleri işlem ücreti içerebilir ve web sitesi yalnızca İngilizcedir.';

  @override
  String get doubaoProviderPros =>
      'ByteDance tarafından geliştirilmiştir, Çince ve çoklu dilde güçlüdür. Yeni kullanıcılara model başına 500 bin ücretsiz belirteç verilir.';

  @override
  String get doubaoProviderCons =>
      'Kayıt işlemi nispeten karmaşıktır ve gerçek isim doğrulaması gerektirir.';

  @override
  String get deepseekProviderPros =>
      'İyi anlama yeteneği, düşük fiyatlandırma ve şarkı sözü çevirisi için çok uygundur.';

  @override
  String get deepseekProviderCons =>
      'Yalnızca metin girişi destekler. Söz oluşturma ve zaman çizelgesi hizalama için başka bir sağlayıcıdan API anahtarı gerekir.';

  @override
  String get highlights => 'Öne Çıkanlar';

  @override
  String get notes => 'Notlar';

  @override
  String enterProviderApiKey(Object provider) {
    return '$provider API anahtarınızı girin:';
  }

  @override
  String get pasteYourApiKey => 'API anahtarınızı buraya yapıştırın';

  @override
  String get getApiKey => 'API anahtarı al';

  @override
  String get testConnectionButton => 'Bağlantıyı test et';

  @override
  String get enableAiLyricGeneration => 'AI Şarkı Sözü Oluşturmayı Etkinleştir';

  @override
  String get enableAiLyricTranslation => 'AI Şarkı Sözü Çevirisini Etkinleştir';

  @override
  String get notNow => 'Şimdi Değil';

  @override
  String get startSetup => 'Kuruluma Başla';

  @override
  String get chooseAiProvider => 'AI Sağlayıcısı Seçin';

  @override
  String get backStep => 'Geri';

  @override
  String get continueAction => 'Devam Et';

  @override
  String get nextStep => 'İleri';

  @override
  String get configureApiKey => 'API Anahtarını Yapılandır';

  @override
  String get saveAndFinish => 'Kaydet ve Bitir';

  @override
  String get testing => 'Test ediliyor...';

  @override
  String get noteTitle => 'Not';

  @override
  String get deepseekTextInputOnlyNote =>
      'DeepSeek yalnızca metin girişini destekler. Söz oluşturma ve zaman çizelgesi hizalama için başka bir sağlayıcıdan API anahtarı gerekir.';

  @override
  String retryAttemptOfMax(Object attempt, Object maxRetry) {
    return 'Yeniden deneme: $attempt / $maxRetry';
  }

  @override
  String generatingTaskKind(Object taskKind) {
    return '$taskKind oluşturuluyor';
  }

  @override
  String connectionTestException(Object error) {
    return 'Bağlantı testi hatası: $error';
  }

  @override
  String get testingConnectionProgress => 'Bağlantı test ediliyor...';

  @override
  String get clear => 'Temizle';

  @override
  String get enterDoubaoApiKey => 'Doubao API Anahtarını Girin';

  @override
  String get doubaoApiKeyDescription =>
      'Söz oluşturma ve çeviri için lütfen Volcano/Doubao API anahtarınızı girin.';

  @override
  String get enterDeepseekApiKey => 'DeepSeek API Anahtarını Girin';

  @override
  String get deepseekApiKeyDescription =>
      'Yalnızca söz çevirisi için lütfen DeepSeek API anahtarınızı girin.';

  @override
  String get pleaseEnterApiKeyHint => 'Lütfen API anahtarını girin';

  @override
  String get platform => 'Platform';

  @override
  String get showRecommendedOnly => 'Yalnızca önerilenleri göster';

  @override
  String get noAvailableChannels => 'Kullanılabilir kanal yok';

  @override
  String get noMatchingModels => 'Eşleşen model bulunamadı';

  @override
  String get leaveEmpty => 'Boş bırak';

  @override
  String get leaveEmptyFallbackDescription =>
      'Yedek model ayarlamamak için bunu seçin.';

  @override
  String get modelSearchHint => 'Model adı veya ID girin';

  @override
  String sendFilesFailed(Object error) {
    return 'Dosya gönderme başarısız: $error';
  }

  @override
  String get scanningFolderMusic => 'Klasördeki müzik dosyaları taranıyor...';

  @override
  String scanFolderFailed(Object error) {
    return 'Klasör tarama başarısız: $error';
  }

  @override
  String get noMusicFilesFound =>
      'Bu klasörde desteklenen müzik dosyası bulunamadı';

  @override
  String sendFolderFailed(Object error) {
    return 'Klasör gönderme başarısız: $error';
  }

  @override
  String get lanSharingStartFailed =>
      'Yerel ağ paylaşımı başlatılamadı. Lütfen yerel ağ izinlerini kontrol edin.';

  @override
  String syncingLyricsToDevice(Object deviceName) {
    return '$deviceName cihazına şarkı sözleri senkronize ediliyor...';
  }

  @override
  String syncLyricsSuccess(Object matched, Object overwritten, Object skipped) {
    return 'Senkronizasyon tamamlandı: $matched eşleşti, $overwritten güncellendi, $skipped atlandı';
  }

  @override
  String syncLyricsFailed(Object error) {
    return 'Söz senkronizasyonu başarısız: $error';
  }

  @override
  String syncingLyricsFromDevice(Object deviceName) {
    return '$deviceName cihazından şarkı sözleri senkronize ediliyor...';
  }

  @override
  String get transferInProgressDoNotLeave =>
      'Aktarım devam ediyor, lütfen paylaşım sayfasından ayrılmayın';

  @override
  String get lanSharingTitle => 'Yerel Ağ Paylaşımı';

  @override
  String get lanSharingEnabledStatus => 'Yerel ağ paylaşımı etkinleştirildi';

  @override
  String get lanSharingDisabledStatus => 'Yerel ağ paylaşımı devre dışı';

  @override
  String lanSharingRunningStatus(Object ip, Object port) {
    return 'Yerel IP: $ip (Port: $port)';
  }

  @override
  String get lanSharingDefaultOffHint =>
      'Varsayılan olarak kapalıdır. Etkinleştirildiğinde yerel ağ izni istenecektir.';

  @override
  String get receiveDirectoryNotSetWarning =>
      'Dosya alabilmek için bir alıcı dizini ayarlanmalıdır. Lütfen bir dizin seçin.';

  @override
  String get receiveDirectoryNoWritePermission =>
      'Mevcut kayıt dizini için yazma izni yok. Lütfen değiştirin.';

  @override
  String get restoreDefaultDirectory => 'Varsayılan Dizini Geri Yükle';

  @override
  String get chooseOtherDirectory => 'Başka Bir Dizin Seç';

  @override
  String get receiveDirectoryRestoredDefault =>
      'Varsayılan alıcı dizini geri yüklendi';

  @override
  String receiveDirectoryUpdated(Object path) {
    return 'Alıcı dizini güncellendi: $path';
  }

  @override
  String get receiveDirectoryTitle => 'Alıcı Dizini';

  @override
  String get linkCopiedToClipboard => 'Bağlantı panoya kopyalandı';

  @override
  String get nearbyDevices => 'Yakındaki Cihazlar';

  @override
  String get searchingDevices => 'Yerel ağdaki diğer cihazlar aranıyor...';

  @override
  String get startSharingToFindDevices =>
      'Cihazları bulmak için paylaşımı etkinleştirin';

  @override
  String get deviceOnline => 'Çevrimiçi';

  @override
  String get deviceOffline => 'Çevrimdışı';

  @override
  String get sendMusicFiles => 'Müzik Dosyaları Gönder';

  @override
  String get sendFolder => 'Klasör Gönder';

  @override
  String get syncLyricsToDeviceAction => 'Sözleri Cihaza Eşitle';

  @override
  String get syncLyricsFromDeviceAction => 'Sözleri Cihazdan Eşitle';

  @override
  String loadDevicesError(Object error) {
    return 'Cihazlar yüklenemedi: $error';
  }

  @override
  String incomingFilesFormat(Object name1, Object name2, Object count) {
    return '$name1, $name2 ve $count diğer dosya';
  }

  @override
  String get incomingTransferRequestTitle => 'Gelen Dosya Aktarım İsteği';

  @override
  String incomingTransferFrom(Object senderName) {
    return '\"$senderName\" cihazından aktarım isteği:';
  }

  @override
  String fileSizeMb(Object sizeMb) {
    return 'Dosya boyutu: $sizeMb MB';
  }

  @override
  String get receiveFileHint =>
      'Alınan dosyalar müzik klasörüne kaydedilecek ve kitaplığa eklenecektir.';

  @override
  String get reject => 'Reddet';

  @override
  String get accept => 'Kabul Et';

  @override
  String get incomingLyricsExportTitle => 'Şarkı Sözü Dışa Aktarma İsteği';

  @override
  String incomingLyricsExportFrom(Object senderName) {
    return '\"$senderName\" cihazı şarkı sözü kitaplığınızı dışa aktarmak istiyor.';
  }

  @override
  String get incomingLyricsImportTitle => 'Şarkı Sözü İçe Aktarma İsteği';

  @override
  String incomingLyricsImportFrom(Object senderName, Object count) {
    return '\"$senderName\" cihazı $count şarkı için söz içe aktarmak istiyor.';
  }

  @override
  String get lyricsRequestRejected =>
      'Uzak cihaz şarkı sözü eşitleme isteğini reddetti.';

  @override
  String sendCompleted(Object fileName) {
    return '\"$fileName\" gönderildi';
  }

  @override
  String receiveCompleted(int count) {
    return '$count şarkı başarıyla alındı';
  }

  @override
  String transferCancelledWithReason(Object direction, Object reason) {
    return '$direction iptal edildi ($reason)';
  }

  @override
  String transferFailedFormat(Object direction, Object fileName) {
    return '$direction \"$fileName\" başarısız oldu';
  }

  @override
  String sendingToDevice(Object deviceName) {
    return '$deviceName cihazına gönderiliyor';
  }

  @override
  String receivingFromDevice(Object deviceName) {
    return '$deviceName cihazından alınıyor';
  }

  @override
  String progressFormat(Object percent) {
    return 'İlerleme: %$percent';
  }

  @override
  String get currentlyTransferring => 'Şu Anda Aktarılıyor';

  @override
  String get fileConflictTitle => 'Dosya Çakışması';

  @override
  String get fileConflictMessage =>
      'Hedef cihazda aynı ada sahip bir dosya zaten mevcut:';

  @override
  String get fileConflictChooseAction => 'Lütfen bir işlem seçin:';

  @override
  String get skipAction => 'Atla';

  @override
  String get overwriteAction => 'Üzerine Yaz';

  @override
  String get skipAllAction => 'Tümünü Atla';

  @override
  String get overwriteAllAction => 'Tümünün Üzerine Yaz';

  @override
  String get sendDirection => 'Gönder';

  @override
  String get receiveDirection => 'Al';

  @override
  String get fileAssociationEnabled => 'İlişkilendirildi';

  @override
  String get fileAssociationDisabled => 'İlişkilendirilmedi';

  @override
  String get windowsAutoRepairShortcut =>
      'Başlat Menüsü Kısayolunu Otomatik Onar';

  @override
  String get windowsAutoRepairShortcutDescription =>
      'Doğru medya denetim adını ve simgesini görüntülemek için her başlangıçta Başlat Menüsü kısayolunu otomatik kontrol et ve oluştur';

  @override
  String get confirmDisableShortcutRepair =>
      'Bu özellik devre dışı bırakılsın mı?';

  @override
  String get confirmDisableShortcutRepairContent =>
      'Başlat Menüsü kısayolu olmadan, Windows medya kontrolleri uygulamayı \"Bilinmeyen\" olarak gösterebilir ve simge görüntülemeyebilir. Bunu devre dışı bırakmak istediğinizden emin misiniz?';

  @override
  String get confirmDisable => 'Devre Dışı Bırak';

  @override
  String get enableSystemTray => 'Sistem Tepsisini Etkinleştir';

  @override
  String get enableSystemTrayDescription =>
      'Hızlı oynatma kontrolü için sistem tepsisinde simge göster';

  @override
  String get closeToTray => 'Kapatıldığında Sistem Tepsisine Küçült';

  @override
  String get closeToTrayDescription =>
      'Pencere kapatıldığında arka planda çalışmaya devam et';

  @override
  String get closeWindowActionTitle => 'Pencere kapatıldığında';

  @override
  String get closeWindowActionDescription =>
      'Kapat düğmesine tıklandığında ne olacağını seçin';

  @override
  String get closeWindowActionAsk => 'Her zaman sor';

  @override
  String get closeWindowActionMinimize => 'Sistem tepsisine küçült';

  @override
  String get closeWindowActionExit => 'Uygulamadan çık';

  @override
  String get closeWindowActionRemember => 'Seçimimi hatırla ve tekrar sorma';

  @override
  String get closeWindowActionTrayDisabledTip =>
      '(Sistem tepsisi etkin olmalıdır)';

  @override
  String get closeWindowDialogTitle => 'Pencereyi Kapat';

  @override
  String get closeWindowDialogContent =>
      'Lütfen kapat düğmesine tıklandığında ne olacağını seçin:';

  @override
  String get googleAiStudioApiKey => 'Google AI Studio API Anahtarı';

  @override
  String get openRouterApiKey => 'OpenRouter API Anahtarı';

  @override
  String get doubaoApiKey => 'Doubao API Anahtarı';

  @override
  String get deepseekApiKey => 'DeepSeek API Anahtarı';

  @override
  String get unexpectedResponseFormat => 'Beklenmeyen yanıt formatı.';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get openaiCompatibleEndpoint => 'OpenAI uyumlu API uç noktası';

  @override
  String onboardingAddedDirectoriesCount(Object count) {
    return 'Eklenen dizinler ($count):';
  }

  @override
  String get gnomeDisksOpenFailed =>
      'Disk Yöneticisi otomatik olarak açılamadı. Lütfen uygulama menünüzden \"Diskler\"i manuel olarak açın.';

  @override
  String get gnomeDisksNotInstalled =>
      'gnome-disks yüklü değil. Yapılandırmak için lütfen sisteminizin disk yöneticisini açın.';

  @override
  String get linuxMountGuideTitle => 'Linux Disk Bağlama Rehberi';

  @override
  String get linuxMountGuideDescription =>
      'Varsayılan olarak Linux harici bölümleri otomatik bağlamaz. Başlangıçta bağlamayı yapılandırmazsanız harici bölümlerin bağlama yolu her yeniden başlatmada değişebilir ve oynatıcının müzik dizinine erişmesini engelleyebilir. Bunu önlemek için lütfen müziğinizi içeren bölümü başlangıçta otomatik bağlanacak şekilde ayarlayın.';

  @override
  String get linuxMountGuideWarning =>
      'Uyarı: Müziğiniz bağlama gerektiren harici veya dahili bir sürücü bölümündeyse, \"sistem başlangıcında otomatik bağla\" olarak yapılandırmalısınız. Aksi takdirde, yeniden başlatmanın ardından müzik dizini bulunamayabilir veya erişmek için şifre girmeniz gerekebilir.';

  @override
  String get linuxMountGuideStep1 =>
      '1. Sistem \"Diskler\" (Disks) uygulamasını açın';

  @override
  String get linuxMountGuideStep2 =>
      '2. Müzik bölümünüzü seçin, ⚙️ dişli simgesine (Ek bölüm seçenekleri) tıklayın';

  @override
  String get linuxMountGuideStep3 =>
      '3. \"Bağlama Seçeneklerini Düzenle\"yi seçin, \"Kullanıcı Oturumu Varsayılanları\"nı kapatın ve \"Sistem başlangıcında bağla\"yı işaretleyin';

  @override
  String get linuxMountGuideOpenButton => 'Disk Yöneticisini Aç (Disks)';

  @override
  String get unmute => 'Sesi Aç';

  @override
  String get mute => 'Sesi Kapat';

  @override
  String get disableSystemTray => 'Sistem Tepsisini Devre Dışı Bırak';

  @override
  String get restoreWindow => 'Pencereyi Geri Yükle';

  @override
  String get hideWindow => 'Pencereyi Gizle';

  @override
  String get onboardingAndroidBatteryTitle => 'Arka Planda Çalma Koruması';

  @override
  String get onboardingAndroidBatteryDescription =>
      'Android\'in katı pil optimizasyon politikaları nedeniyle müziğin arka planda durmasını önlemek için Vynody\'nin pil kısıtlamasını \"Kısıtlamasız\" olarak ayarlamanızı öneririz.';

  @override
  String get onboardingAndroidBatteryStep1 =>
      '1. Aşağıdaki \"Ayarlara Git\" düğmesine dokunun.';

  @override
  String get onboardingAndroidBatteryStep2 =>
      '2. Sistem isteminde pil optimizasyonlarını yoksaymaya izin verin veya pil ayarlarına gidin.';

  @override
  String get onboardingAndroidBatteryStep3 =>
      '3. Ayarlara yönlendirilirseniz \"Kısıtlamasız\" veya \"Kısıtlama Yok\" seçeneğini belirleyin.';

  @override
  String get onboardingAndroidBatteryButton => 'Ayarlara Git';

  @override
  String get onboardingAndroidBatteryStatusOptimized =>
      'Durum: Kısıtlı (arka planda oynatma durabilir)';

  @override
  String get onboardingAndroidBatteryStatusUnrestricted =>
      'Durum: Kısıtlamasız (önerilen, oynatma korunur)';

  @override
  String get onboardingAndroidMediaTitle => 'Müzik Kitaplığınıza Erişin';

  @override
  String get onboardingAndroidMediaDescription =>
      'İzin verildiğinde Vynody, sistem medya kitaplığınızdaki tüm müzikleri doğrudan okuyabilir — klasörleri manuel olarak seçmenize gerek kalmaz. İzin vermeden de belirli klasörlerden müzik aktarabilirsiniz.';

  @override
  String get onboardingAndroidMediaStep1 =>
      '1. Hemen Hazır: Telefonunuzdaki tüm müzikleri anında gösterir';

  @override
  String get onboardingAndroidMediaStep2 =>
      '2. Otomatik Keşif: Yeni indirilen veya aktarılan müzikler otomatik görünür';

  @override
  String get onboardingAndroidMediaStep3 =>
      '3. Gizlilik Güvenli: Yalnızca yerel ses dosyalarını okur ve kitaplığınızı dışarıya yüklemez (AI sözleri gibi bulut servisleri hariç)';

  @override
  String get onboardingAndroidMediaButton =>
      'Medya Kitaplığına Erişim İzni Ver';

  @override
  String get onboardingAndroidMediaStatusGranted =>
      'Durum: İzin Verildi (Önerilen)';

  @override
  String get onboardingAndroidMediaStatusNotGranted =>
      'Durum: İzin Verilmedi (daha sonra klasörleri manuel ekleyebilirsiniz)';

  @override
  String get exitApp => 'Çıkış';

  @override
  String get showScanProgressToastSetting => 'Tarama Durumu Bildirimini Göster';

  @override
  String get showScanProgressToastSettingDescription =>
      'Klasörler taranırken ekranın üst kısmında gerçek zamanlı tarama ilerlemesini gösterir.';

  @override
  String get openPlaybackOnDirectorySongTap =>
      'Şarkıya dokunulduğunda oynatma sayfasını aç';

  @override
  String get openPlaybackOnDirectorySongTapDescription =>
      'Dizin görünümünde bir şarkıya dokunulduğunda otomatik olarak oynatma sayfasını açar.';

  @override
  String get defaultToLyricsModeOnPlaybackOpen =>
      'Oynatma sayfasında varsayılan olarak sözler modunu aç';

  @override
  String get defaultToLyricsModeOnPlaybackOpenDescription =>
      'Oynatma sayfası açıldığında otomatik olarak şarkı sözü görünümünü gösterir.';

  @override
  String get tapCoverToEnterLyricsMode =>
      'Söz moduna geçmek için kapağa dokunun';

  @override
  String get longPressLyricsPanelToOpenMenu =>
      'Menüyü açmak için sözler paneline uzun basın';

  @override
  String get gotIt => 'Anladım';

  @override
  String get scanToastHiddenHint =>
      'Tarama durumu bildirimi gizlendi. Ayarlar - Arayüz bölümünden yeniden etkinleştirebilirsiniz.';

  @override
  String get doubleSpeedPlayingSwipeUpToLock =>
      'Hızlı sarılıyor... Kilitlemek için yukarı kaydırın';

  @override
  String get doubleSpeedLockedSwipeDownToUnlock =>
      'Hızlı sarma kilitlendi. Kilidi açmak için basılı tutup aşağı kaydırın';

  @override
  String get doubleSpeedUnlocked => 'Hızlı sarma kilidi açıldı';

  @override
  String get lyricsImportExportHeader => 'İçe ve Dışa Aktarma';

  @override
  String get exportAction => 'Dışa Aktar';

  @override
  String get importAction => 'İçe Aktar';

  @override
  String get exportLyricsLabel => 'Şarkı Sözü Yedeğini Dışa Aktar';

  @override
  String get exportLyricsDescription =>
      'Önbelleğe alınmış ve ayarlanmış tüm şarkı sözlerini JSON dosyası olarak dışa aktarın';

  @override
  String get importLyricsLabel => 'Şarkı Sözü Yedeğini İçe Aktar';

  @override
  String get importLyricsDescription =>
      'Dışa aktarılmış bir JSON dosyasından şarkı sözü önbelleğini içe aktarın';

  @override
  String exportSuccess(int count) {
    return '$count şarkı sözü başarıyla dışa aktarıldı.';
  }

  @override
  String exportFailed(String error) {
    return 'Dışa aktarma başarısız: $error';
  }

  @override
  String importSuccess(int count) {
    return 'İçe aktarma tamamlandı! $count şarkı sözü başarıyla içe aktarıldı.';
  }

  @override
  String importFailed(String error) {
    return 'İçe aktarma başarısız: $error';
  }

  @override
  String get importConflictsTitle => 'İçe Aktarma Çakışmaları';

  @override
  String importConflictsMessage(int conflictCount) {
    return 'Yedekte $conflictCount adet çakışan şarkı sözü bulundu (yerel olarak mevcut ancak farklı). Lütfen nasıl devam etmek istediğinizi seçin:';
  }

  @override
  String get overwriteAll => 'Tümünün Üzerine Yaz';

  @override
  String get skipAllConflicts => 'Çakışmaları Atla';

  @override
  String get decideOneByOne => 'Tek Tek Karar Ver';

  @override
  String conflictResolutionTitle(int current, int total) {
    return 'Çakışmayı Çöz ($current/$total)';
  }

  @override
  String get conflictExistingLabel => 'Mevcut Sözler';

  @override
  String get conflictImportedLabel => 'İçe Aktarılan Sözler';

  @override
  String conflictSourceLabel(String source) {
    return 'Kaynak: $source';
  }

  @override
  String conflictTimeLabel(String time) {
    return 'Zaman: $time';
  }

  @override
  String get overwriteThis => 'Üzerine Yaz';

  @override
  String get skipThis => 'Atla';

  @override
  String get overwriteRemaining => 'Kalanların Tümünün Üzerine Yaz';

  @override
  String get skipRemaining => 'Kalanların Tümünü Atla';

  @override
  String get invalidBackupFile => 'Geçersiz yedek dosyası';

  @override
  String get exportLogs => 'Günlükleri Dışa Aktar';

  @override
  String get exportLogsSuccess => 'Günlükler başarıyla dışa aktarıldı';

  @override
  String get exportLogsFailed => 'Günlükler dışa aktarılamadı';

  @override
  String get noLogFileFound => 'Günlük dosyası bulunamadı';

  @override
  String get uiDisplayScale => 'Arayüz Ölçeği';

  @override
  String get uiDisplayScaleDescription =>
      'Arayüz öğelerinin boyutunu ayarlayın';

  @override
  String get uiDisplayScaleDialogTitle => 'Arayüz Ölçeği / Araç Modu';

  @override
  String uiDisplayScaleCurrent(int percent) {
    return 'Geçerli ölçek: $percent%';
  }

  @override
  String get audioSettings => 'Ses Ayarları';

  @override
  String get audioSettingsDescription =>
      'Ses çalma, ekolayzer bantları ve hız yapılandırmalarını yönetin';

  @override
  String get equalizerBandCount => 'Ekolayzer Bant Sayısı';

  @override
  String get equalizerBandCountDescription =>
      'Ekolayzer panelindeki bant sayısını yapılandırın. Yüksek bant modları otomatik olarak yatay kaydırmayı etkinleştirir.';

  @override
  String bandsCountOption(int count) {
    return '$count Bant';
  }

  @override
  String get enableFadeEffect => 'Ses Karartma (Fade) Efekti';

  @override
  String get enableFadeEffectDescription =>
      'Şarkı değiştirme, çalma ve duraklatma sırasında yumuşak ses geçiş efektini etkinleştirin';

  @override
  String get buttonLayoutSettings => 'Düğme Düzeni';

  @override
  String get playbackButtonLayoutTitle => 'Oynatma Sayfası Kontrol Düzeni';

  @override
  String get playbackButtonLayoutDescription =>
      'Oynatma sayfasındaki düğme sırasını ve simgelerini özelleştirin';

  @override
  String get topButtonsRowTitle => '7 Düğmeli Satır Sırası';

  @override
  String get mainButtonsRowTitle => '5 Düğmeli Satır Sol ve Sağ Düğmeleri';

  @override
  String get mainControlsLeftButton => 'Sol Düğme';

  @override
  String get mainControlsRightButton => 'Sağ Düğme';

  @override
  String get lyricsHeaderRightButtonTitle =>
      'Sözler Başlık Çubuğu Daraltılmış Düğmesi';

  @override
  String get resetButtonOrder => 'Varsayılana Sıfırla';

  @override
  String get btnMore => 'Daha Fazla Menüsü';

  @override
  String get btnFavorite => 'Favori';

  @override
  String get btnPlaylistMode => 'Çalma Modu';

  @override
  String get btnShuffle => 'Karışık';

  @override
  String get btnTagCompletion => 'Etiket Tamamlama';

  @override
  String get btnSleepTimer => 'Uyku Zamanlayıcısı';

  @override
  String get btnEqualizer => 'Ekolayzer';

  @override
  String get btnVisualizer => 'Görselleştirici';

  @override
  String get btnVolume => 'Ses';

  @override
  String get remoteControlAction => 'Uzaktan Kontrol';

  @override
  String get remoteControlRequestTitle => 'Uzaktan Kontrol İsteği';

  @override
  String remoteControlRequestFrom(String name) {
    return '\"$name\" cihazı uzaktan kontrol izni istiyor';
  }

  @override
  String get remotePinPairHint =>
      'Lütfen kontrol eden cihazınıza aşağıdaki eşleştirme PIN kodunu girin:';

  @override
  String get remotePinExpiresIn => 'PIN geçerlilik süresi:';

  @override
  String get allowDirectly => 'Doğrudan İzin Ver';

  @override
  String get enterRemotePinTitle => 'Cihaz Eşleştirme';

  @override
  String enterRemotePinPrompt(String name) {
    return '\"$name\" üzerinde gösterilen 4 haneli PIN kodunu girin:';
  }

  @override
  String get remotePinInvalid =>
      'Geçersiz veya süresi dolmuş PIN. Lütfen tekrar deneyin.';

  @override
  String remotePinCooldown(int seconds) {
    return 'Yanlış PIN, $seconds sn sonra tekrar deneyin';
  }

  @override
  String remotePinAttemptsRemaining(int count) {
    return '(Kalan deneme hakkı: $count)';
  }

  @override
  String get remotePinTooManyAttempts =>
      'Çok fazla başarısız deneme. Eşleştirme oturumu sona erdi.';

  @override
  String get remoteConnected => 'Bağlandı';

  @override
  String get remoteConnecting => 'Bağlanıyor...';

  @override
  String get remoteDisconnect => 'Bağlantıyı Kes';

  @override
  String get remoteConnectFailed => 'Uzaktan bağlantı başarısız oldu';

  @override
  String controlledByRemoteDevices(String devices) {
    return 'Uzaktan kontrol eden cihaz(lar): $devices';
  }

  @override
  String get trustedDevicesTitle => 'Güvenilen Uzak Cihazlar';

  @override
  String get manageTrustedDevicesTitle => 'Güvenilen Uzak Cihazları Yönet';

  @override
  String get removeTrustedDevice => 'Güveni Kaldır';

  @override
  String get noMusicPlaying => 'Çalan müzik yok';

  @override
  String get previousSong => 'Önceki';

  @override
  String get nextSong => 'Sonraki';

  @override
  String get shufflePlayback => 'Karışık Çal';

  @override
  String get allowRemoteControlTitle => 'Uzaktan Kontrole İzin Ver';

  @override
  String get allowRemoteControlSubtitle =>
      'Eşleştirmeden sonra yerel ağdaki diğer cihazların müzik çalmayı kontrol etmesine izin verin';

  @override
  String get remoteControlDisabledOnHost =>
      'Hedef cihazda uzaktan kontrol devre dışı bırakılmış';

  @override
  String get trustThisDevice =>
      'Bu cihaza güven ve gelecekte otomatik olarak izin ver';

  @override
  String get remoteRequestRejected =>
      'Bağlantı isteği hedef cihaz tarafından reddedildi.';

  @override
  String get turkishLanguage => 'Türkçe';

  @override
  String get nativeLanguageTr => 'Türkçe';

  @override
  String trustedDevicesCount(int count) {
    return '$count güvenilen cihaz';
  }

  @override
  String get noTrustedDevices => 'Güvenilen cihaz yok';

  @override
  String get noTrustedDevicesHint =>
      'Eşleme sırasında \"Bu cihaza güven\" seçildiğinde cihazlar burada görünür';

  @override
  String pairedAtFormat(String time) {
    return 'Eşleşme zamanı: $time';
  }

  @override
  String transferCancelled(String direction) {
    return '$direction iptal edildi';
  }

  @override
  String get audioFiles => 'Ses Dosyaları';

  @override
  String get remotePairCancelledByClient =>
      'Eşleştirme isteği hedef cihaz tarafından iptal edildi.';

  @override
  String get proFeatureAiLyricsTitle => 'Yapay Zeka Şarkı Sözleri ve Çeviri';

  @override
  String get proFeatureAiLyricsDesc =>
      'Yapay zeka ile şarkı sözü oluşturma, zaman çizelgesi hizalama ve çeviri';

  @override
  String get proFeatureTagCompletionTitle =>
      'Şarkı Meta Verilerini Otomatik Tamamlama';

  @override
  String get proFeatureTagCompletionDesc =>
      'MusicBrainz ile şarkı etiketlerini ve albüm meta verilerini otomatik tamamlama';

  @override
  String get proFeatureEqualizerTitle => 'Çok Bantlı EQ ve Oynatma Hızı (EQ)';

  @override
  String get proFeatureEqualizerDesc =>
      'Profesyonel frekans ayarı, 0.5x–5.0x oynatma hızı, preamp kazancı ve ses stilleri';

  @override
  String get proFeatureCustomThemeColorTitle =>
      'Tam Spektrum Temalar ve Gelişmiş Renkler';

  @override
  String get proFeatureCustomThemeColorDesc =>
      'Serbest renk seçici paletini ve özel premium önceden tanımlı tema renklerini açın';

  @override
  String get proFeatureFftVisualizerTitle => 'Gerçek Zamanlı FFT Ses Spektrumu';

  @override
  String get proFeatureFftVisualizerDesc =>
      '6 spektrum stili (Klasik Çubuklar, Pürüzsüz Dalga, Kayan Başlıklar, Radyal Işık Halkası, Neon Matris, Aynalanmış Dalga) ve tam ekran ortam modu';

  @override
  String get proFeatureWaveformBarTitle =>
      'Dinamik Ses Dalgası İlerleme Çubuğu';

  @override
  String get proFeatureWaveformBarDesc =>
      'Gerçek zamanlı dalga formu çıkarma ve akıcı etkileşimli arama';

  @override
  String get proFeatureLanSharingTitle => 'LAN Müzik Dosyası Paylaşımı';

  @override
  String get proFeatureLanSharingDesc =>
      'Yerel ağ üzerinden cihazlar arası ultra hızlı şarkı paylaşımı ve aktarımı';

  @override
  String get proFeatureRemoteControlTitle => 'Çoklu Cihaz Uzaktan Kontrol';

  @override
  String get proFeatureRemoteControlDesc =>
      'Cihazlar arasında kesintisiz bağlantı ve kablosuz oynatma kontrolü';

  @override
  String get proFeatureTranscoderTitle => 'Toplu Ses Dönüştürücü';

  @override
  String get proFeatureTranscoderDesc =>
      'Kayıpsız formatları hızlı dönüştürme ve taşınabilir cihazlar için toplu dışa aktarma';

  @override
  String get proFeatureDynamicMeshBackgroundTitle => 'Dinamik Mesh Arka Planı';

  @override
  String get proFeatureDynamicMeshBackgroundDesc =>
      'Albüm kapağı renklerinden üretilen akıcı gradyan animasyonu ve ayarlanabilir hız';

  @override
  String get proFeatureCustomImageBackgroundTitle =>
      'Özel Çalma Arka Plan Duvar Kağıdı';

  @override
  String get proFeatureCustomImageBackgroundDesc =>
      'Favori yerel resimlerinizi ve fotoğraflarınızı oynatıcı arka planı olarak ayarlayın';

  @override
  String get proCommunityUnlocked =>
      'Topluluk Sürümü: Tüm Pro özelliklerinin kilidi kalıcı olarak açıldı';

  @override
  String proTrialActive(int days) {
    return 'Ücretsiz deneme süresi etkin ($days gün kaldı)';
  }

  @override
  String get proTrialExpired =>
      'Ücretsiz deneme süresi doldu. Pro\'ya yükseltin';

  @override
  String get proPermanentlyActivated =>
      'Tüm Pro özellikleri kalıcı olarak etkinleştirildi';

  @override
  String proStatusTrialTitle(int days) {
    return 'Lisans Durumu: $days günlük ücretsiz deneme etkin';
  }

  @override
  String get proStatusTrialExpiredTitle =>
      'Lisans Durumu: Deneme süresi doldu (Sınırlı özellikler)';

  @override
  String get proStatusActivatedTitle =>
      'Lisans Durumu: Vynody Pro etkinleştirildi';

  @override
  String proSettingsTrialRemaining(int days) {
    return '$days gün deneme süresi kaldı';
  }

  @override
  String get proSettingsUpgradePrompt =>
      'Yapay zeka sözleri, FFT spektrumu ve Pro özelliklerinin kilidini açın';

  @override
  String get proSettingsLifetimeNotice =>
      'Tüm Pro özellikleri ve gelecek güncellemeler dahil';

  @override
  String get proSettingsUpgrade => 'Yükselt';

  @override
  String get proSettingsView => 'Görüntüle';

  @override
  String get connectingToStore => 'Mağazaya bağlanılıyor...';

  @override
  String get buyFullVersionWindowsTrial =>
      'Microsoft Store\'dan Tam Sürümü Satın Alın';

  @override
  String get buyFullVersionWindows =>
      'Microsoft Store\'dan Tam Sürümü Satın Alın';

  @override
  String unlockProLifetimeWithPrice(String price) {
    return '$price Pro Tam Sürüm Kilidini Aç';
  }

  @override
  String get buyProTrialEarly => 'Ömür Boyu Pro Lisansı Satın Alın';

  @override
  String get upgradeToProNow => 'Şimdi Pro\'ya Yükseltin';

  @override
  String get iUnderstand => 'Anladım';

  @override
  String get restorePurchases => 'Satın Alımları Geri Yükle';

  @override
  String get restoringPurchases => 'Satın alımlar geri yükleniyor...';

  @override
  String get sharingProDescription =>
      'LAN bağlantısı, Vynody Pro\'ya özel gelişmiş bir özelliktir. Aynı yerel ağda ultra hızlı müzik aktarımı, kütüphane senkronizasyonu ve kablosuz uzaktan kontrolün keyfini çıkarın.';

  @override
  String get sharingHighlightSpeedTitle => 'Ultra Hızlı LAN Aktarımı';

  @override
  String get sharingHighlightSpeedDesc =>
      'Wi-Fi LAN içinde veri tüketimi veya sıkıştırma olmadan doğrudan P2P kayıpsız ses aktarımı.';

  @override
  String get sharingHighlightSyncTitle =>
      'Kütüphane ve Şarkı Sözü Senkronizasyonu';

  @override
  String get sharingHighlightSyncDesc =>
      'Cihazlarınız arasında müzik kütüphanenizi güncel tutmak için tek tıkla aktarım.';

  @override
  String get sharingHighlightRemoteTitle => 'Kablosuz Uzaktan Kontrol';

  @override
  String get sharingHighlightRemoteDesc =>
      'Telefon, tablet ve bilgisayarlar arasında kesintisiz oynatma, parça değiştirme ve ses kontrolü.';

  @override
  String get sharingHighlightSecurityTitle =>
      'Uçtan Uca TLS Güvenlik Şifrelemesi';

  @override
  String get sharingHighlightSecurityDesc =>
      'Gizli ve güvenli aktarım için tam TLS sertifika şifrelemesi ve cihaz güven eşleştirmesi.';

  @override
  String get upgradeToProToUnlock => 'Vynody Pro\'ya Yükseltin';

  @override
  String get proOneTimePurchaseNotice =>
      'Tek seferlik satın alma, bu platformdaki tüm Pro özelliklerini ömür boyu açar';

  @override
  String get proOneTimePurchaseNoticeApple =>
      'Tek seferlik satın alma, tüm Apple platformlarındaki (iPhone / iPad / Mac) Pro özelliklerini ömür boyu açar';

  @override
  String get proUniversalPurchaseNoticeApple =>
      'Tek satın alma, iPhone, iPad ve Mac\'te kullanılabilir';

  @override
  String get iapPurchaseSuccess =>
      'Vynody Pro başarıyla satın alındı! Desteğiniz için teşekkür ederiz!';

  @override
  String get iapRestoreSuccess =>
      'Vynody Pro satın alımları başarıyla geri yüklendi!';

  @override
  String iapPurchaseCancelledOrFailed(String message) {
    return 'Satın alma tamamlanamadı veya iptal edildi: $message';
  }
}
