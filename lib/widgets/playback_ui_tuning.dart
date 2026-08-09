import 'package:flutter/material.dart';

class PlaybackPageUiTuning {
  PlaybackPageUiTuning._();

  static bool isSmallWindow(
    Size size, {
    required bool isWaveformEnabled,
    bool isSmallWindowMode = false,
  }) {
    return isSmallWindowMode;
  }

  static const Size smallWindowMinSize = Size(360, 360);
  static const Size smallWindowMaxSize = Size(600, 600);
  static const Size smallWindowDefaultSize = Size(360, 360);

  static const double desktopTopSpacer = 32.0;
  static const double statusBannerTop = 12.0;

  static const double lyricsLandscapeLeftPadding = 40.0;
  static const double lyricsPortraitLeftPadding = 8.0;
  static const double normalLandscapeHorizontalPadding = 32.0;
  static const double normalPortraitHorizontalPadding = 8.0;
  static const double lyricsLandscapeRightPadding = 24.0;
  static const double lyricsPortraitRightPadding = 8.0;
  static const double landscapeTopPadding = 32.0;
  static const double landscapeBottomPadding = 32.0;
  static const double portraitTopPadding = 12.0;
  static const double lyricsTopPadding = 8.0;

  static const double traditionalLyricsVerticalPadding = 20.0; // 传统歌词面板每行歌词之间的间距
  static const double appleLyricsVerticalPadding = 10.0; // 苹果样式歌词面板每行歌词之间的间距
  static const double appleLyricsInactiveOpacity = 0.65; // 苹果样式歌词非当前行不透明度（包含翻译及逐字歌词未唱到部分）
  static const double appleLyricsTranslationFontSizePortrait = 11.0; // 苹果样式歌词翻译在竖屏模式下的字体大小
  static const double appleLyricsTranslationFontSizeLandscape = 11.0; // 苹果样式歌词翻译在横屏模式下的字体大小

  static const double appleLyricsTopPaddingPortrait = 50.0; // 苹果样式歌词竖屏顶部边距
  static const double appleLyricsTopPaddingLandscape = 50.0; // 苹果样式歌词横屏顶部边距 (原为120.0，调整为与竖屏一致)
  static const double appleLyricsTopPaddingSmallWin = 30.0; // 苹果样式歌词小窗顶部边距

  static const double appleLyricsScrollOffsetPortrait = 25.0; // 苹果样式歌词竖屏滚动偏移量
  static const double appleLyricsScrollOffsetLandscape = 25.0; // 苹果样式歌词横屏滚动偏移量 (原为100.0，调整为与竖屏一致)
  static const double appleLyricsScrollOffsetSmallWin = 25.0; // 苹果样式歌词小窗滚动偏移量

  // 苹果样式歌词高斯模糊相关参数
  static const double appleLyricsBaseBlurSigma = 1.8; // 苹果样式歌词基础模糊强度
  static const double appleLyricsBlurGradientFactor = 0.25; // 苹果样式歌词模糊强度随位置变化系数（从上到下逐渐增强）
  static const double appleLyricsMinBlurSigma = 0.4; // 苹果样式歌词最小模糊强度
  static const double appleLyricsMaxBlurSigma = 4.5; // 苹果样式歌词最大模糊强度


  // 歌词自适应字体大小配置参数
  static const double lyricsMinFontScale = 1.3;
  static const double lyricsMaxFontScale = 3.0;
  static const double lyricsBaseScaleSmallScreenWidth = 360.0;
  static const double lyricsBaseScaleLargeScreenWidth = 1000.0;
  static const double lyricsMinBaseScale = 1.15;
  static const double lyricsMaxBaseScale = 1.20;
  static const double lyricsPanelWidthReference = 360.0;
  static const double lyricsPanelWidthGrowFactor = 0.0015;
  static const double lyricsPanelWidthShrinkFactor = 0.0025;
  static const double traditionalLyricsMaxWidthClamp = 560.0; // 传统歌词模式下用于计算字体缩放的最大面板宽度
  static const double appleLyricsMaxWidthClamp = 560.0; // 苹果样式歌词模式下用于计算字体缩放的最大面板宽度
  static const double appleLyricsLandscapeMaxWidthClamp = 800.0; // 苹果样式歌词在横屏下用于计算字体缩放的最大面板宽度
  static const double appleLyricsBaseScreenWidth = 1920.0; // 苹果样式歌词高分辨率适配的基准屏幕宽度
  static const double appleLyricsHighResSlope = 0.00015; // 超过基准宽度后苹果样式歌词的增长斜率系数

