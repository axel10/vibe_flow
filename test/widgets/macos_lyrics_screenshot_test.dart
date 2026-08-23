// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/macos_screenshot_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('macOS Store 02 - 聚焦歌词 (Render Window & 2880x1800 Poster)', (tester) async {
    // 1. Prepare artwork and song data
    Uint8List? artworkBytes;
    final coverFile = File('/tmp/sunset_cover.jpg');
    if (coverFile.existsSync()) {
      artworkBytes = Uint8List.fromList(coverFile.readAsBytesSync());
    }

    const demoLrc = '''[00:00.00]《把这一天留给你》
[00:16.00]街角的风吹过红色的墙
[00:20.50]阳光落在旧信纸上
[00:24.80]你写下一个日期
[00:28.90]却没有告诉我理由是什么
[00:34.80]我把那一天圈了又圈
[00:39.20]像害怕它会突然走远
[00:43.60]窗外云朵慢慢变淡
[00:47.80]心里的期待却越来越明显
[00:53.50]如果你也在等
[00:57.40]那就让我听见
[01:01.60]藏在晚风里面
[01:05.70]没有说完的语言
[01:11.20]我把这一天留给你
[01:15.70]把所有温柔都写进日期
[01:20.20]等钟声响起
[01:23.50]等你出现在我眼里
[01:28.90]我把这一天留给你
[01:33.30]不管晴天还是下着小雨
[01:37.90]只要你愿意
[01:41.20]我们就从这里开始相遇
[01:53.00]人群从身边匆匆经过
[01:57.30]城市依旧不停闪烁
[02:01.70]可我忽然觉得
[02:05.60]世界只剩下你和我
[02:11.00]也许所谓的命运
[02:15.10]就是恰好遇见的那个人
[02:19.60]在某个普通的黄昏
[02:23.80]让平凡的日子变得特别认真
[02:29.70]如果你也在等
[02:33.70]那就别说再见
[02:37.80]让时间慢一点
[02:41.90]让这一刻停留久一些
[02:47.50]我把这一天留给你
[02:52.00]把所有温柔都写进日期
[02:56.50]等钟声响起
[02:59.80]等你出现在我眼里
[03:05.30]我把这一天留给你
[03:09.70]把没说出口的话都给你
[03:14.30]如果你愿意
[03:17.50]就让我们记住今天的约定
[03:23.30]哪怕很多年以后
[03:27.00]翻开这张泛红的日历
[03:31.20]我还是会想起
[03:34.80]那天我等着你
[03:40.00]我把这一天留给你
[03:44.50]也把未来的一点点留给你
[03:49.00]当我们再次相遇
[03:52.50]愿故事还没有结局
[04:00.00]把这一天留给你
[04:04.00]把这一天留给你
[04:08.00]这是我写给你的约定
[04:12.50]也是我最期待的日期''';

    final lyrics = parseLrc(demoLrc);
    final waveformBlob = generateRealisticWaveform(128, seed: 1.8);
    const songPath =
        '/Users/axel10/Music/Vynody Music/Demo Music/zh/Demo Music/04 - Walking Home at Sunset.mp3';

    final demoSong = MusicFile(
      path: songPath,
      name: '04 - Walking Home at Sunset.mp3',
      title: '把这一天留给你',
      artist: '晚风邮局',
      album: '约定的红色夏天',
      durationMillis: 251970,
      artworkBytes: artworkBytes,
      waveformBlob: waveformBlob,
      lyrics: lyrics,
    );

    // Active climax line: 01:15.70 "把所有温柔都写进日期"
    final currentPosition = const Duration(seconds: 76);

    final snapshot = AudioSnapshot(
      isPlaying: true,
      isTransitioning: false,
      isLastActionNext: null,
      currentMusic: demoSong,
      position: currentPosition,
      duration: const Duration(seconds: 251, milliseconds: 970),
      volume: 0.82,
      isMuted: false,
      playbackQueue: [demoSong],
      currentIndex: 0,
      isRandomMode: false,
      isShuffleRandomMode: false,
      playbackMode: AppPlaybackMode.queue,
      equalizerConfig: EqualizerConfig(
        enabled: false,
        bandCount: 10,
        preampDb: 0.0,
        bassBoostDb: 0.0,
        bassBoostFrequencyHz: 80.0,
        bassBoostQ: 1.0,
        bandGainsDb: Float32List(10),
      ),
      currentVisualizerOptions: const VisualizerOptimizationOptions(
        frequencyGroups: 100,
      ),
      randomHistory: const [],
      randomQueue: const [],
      historyCursor: null,
      deckCursor: null,
      isVisualizerEnabled: true,
      dynamicStartColor: const Color(0xFFC83A3A),
      dynamicEndColor: const Color(0xFF1E1528),
      currentThemeColorsMap: const {
        'darkVibrant': Color(0xFFFF5252),
        'vibrant': Color(0xFFFF6E40),
        'dominant': Color(0xFFC83A3A),
        'darkMuted': Color(0xFF3E1C2B),
        'lightVibrant': Color(0xFFFFB4AB),
      },
      isLyricsActive: true,
      sleepTimerRemaining: null,
      sleepTimerDuration: null,
    );

    final lyricsState = LyricsControllerState(
      hasLyrics: true,
      currentLyricsLines: lyrics.syncedLines,
      lyricsTranslationLanguageCode: 'zh',
    );

    // 2. Capture 1080p native macOS App Window
    final windowBytes = await captureMacosWindow(
      tester: tester,
      song: demoSong,
      snapshot: snapshot,
      lyricsState: lyricsState,
      lyrics: lyrics,
      saveWindowFileName: 'macos_window_02_lyrics.png',
      configureSettings: (s) {
        s.lyricsStyle = LyricsStyle.apple;
        s.collapseButtonsInLandscapeLyrics = true;
        s.visualizerColor = const Color(0xFFFF7272);
      },
    );

    // 3. Render 2880x1800 macOS Store Poster
    await renderMacosStorePoster(
      tester: tester,
      windowBytes: windowBytes,
      config: const MacosPosterConfig(
        tagText: '全屏沉浸歌词',
        tagColor: Color(0xFFFF8E72),
        title: '聚焦歌词',
        subtitle: '逐行平滑滚动 · 动态高斯虚化与双语对照',
        backgroundGradient: [
          Color(0xFF201322),
          Color(0xFF100B17),
          Color(0xFF050408),
        ],
        glowColors: [
          Color(0x3DC83A3A),
          Color(0x217A2062),
          Colors.transparent,
        ],
        outputFileName: 'macos_store_02_lyrics.png',
      ),
    );
  });
}
