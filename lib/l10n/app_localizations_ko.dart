// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Vynody';

  @override
  String get alwaysOnTop => '항상 위에 표시';

  @override
  String get systemMediaLibrary => '시스템 미디어 라이브러리';

  @override
  String get scanningDirectory => '디렉토리 검색 중...';

  @override
  String filesPreprocessed(Object count) {
    return '전처리됨 $count';
  }

  @override
  String filesDiscovered(Object count) {
    return '발견됨 $count';
  }

  @override
  String filesFullyProcessed(Object count) {
    return '완전히 처리됨 $count';
  }

  @override
  String get directoryAddedSuccess => '디렉토리가 성공적으로 추가되었습니다';

  @override
  String get directoryAddedNoMusic => '디렉토리가 추가되었지만 재생 가능한 오디오 파일이 없습니다';

  @override
  String get scanDirectory => '디렉토리 검색';

  @override
  String get sort => '정렬';

  @override
  String get addRootDirectory => '루트 디렉토리 추가';

  @override
  String get goBack => '뒤로 가기';

  @override
  String get noMediaLibraryPermission => '미디어 라이브러리 접근 권한 없음';

  @override
  String get grantPermission => '권한 허용';

  @override
  String get needPermissionToScan => '로컬 음악을 검색하려면 권한이 필요합니다';

  @override
  String get rebuildTagDatabase => '태그 데이터베이스 재구축';

  @override
  String get rebuildDatabase => '데이터베이스 재구축';

  @override
  String get confirmRebuildDatabase =>
      '모든 노래 태그 정보를 수동으로 새로고침하시겠습니까? 커버와 메타데이터를 다시 로드하는 데 시간이 걸릴 수 있습니다.';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get rebuildingDatabase => '노래 태그 데이터베이스 재구축 중...';

  @override
  String get sortBy => '정렬 기준';

  @override
  String get sortScope => '범위';

  @override
  String get sortOrder => '정렬 순서';

  @override
  String get title => '제목';

  @override
  String get fileName => '파일 이름';

  @override
  String get trackNumber => '트랙 번호';

  @override
  String get ascending => '오름차순';

  @override
  String get descending => '내림차순';

  @override
  String get currentFolderScope => '현재 폴더';

  @override
  String get globalScope => '전체';

  @override
  String get visualizerSettings => '재생 페이지 설정';

  @override
  String get algorithm => '스펙트럼';

  @override
  String get appearance => '모양';

  @override
  String get spectrumAppearanceGroup => '스펙트럼 모양';

  @override
  String get spectrumAdvancedOptions => '스펙트럼 고급 옵션';

  @override
  String get resetAlgorithm => '알고리즘 초기화';

  @override
  String get resetAppearance => '모양 초기화';

  @override
  String get smoothing => '부드럽게';

  @override
  String get gravity => '중력';

  @override
  String get logScale => '로그 스케일';

  @override
  String get contrast => '대비';

  @override
  String get normalization => '정규화';

  @override
  String get multiplier => '승수';

  @override
  String get skipHighFrequency => '고주파 건너뛰기';

  @override
  String get frequencyGroups => '주파수 그룹';

  @override
  String get aggregationMode => '집계 모드';

  @override
  String get opacity => '불투명도';

  @override
  String get enableGradient => '그라데이션 사용';

  @override
  String get startColor => '시작 색상';

  @override
  String get endColor => '끝 색상';

  @override
  String get gradientRangeStop1 => '그라데이션 범위 중지점 1';

  @override
  String get gradientRangeStop2 => '그라데이션 범위 중지점 2';

  @override
  String get gradientRepeatMode => '그라데이션 반복 모드';

  @override
  String get color => '색상';

  @override
  String get followCoverColor => '커버 색상 따라가기';

  @override
  String get selectColor => '색상 선택';

  @override
  String get volume => '볼륨';

  @override
  String get clearQueue => '대기열 비우기';

  @override
  String get confirmClearQueue => '현재 대기열을 비우시겠습니까?';

  @override
  String get queueCleared => '대기열이 비워졌습니다';

  @override
  String get locateCurrentSong => '현재 노래 찾기';

  @override
  String get songNotInScannedFolders => '현재 노래가 검색된 디렉토리에 없습니다';

  @override
  String get queue => '대기열';

  @override
  String get queueEmpty => '대기열이 비어 있습니다';

  @override
  String selectedSongs(int count) {
    return '$count곡 선택됨';
  }

  @override
  String get unknownArtist => '알 수 없는 아티스트';

  @override
  String deletedSongs(int count) {
    return '$count곡 삭제됨';
  }

  @override
  String get delete => '삭제';

  @override
  String get createPlaylist => '재생목록 만들기';

  @override
  String get playlistName => '재생목록 이름';

  @override
  String get enterPlaylistName => '재생목록 이름 입력';

  @override
  String get playlistNameExists => '재생목록 이름이 이미 존재합니다';

  @override
  String get renamePlaylist => '재생목록 이름 바꾸기';

  @override
  String get deletePlaylist => '재생목록 삭제';

  @override
  String confirmDeletePlaylist(String name) {
    return '재생목록 \"$name\"을(를) 삭제하시겠습니까?';
  }

  @override
  String get addToPlaylist => '재생목록에 추가';

  @override
  String get selectAll => '모두 선택';

  @override
  String get addToQueue => '대기열에 추가';

  @override
  String get addedToQueue => '대기열에 추가됨';

  @override
  String songCount(int count) {
    return '$count곡';
  }

  @override
  String addedToPlaylist(int count, String playlist) {
    return '$count곡을 $playlist에 추가함';
  }

  @override
  String get createNewList => '새 목록 만들기';

  @override
  String createdPlaylist(String name, int count) {
    return '재생목록 \"$name\"을(를) 만들고 $count곡을 추가함';
  }

  @override
  String get rename => '이름 바꾸기';

  @override
  String get playlist => '재생목록';

  @override
  String get mostPlayed => '가장 많이 재생';

  @override
  String get recentlyPlayed => '최근 재생';

  @override
  String get recentlyAdded => '최근 추가됨';

  @override
  String get albums => '앨범';

  @override
  String get artists => '아티스트';

  @override
  String get mostPlayedDescription => '완료된 재생 횟수 기준';

  @override
  String get recentlyPlayedDescription => '최근 재생 시간순 정렬 (외부 파일 포함)';

  @override
  String get recentlyAddedDescription => '라이브러리에 추가된 순서대로 정렬';

  @override
  String get allTime => '전체';

  @override
  String get pastWeek => '지난 주';

  @override
  String get pastMonth => '지난 달';

  @override
  String get past90Days => '지난 90일';

  @override
  String get noPlayHistory => '아직 재생 기록이 없습니다';

  @override
  String get noPlayHistoryInRange => '이 시간 범위에 재생 기록이 없습니다';

  @override
  String get noRecentlyPlayedSongs => '재생 기록이 없습니다';

  @override
  String get noRecentlyPlayedInRange => '해당 기간에 재생 기록이 없습니다';

  @override
  String get noRecentlyAddedSongs => '아직 라이브러리에 노래가 없습니다';

  @override
  String get noRecentlyAddedInRange => '이 시간 범위에 추가된 노래가 없습니다';

  @override
  String get addedOn => '추가된 날짜';

  @override
  String get externalSourceTag => '외부';

  @override
  String get lastPlayed => '마지막 재생';

  @override
  String playCountLabel(int count) {
    return '$count회 재생';
  }

  @override
  String get playAll => '전체 재생';

  @override
  String get shufflePlay => '셔플 재생';

  @override
  String get noAlbums => '아직 앨범이 없습니다';

  @override
  String get noArtists => '아직 아티스트가 없습니다';

  @override
  String get searchAlbums => '앨범 또는 아티스트 검색';

  @override
  String get searchArtists => '아티스트 검색';

  @override
  String get albumSort => '정렬';

  @override
  String get sortArtistAsc => '아티스트 A-Z';

  @override
  String get sortTitleAsc => '앨범 제목 A-Z';

  @override
  String get sortTrackCount => '곡 수';

  @override
  String get sortDuration => '총 재생 시간';

  @override
  String get sortRecentAdded => '최근 추가됨';

  @override
  String get sortAscending => '오름차순';

  @override
  String get sortDescending => '내림차순';

  @override
  String get playNext => '다음에 재생';

  @override
  String get addToFavorites => '즐겨찾기에 추가';

  @override
  String get removeFromFavorites => '즐겨찾기에서 제거';

  @override
  String get viewAlbumDetails => '앨범 상세 보기';

  @override
  String get viewArtistDetails => '아티스트 상세 보기';

  @override
  String get openFileLocation => '파일 위치 열기';

  @override
  String get copyAlbumTitle => '앨범 제목 복사';

  @override
  String get copyArtistName => '아티스트 이름 복사';

  @override
  String albumCount(int count) {
    return '$count개 앨범';
  }

  @override
  String get emptyList => '목록이 비어 있습니다';

  @override
  String get dragToAddMusic => '파일이나 폴더를 끌어다 놓아 음악을 추가하세요';

  @override
  String get unknownAlbum => '알 수 없는 앨범';

  @override
  String get managePlaylists => '재생목록 관리';

  @override
  String get createNewPlaylist => '새 재생목록 만들기';

  @override
  String get defaultList => '기본 목록';

  @override
  String get playbackMode => '재생 모드';

  @override
  String get playbackOptions => '재생 옵션';

  @override
  String get setVisualizerDisplay => '비주얼라이저 표시 설정';

  @override
  String get noPlaybackContent => '재생 콘텐츠 없음';

  @override
  String get file => '파일';

  @override
  String get play => '재생';

  @override
  String get list => '라이브러리';

  @override
  String get queueTab => '대기열';

  @override
  String get more => '더보기';

  @override
  String get settings => '설정';

  @override
  String get themeMode => '테마';

  @override
  String get themeModeSystem => '시스템 따라가기';

  @override
  String get themeModeLight => '라이트';

  @override
  String get themeModeDark => '다크';

  @override
  String get themeColor => '테마 색상';

  @override
  String get customThemeColor => '사용자 지정 테마 색상';

  @override
  String get themeColorMikuTeal => '하츠네 미쿠 틸';

  @override
  String get themeColorClassicBlue => '클래식 블루';

  @override
  String get themeColorIrisPurple => '아이리스 퍼플';

  @override
  String get themeColorViolet => '바이올렛';

  @override
  String get themeColorSakuraPink => '사쿠라 핑크';

  @override
  String get themeColorCoralOrange => '코랄 오렌지';

  @override
  String get themeColorAmberGold => '호박 골드';

  @override
  String get themeColorForestGreen => '포레스트 그린';

  @override
  String get themeColorAuroraCyan => '오로라 시안';

  @override
  String get themeColorCrimsonRed => '크림슨 레드';

  @override
  String get themeColorSlateGrey => '슬레이트 그레이';

  @override
  String get immersiveTabBar => '몰입형 탭 바';

  @override
  String get immersiveTabBarDescription =>
      '마우스를 움직이면 탐색 모음을 표시하고, 3초 동안 활동이 없으면 숨깁니다';

  @override
  String get collapseButtonsInLandscapeLyrics => '가로 가사 모드에서 버튼 접기';

  @override
  String get collapseButtonsInLandscapeLyricsDescription =>
      '가로 가사 모드에서 7개 버튼 행을 접고 제목을 왼쪽으로 정렬하며 오른쪽에 작업 버튼을 추가합니다';

  @override
  String get sampleStride => '샘플 간격';

  @override
  String get sampleStrideDescription =>
      '값이 클수록 빠르게 스캔하지만 파형 정밀도가 낮아집니다 (기본값: 4)';

  @override
  String get waveformSegments => '파형 세그먼트';

  @override
  String get waveformSegmentsDescription => '표시할 파형 막대 수 (기본값: 80)';

  @override
  String get showDeveloperOptions => '개발자 옵션 표시';

  @override
  String get playbackBackground => '재생 배경';

  @override
  String get playbackRadialGradient => '중앙 어두운 그라데이션';

  @override
  String get blurIntensity => '블러 강도';

  @override
  String get blurredArtwork => '블러 처리된 아트워크 (기본값)';

  @override
  String get dynamicMesh => '다이나믹 메시';

  @override
  String get solidColor => '단색';

  @override
  String get customImage => '사용자 지정 이미지';

  @override
  String get presetColors => '프리셋 색상';

  @override
  String get customColor => '사용자 지정 색상';

  @override
  String get uploadImage => '이미지 선택';

  @override
  String get normalOpacity => '일반 어두운 레이어 불투명도';

  @override
  String get lyricsOpacity => '가사 어두운 레이어 불투명도';

  @override
  String get chooseImageError => '이미지 선택 실패';

  @override
  String get noImageSelected => '선택된 이미지 없음';

  @override
  String get unknown => '알 수 없음';

  @override
  String get playlistModeSingle => '단일';

  @override
  String get playlistModeSingleLoop => '단일 반복';

  @override
  String get playlistModeQueue => '대기열';

  @override
  String get playlistModeQueueLoop => '대기열 반복';

  @override
  String get playlistModeAutoQueueLoop => '자동 대기열 반복';

  @override
  String get visualizer => '비주얼라이저';

  @override
  String get previous => '이전';

  @override
  String get next => '다음';

  @override
  String get pause => '일시 정지';

  @override
  String get autoMode => '자동 모드';

  @override
  String get advancedOptions => '고급 옵션';

  @override
  String get spectrumQuantity => '스펙트럼 수량';

  @override
  String get speed => '속도';

  @override
  String get quantityHigh => '높음';

  @override
  String get quantityMedium => '중간';

  @override
  String get quantityLow => '낮음';

  @override
  String get speedFast => '빠름';

  @override
  String get speedMedium => '중간';

  @override
  String get speedSlow => '느림';

  @override
  String get portraitFrequencyGroups => '세로 주파수 수량';

  @override
  String get landscapeFrequencyGroups => '가로 주파수 수량';

  @override
  String get portraitGap => '세로 간격';

  @override
  String get landscapeGap => '가로 간격';

  @override
  String get enableWaveformProgressBar => '파형 진행 표시줄 사용';

  @override
  String get enableWaveformProgressBarDescription => '표준 슬라이더 대신 전체 곡 파형 사용';

  @override
  String get waveformLongPressSeekSpeed => '파형 길게 누르기 빨리감기 속도';

  @override
  String get waveformLongPressSeekSpeedDescription =>
      '파형 진행 표시줄 오른쪽을 길게 누를 때 빨리감기 재생 속도(×)';

  @override
  String get enableWaveformLongPressSeek => '파형 길게 누르기 빨리감기 사용';

  @override
  String get enableWaveformLongPressSeekDescription =>
      '파형 진행 표시줄 오른쪽을 길게 눌러 빨리감기 재생을 사용합니다';

  @override
  String get clearWaveformCache => '전체 곡 파형 캐시 삭제';

  @override
  String get clearWaveformCacheDescription => '데이터베이스의 파형 캐시를 지우고 다시 계산합니다';

  @override
  String get waveformCacheCleared => '파형 캐시가 삭제되었습니다';

  @override
  String get storageAndCache => '저장 공간 및 캐시';

  @override
  String get remoteAudioCache => '원격 오디오 캐시';

  @override
  String get remoteAudioCacheDescription =>
      'Navidrome 및 WebDAV 스트리밍 및 프리페치용 로컬 캐시';

  @override
  String get remoteCacheLimit => '원격 캐시 용량 제한';

  @override
  String get remotePrefetchCount => '원격 트랙 사전 로드 수';

  @override
  String get remotePrefetchCountDescription =>
      '원활한 재생 전환을 위해 재생 대기열의 다음 원격 트랙을 미리 다운로드합니다';

  @override
  String get clearRemoteCache => '원격 캐시 삭제';

  @override
  String get remoteCacheCleared => '원격 오디오 캐시가 삭제되었습니다';

  @override
  String get unlimited => '무제한';

  @override
  String get off => '끄기';

  @override
  String get randomMode => '랜덤 모드';

  @override
  String get randomHistory => '랜덤 기록';

  @override
  String get randomRange => '랜덤 범위';

  @override
  String get randomMethod => '랜덤 방식';

  @override
  String get currentQueue => '현재 대기열';

  @override
  String get globalRange => '전체 (모든 재생목록)';

  @override
  String get completeRandom => '완전 랜덤';

  @override
  String get shuffleRandom => '셔플 랜덤';

  @override
  String get randomQueue => '랜덤 대기열';

  @override
  String get notSelected => '선택된 음악 없음';

  @override
  String get saveTagsToFile => '태그를 파일에 저장';

  @override
  String get saveCurrentTagsToFile => '현재 노래 태그를 파일에 저장';

  @override
  String get saveQueueTagsToFile => '모든 대기열 태그를 파일에 저장';

  @override
  String get tagsSaved => '태그가 성공적으로 저장되었습니다';

  @override
  String tagsSavedCount(Object count) {
    return '태그 저장됨 ($count곡)';
  }

  @override
  String get tagsSaveFailed => '태그 저장 실패';

  @override
  String tagsSaveFailedCount(Object count) {
    return '$count곡 저장 실패';
  }

  @override
  String unsupportedFormat(Object count) {
    return '$count곡이 지원되지 않는 형식입니다 (OGG/Opus는 저장할 수 없음)';
  }

  @override
  String get unsupportedFormatSingle => '이 형식(OGG/Opus)은 태그 저장을 지원하지 않습니다';

  @override
  String get savingTags => '태그 저장 중...';

  @override
  String get noModifiedTagsToSave => '저장할 수정된 태그가 없습니다';

  @override
  String get clearPlaylist => '목록 비우기';

  @override
  String get copyTitle => '제목 복사';

  @override
  String get transcodeAction => '트랜스코딩';

  @override
  String get transcodeSectionTitle => '오디오 트랜스코딩';

  @override
  String get transcodeSectionDescription =>
      '오디오 변환을 위한 기본 출력 형식 및 품질 프리셋을 설정합니다.';

  @override
  String get transcodeDefaultFormat => '기본 출력 형식';

  @override
  String get transcodeDefaultQuality => '기본 품질 프리셋';

  @override
  String get transcodeTitle => '오디오 트랜스코딩';

  @override
  String transcodeSongCount(int count) {
    return '$count곡';
  }

  @override
  String transcodeCompletedCount(int count) {
    return '$count개 파일 트랜스코딩 완료';
  }

  @override
  String transcodeCompletedWithFailures(int success, int total, int failed) {
    return '$success / $total개 파일 트랜스코딩 완료, $failed개 실패';
  }

  @override
  String get transcodeFailedGeneric => '트랜스코딩 실패';

  @override
  String get transcodePreparing => '트랜스코딩 준비 중...';

  @override
  String transcodeProgress(int current, int total) {
    return '트랜스코딩 중 $current / $total';
  }

  @override
  String get transcoding => '트랜스코딩 중...';

  @override
  String get startTranscode => '트랜스코딩 시작';

  @override
  String transcodeEngine(Object engine) {
    return '엔진: $engine';
  }

  @override
  String get transcodeUsingSystemFfmpeg => '시스템 PATH의 ffmpeg를 사용합니다.';

  @override
  String transcodeUsingCustomFfmpeg(Object path) {
    return '사용자 지정 ffmpeg 사용: $path';
  }

  @override
  String get transcodeFormat => '출력 형식';

  @override
  String get transcodeQualityPreset => '품질 프리셋';

  @override
  String get transcodeQualityLow => '낮음';

  @override
  String get transcodeQualityMedium => '중간';

  @override
  String get transcodeQualityHigh => '높음';

  @override
  String get transcodeQualityExtreme => '최고';

  @override
  String get transcodeLosslessPresetHint =>
      '이 무손실 형식은 품질 등급이나 비트레이트 모드를 사용하지 않습니다.';

  @override
  String get transcodeAdvancedOptions => '고급 옵션';

  @override
  String get transcodeAdvancedCustomized => '고급 매개변수가 사용자 지정되었습니다';

  @override
  String get transcodeAdvancedFollowingPreset => '고급 매개변수가 현재 프리셋을 따릅니다';

  @override
  String get transcodeLosslessAdvancedHint =>
      '이 무손실 형식에는 소스 보존 옵션만 사용할 수 있습니다.';

  @override
  String get transcodeBitRateInvalid => '유효한 비트레이트를 입력해주세요';

  @override
  String get transcodeBitRate => '비트레이트';

  @override
  String get transcodeBitRateMode => '비트레이트 모드';

  @override
  String get transcodeEncodingEngine => '인코딩 엔진';

  @override
  String get transcodeSystemEncoder => 'Media3 (시스템)';

  @override
  String get transcodeFfmpegRustEncoder => 'FFmpeg (Rust)';

  @override
  String get transcodeAacEncoder => 'AAC 인코더';

  @override
  String get transcodeSampleRate => '샘플레이트';

  @override
  String get transcodeChannels => '채널';

  @override
  String get transcodeResetToPreset => '현재 프리셋으로 초기화';

  @override
  String get transcodeResetLosslessOptions => '무손실 옵션 초기화';

  @override
  String get transcodeOutputDirectory => '출력 디렉토리';

  @override
  String get transcodeOutputPreview => '미리보기';

  @override
  String get transcodeChooseDirectory => '디렉토리 선택';

  @override
  String get transcodeUseSourceDirectory => '소스 디렉토리 사용';

  @override
  String get transcodeKeepSource => '소스 유지';

  @override
  String get transcodeMono => '모노';

  @override
  String get transcodeStereo => '스테레오';

  @override
  String get openFolderLocation => '폴더 위치 열기';

  @override
  String get songTagsSavedToSourceFileAndApp => '노래 태그가 소스 파일과 앱에 저장되었습니다';

  @override
  String get songTagsSavedToApp => '노래 태그가 앱에 저장되었습니다';

  @override
  String get durationZero => '0:00';

  @override
  String get generateLyrics => '가사 생성';

  @override
  String get generateTimeline => '타임라인 생성';

  @override
  String get queueGenerateLyrics => '가사 생성 대기열';

  @override
  String get pauseAutoScroll => '자동 스크롤 일시 정지';

  @override
  String get resumeAutoScroll => '자동 스크롤 재개';

  @override
  String get translateLyrics => '가사 번역';

  @override
  String get clearLyricsCache => '현재 가사 캐시 지우기';

  @override
  String get clearTranslationCache => '현재 번역 캐시 지우기';

  @override
  String get requery => '재조회';

  @override
  String get sleepTimerTitle => '슬립 타이머';

  @override
  String get sleepTimerDescription => '카운트다운을 선택하면 시간이 되면 재생이 일시 정지됩니다.';

  @override
  String get sleepTimerRunningTitle => '슬립 타이머 작동 중';

  @override
  String get sleepTimerRunningDescription => '카운트다운이 종료되면 재생이 자동으로 일시 정지됩니다.';

  @override
  String get sleepTimerStopAfterCurrentSong => '마지막 곡이 끝난 후 중지';

  @override
  String get remainingTime => '남은 시간';

  @override
  String get startCountdown => '카운트다운 시작';

  @override
  String get end => '종료';

  @override
  String get equalizer => '이퀄라이저';

  @override
  String get equalizerEnabledStatus => '고음질 조정 활성화됨';

  @override
  String get equalizerDisabledStatus => '비활성화됨';

  @override
  String get eqPresetFlat => '플랫';

  @override
  String get eqPresetPop => '팝';

  @override
  String get eqPresetRock => '락';

  @override
  String get eqPresetVocal => '보컬';

  @override
  String get eqPresetBassBoost => '베이스 부스트';

  @override
  String get eqPresetElectronic => '일렉트로닉';

  @override
  String get eqPresetJazz => '재즈';

  @override
  String get eqPresetClassical => '클래식';

  @override
  String get eqPresetAcoustic => '어쿠스틱';

  @override
  String get eqPresetDance => '댄스';

  @override
  String get eqPresetHifi => 'Hi-Fi';

  @override
  String get eqPresets => '이퀄라이저 프리셋';

  @override
  String get customPresets => '사용자 정의 프리셋';

  @override
  String get builtInPresets => '기본 프리셋';

  @override
  String get saveAsPreset => '프리셋으로 저장';

  @override
  String get saveCurrentAsPreset => '현재 설정을 새 프리셋으로 저장';

  @override
  String get enterPresetName => '프리셋 이름 입력';

  @override
  String get presetName => '프리셋 이름';

  @override
  String get presetNameAlreadyExists => '이미 존재하는 프리셋 이름입니다';

  @override
  String get presetNameCannotBeEmpty => '프리셋 이름을 입력해주세요';

  @override
  String get presetSaved => '프리셋이 저장되었습니다';

  @override
  String get updatePreset => '프리셋 업데이트';

  @override
  String get presetUpdated => '프리셋이 업데이트되었습니다';

  @override
  String get renamePreset => '프리셋 이름 변경';

  @override
  String get presetRenamed => '프리셋 이름이 변경되었습니다';

  @override
  String get saveAsNewPreset => '새 프리셋으로 저장';

  @override
  String get updateWithCurrentSettings => '현재 설정으로 덮어쓰기';

  @override
  String get modified => '수정됨';

  @override
  String get deletePreset => '프리셋 삭제';

  @override
  String get deletePresetConfirm => '이 프리셋을 삭제하시겠습니까?';

  @override
  String get custom => '사용자 지정';

  @override
  String get noCustomPresets => '사용자 정의 프리셋이 없습니다';

  @override
  String get savePresetPrompt => '현재 EQ 대역 게인, 베이스 부스트 및 프리앰프 게인 저장';

  @override
  String get effects => '효과';

  @override
  String get playbackSpeed => '재생 속도';

  @override
  String get playbackSpeedLimit5x => '5배속 제한';

  @override
  String get normal => '일반';

  @override
  String get bassBoost => '베이스 부스트';

  @override
  String get preampGain => '프리앰프 게인';

  @override
  String get reset => '초기화';

  @override
  String get close => '닫기';

  @override
  String get timelineAdjustmentTitle => '타임라인 조정';

  @override
  String get timelineAdjustmentDescription =>
      '오른쪽으로 드래그하면 가사가 늦어지고, 왼쪽으로 드래그하면 빨리 재생됩니다.';

  @override
  String timelineOffsetEarlier(Object seconds) {
    return '$seconds초 앞서';
  }

  @override
  String timelineOffsetLater(Object seconds) {
    return '$seconds초 늦음';
  }

  @override
  String get timelineOffsetCurrent => '현재 오프셋: 0.0초';

  @override
  String get enterAcoustidApiKeyTitle => 'AcoustID API 키 입력';

  @override
  String get acoustidApiKeyDescription =>
      '오디오 핑거프린팅에 사용됩니다. 비워두면 기본 내장 키가 복원됩니다.';

  @override
  String get acoustidApiKeyHint => 'AcoustID API 키 붙여넣기';

  @override
  String get apiKey => 'API 키';

  @override
  String get save => '저장';

  @override
  String get enterLyricsTitle => '가사 입력';

  @override
  String get lyricsInputHint => '여기에 가사를 붙여넣거나 입력하세요. 여러 줄 텍스트를 지원합니다.';

  @override
  String get enterGoogleAiStudioApiKeyTitle => 'Google AI Studio API 키 입력';

  @override
  String get googleAiStudioApiKeyDescription =>
      'Google AI Studio에서 가사 생성, 타임라인 생성 및 번역에 사용됩니다.';

  @override
  String get pasteGoogleAiStudioApiKey => 'Google AI Studio API 키 붙여넣기';

  @override
  String get enterOpenRouterApiKeyTitle => 'OpenRouter API 키 입력';

  @override
  String get openRouterApiKeyDescription =>
      'OpenRouter에서 가사 생성, 타임라인 생성 및 가사 번역에 사용됩니다.';

  @override
  String get pasteOpenRouterApiKey => 'OpenRouter API 키 붙여넣기';

  @override
  String get enterGeminiApiKeyTitle => 'Gemini API 키 입력';

  @override
  String get geminiApiKeyDescription => '가사 번역에 사용됩니다.';

  @override
  String get pasteGeminiApiKey => 'Gemini API 키 붙여넣기';

  @override
  String get testConnection => '연결 테스트';

  @override
  String get enterApiKey => 'API 키를 입력해주세요.';

  @override
  String get testingConnection => '연결 테스트 중...';

  @override
  String get getKey => '키 받기';

  @override
  String get editSongTagsTitle => '노래 태그 편집';

  @override
  String get changeArtwork => '커버 변경';

  @override
  String get clearArtwork => '커버 지우기';

  @override
  String get editSongTagsDescription => '앱에만 변경사항을 저장하거나 소스 파일에도 다시 쓸 수 있습니다.';

  @override
  String get artistLabel => '아티스트';

  @override
  String get albumLabel => '앨범';

  @override
  String get trackNumberLabel => '트랙 번호';

  @override
  String get trackNumberMustBeInteger => '트랙 번호는 정수여야 합니다';

  @override
  String get leaveBlankKeepsCurrentValue => '비워두면 이 필드가 지워집니다';

  @override
  String get currentFileFormatCannotWriteBack =>
      '이 파일 형식은 소스 파일에 다시 쓰기를 지원하지 않습니다. 변경사항은 앱에만 저장할 수 있습니다.';

  @override
  String get leaveBlankDoesNotClearOriginalValue => '팁: 필드를 비워두면 값이 지워집니다.';

  @override
  String get saveToApp => '앱에 저장';

  @override
  String get saveToSourceFileAndApp => '소스 파일과 앱에 저장';

  @override
  String get saveToSourceFileFailed =>
      '소스 파일 저장에 실패했습니다. 파일 형식이 쓰기를 지원하고 파일이 사용 중이 아닌지 확인해주세요.';

  @override
  String get fileOccupiedByOtherApp => '파일이 다른 앱에서 사용 중이어서 쓸 수 없습니다';

  @override
  String get saveFailed => '저장 실패. 나중에 다시 시도해주세요.';

  @override
  String apiKeySaved(Object provider) {
    return '$provider API 키 저장됨';
  }

  @override
  String get apiKeySavedAcoustid => 'AcoustID API 키가 저장되었습니다';

  @override
  String get generalSectionTitle => '인터페이스 및 동작';

  @override
  String get generalSectionDescription => '모양, 재생 상호작용 및 창/시스템 동작을 설정합니다.';

  @override
  String get uiAppearanceGroup => '모양 및 디스플레이';

  @override
  String get playbackBehaviorGroup => '재생 및 상호작용';

  @override
  String get systemWindowBehaviorGroup => '창 및 시스템 동작';

  @override
  String get interfaceLanguage => '인터페이스 언어';

  @override
  String get interfaceLanguageDescription => '애플리케이션의 표시 언어를 선택합니다.';

  @override
  String get scanSectionTitle => '검색';

  @override
  String get scanSectionDescription =>
      '이 옵션들은 라이브러리 검색이 오디오 파일을 처리하는 방식을 제어합니다.';

  @override
  String get skipShortAudioDuringScan => '검색 중 짧은 오디오 건너뛰기';

  @override
  String get skipShortAudioDuringScanDescription =>
      '임계값보다 짧은 오디오는 라이브러리에 추가되지 않습니다.';

  @override
  String get shortAudioScanThreshold => '짧은 오디오 임계값';

  @override
  String get shortAudioScanThresholdDescription => '이 시간보다 짧은 파일은 건너뜁니다.';

  @override
  String shortAudioScanThresholdValue(Object seconds) {
    return '$seconds초';
  }

  @override
  String get shortcutSettingsTitle => '사용자 지정 단축키';

  @override
  String get shortcutSettingsDescription => '클릭하여 플레이어 동작의 단축키를 다시 기록하고 저장합니다.';

  @override
  String get edit => '편집';

  @override
  String get lyricsSectionTitle => '가사';

  @override
  String get lyricsSectionDescription => '이 설정들은 가사 생성 및 타임라인 생성에만 영향을 줍니다.';

  @override
  String get lyricsTranslationTargetLanguageLabel => '번역 대상 언어';

  @override
  String get lyricsTranslationTargetLanguageDescription =>
      '기본값은 시스템 언어이며 수동으로 선택할 수도 있습니다.';

  @override
  String get lyricsSaveMethodLabel => '가사 저장 위치';

  @override
  String get lyricsSaveMethodDescription => '파일에 쓸 때 가사가 저장될 위치를 선택합니다.';

  @override
  String get lyricsSaveMethodOriginal => '원본 위치';

  @override
  String get lyricsSaveMethodEmbedded => '내장';

  @override
  String get lyricsSaveMethodLrcFile => 'LRC 파일';

  @override
  String get lyricsStyleLabel => '가사 패널 스타일';

  @override
  String get lyricsStyleDescription => '가사 패널의 표시 스타일을 선택합니다.';

  @override
  String get lyricsStyleTraditional => '기본 스크롤';

  @override
  String get lyricsStyleApple => '줄 단위 포커스';

  @override
  String get resumeLyricsSync => '가사 동기화 재개';

  @override
  String get followSystemLanguage => '시스템 언어 따르기';

  @override
  String get autoSwitchLyricsProvider => '자동 가사 제공자 전환';

  @override
  String get autoSwitchLyricsProviderEnabledDesc =>
      'Google AI Studio를 먼저 시도합니다. 기본 모델과 대체 모델 모두 429 또는 5xx 오류로 실패하면 앱이 자동으로 OpenRouter로 전환하여 계속 시도합니다.';

  @override
  String get autoSwitchLyricsProviderDisabledDesc =>
      '자동 전환을 활성화하려면 Google AI Studio와 OpenRouter 모두에 대한 API 키가 필요합니다.';

  @override
  String get lyricsAiProviderTitle => '가사 AI 제공자';

  @override
  String get lyricsAiProviderDescription =>
      '이 설정은 가사 생성 및 타임라인 생성에만 영향을 줍니다. 번역은 항상 Google AI Studio를 사용합니다.';

  @override
  String get googleAiStudioApiKeySaved => 'Google AI Studio API 키가 저장되었습니다';

  @override
  String get googleAiStudioApiKeyMissing =>
      '아직 Google AI Studio API 키가 저장되지 않았습니다. 가사 생성 및 타임라인 생성 시 먼저 입력하라는 메시지가 표시됩니다.';

  @override
  String get openRouterApiKeySaved => 'OpenRouter API 키가 저장되었습니다';

  @override
  String get openRouterApiKeyMissing =>
      '아직 OpenRouter API 키가 저장되지 않았습니다. 가사 생성 및 타임라인 생성 시 먼저 입력하라는 메시지가 표시됩니다.';

  @override
  String get apiKeySavedStatus => '저장됨';

  @override
  String get apiKeyMissingStatus => '입력되지 않음';

  @override
  String get platformApiKeysSectionTitle => '플랫폼 API 키';

  @override
  String get fill => '입력';

  @override
  String get modify => '수정';

  @override
  String get geminiModelsSectionTitle => '모델 선택';

  @override
  String get geminiModelsSectionDescription =>
      '이 모델들은 Google AI Studio에서 가사 생성, 타임라인 생성 및 가사 번역에 사용됩니다.';

  @override
  String get primaryModelLabel => '기본 모델';

  @override
  String get backupModelLabel => '대체 모델';

  @override
  String get translationModelLabel => '번역 모델';

  @override
  String get fetching => '가져오는 중...';

  @override
  String get fetchModelList => '모델 목록 가져오기';

  @override
  String get restoreDefault => '기본값 복원';

  @override
  String get acoustidSectionTitle => '핑거프린팅';

  @override
  String get acoustidApiKeyTitle => 'AcoustID API 키';

  @override
  String get acoustidApiKeyHelp =>
      'AcoustID는 오디오 핑거프린팅에 사용됩니다. 자체 API 키 사용을 권장합니다.';

  @override
  String get acoustidApiKeySaved => 'AcoustID API 키가 저장되었습니다';

  @override
  String get acoustidApiKeyDefault =>
      '현재 내장 기본 키가 사용 중입니다. 자체 키로 교체하는 것을 권장합니다.';

  @override
  String get applyForApiKey => 'API 키 신청: https://acoustid.org/new-application';

  @override
  String get queueTabBarFavoriteAdded => '즐겨찾기에 추가됨';

  @override
  String get queueTabBarFavoriteRemoved => '즐겨찾기에서 제거됨';

  @override
  String get tagCompletion => '태그 완성';

  @override
  String get tagCompletionDescription => 'AcoustID 및 MusicBrainz 결과로 태그 일치';

  @override
  String get goToSettings => '설정으로 이동';

  @override
  String get searchReleaseTitles => '릴리스 제목 검색';

  @override
  String get closeSearch => '검색 닫기';

  @override
  String get refreshResults => '결과 새로고침';

  @override
  String get filterMusicBrainzReleaseTitle => 'MusicBrainz 릴리스 제목 필터';

  @override
  String get clearSearch => '검색 지우기';

  @override
  String get localTitle => '로컬 제목';

  @override
  String get queryConditions => '쿼리 조건';

  @override
  String get musicBrainzLoading => 'MusicBrainz 로딩 중';

  @override
  String get musicBrainzLoadingWithResults => '기존 결과는 패널에 유지됩니다';

  @override
  String get musicBrainzLoadingHint => '잠시만 기다려주세요';

  @override
  String get musicBrainzQueryFailed => 'MusicBrainz 쿼리 실패';

  @override
  String get musicBrainzNetworkErrorHint =>
      '요청이 실패했습니다. 일반적으로 불안정한 네트워크, 시간 초과 또는 서버 거부로 인해 발생합니다. 나중에 다시 시도하세요.';

  @override
  String get musicBrainzFilteredEmptyHint =>
      '현재 필터에서 해당 키워드가 포함된 릴리스 제목을 찾을 수 없습니다.';

  @override
  String get musicBrainzEmptyHint =>
      'MusicBrainz가 사용 가능한 결과를 반환하지 않았습니다. 제목, 아티스트 또는 앨범 필터를 완화해보세요.';

  @override
  String get musicBrainzEmptyMoreCompleteHint =>
      '나중에 다시 시도하거나 현재 제목 또는 아티스트 정보를 더 완전하게 확인하세요.';

  @override
  String get retry => '재시도';

  @override
  String get noMatchingRelease => '일치하는 릴리스를 찾을 수 없습니다';

  @override
  String get noMatchingResults => '일치하는 결과가 없습니다';

  @override
  String get networkConnectionFailed => '네트워크 연결 실패';

  @override
  String get searchAgain => '다시 검색';

  @override
  String get acoustidRecognitionRecords => 'AcoustID 인식 기록';

  @override
  String get musicBrainzRecordings => 'MusicBrainz 녹음';

  @override
  String get noExpandableReleaseGroups => '확장 가능한 릴리스 그룹이 없습니다';

  @override
  String get noExpandableReleases => '확장 가능한 릴리스가 없습니다';

  @override
  String get noMatchingResultHint =>
      '나중에 다시 시도하거나 현재 제목 또는 아티스트 정보를 더 완전하게 확인하세요.';

  @override
  String releaseCountLabel(int count) {
    return '$count개 릴리스 버전';
  }

  @override
  String recordingCountLabel(int count) {
    return '$count개 녹음';
  }

  @override
  String trackCountShort(int count) {
    return '$count개 트랙';
  }

  @override
  String scoreLabel(int score) {
    return '점수 $score';
  }

  @override
  String matchScoreLabel(int score) {
    return '일치 $score%';
  }

  @override
  String get editQueryCondition => '쿼리 조건 편집';

  @override
  String get enterNewQueryText => '새 쿼리 텍스트 입력';

  @override
  String get durationLabel => '재생 시간';

  @override
  String get customShortcuts => '사용자 지정 단축키';

  @override
  String get pressShortcutCombo => '단축키 조합을 누르세요';

  @override
  String get clickToRecord => '클릭하여 설정';

  @override
  String get searchingLyrics => '가사 검색 중';

  @override
  String get noLyrics => '아직 가사가 없습니다';

  @override
  String get providerLabel => '제공자';

  @override
  String get modelLabel => '모델';

  @override
  String get unspecified => '지정되지 않음';

  @override
  String targetTimeLabel(String duration) {
    return '대상 시간 $duration';
  }

  @override
  String get songDeletedSkipped => '노래 삭제됨, 건너뜀';

  @override
  String get songDeleted => '노래 삭제됨';

  @override
  String get lyricsTaskUploading => '업로드 중';

  @override
  String get lyricsTaskWaiting => '대기 중';

  @override
  String get lyricsTaskRequesting => '요청 중';

  @override
  String get lyricsTaskGenerating => '생성 중';

  @override
  String get lyricsTaskRetrying => '재시도 중';

  @override
  String get lyricsTaskProcessing => '처리 중';

  @override
  String get unknownModel => '알 수 없는 모델';

  @override
  String selectedFolders(int count) {
    return '$count개 폴더 선택됨';
  }

  @override
  String foldersDeleted(int count) {
    return '$count개 폴더 삭제됨';
  }

  @override
  String get persistentAccessDenied => '해당 폴더에 대한 접근을 저장할 수 없습니다. 다시 선택해주세요.';

  @override
  String get folderAddFailed => '폴더 추가 실패';

  @override
  String get sleepTimer => '슬립 타이머';

  @override
  String sleepTimerRemaining(Object duration) {
    return '슬립 타이머 $duration';
  }

  @override
  String get unknownArtistOrAlbum => '알 수 없음';

  @override
  String get pressAgainToExit => '한 번 더 누르면 종료됩니다';

  @override
  String get tagCompletionSuccessWithCover =>
      '태그가 완성되어 저장되었으며, 커버가 임시 디렉토리에 다운로드되었습니다';

  @override
  String get tagCompletionSuccess => '태그가 완성되어 저장되었습니다';

  @override
  String get selectOnlineLyrics => '온라인 가사 선택';

  @override
  String get increaseLyricsFont => '가사 글꼴 크게';

  @override
  String get decreaseLyricsFont => '가사 글꼴 작게';

  @override
  String get restoreDefaultSize => '기본 크기로 복원';

  @override
  String get adjustLyricsFont => '텍스트 크기 조정';

  @override
  String get searchingOnlineLyrics => '온라인 가사 검색 중';

  @override
  String get onlineLyricsResults => '온라인 가사 결과';

  @override
  String get untitledLyrics => '제목 없는 가사';

  @override
  String get hasTimeline => '타임라인 있음';

  @override
  String get viewLyricsDetails => '가사 상세 보기';

  @override
  String get lyricsDetails => '가사 상세';

  @override
  String get lyricsContent => '가사 내용';

  @override
  String get noLyricsContent => '가사 내용 없음';

  @override
  String get queryContentLabel => '내용';

  @override
  String get yes => '예';

  @override
  String get no => '아니오';

  @override
  String dropAddedSongs(int addedCount) {
    return '$addedCount곡 추가됨';
  }

  @override
  String dropAddedSongsWithExisting(int addedCount, int existingCount) {
    return '$addedCount곡 추가됨, $existingCount곡은 이미 존재함';
  }

  @override
  String get copyCover => '커버를 클립보드에 복사';

  @override
  String get copyCoverSuccess => '커버가 클립보드에 복사되었습니다';

  @override
  String get searchLyricsPlaceholder => '노래 제목, 아티스트 또는 가사를 입력하여 검색';

  @override
  String get share => '공유';

  @override
  String get windowsSettingsTitle => 'Windows 설정';

  @override
  String get fileAssociationTitle => '파일 연결';

  @override
  String get fileAssociationDescription =>
      '일반적인 음악 형식(mp3, flac, wav 등)을 이 앱과 연결하여 더블클릭으로 열 수 있습니다.';

  @override
  String get associateButton => '연결';

  @override
  String get disassociateButton => '제거';

  @override
  String get associationSuccess =>
      '연결 성공! 더블클릭이 작동하지 않으면 Windows 기본 앱 설정에서 Vynody를 선택해주세요.';

  @override
  String get disassociationSuccess => '파일 연결이 성공적으로 제거되었습니다.';

  @override
  String associationFailed(Object error) {
    return '연결 실패: $error';
  }

  @override
  String get onboardingTitle => 'Vynody에 오신 것을 환영합니다';

  @override
  String get onboardingSubtitle => '몇 가지 간단한 단계로 음악 여정을 시작하세요.';

  @override
  String get onboardingStepFileAssociation => '파일 형식 연결';

  @override
  String get onboardingFileAssociationDesc =>
      '일반적인 음악 형식(mp3, flac, wav 등)을 Vynody와 연결하여 파일 탐색기에서 더블클릭으로 음악을 재생하세요.';

  @override
  String get onboardingFileAssociationTip =>
      '연결 후 시스템에서 \'연결 프로그램\' 선택 메뉴가 나타날 수 있습니다. 목록에서 \'Vynody\'를 선택하고 \'항상 이 앱 사용\'을 선택해주세요.';

  @override
  String get onboardingStepRootDirectory => '음악 루트 디렉토리 추가';

  @override
  String get onboardingRootDirectoryDesc =>
      '음악 파일이 저장된 폴더를 선택하세요. Vynody가 자동으로 스캔하여 개인 음악 라이브러리를 구축합니다.';

  @override
  String get onboardingAndroidPermissionTip =>
      '참고: Android에서 로컬 음악을 가져오고 스캔하려면 미디어 라이브러리 접근 권한이 필요합니다. [폴더 선택]을 누르면 권한 요청이 표시되므로 허용해 주세요.';

  @override
  String get onboardingSelectDirectory => '폴더 선택';

  @override
  String get onboardingSuccessTitle => '모든 준비 완료!';

  @override
  String get onboardingSuccessDesc => '미디어 라이브러리가 성공적으로 추가되었습니다. 음악을 즐겨보세요!';

  @override
  String get onboardingStartButton => '시작하기';

  @override
  String get onboardingSkip => '나중에 설정';

  @override
  String get onboardingNext => '다음';

  @override
  String get onboardingBack => '뒤로';

  @override
  String get resetOnboarding => '온보딩 초기화';

  @override
  String get resetOnboardingDesc => '온보딩 상태를 지웁니다. 다음 시작 시 환영 가이드가 다시 표시됩니다.';

  @override
  String get songProperties => '노래 속성';

  @override
  String get failedToLoadDetails => '세부 정보를 불러오지 못했습니다';

  @override
  String get noPropertiesAvailable => '사용 가능한 속성이 없습니다';

  @override
  String get detailFilePath => '파일 경로';

  @override
  String get detailFormat => '형식';

  @override
  String get detailCodec => '코덱';

  @override
  String get detailDuration => '재생 시간';

  @override
  String get detailFileSize => '파일 크기';

  @override
  String get detailBitrate => '비트레이트';

  @override
  String get detailSampleRate => '샘플레이트';

  @override
  String get detailChannels => '채널';

  @override
  String get detailBitDepth => '비트 심도';

  @override
  String get detailMono => '모노';

  @override
  String get detailStereo => '스테레오';

  @override
  String detailChannelsCount(int count) {
    return '$count채널';
  }

  @override
  String get localNetworkPermissionDeniedTitle => '로컬 네트워크 접근 제한';

  @override
  String get localNetworkPermissionDeniedMessage =>
      '사용 가능한 로컬 네트워크 IP 주소가 감지되지 않았거나 로컬 네트워크 권한이 거부되었습니다.\n\n다음 사항을 확인해주세요:\n1. 기기가 Wi-Fi 또는 로컬 네트워크에 연결되어 있는지 확인하세요.\n2. 시스템 설정에서 앱이 로컬 네트워크에 접근할 수 있는 권한이 있는지 확인하세요:\n   - iOS/macOS: 설정 > 개인정보 보호 및 보안 > 로컬 네트워크로 이동하여 Vynody의 스위치를 켜세요.\n   - Windows: 연결되어 있는지 확인하고 Windows 방화벽이 Vynody의 네트워크 접근을 허용하는지 확인하세요.';

  @override
  String get localNetworkPermissionWindowsMessage =>
      '사용 가능한 로컬 네트워크 IP 주소가 감지되지 않았습니다.\n\n다음 사항을 확인해주세요:\n1. 기기가 로컬 네트워크(Wi-Fi 또는 이더넷)에 연결되어 있는지 확인하세요.\n2. 연결되어 있지만 오류가 지속되면 Windows 방화벽 설정에서 Vynody가 방화벽을 통과하도록 허용되어 있는지 확인하세요.';

  @override
  String get openSettingsButton => '설정 열기';

  @override
  String get closeButton => '닫기';

  @override
  String get copyTranslationResults => '번역 결과 복사';

  @override
  String get writeLyricsToFile => '가사를 파일에 쓰기';

  @override
  String get selectLyricSource => '가사 소스 선택';

  @override
  String get regenerateLyrics => '가사 다시 생성';

  @override
  String get regenerateLyricsConfirmation => '현재 가사가 지워지고 다시 생성됩니다. 계속하시겠습니까?';

  @override
  String get regenerateTimeline => '타임라인 다시 생성';

  @override
  String get regenerateTimelineConfirmation =>
      '현재 타임라인이 지워지고 다시 생성됩니다. 계속하시겠습니까?';

  @override
  String get retranslateLyrics => '가사 다시 번역';

  @override
  String get retranslateLyricsConfirmation => '현재 번역이 지워지고 다시 번역됩니다. 계속하시겠습니까?';

  @override
  String get translationCopiedToClipboard => '번역 결과가 클립보드에 복사되었습니다';

  @override
  String get writingLyrics => '가사 쓰는 중...';

  @override
  String get lyricsWrittenToFile => '가사가 파일에 성공적으로 저장되었습니다';

  @override
  String get writeLyricsFailed => '가사 쓰기 실패';

  @override
  String get externalLrcFile => '외부 LRC 파일';

  @override
  String get embeddedLyrics => '내장 가사';

  @override
  String get manuallyAdjustedLyrics => '수동 조정된 가사';

  @override
  String get lrclibOnlineLyrics => 'LrcLib 온라인 가사';

  @override
  String get aiGeneratedLyrics => 'AI 생성 가사';

  @override
  String get matchScore => '일치';

  @override
  String get untitledRelease => '제목 없는 릴리스';

  @override
  String get localSongFileNotFoundForGeneration =>
      '로컬 노래 파일이 존재하지 않아 가사를 생성할 수 없습니다.';

  @override
  String get localSongFileNotFoundForTimeline =>
      '로컬 노래 파일이 존재하지 않아 타임라인을 생성할 수 없습니다.';

  @override
  String get noLyricsForTimelineGeneration => '타임라인 생성에 사용할 수 있는 가사가 없습니다.';

  @override
  String get noLyricsAvailableForTranslation => '번역에 사용할 수 있는 가사가 없습니다.';

  @override
  String get noCurrentSongAvailable => '현재 노래가 없습니다.';

  @override
  String get invalidTargetLanguage => '유효하지 않은 대상 언어입니다.';

  @override
  String get songAlreadyQueuedForTranslation => '현재 노래가 이미 번역 대기열에 있습니다.';

  @override
  String get songAlreadyQueuedForGeneration => '현재 노래가 이미 가사 생성 대기열에 있습니다.';

  @override
  String get songNoLongerExistsForTranslation =>
      '현재 노래가 더 이상 존재하지 않아 가사를 번역할 수 없습니다.';

  @override
  String get generationFailed => '생성 실패.';

  @override
  String get generatingLyrics => '가사 생성 중';

  @override
  String get generatingTimeline => '타임라인 생성 중';

  @override
  String get regeneratingLyrics => '가사 다시 생성 중';

  @override
  String get translatingLyrics => '가사 번역 중';

  @override
  String get transcodingSongFile => '노래 파일 트랜스코딩 중';

  @override
  String get uploadingSongFile => '노래 파일 업로드 중';

  @override
  String get fileUploadedWaitingForReadiness => '파일 업로드됨, 준비 대기 중';

  @override
  String get waitingForFileReadiness => '파일 준비 대기 중';

  @override
  String get requestingModelResponse => '모델 응답 요청 중';

  @override
  String retryingTaskKindGeneration(Object taskKind) {
    return '$taskKind 생성 재시도 중';
  }

  @override
  String get retrying => '재시도 중';

  @override
  String get processing => '처리 중';

  @override
  String get timeline => '타임라인';

  @override
  String get lyrics => '가사';

  @override
  String lyricGenerationError(Object error) {
    return '가사 생성 중 오류 발생: $error';
  }

  @override
  String timelineGenerationError(Object error) {
    return '타임라인 생성 중 오류 발생: $error';
  }

  @override
  String get unknownGenerationError => '가사 생성 중 알 수 없는 오류가 발생했습니다.';

  @override
  String get unknownTimelineGenerationError => '타임라인 생성 중 알 수 없는 오류가 발생했습니다.';

  @override
  String get unknownTranslationError => '가사 번역 중 알 수 없는 오류가 발생했습니다.';

  @override
  String get unknownError => '알 수 없는 오류';

  @override
  String get modelRefusedToGenerateLyrics => '모델이 가사 생성을 거부했습니다.';

  @override
  String get modelRefusedToGenerateTimeline => '모델이 타임라인 생성을 거부했습니다.';

  @override
  String get doubaoPreUploadTranscodingFailed => 'Doubao 업로드 전 오디오 트랜스코딩 실패';

  @override
  String get doubaoTempTranscodeNotInTempDir =>
      '임시 트랜스코딩 파일이 임시 디렉토리에 생성되지 않았습니다.';

  @override
  String get doubaoEmptyStreamingResponse => 'Doubao가 빈 스트리밍 응답을 반환했습니다.';

  @override
  String get doubaoEmptyResponse => 'Doubao가 빈 응답을 반환했습니다.';

  @override
  String get geminiEmptyStreamingResponse => 'Gemini가 빈 스트리밍 응답을 반환했습니다.';

  @override
  String get geminiEmptyResponse => 'Gemini가 빈 응답을 반환했습니다.';

  @override
  String get openRouterEmptyStreamingResponse =>
      'OpenRouter가 빈 스트리밍 응답을 반환했습니다.';

  @override
  String get openRouterEmptyResponse => 'OpenRouter가 빈 응답을 반환했습니다.';

  @override
  String get deepseekEmptyStreamingResponse => 'DeepSeek가 빈 스트리밍 응답을 반환했습니다.';

  @override
  String get deepseekEmptyResponse => 'DeepSeek가 빈 응답을 반환했습니다.';

  @override
  String get customProviderEmptyStreamingResponse =>
      '사용자 지정 제공자가 빈 스트리밍 응답을 반환했습니다.';

  @override
  String get customProviderEmptyResponse => '사용자 지정 제공자가 빈 응답을 반환했습니다.';

  @override
  String get fileUploadFailed => '파일 업로드 실패. 다시 시도해주세요.';

  @override
  String get uploadedFileNotReady => '업로드된 파일이 준비되지 않았습니다. 나중에 다시 시도해주세요.';

  @override
  String get audioTranscodingFailed => '오디오 트랜스코딩 실패.';

  @override
  String get tempTranscodeNotInTempDir => '임시 트랜스코딩 파일이 임시 디렉토리에 생성되지 않았습니다.';

  @override
  String get networkRequestFailedCheckProxy =>
      '네트워크 요청 실패. 네트워크 및 프록시 설정을 확인해주세요.';

  @override
  String get quotaExhaustedToday => '오늘의 할당량이 소진되었습니다. 내일 초기화된 후 다시 시도해주세요.';

  @override
  String get googleAiHeavyLoad => 'Google AI가 과부하 상태여서 일시적으로 사용할 수 없습니다.';

  @override
  String lyricsGenerationFailedWithError(Object error) {
    return '가사 생성 실패: $error';
  }

  @override
  String missingApiKeyForAction(Object action, Object providerName) {
    return '$providerName의 API 키를 찾을 수 없어 $action을(를) 사용할 수 없습니다.';
  }

  @override
  String locationNotSupportedForModel(String modelName) {
    return '현재 위치에서는 $modelName을(를) 지원하지 않습니다';
  }

  @override
  String get googleServerFlaky => 'Google에 일시적인 문제가 있습니다. 다시 시도하면 성공할 수 있습니다.';

  @override
  String get translateLyricsAction => '가사 번역';

  @override
  String get generateLyricsAction => '가사 생성';

  @override
  String get generateTimelineAction => '타임라인 생성';

  @override
  String get deepseekOnlyTranslation => 'DeepSeek는 가사 번역에만 사용할 수 있습니다.';

  @override
  String get customProviderOnlyTranslation => '사용자 지정 제공자는 가사 번역에만 사용할 수 있습니다.';

  @override
  String get customProviderNoBaseUrl => '사용자 지정 제공자의 기본 URL이 설정되지 않았습니다.';

  @override
  String get pleaseEnterApiKey => 'API 키를 입력해주세요.';

  @override
  String get connectionSuccessVerificationPassed => '연결 성공, 확인 통과.';

  @override
  String connectionSuccessDetectedModels(Object count) {
    return '연결 성공, $count개 모델 감지됨.';
  }

  @override
  String testFailedWithStatus(Object message, Object statusCode) {
    return '테스트 실패 ($statusCode): $message';
  }

  @override
  String get testFailedCheckNetworkOrApiKey => '테스트 실패. 네트워크 또는 API 키를 확인해주세요.';

  @override
  String testFailedStatusCheckApiKey(Object statusCode) {
    return '테스트 실패 ($statusCode). API 키가 유효한지 확인해주세요.';
  }

  @override
  String get enterGoogleAiStudioApiKeyFirst =>
      '먼저 Google AI Studio API 키를 입력해주세요.';

  @override
  String get enterDoubaoApiKeyFirst => '먼저 Doubao API 키를 입력해주세요.';

  @override
  String get enterDeepseekApiKeyFirst => '먼저 DeepSeek API 키를 입력해주세요.';

  @override
  String get enterCustomApiKeyAndBaseUrl => '먼저 사용자 지정 API 키와 기본 URL을 입력해주세요.';

  @override
  String fetchedCountModels(Object count) {
    return '$count개 모델을 가져왔습니다.';
  }

  @override
  String requestFailedWithStatus(Object message, Object statusCode) {
    return '요청 실패 ($statusCode): $message';
  }

  @override
  String get requestFailedCheckNetwork => '요청 실패. 네트워크를 확인하세요.';

  @override
  String requestFailedStatus(Object statusCode) {
    return '요청 실패 ($statusCode).';
  }

  @override
  String get doubao => 'Doubao';

  @override
  String get noModelSelected => '선택된 모델 없음';

  @override
  String get acoustidRequestFailed => 'AcoustID 요청 실패';

  @override
  String acoustidRequestReturnedStatus(Object statusCode) {
    return 'AcoustID 요청이 $statusCode을(를) 반환했습니다. 자체 AcoustID API 키를 신청하여 설정에 입력해주세요.';
  }

  @override
  String get writeTagDatabaseFailed => '태그 데이터베이스 쓰기 실패';

  @override
  String get playPause => '재생 / 일시 정지';

  @override
  String get nextTrack => '다음';

  @override
  String get previousTrack => '이전';

  @override
  String get volumeUp => '볼륨 업';

  @override
  String get volumeDown => '볼륨 다운';

  @override
  String get toggleMute => '음소거 전환';

  @override
  String get seekForward5s => '5초 앞으로';

  @override
  String get seekBackward5s => '5초 뒤로';

  @override
  String get toggleFullScreen => '전체 화면 전환';

  @override
  String get playPauseDescription => '현재 재생 상태를 제어합니다.';

  @override
  String get nextDescription => '다음 노래로 건너뜁니다.';

  @override
  String get previousDescription => '이전 노래로 돌아갑니다.';

  @override
  String get volumeUpDescription => '볼륨을 5%씩 올립니다.';

  @override
  String get volumeDownDescription => '볼륨을 5%씩 내립니다.';

  @override
  String get toggleMuteDescription => '음소거를 전환합니다.';

  @override
  String get seekForward5sDescription => '5초 앞으로 탐색합니다.';

  @override
  String get seekBackward5sDescription => '5초 뒤로 탐색합니다.';

  @override
  String get toggleFullScreenDescription => '창 모드와 전체 화면 간 전환합니다.';

  @override
  String get unknownKey => '알 수 없는 키';

  @override
  String get removeFromQueue => '대기열에서 제거';

  @override
  String get removeFromPlaylist => '재생목록에서 제거';

  @override
  String get alreadyLatestVersion => '이미 최신 버전입니다.';

  @override
  String get updateAvailable => '업데이트 가능';

  @override
  String newVersionAvailable(Object version) {
    return '새 버전 v$version을 사용할 수 있습니다. GitHub 릴리스 페이지에서 다운로드하세요.';
  }

  @override
  String get openRelease => '릴리스 열기';

  @override
  String get checkUpdateFailedNetwork =>
      '업데이트 확인 실패. 네트워크 문제 또는 GitHub 속도 제한일 수 있습니다.';

  @override
  String get tags => '태그';

  @override
  String get about => '정보';

  @override
  String get rebuildIndex => '인덱스 재구축';

  @override
  String get rebuildIndexDescription =>
      '모든 노래 기록(외부 소스 제외)을 지우고 모든 루트 디렉토리를 다시 검색합니다.';

  @override
  String get rebuildIndexConfirmation =>
      '모든 노래 기록(외부 소스 제외)을 지우고 모든 루트 디렉토리를 다시 검색하시겠습니까? 이 과정은 시간이 걸릴 수 있습니다.';

  @override
  String get rebuildIndexStarted => '인덱스 재구축 시작됨';

  @override
  String get rebuild => '재구축';

  @override
  String get advanced => '고급';

  @override
  String get advancedOptionsDescription => '디버깅 및 동작 튜닝을 위한 옵션입니다.';

  @override
  String get showDeveloperOptionsDescription => '디버깅용 더 많은 고급 옵션을 표시합니다.';

  @override
  String get onboardingReset => '온보딩이 초기화되었습니다. 다음 시작 시 적용됩니다.';

  @override
  String get tagsSectionDescription => '오디오 파일 메타데이터 및 자동 완성을 구성합니다.';

  @override
  String get autoSaveToSourceFile => '소스 파일에 자동 저장';

  @override
  String get autoSaveToSourceFileDescription =>
      '완료 시 태그를 물리적 오디오 파일에 자동으로 다시 씁니다.';

  @override
  String get aboutSectionDescription => '버전 정보, 프로젝트 링크 및 관련 정보.';

  @override
  String get checkForUpdates => '업데이트 확인';

  @override
  String get storeUpdateNotice =>
      '이 앱의 업데이트는 Microsoft Store에서 관리합니다. Microsoft Store에서 최신 버전을 확인하실 수 있습니다.';

  @override
  String get openMicrosoftStore => 'Microsoft Store로 이동';

  @override
  String get appStoreUpdateNotice =>
      '이 앱의 업데이트는 App Store에서 관리됩니다. App Store에서 최신 버전을 확인하거나 다운로드할 수 있습니다.';

  @override
  String get openAppStore => 'App Store로 이동';

  @override
  String get lyricsGenerationModel => '가사 생성 모델';

  @override
  String get lyricsGenerationModelDescription =>
      'AI 가사 생성 및 타임라인 생성/수정에 사용됩니다.';

  @override
  String get lyricsTranslationModel => '가사 번역 모델';

  @override
  String get lyricsTranslationModelDescription => '대상 언어로 가사를 번역하는 데 사용됩니다.';

  @override
  String get onlyForLyricTranslation => '가사 번역 전용';

  @override
  String get fillApiKeyFirstEnablesModels => '하나 이상의 API 키를 입력해야 모델 선택이 가능합니다.';

  @override
  String get customApiProvider => '사용자 지정 API 제공자';

  @override
  String get clearedGoogleAiStudioApiKey => 'Google AI Studio API 키가 지워졌습니다';

  @override
  String get clearedOpenRouterApiKey => 'OpenRouter API 키가 지워졌습니다';

  @override
  String get clearedDoubaoApiKey => 'Doubao API 키가 지워졌습니다';

  @override
  String get clearedDeepseekApiKey => 'DeepSeek API 키가 지워졌습니다';

  @override
  String get clearedCustomProviderConfig => '사용자 지정 제공자 구성이 지워졌습니다';

  @override
  String get savedDoubaoApiKey => 'Doubao API 키가 저장되었습니다';

  @override
  String get savedDeepseekApiKey => 'DeepSeek API 키가 저장되었습니다';

  @override
  String get savedCustomProviderConfig => '사용자 지정 제공자 구성이 저장되었습니다';

  @override
  String get noMatchingFoldersOrSongs => '일치하는 폴더 또는 노래가 없습니다';

  @override
  String get searching => '검색 중...';

  @override
  String get listView => '목록 보기';

  @override
  String get gridView => '격자 보기';

  @override
  String get hybridView => '하이브리드 보기';

  @override
  String songsCountFormat(Object count) {
    return '$count곡';
  }

  @override
  String get searchInFolderAndSubfolders => '폴더 및 하위 폴더에서 검색...';

  @override
  String get shuffle => '셔플';

  @override
  String get search => '검색';

  @override
  String get selectFolders => '폴더 선택';

  @override
  String get removeDirectory => '디렉토리 제거';

  @override
  String removeRootDirectoryConfirmation(Object name) {
    return '루트 디렉토리 \"$name\"을(를) 제거하시겠습니까? 디스크의 물리적 파일은 삭제되지 않습니다.';
  }

  @override
  String get deselectAll => '모두 선택 해제';

  @override
  String get favorites => '즐겨찾기';

  @override
  String get aggregationPeak => '최고점';

  @override
  String get aggregationMean => '평균';

  @override
  String get aggregationRms => 'RMS';

  @override
  String get filesToTranscode => '트랜스코딩할 파일';

  @override
  String get chooseAndroidOutputDirectoryFirst => '먼저 Android 출력 디렉토리를 선택해주세요.';

  @override
  String currentSongProgressPercent(Object percent) {
    return '현재 노래 $percent%';
  }

  @override
  String overallProgressPercent(Object percent) {
    return '전체 $percent%';
  }

  @override
  String get pleaseChooseOutputDirectory => '출력 디렉토리를 선택해주세요.';

  @override
  String selectedArtistsCount(Object count) {
    return '$count명의 아티스트 선택됨';
  }

  @override
  String selectedAlbumsCount(Object count) {
    return '$count개 앨범 선택됨';
  }

  @override
  String get simplifiedChinese => '간체 중국어';

  @override
  String get traditionalChinese => '번체 중국어';

  @override
  String get chineseLanguage => '중국어';

  @override
  String get englishLanguage => '영어';

  @override
  String get japaneseLanguage => '일본어';

  @override
  String get koreanLanguage => '한국어';

  @override
  String get frenchLanguage => '프랑스어';

  @override
  String get germanLanguage => '독일어';

  @override
  String get spanishLanguage => '스페인어';

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
  String get portugueseLanguage => '포르투갈어';

  @override
  String get russianLanguage => '러시아어';

  @override
  String get systemLanguage => '시스템 언어';

  @override
  String get targetLanguage => '대상 언어';

  @override
  String get whatAreAiLyrics => 'AI 가사란 무엇인가요?';

  @override
  String get whatIsAiLyricTranslation => 'AI 가사 번역이란 무엇인가요?';

  @override
  String get aiLyricsIntroGeneration => 'AI가 노래에서 가사를 생성하고 타임라인에 맞출 수 있습니다.';

  @override
  String get aiLyricsIntroTranslation =>
      'AI가 가사를 원하는 언어로 번역하여 노래를 더 쉽게 이해할 수 있게 해줍니다.';

  @override
  String get whyNeedApiKey => 'API 키가 왜 필요한가요?';

  @override
  String get apiKeyExplanation =>
      'API 키는 AI 제공자에 대한 액세스 자격 증명입니다. 앱이 이를 사용하여 가사 생성, 타임라인 조정 또는 번역을 위해 직접 요청을 보냅니다.';

  @override
  String get apiKeyLocalOnly => 'API 키는 이 기기에만 저장되며 Vynody 개발자 서버에 업로드되지 않습니다.';

  @override
  String get chooseAnAiProvider => 'AI 제공자를 선택하세요:';

  @override
  String get googleProviderPros =>
      '공식 Google 채널로 강력한 Gemini 모델과 넉넉한 무료 할당량이 제공됩니다.';

  @override
  String get googleProviderCons =>
      '트래픽이 많으면 가끔 429 오류가 발생할 수 있습니다. 그런 경우 다른 제공자로 전환하세요.';

  @override
  String get openRouterProviderPros =>
      '다양한 AI 모델을 통합 제공하는 해외 플랫폼으로, 일부 무료 모델도 제공합니다.';

  @override
  String get openRouterProviderCons => '충전에 수수료가 포함될 수 있으며 웹사이트는 영어 전용입니다.';

  @override
  String get doubaoProviderPros =>
      'ByteDance에서 개발했으며 중국어 텍스트 처리에 강력합니다. 신규 사용자는 모델당 50만 개의 무료 토큰을 받습니다.';

  @override
  String get doubaoProviderCons => '가입 절차가 비교적 복잡하고 실명 인증이 필요합니다.';

  @override
  String get deepseekProviderPros => '중국어 이해도가 좋고 가격이 저렴하며 가사 번역에 적합합니다.';

  @override
  String get deepseekProviderCons =>
      '텍스트 입력만 가능합니다. 가사 생성 및 타임라인 조정은 다른 제공자의 API 키가 필요합니다.';

  @override
  String get highlights => '하이라이트';

  @override
  String get notes => '참고';

  @override
  String enterProviderApiKey(Object provider) {
    return '$provider API 키를 입력하세요:';
  }

  @override
  String get pasteYourApiKey => '여기에 API 키를 붙여넣으세요';

  @override
  String get getApiKey => 'API 키 받기';

  @override
  String get testConnectionButton => '연결 테스트';

  @override
  String get enableAiLyricGeneration => 'AI 가사 생성 활성화';

  @override
  String get enableAiLyricTranslation => 'AI 가사 번역 활성화';

  @override
  String get notNow => '나중에';

  @override
  String get startSetup => '설정 시작';

  @override
  String get chooseAiProvider => 'AI 제공자 선택';

  @override
  String get backStep => '뒤로';

  @override
  String get continueAction => '계속';

  @override
  String get nextStep => '다음';

  @override
  String get configureApiKey => 'API 키 구성';

  @override
  String get saveAndFinish => '저장 및 완료';

  @override
  String get testing => '테스트 중...';

  @override
  String get noteTitle => '참고';

  @override
  String get deepseekTextInputOnlyNote =>
      'DeepSeek는 텍스트 입력만 지원합니다. 가사 생성 및 타임라인 조정은 다른 제공자의 API 키가 필요합니다.';

  @override
  String retryAttemptOfMax(Object attempt, Object maxRetry) {
    return '재시도 $attempt / $maxRetry';
  }

  @override
  String generatingTaskKind(Object taskKind) {
    return '$taskKind 생성 중';
  }

  @override
  String connectionTestException(Object error) {
    return '연결 테스트 오류: $error';
  }

  @override
  String get testingConnectionProgress => '연결 테스트 중...';

  @override
  String get clear => '지우기';

  @override
  String get enterDoubaoApiKey => 'Doubao API 키 입력';

  @override
  String get doubaoApiKeyDescription =>
      '가사 생성 및 번역을 위한 Volcano/Doubao API 키를 입력해주세요.';

  @override
  String get enterDeepseekApiKey => 'DeepSeek API 키 입력';

  @override
  String get deepseekApiKeyDescription => '가사 번역 전용 DeepSeek API 키를 입력해주세요.';

  @override
  String get pleaseEnterApiKeyHint => 'API 키를 입력해주세요';

  @override
  String get platform => '플랫폼';

  @override
  String get showRecommendedOnly => '추천만 표시';

  @override
  String get noAvailableChannels => '사용 가능한 채널이 없습니다';

  @override
  String get noMatchingModels => '일치하는 모델을 찾을 수 없습니다';

  @override
  String get leaveEmpty => '비워두기';

  @override
  String get leaveEmptyFallbackDescription => '대체 모델을 설정하지 않으려면 선택하세요.';

  @override
  String get modelSearchHint => '모델 이름, ID 입력';

  @override
  String sendFilesFailed(Object error) {
    return '파일 전송 실패: $error';
  }

  @override
  String get scanningFolderMusic => '폴더에서 음악 파일 검색 중...';

  @override
  String scanFolderFailed(Object error) {
    return '폴더 검색 실패: $error';
  }

  @override
  String get noMusicFilesFound => '이 폴더에서 지원되는 음악 파일을 찾을 수 없습니다';

  @override
  String sendFolderFailed(Object error) {
    return '폴더 전송 실패: $error';
  }

  @override
  String get lanSharingStartFailed => 'LAN 공유 시작 실패. 로컬 네트워크 권한을 확인해주세요.';

  @override
  String syncingLyricsToDevice(Object deviceName) {
    return '$deviceName에 가사 동기화 중...';
  }

  @override
  String syncLyricsSuccess(Object matched, Object overwritten, Object skipped) {
    return '동기화 완료: 일치 $matched곡, 업데이트 $overwritten곡, 건너뜀 $skipped곡';
  }

  @override
  String syncLyricsFailed(Object error) {
    return '가사 동기화 실패: $error';
  }

  @override
  String syncingLyricsFromDevice(Object deviceName) {
    return '$deviceName에서 가사 동기화 중...';
  }

  @override
  String get transferInProgressDoNotLeave => '전송 중입니다. 공유 페이지를 떠나지 마세요';

  @override
  String get lanSharingTitle => 'LAN 연결';

  @override
  String get lanSharingEnabledStatus => 'LAN 공유가 활성화되었습니다';

  @override
  String get lanSharingDisabledStatus => 'LAN 공유가 비활성화되었습니다';

  @override
  String lanSharingRunningStatus(Object ip, Object port) {
    return '로컬 IP: $ip (포트: $port)';
  }

  @override
  String get lanSharingDefaultOffHint =>
      '기본적으로 비활성화됩니다. 활성화하면 로컬 네트워크 권한을 요청합니다.';

  @override
  String get receiveDirectoryNotSetWarning =>
      'Android에서 파일을 수신하려면 먼저 수신 디렉터리를 선택해야 합니다. 탭하여 설정하세요.';

  @override
  String get receiveDirectoryNoWritePermission =>
      '현재 저장 디렉토리에 쓰기 권한이 없습니다. 다시 설정해주세요.';

  @override
  String get restoreDefaultDirectory => '기본 디렉토리로 복원';

  @override
  String get chooseOtherDirectory => '다른 디렉토리 선택';

  @override
  String get receiveDirectoryRestoredDefault => '기본 수신 디렉토리로 복원되었습니다';

  @override
  String receiveDirectoryUpdated(Object path) {
    return '수신 디렉토리가 업데이트되었습니다: $path';
  }

  @override
  String get receiveDirectoryTitle => '수신 디렉토리';

  @override
  String get linkCopiedToClipboard => '클립보드에 링크가 복사되었습니다';

  @override
  String get nearbyDevices => '근처 기기';

  @override
  String get searchingDevices => 'LAN에서 다른 기기 검색 중...';

  @override
  String get startSharingToFindDevices => '공유를 활성화하여 기기 검색';

  @override
  String get deviceOnline => '온라인';

  @override
  String get deviceOffline => '오프라인';

  @override
  String get sendMusicFiles => '음악 파일 보내기';

  @override
  String get sendFolder => '폴더 보내기';

  @override
  String get syncLyricsToDeviceAction => '기기로 가사 동기화';

  @override
  String get syncLyricsFromDeviceAction => '기기에서 가사 동기화';

  @override
  String loadDevicesError(Object error) {
    return '기기 로드 실패: $error';
  }

  @override
  String incomingFilesFormat(Object name1, Object name2, Object count) {
    return '$name1, $name2 등 총 $count개 파일';
  }

  @override
  String get incomingTransferRequestTitle => '파일 전송 요청 수신';

  @override
  String incomingTransferFrom(Object senderName) {
    return '\"$senderName\"의 전송 요청:';
  }

  @override
  String fileSizeMb(Object sizeMb) {
    return '파일 크기: $sizeMb MB';
  }

  @override
  String get receiveFileHint => '수신된 파일은 음악 폴더에 저장되고 라이브러리에 추가됩니다.';

  @override
  String get reject => '거절';

  @override
  String get accept => '수락';

  @override
  String get incomingLyricsExportTitle => '가사 내보내기 요청';

  @override
  String incomingLyricsExportFrom(Object senderName) {
    return '\"$senderName\" 기기에서 가사 라이브러리 읽기 및 내보내기를 요청했습니다.';
  }

  @override
  String get incomingLyricsImportTitle => '가사 가져오기 요청';

  @override
  String incomingLyricsImportFrom(Object senderName, Object count) {
    return '\"$senderName\" 기기에서 $count개 곡의 가사 가져오기를 요청했습니다.';
  }

  @override
  String get lyricsRequestRejected => '상대 기기에서 가사 동기화 요청을 거절했습니다.';

  @override
  String sendCompleted(Object fileName) {
    return '\"$fileName\" 전송 완료';
  }

  @override
  String receiveCompleted(int count) {
    return '$count곡을 성공적으로 수신했습니다';
  }

  @override
  String transferCancelledWithReason(Object direction, Object reason) {
    return '$direction 취소됨 ($reason)';
  }

  @override
  String transferFailedFormat(Object direction, Object fileName) {
    return '$direction \"$fileName\" 실패';
  }

  @override
  String sendingToDevice(Object deviceName) {
    return '$deviceName에 보내는 중';
  }

  @override
  String receivingFromDevice(Object deviceName) {
    return '$deviceName에서 받는 중';
  }

  @override
  String progressFormat(Object percent) {
    return '진행: $percent%';
  }

  @override
  String get currentlyTransferring => '현재 전송 중';

  @override
  String get fileConflictTitle => '파일 충돌';

  @override
  String get fileConflictMessage => '대상 기기에 같은 이름의 파일이 이미 존재합니다:';

  @override
  String get fileConflictChooseAction => '수행할 작업을 선택하세요:';

  @override
  String get skipAction => '건너뛰기';

  @override
  String get overwriteAction => '덮어쓰기';

  @override
  String get skipAllAction => '모두 건너뛰기';

  @override
  String get overwriteAllAction => '모두 덮어쓰기';

  @override
  String get sendDirection => '보내기';

  @override
  String get receiveDirection => '받기';

  @override
  String get fileAssociationEnabled => '연결됨';

  @override
  String get fileAssociationDisabled => '연결 안 됨';

  @override
  String get windowsAutoRepairShortcut => '시작 메뉴 바로가기 자동 복구';

  @override
  String get windowsAutoRepairShortcutDescription =>
      '시작할 때마다 시작 메뉴 바로가기를 자동으로 확인 및 생성하여 미디어 컨트롤 이름과 아이콘을 올바르게 표시합니다';

  @override
  String get confirmDisableShortcutRepair => '이 기능을 비활성화하시겠습니까?';

  @override
  String get confirmDisableShortcutRepairContent =>
      '시작 메뉴 바로가기가 없으면 Windows 미디어 컨트롤에 앱이 \"알 수 없음\"으로 표시되고 아이콘이 표시되지 않을 수 있습니다. 정말 비활성화하시겠습니까?';

  @override
  String get confirmDisable => '비활성화';

  @override
  String get enableSystemTray => '시스템 트레이 활성화';

  @override
  String get enableSystemTrayDescription => '시스템 트레이에 아이콘을 표시하여 빠른 재생 제어';

  @override
  String get closeToTray => '닫기 버튼 클릭 시 백그라운드로 최소화';

  @override
  String get closeToTrayDescription => '메인 창을 닫아도 앱을 종료하지 않고 백그라운드 재생 유지';

  @override
  String get closeWindowActionTitle => '창을 닫을 때';

  @override
  String get closeWindowActionDescription => '메인 창 닫기 버튼을 누를 때 수행할 작업 선택';

  @override
  String get closeWindowActionAsk => '매번 확인';

  @override
  String get closeWindowActionMinimize => '시스템 트레이로 최소화';

  @override
  String get closeWindowActionExit => '앱 완전 종료';

  @override
  String get closeWindowActionRemember => '선택 기억하기 (다시 묻지 않음)';

  @override
  String get closeWindowActionTrayDisabledTip => '(먼저 시스템 트레이를 활성화해야 합니다)';

  @override
  String get closeWindowDialogTitle => '앱 종료 확인';

  @override
  String get closeWindowDialogContent => '닫기 버튼을 누를 때 수행할 작업을 선택하세요:';

  @override
  String get googleAiStudioApiKey => 'Google AI Studio API Key';

  @override
  String get openRouterApiKey => 'OpenRouter API Key';

  @override
  String get doubaoApiKey => 'Doubao API Key';

  @override
  String get deepseekApiKey => 'DeepSeek API Key';

  @override
  String get unexpectedResponseFormat => '예상치 못한 응답 형식입니다.';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get openaiCompatibleEndpoint => 'OpenAI 호환 API 엔드포인트';

  @override
  String onboardingAddedDirectoriesCount(Object count) {
    return '추가된 디렉터리($count개):';
  }

  @override
  String get gnomeDisksOpenFailed =>
      '디스크 유틸리티를 자동으로 열 수 없습니다. 애플리케이션 메뉴에서 \"Disks\"를 수동으로 열어주세요.';

  @override
  String get gnomeDisksNotInstalled =>
      'gnome-disks가 설치되지 않았습니다. 시스템 디스크 유틸리티를 열어 설정하세요.';

  @override
  String get linuxMountGuideTitle => '디스크 자동 마운트 구성';

  @override
  String get linuxMountGuideDescription =>
      'Linux는 기본적으로 외부 파티션을 마운트하지 않습니다. 부팅 시 마운트를 설정하지 않으면 재부팅할 때마다 외부 파티션의 경로가 변경되어 플레이어가 음악 디렉토리에 접근할 수 없게 됩니다. 이를 방지하려면 음악이 저장된 파티션을 부팅 시 자동 마운트하도록 설정하세요.';

  @override
  String get linuxMountGuideWarning =>
      '주의: 음악이 마운트가 필요한 외장 또는 내장 파티션에 있는 경우, 반드시 \"시스템 시작 시 자동 마운트\"되도록 설정해야 합니다. 그렇지 않으면 재부팅 후 음악 디렉터리를 찾지 못하거나 액세스를 위해 비밀번호를 입력해야 할 수 있습니다.';

  @override
  String get linuxMountGuideStep1 => '1. 시스템의 \"Disks\" 유틸리티를 엽니다';

  @override
  String get linuxMountGuideStep2 =>
      '2. 음악 파티션을 선택하고 ⚙️ 톱니바퀴 아이콘을 클릭합니다 (추가 파티션 옵션)';

  @override
  String get linuxMountGuideStep3 =>
      '3. \"마운트 옵션 편집\"을 선택하고 \"사용자 세션 기본값\"을 끈 후 \"시스템 시작 시 마운트\"를 체크합니다';

  @override
  String get linuxMountGuideOpenButton => '디스크 관리자(Disks) 열기';

  @override
  String get unmute => '음소거 해제';

  @override
  String get mute => '음소거';

  @override
  String get disableSystemTray => '시스템 트레이 비활성화';

  @override
  String get restoreWindow => '창 복원';

  @override
  String get hideWindow => '창 숨기기';

  @override
  String get onboardingAndroidBatteryTitle => '백그라운드 재생 보호 설정';

  @override
  String get onboardingAndroidBatteryDescription =>
      '안드로이드의 엄격한 배터리 최적화 정책으로 인해 백그라운드에서 음악 재생이 강제 종료되는 것을 방지하려면 Vynody의 배터리 사용 제한을 \'제한 없음\'(Unrestricted)으로 설정하는 것이 좋습니다.';

  @override
  String get onboardingAndroidBatteryStep1 => '1. 아래 \'설정으로 이동\' 버튼을 누릅니다.';

  @override
  String get onboardingAndroidBatteryStep2 =>
      '2. 시스템 팝업에서 배터리 최적화 예외를 허용하거나 배터리 설정 페이지로 이동합니다.';

  @override
  String get onboardingAndroidBatteryStep3 =>
      '3. 설정 페이지로 이동하면 \'제한 없음\'을 선택하십시오.';

  @override
  String get onboardingAndroidBatteryButton => '설정으로 이동';

  @override
  String get onboardingAndroidBatteryStatusOptimized =>
      '현재 상태: 제한됨 (백그라운드 재생이 중단될 수 있음)';

  @override
  String get onboardingAndroidBatteryStatusUnrestricted =>
      '현재 상태: 제한 없음 (권장, 백그라운드 재생 보호됨)';

  @override
  String get onboardingAndroidMediaTitle => '음악 라이브러리 접근';

  @override
  String get onboardingAndroidMediaDescription =>
      '권한을 허용하면 Vynody가 수동으로 폴더를 선택할 필요 없이 기기 미디어 라이브러리의 모든 음악을 직접 읽어옵니다. 권한을 허용하지 않아도 수동으로 폴더를 가져올 수 있습니다.';

  @override
  String get onboardingAndroidMediaStep1 => '1. 즉시 사용: 휴대폰의 모든 음악을 즉시 표시';

  @override
  String get onboardingAndroidMediaStep2 =>
      '2. 자동 감지: 새로 추가된 음악이 라이브러리에 자동으로 나타남';

  @override
  String get onboardingAndroidMediaStep3 =>
      '3. 개인정보 보호: 로컬 오디오 파일만 읽으며 라이브러리를 자동으로 업로드하지 않음 (AI 가사 등 클라우드 서비스 제외)';

  @override
  String get onboardingAndroidMediaButton => '음악 라이브러리 접근 허용';

  @override
  String get onboardingAndroidMediaStatusGranted => '현재 상태: 허용됨 (권장)';

  @override
  String get onboardingAndroidMediaStatusNotGranted =>
      '현재 상태: 허용 안 됨 (나중에 수동으로 폴더를 가져올 수 있음)';

  @override
  String get exitApp => '종료';

  @override
  String get showScanProgressToastSetting => '스캔 상태 토스트 표시';

  @override
  String get showScanProgressToastSettingDescription =>
      '폴더 스캔 시 화면 상단에 실시간 스캔 진행 상황을 표시합니다.';

  @override
  String get openPlaybackOnDirectorySongTap => '곡을 탭할 때 재생 페이지로 이동';

  @override
  String get openPlaybackOnDirectorySongTapDescription =>
      '폴더 뷰에서 곡을 탭하여 재생할 때 자동으로 재생 페이지로 이동합니다.';

  @override
  String get defaultToLyricsModeOnPlaybackOpen => '재생 페이지 진입 시 가사 모드 기본 사용';

  @override
  String get defaultToLyricsModeOnPlaybackOpenDescription =>
      '재생 페이지를 열 때 자동으로 가사 모드로 전환합니다.';

  @override
  String get tapCoverToEnterLyricsMode => '커버를 탭하여 가사 모드로 전환';

  @override
  String get longPressLyricsPanelToOpenMenu => '가사 패널을 길게 누르면 메뉴가 나타납니다';

  @override
  String get gotIt => '확인';

  @override
  String get scanToastHiddenHint =>
      '스캔 상태 토스트가 숨겨졌습니다. \'설정 - 인터페이스\'에서 다시 활성화할 수 있습니다.';

  @override
  String get doubleSpeedPlayingSwipeUpToLock => '빨리 감기 중... 위로 스와이프하여 잠금';

  @override
  String get doubleSpeedLockedSwipeDownToUnlock =>
      '빨리 감기 잠금됨. 길게 누르고 아래로 스와이프하여 해제';

  @override
  String get doubleSpeedUnlocked => '빨리 감기 잠금 해제됨';

  @override
  String get lyricsImportExportHeader => '가져오기 및 내보내기';

  @override
  String get exportAction => '내보내기';

  @override
  String get importAction => '가져오기';

  @override
  String get exportLyricsLabel => '가사 백업 내보내기';

  @override
  String get exportLyricsDescription => '모든 캐시 및 조정된 가사를 JSON 파일로 내보내기';

  @override
  String get importLyricsLabel => '가사 백업 가져오기';

  @override
  String get importLyricsDescription => '내보낸 JSON 파일에서 가사 캐시 가져오기';

  @override
  String exportSuccess(int count) {
    return '$count개의 가사를 성공적으로 내보냈습니다.';
  }

  @override
  String exportFailed(String error) {
    return '내보내기 실패: $error';
  }

  @override
  String importSuccess(int count) {
    return '가져오기 완료! $count개의 가사를 성공적으로 가져왔습니다.';
  }

  @override
  String importFailed(String error) {
    return '가져오기 실패: $error';
  }

  @override
  String get importConflictsTitle => '가져오기 충돌';

  @override
  String importConflictsMessage(int conflictCount) {
    return '백업에서 $conflictCount개의 충돌하는 가사를 발견했습니다(로컬에 존재하지만 내용이 다름). 처리 방법을 선택하세요:';
  }

  @override
  String get overwriteAll => '모두 덮어쓰기';

  @override
  String get skipAllConflicts => '충돌 건너뛰기';

  @override
  String get decideOneByOne => '하나씩 결정';

  @override
  String conflictResolutionTitle(int current, int total) {
    return '충돌 해결 ($current/$total)';
  }

  @override
  String get conflictExistingLabel => '기존 가사';

  @override
  String get conflictImportedLabel => '가져온 가사';

  @override
  String conflictSourceLabel(String source) {
    return '출처: $source';
  }

  @override
  String conflictTimeLabel(String time) {
    return '시간: $time';
  }

  @override
  String get overwriteThis => '덮어쓰기';

  @override
  String get skipThis => '건너뛰기';

  @override
  String get overwriteRemaining => '나머지 모두 덮어쓰기';

  @override
  String get skipRemaining => '나머지 모두 건너뛰기';

  @override
  String get invalidBackupFile => '유효하지 않은 백업 파일';

  @override
  String get exportLogs => '로그 내보내기';

  @override
  String get exportLogsSuccess => '로그를 성공적으로 내보냈습니다';

  @override
  String get exportLogsFailed => '로그 내보내기 실패';

  @override
  String get noLogFileFound => '로그 파일을 찾을 수 없습니다';

  @override
  String get uiDisplayScale => 'UI 디스플레이 스케일';

  @override
  String get uiDisplayScaleDescription =>
      '차량용 디스플레이 등에 맞게 모든 UI 구성 요소 및 텍스트 크기를 전체적으로 조정';

  @override
  String get uiDisplayScaleDialogTitle => 'UI 디스플레이 스케일 / 차량 모드';

  @override
  String uiDisplayScaleCurrent(int percent) {
    return '현재 스케일: $percent%';
  }

  @override
  String get audioSettings => '오디오 설정';

  @override
  String get audioSettingsDescription => '오디오 재생, 이퀄라이저 밴드 및 재생 속도 설정 관리';

  @override
  String get equalizerBandCount => '이퀄라이저 밴드 수';

  @override
  String get equalizerBandCountDescription =>
      '이퀄라이저 패널에 표시할 밴드 수를 설정합니다. 높은 밴드 모드에서는 부드러운 가로 스크롤이 자동으로 활성화됩니다.';

  @override
  String bandsCountOption(int count) {
    return '$count 밴드';
  }

  @override
  String get enableFadeEffect => '오디오 페이드 효과';

  @override
  String get enableFadeEffectDescription =>
      '곡 전환, 재생/일시정지 시 부드러운 페이드 인/아웃 및 크로스페이드 전환 사용';

  @override
  String get buttonLayoutSettings => '버튼 레이아웃';

  @override
  String get playbackButtonLayoutTitle => '재생 화면 버튼 레이아웃';

  @override
  String get playbackButtonLayoutDescription =>
      '재생 화면 7버튼 및 5버튼 행의 표시 및 순서 사용자 지정';

  @override
  String get topButtonsRowTitle => '7버튼 행 순서';

  @override
  String get mainButtonsRowTitle => '5버튼 행 좌우 버튼';

  @override
  String get mainControlsLeftButton => '좌측 버튼';

  @override
  String get mainControlsRightButton => '우측 버튼';

  @override
  String get lyricsHeaderRightButtonTitle => '가사 제목 표시줄 접힘 시 우측 버튼';

  @override
  String get resetButtonOrder => '기본 레이아웃으로 복원';

  @override
  String get btnMore => '더보기 메뉴';

  @override
  String get btnFavorite => '즐겨찾기';

  @override
  String get btnPlaylistMode => '재생 모드';

  @override
  String get btnShuffle => '셔플 재생';

  @override
  String get btnTagCompletion => '태그 자동 완성';

  @override
  String get btnSleepTimer => '취침 타이머';

  @override
  String get btnEqualizer => '이퀄라이저';

  @override
  String get btnVisualizer => '비주얼라이저';

  @override
  String get btnVolume => '음량';

  @override
  String get remoteControlAction => '원격 제어';

  @override
  String get remoteControlRequestTitle => '원격 제어 요청';

  @override
  String remoteControlRequestFrom(String name) {
    return '기기 \"$name\"에서 이 기기의 재생 제어를 요청합니다';
  }

  @override
  String get remotePinPairHint => '제어할 기기에 다음 페어링 PIN 코드를 입력하세요:';

  @override
  String get remotePinExpiresIn => 'PIN 코드 유효 시간:';

  @override
  String get allowDirectly => '바로 허용';

  @override
  String get enterRemotePinTitle => '기기 페어링';

  @override
  String enterRemotePinPrompt(String name) {
    return '\"$name\" 화면에 표시된 4자리 PIN 코드를 입력하세요:';
  }

  @override
  String get remotePinInvalid => 'PIN 코드가 잘못되었거나 만료되었습니다. 다시 시도해 주세요';

  @override
  String remotePinCooldown(int seconds) {
    return 'PIN 번호가 올바르지 않습니다. $seconds초 후 다시 시도하세요';
  }

  @override
  String remotePinAttemptsRemaining(int count) {
    return '(남은 시도 횟수: $count회)';
  }

  @override
  String get remotePinTooManyAttempts => '시도 횟수를 초과했습니다. 페어링이 만료되었습니다';

  @override
  String get remoteConnected => '연결됨';

  @override
  String get remoteConnecting => '연결 중...';

  @override
  String get remoteDisconnect => '연결 해제';

  @override
  String get remoteConnectFailed => '원격 연결 실패';

  @override
  String controlledByRemoteDevices(String devices) {
    return '다음 기기에서 원격 제어 중: $devices';
  }

  @override
  String get trustedDevicesTitle => '신뢰할 수 있는 원격 제어 기기';

  @override
  String get manageTrustedDevicesTitle => '신뢰할 수 있는 원격 제어 기기 관리';

  @override
  String get removeTrustedDevice => '신뢰 제거';

  @override
  String get noMusicPlaying => '현재 재생 중인 음악 없음';

  @override
  String get previousSong => '이전 곡';

  @override
  String get nextSong => '다음 곡';

  @override
  String get shufflePlayback => '셔플 재생';

  @override
  String get allowRemoteControlTitle => '원격 제어 허용';

  @override
  String get allowRemoteControlSubtitle =>
      '페어링 후 LAN 내 다른 기기가 이 기기의 음악 재생을 제어하도록 허용';

  @override
  String get remoteControlDisabledOnHost => '상대 기기에서 원격 제어가 비활성화되어 있습니다';

  @override
  String get trustThisDevice => '이 기기를 신뢰하고 앞으로 자동으로 연결 허용';

  @override
  String get remoteRequestRejected => '상대 기기에서 연결 요청을 거부했습니다';

  @override
  String get turkishLanguage => '터키어';

  @override
  String get nativeLanguageTr => 'Türkçe';

  @override
  String trustedDevicesCount(int count) {
    return '$count개의 신뢰할 수 있는 기기';
  }

  @override
  String get noTrustedDevices => '신뢰할 수 있는 기기가 없습니다';

  @override
  String get noTrustedDevicesHint => '페어링 시 \'이 기기 신뢰\'를 체크하면 여기에 표시됩니다';

  @override
  String pairedAtFormat(String time) {
    return '페어링 시간: $time';
  }

  @override
  String transferCancelled(String direction) {
    return '$direction 취소됨';
  }

  @override
  String get audioFiles => '오디오 파일';

  @override
  String get remotePairCancelledByClient => '상대 기기에서 페어링 요청을 취소했습니다';

  @override
  String get proFeatureAiLyricsTitle => 'AI 가사 및 번역';

  @override
  String get proFeatureAiLyricsDesc => 'AI 가사 생성, 타임라인 정렬 및 가사 번역';

  @override
  String get proFeatureTagCompletionTitle => '음악 메타데이터 자동 완성';

  @override
  String get proFeatureTagCompletionDesc =>
      'MusicBrainz를 통한 곡 태그 및 앨범 메타데이터 자동 완성';

  @override
  String get proFeatureEqualizerTitle => '다중 밴드 EQ 및 재생 속도 (EQ)';

  @override
  String get proFeatureEqualizerDesc =>
      '전문가 수준의 주파수 튜닝, 0.5x~5.0x 배속 재생, 프리앰프 및 사운드 스타일';

  @override
  String get proFeatureCustomThemeColorTitle => '풀 스펙트럼 테마 및 고급 색상 커스텀';

  @override
  String get proFeatureCustomThemeColorDesc =>
      '자유 색상 선택기 팔레트 및 독점 프리미엄 프리셋 테마 색상 잠금 해제';

  @override
  String get proFeatureFftVisualizerTitle => '실시간 FFT 오디오 스펙트럼';

  @override
  String get proFeatureFftVisualizerDesc =>
      '클래식 바, 스무스 웨이브, 플로팅 캡, 래디얼 헤일로, 네온 매트릭스, 미러 웨이브 등 6가지 스펙트럼 스타일 및 전체 화면 앰비언트 모드';

  @override
  String get proFeatureWaveformBarTitle => '동적 오디오 파형 진행률 바';

  @override
  String get proFeatureWaveformBarDesc => '실시간 오디오 진폭 파형 추출 및 부드러운 인터랙티브 탐색';

  @override
  String get proFeatureLanSharingTitle => 'LAN 음악 파일 공유';

  @override
  String get proFeatureLanSharingDesc => '로컬 네트워크 내 초고속 기기간 음악 파일 공유 및 전송';

  @override
  String get proFeatureRemoteControlTitle => '멀티 디바이스 원격 제어';

  @override
  String get proFeatureRemoteControlDesc => '스마트폰, 태블릿, PC 간 매끄러운 무선 원격 제어';

  @override
  String get proFeatureTranscoderTitle => '오디오 일괄 변환 도구';

  @override
  String get proFeatureTranscoderDesc => '무손실 형식 빠른 변환 및 휴대용 기기를 위한 일괄 내보내기';

  @override
  String get proFeatureDynamicMeshBackgroundTitle => '동적 메시 배경';

  @override
  String get proFeatureDynamicMeshBackgroundDesc =>
      '앨범 아트 색상 기반의 유체 그라데이션 애니메이션 및 속도 조절';

  @override
  String get proFeatureCustomImageBackgroundTitle => '사용자 지정 재생 배경';

  @override
  String get proFeatureCustomImageBackgroundDesc =>
      '로컬 이미지와 사진을 재생 화면 배경으로 자유롭게 설정';

  @override
  String get proCommunityUnlocked => '커뮤니티 버전: 모든 Pro 기능이 영구 잠금 해제되었습니다';

  @override
  String proTrialActive(int days) {
    return '무료 체험 진행 중 (남은 기간: $days일)';
  }

  @override
  String get proTrialExpired => '무료 체험 기간이 만료되었습니다. Pro로 업그레이드하세요';

  @override
  String get proPermanentlyActivated => '모든 Pro 기능이 영구 활성화되었습니다';

  @override
  String proStatusTrialTitle(int days) {
    return '라이선스 상태: $days일 무료 체험 중';
  }

  @override
  String get proStatusTrialExpiredTitle => '라이선스 상태: 체험 종료 (일부 기능 제한)';

  @override
  String get proStatusActivatedTitle => '라이선스 상태: Vynody Pro 활성화됨';

  @override
  String proSettingsTrialRemaining(int days) {
    return '남은 체험 기간 $days일';
  }

  @override
  String get proSettingsUpgradePrompt => '업그레이드하여 AI 가사, FFT 스펙트럼 및 고급 기능 해제';

  @override
  String get proSettingsLifetimeNotice => '모든 Pro 기능 및 향후 업데이트 포함';

  @override
  String get proSettingsUpgrade => '업그레이드';

  @override
  String get proSettingsView => '확인';

  @override
  String get connectingToStore => '스토어에 연결 중...';

  @override
  String get buyFullVersionWindowsTrial => 'Microsoft Store에서 정식 버전 구매';

  @override
  String get buyFullVersionWindows => 'Microsoft Store에서 정식 버전 구매';

  @override
  String unlockProLifetimeWithPrice(String price) {
    return '$price로 Pro 전체 기능 평생 잠금 해제';
  }

  @override
  String get buyProTrialEarly => 'Pro 평생 라이선스 구매';

  @override
  String get upgradeToProNow => '지금 Pro로 업그레이드';

  @override
  String get iUnderstand => '확인';

  @override
  String get restorePurchases => '구매 내역 복원';

  @override
  String get restoringPurchases => '구매 내역 복원 중...';

  @override
  String get sharingProDescription =>
      'LAN 상호 연결은 Vynody Pro 전용 고급 기능입니다. 동일 로컬 네트워크에서 초고속 음악 전송, 라이브러리 동기화 및 무선 원격 제어를 이용할 수 있습니다.';

  @override
  String get sharingHighlightSpeedTitle => '초고속 LAN 전송';

  @override
  String get sharingHighlightSpeedDesc =>
      'Wi-Fi LAN 내 P2P 초고속 전송. 데이터 소모 없이 무손실 음원과 재생목록을 무압축 전송.';

  @override
  String get sharingHighlightSyncTitle => '라이브러리 및 가사 동기화';

  @override
  String get sharingHighlightSyncDesc =>
      '다운로드한 가사 및 곡을 원클릭으로 전송하여 여러 기기의 음악 라이브러리를 동기화 유지.';

  @override
  String get sharingHighlightRemoteTitle => '크로스 플랫폼 원격 제어';

  @override
  String get sharingHighlightRemoteDesc =>
      '스마트폰, 태블릿, PC 간 매끄러운 연동으로 언제 어디서나 무선 재생 제어, 곡 전환 및 볼륨 조절.';

  @override
  String get sharingHighlightSecurityTitle => '종단간 TLS 보안 암호화';

  @override
  String get sharingHighlightSecurityDesc =>
      '전체 LAN 통신 구간 TLS 인증서 암호화 및 기기 인증으로 안전하고 개인적인 전송 보장.';

  @override
  String get upgradeToProToUnlock => 'Vynody Pro로 업그레이드하여 잠금 해제';

  @override
  String get proOneTimePurchaseNotice =>
      '일회성 구매로 현재 플랫폼의 모든 Pro 고급 기능 영구 잠금 해제';

  @override
  String get proOneTimePurchaseNoticeApple =>
      '일회성 구매로 Apple 플랫폼(iPhone / iPad / Mac)의 모든 Pro 고급 기능 영구 잠금 해제';

  @override
  String get proUniversalPurchaseNoticeApple =>
      '한 번 구매로 iPhone, iPad 및 Mac에서 모두 사용 가능';

  @override
  String get iapPurchaseSuccess => 'Vynody Pro 구매가 완료되었습니다! 지원해 주셔서 감사합니다!';

  @override
  String get iapRestoreSuccess => 'Vynody Pro 구매 내역이 성공적으로 복원되었습니다!';

  @override
  String iapPurchaseCancelledOrFailed(String message) {
    return '구매가 완료되지 않았거나 취소되었습니다: $message';
  }

  @override
  String get tabLanSharing => 'LAN 공유 & 리모컨';

  @override
  String get tabCloudServers => '클라우드 미디어 서버';

  @override
  String get addRemoteServer => '미디어 서버 추가';

  @override
  String get editRemoteServer => '미디어 서버 수정';

  @override
  String get serverName => '서버 이름';

  @override
  String get serverNameAlreadyExists => '이미 존재하는 서버 이름입니다. 다른 이름을 사용해주세요.';

  @override
  String get serverType => '서버 유형';

  @override
  String get serverUrl => '서버 URL';

  @override
  String get serverUsername => '사용자 이름';

  @override
  String get serverPassword => '비밀번호 / 토큰';

  @override
  String get customPath => '사용자 지정 경로 (선택 사항)';

  @override
  String get maxBitRate => '트랜스코딩 비트레이트 제한 (kbps)';

  @override
  String get ignoreSsl => 'SSL 인증서 오류 무시';

  @override
  String get connectionSuccess => '연결 성공';

  @override
  String get connectionFailed => '연결 실패';

  @override
  String get noRemoteServers => '추가된 미디어 서버 없음';

  @override
  String get noRemoteServersDesc =>
      'Navidrome (Subsonic) 또는 WebDAV 서버를 추가하여 개인 클라우드 음악을 즐겨보세요';

  @override
  String get browseServer => '탐색';

  @override
  String get manageServer => '관리';

  @override
  String get deleteServerConfirm => '이 미디어 서버 연결을 삭제하시겠습니까?';

  @override
  String get remoteSongCannotEditTags => '원격 곡의 태그는 수정할 수 없습니다';

  @override
  String get addToServerPlaylist => '서버 재생목록에 추가';

  @override
  String get addToLocalPlaylist => '로컬 재생목록에 추가';

  @override
  String get serverPlaylists => '서버 재생목록';

  @override
  String get localPlaylists => '로컬 재생목록';

  @override
  String get createNewServerPlaylist => '서버 재생목록 생성';

  @override
  String get downloadSong => '곡 다운로드';

  @override
  String get downloadAlbum => '앨범 전체 다운로드';

  @override
  String get downloadArtist => '아티스트 전곡 다운로드';

  @override
  String downloadStarted(Object title) {
    return '다운로드 중: $title';
  }

  @override
  String downloadCompleted(Object title) {
    return '로컬 라이브러리에 저장됨: $title';
  }

  @override
  String downloadFailed(Object error) {
    return '다운로드 실패: $error';
  }

  @override
  String get alreadyDownloaded => '이미 로컬 라이브러리에 존재하는 곡입니다';

  @override
  String get starItem => '서버 즐겨찾기에 추가';

  @override
  String get unstarItem => '서버 즐겨찾기에서 제거';

  @override
  String get starredSuccess => '서버 즐겨찾기에 추가되었습니다';

  @override
  String get unstarredSuccess => '서버 즐겨찾기에서 제거되었습니다';

  @override
  String batchDownloadStarted(Object count) {
    return '백그라운드에서 $count곡 다운로드 중...';
  }

  @override
  String batchDownloadCompleted(Object count) {
    return '$count곡을 로컬 라이브러리에 다운로드했습니다';
  }

  @override
  String get viewAlbum => '앨범 보기';

  @override
  String get viewArtist => '아티스트 보기';

  @override
  String get downloadManager => '다운로드 관리';

  @override
  String get downloadingTab => '다운로드 중';

  @override
  String get completedTab => '완료됨';

  @override
  String get pauseAll => '모두 일시중지';

  @override
  String get resumeAll => '모두 계속';

  @override
  String get cancelAll => '모두 취소';

  @override
  String get clearCompleted => '기록 삭제';

  @override
  String get noActiveDownloads => '진행 중인 다운로드 작업 없음';

  @override
  String get noCompletedDownloads => '완료된 다운로드 기록 없음';

  @override
  String get viewDownloadProgress => '진행 상황 보기';

  @override
  String get addedToDownloadQueue => '다운로드 큐에 추가됨';

  @override
  String batchAddedToDownloadQueue(Object count) {
    return '$count곡을 다운로드 큐에 추가했습니다';
  }

  @override
  String get downloadFolder => '다운로드 저장 위치';

  @override
  String get downloadAllAudio => '폴더 내 모든 오디오 다운로드';

  @override
  String get starredSongs => '좋아요 표시한 음악';

  @override
  String get starredSongsDesc => 'Navidrome 서버의 즐겨찾기 곡';

  @override
  String get starredArtists => '즐겨찾는 아티스트';

  @override
  String get shuffleAlbumOrder => '앨범 순서 셔플';

  @override
  String get threeDView => '3D 뷰';

  @override
  String receiveFailed(Object fileName) {
    return '\"$fileName\" 수신 실패';
  }

  @override
  String get quickPresets => '빠른 사전 설정';

  @override
  String get presetStandard => '100% 기본';

  @override
  String get presetModerate => '125% 중간';

  @override
  String get presetCarRecommended => '135% 차량용 추천';

  @override
  String get presetLarge => '150% 크게';

  @override
  String get safFallbackScanningNotice =>
      '(미디어 권한이 부여되지 않아 SAF 호환 스캔을 사용 중입니다. 속도가 느릴 수 있습니다)';

  @override
  String get justNow => '방금 전';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes분 전';
  }

  @override
  String todayTime(Object time) {
    return '오늘 $time';
  }

  @override
  String yesterdayTime(Object time) {
    return '어제 $time';
  }

  @override
  String get playlists => '재생목록';

  @override
  String get songs => '노래';

  @override
  String createdPlaylistSuccess(String name) {
    return '재생목록 생성됨: $name';
  }

  @override
  String get loadingAlbumTracks => '앨범 트랙 로딩 중...';

  @override
  String get loadingArtistTracks => '아티스트 트랙 로딩 중...';

  @override
  String get loadingFolderAudio => '폴더 오디오 로딩 중...';

  @override
  String get noAudioFilesInFolder => '이 폴더에 오디오 파일이 없습니다';

  @override
  String failedToLoadFolder(String error) {
    return '폴더 로드 실패: $error';
  }

  @override
  String get starFailed => '즐겨찾기 실패';

  @override
  String playAlbumFailed(String error) {
    return '앨범 재생 실패: $error';
  }

  @override
  String get sortAllAZ => '전체 (A-Z)';

  @override
  String get sortRecentlyPlayed => '최근 재생';

  @override
  String get sortMostPlayed => '가장 많이 재생됨';

  @override
  String get sortStarred => '즐겨찾기';

  @override
  String get sortRandom => '무작위';

  @override
  String get filterAlbums => '앨범 필터링...';

  @override
  String get filterArtists => '아티스트 필터링...';

  @override
  String get searchPlaylists => '재생목록 검색...';

  @override
  String get searchRemoteHint => '노래, 앨범, 아티스트 검색...';

  @override
  String errorLoadingAlbums(String error) {
    return '앨범 로드 실패: $error';
  }

  @override
  String get noAlbumsOnServer => '서버에서 앨범을 찾을 수 없습니다';

  @override
  String get noMatchingAlbums => '일치하는 앨범이 없습니다';

  @override
  String get playAlbum => '앨범 재생';

  @override
  String get shuffleAlbum => '앨범 셔플 재생';

  @override
  String errorLoadingArtists(String error) {
    return '아티스트 로드 실패: $error';
  }

  @override
  String get noArtistsFound => '아티스트를 찾을 수 없습니다';

  @override
  String get noMatchingArtists => '일치하는 아티스트가 없습니다';

  @override
  String get noArtistSelected => '선택된 아티스트 없음';

  @override
  String errorLoadingPlaylists(String error) {
    return '재생목록 로드 실패: $error';
  }

  @override
  String get noPlaylistsFound => '재생목록을 찾을 수 없습니다';

  @override
  String get noMatchingPlaylists => '일치하는 재생목록이 없습니다';

  @override
  String get noPlaylistSelected => '선택된 재생목록 없음';

  @override
  String get typeToSearch => '검색어를 입력하세요';

  @override
  String get albumNotFound => '앨범 정보를 찾을 수 없습니다';

  @override
  String playingTracksCount(int count) {
    return '$count곡 재생 중';
  }

  @override
  String get artistNotFound => '서버에서 아티스트 정보를 찾을 수 없습니다';

  @override
  String get noTracksForArtist => '이 아티스트의 트랙을 찾을 수 없습니다';

  @override
  String get noAlbumsForArtist => '이 아티스트의 앨범을 찾을 수 없습니다';

  @override
  String get playlistNotFound => '서버에서 재생목록 정보를 찾을 수 없습니다';

  @override
  String removedFromPlaylistSuccess(String title) {
    return '재생목록에서 \"$title\" 제거됨';
  }

  @override
  String get removeTrackFailed => '트랙 제거 실패';

  @override
  String get playlistDeleted => '재생목록 삭제됨';

  @override
  String get deletePlaylistFailed => '재생목록 삭제 실패';

  @override
  String byAuthor(String author) {
    return '생성자: $author';
  }

  @override
  String get downloadAllTracks => '모두 다운로드';

  @override
  String get downloadFailedGeneric => '다운로드 실패';

  @override
  String downloadPaused(String progress) {
    return '일시 중지됨 ($progress%)';
  }

  @override
  String get waitingInQueue => '대기열 대기 중...';

  @override
  String get downloadCancelled => '취소됨';

  @override
  String fileNotFoundAtPath(String path) {
    return '파일을 찾을 수 없음: $path';
  }

  @override
  String addedTracksToPlaylistSuccess(int count, String name) {
    return '\"$name\"에 $count곡 추가됨';
  }

  @override
  String get addToPlaylistFailed => '재생목록에 추가 실패';

  @override
  String errorAddingToPlaylist(String error) {
    return '재생목록 추가 오류: $error';
  }

  @override
  String createdPlaylistWithTracksSuccess(String name, int count) {
    return '재생목록 \"$name\" 생성됨 ($count곡 추가)';
  }

  @override
  String get createServerPlaylistFailed => '서버 재생목록 생성 실패';

  @override
  String errorCreatingPlaylist(String error) {
    return '재생목록 생성 오류: $error';
  }

  @override
  String get noServerPlaylistsFound => '서버 재생목록 없음';

  @override
  String get download => '다운로드';

  @override
  String get resume => '재개';

  @override
  String get remove => '삭제';

  @override
  String get refresh => '새로고침';

  @override
  String get copyFilePath => '파일 경로 복사';

  @override
  String get openFolder => '폴더 열기';

  @override
  String get copyFolderName => '폴더 이름 복사';

  @override
  String get copyFolderPath => '폴더 경로 복사';

  @override
  String errorWithMessage(String error) {
    return '오류: $error';
  }
}