  static EdgeInsets contentPadding({
    required bool isLandscape,
    required bool isLyricsMode,
    required double bottomPadding,
    required bool reserveBottomNavSpace,
    bool isSmallWin = false,
  }) {
    if (isSmallWin) {
      return EdgeInsets.zero;
    }
    final left = isLyricsMode
        ? (isLandscape ? lyricsLandscapeLeftPadding : lyricsPortraitLeftPadding)
        : (isLandscape
              ? normalLandscapeHorizontalPadding
              : normalPortraitHorizontalPadding);
    final top = isLyricsMode
        ? lyricsTopPadding
        : (isLandscape ? landscapeTopPadding : portraitTopPadding);
    final right = isLyricsMode
        ? (isLandscape
              ? lyricsLandscapeRightPadding
              : lyricsPortraitRightPadding)
        : (isLandscape
              ? normalLandscapeHorizontalPadding
              : normalPortraitHorizontalPadding);
    final bottom = isLandscape
        ? (isLyricsMode ? lyricsTopPadding : landscapeBottomPadding)
        : (reserveBottomNavSpace ? bottomPadding : 0.0);

    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }
}

class PlaybackHeroCardUiTuning {
  PlaybackHeroCardUiTuning._();

  static const Duration transitionDuration = Duration(milliseconds: 400);

  // 竖屏参数 (Portrait parameters)
  static const double pInfoHeight = 80.0;
  static const double pCoverMaxSide = 1000.0;
  static const double pNormalCoverInfoMinGap = 26.0; // 竖屏下标题区距离封面底部的最小距离
  static const double portraitControlsWidthFactor =
      1.0; // 竖屏控件区宽度比例 (0.0 - 1.0)
  static const double pControlsHeightFactor = 0.58; // 竖屏控件区最大高度比例 (相对于屏幕高度)
  static const double pLyricsCoverSide = 80.0;
  static const double pLyricsCoverTop = 16.0;
  static const double pLyricsCoverLeft = 24.0;

  // 横屏参数 (Landscape parameters)
  static const double lControlsMinWidth = 440.0;
  static const double lControlsMaxWidth = 1000.0;
  static const double lCoverMinSide = 240.0;
  static const double lCoverMaxSide = 1800.0;
  static const double lNormalCoverSideFactor = 0.72; // 横屏普通模式封面尺寸系数

  // 横屏歌词模式统一调节入口 (Unified tuning entry for landscape lyrics mode)
  static const double lLyricsPreferredCoverSide = 420.0; // 横屏歌词封面基础尺寸
  static const double lLyricsBaseControlsScale = 0.8; // 横屏歌词控件区基础缩放倍率 (包含按钮、图标、字体)
  static const double lLyricsMaxCoverExpansion = 120.0; // 窗口空间充裕时封面最大额外扩大尺寸
  static const double lLyricsMaxControlsExpansion = 0.22; // 窗口空间充裕时控件区最大额外放大倍率
  static const double lLyricsVerticalMargin = 48.0; // 横屏歌词模式左侧控件区上下预留边距 (单位：像素，如 28.0px 即上下各留 28px)
  static const double lLyricsMaxHeightFactor = 0.8; // 横屏歌词模式左侧控件区最大高度比例 (相对于窗口屏幕高度)

  static const double appleLyricsRightPanelRatio = 0.5; // 苹果样式下歌词模式占比

  static const double trackTitlePortraitLyricsFont = 20.0;
  static const double trackTitleStandardFont = 24.0;
  static const double trackTitleLandscapeLyricsFont = 21.0;
  static const double minTrackTitleFontSize = 14.0;
  static const double trackArtistPortraitLyricsFont = 14.0;
  static const double trackArtistStandardFont = 16.0;
  static const double trackArtistLandscapeLyricsFont = 19.0;
  static const double minTrackArtistFontSize = 12.0;
  static const double trackInfoLandscapeLyricsGap = 5.0;

  // 横屏歌词模式下标题按钮区尺寸基准参数 (Base dimension for title button area in landscape lyrics mode)
  static const double lLyricsTitleButtonSize = 32.0;

  // 以下参数均基于 lLyricsTitleButtonSize 自动等比例缩放 (The following parameters scale proportionally based on lLyricsTitleButtonSize)
  static const double lLyricsTitleButtonHeight = lLyricsTitleButtonSize;
  static const double lLyricsTitleIconSize = lLyricsTitleButtonSize * (16.0 / 24.0);
  static const double lLyricsSleepTimerButtonWidth = lLyricsTitleButtonSize * (38.0 / 24.0);
  static const double lLyricsSleepTimerButtonHeight = lLyricsTitleButtonSize * (28.0 / 24.0);
  static const double lLyricsSleepTimerFontSize = lLyricsTitleButtonSize * (8.0 / 24.0);

  // static const double controlsRowLandscapeGap = 16.0;
  static const double controlsRowPortraitGap = 8.0;
  static const double topButtonsHorizontalPadding = 0.0; // 顶部按钮行的水平内边距
  static const double topButtonsIconSize = 22.0; // 顶部按钮图标的基础大小
  static const double topButtonsInnerGap = 8.0; // 按钮之间的间距

  static const double waveformOverlayHeight = 200.0;
  static const double waveformOverlayTimeSide = 20.0;
  static const double waveformOverlayTimeBottom = 10.0;
  static const double waveformPortraitLyricsHeight = 100.0; // 竖屏下波形进度条的高度
  static const double waveformLandscapeHeight = 74.0; // 横屏下波形进度条的高度
  static const double waveformStandardHorizontalPadding = 16.0;
  static const double waveformStandardTimeRowSpacing = 0.0;
  static const double portraitWaveformOverflowScale =
      1.35; // 竖屏波形进度条溢出缩放 (仅视觉，不影响布局)
  static const double minProgressTimeFontSize = 11.0; // 小窗模式时间文字最小尺寸
  static const double waveformBarWidth = 7.0; // 波形柱子宽度
  static const double waveformBarGap = 2.0; // 波形柱子间隙
  static const double waveformBarWidthLandscape = 4.5; // 横屏下波形柱子宽度
  static const double waveformBarGapLandscape = 2; // 横屏下波形柱子间隙

  // 控件区理想高度计算及缩放基准 (Ideal height calculation and scaling base)
  // 减小此值会让按钮和文字在相同屏幕宽度下显得更大
  static const double pControlsScaleBase = 375.0; // 竖屏缩放基准
  static const double lControlsScaleBase = 550.0; // 横屏缩放基准
  static const double controlsTopButtonsHeight = 44.0; // 减小顶部按钮高度
  static const double controlsMainButtonsHeight = 72.0;
  static const double controlsTimeRowHeight = 24.0;
  static const double controlsTimeGap = 8.0;
  static const double progressBarWidthFactor = 1.0; // 进度条宽度比例（相对于按钮区）
  static const double portraitProgressBarWidthFactor = 1.0; // 竖屏进度条宽度比例
  static const double landscapeInfoControlsGap = 14.0; // 横屏普通模式下标题区到控件区的距离
  static const double landscapeLyricsInfoControlsGap = 0.0; // 横屏歌词模式下标题区到控件区的距离 (保持紧凑)
  static const double landscapeLyricsInfoControlsGapCollapsed = 14.0; // 横屏歌词模式收起7按钮行时标题区距离波形进度条的距离
  static const double landscapeInfoHeightBase = 52.0;
  static const double landscapeLyricsInfoHeightBase = 64.0;
  static const double landscapeLyricsInfoHeightSmall = 46.0;
  static const double landscapeLyricsTitleScaleSmall = 0.85;
  static const double landscapeLyricsCoverInfoGapBase = 24.0;
  static const double controlsRowLandscapeGap = 12.0; // 顶部按钮到进度条的间距
  static const double controlsRowLandscapeMainGap = 16.0; // 进度条/时间行到主播放控制行的间距 (横屏普通模式)

  static const double portraitBottomReservedSpace = 0;
}
