import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_core/audio_core.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/widgets/visualizer_painter.dart';

/// 高性能频谱视觉层。
///
/// 特性说明：
/// 1. 不使用 [StreamBuilder] 触发 Widget 树频繁 rebuild（避免 30~60 FPS 重建引起的 GC 压力与 Windows AXTree 无障碍同步错误）。
/// 2. 使用 [ValueNotifier] + [CustomPainter.repaint]，仅在 Render 树层面触发重绘。
/// 3. 最外层包裹 [ExcludeSemantics]，彻底与操作系统无障碍树（AXTree）隔离。
class PlaybackVisualizerLayer extends ConsumerStatefulWidget {
  final Orientation orientation;

  const PlaybackVisualizerLayer({
    super.key,
    required this.orientation,
  });

  @override
  ConsumerState<PlaybackVisualizerLayer> createState() =>
      _PlaybackVisualizerLayerState();
}

class _PlaybackVisualizerLayerState
    extends ConsumerState<PlaybackVisualizerLayer> {
  final ValueNotifier<List<double>> _fftNotifier =
      ValueNotifier<List<double>>(const []);
  StreamSubscription<FftFrame>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = ref
        .read(audioServiceProvider)
        .visualizerStream
        .listen(
      (frame) {
        _fftNotifier.value = frame.values;
      },
      onError: (_) {
        _fftNotifier.value = const [];
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _fftNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsServiceProvider);
    final dynamicStartColor = ref.watch(audioDynamicStartColorProvider);
    final dynamicEndColor = ref.watch(audioDynamicEndColorProvider);
    final isLandscape = widget.orientation == Orientation.landscape;
    final gap = isLandscape ? settings.landscapeGap : settings.portraitGap;

    return Positioned.fill(
      child: ExcludeSemantics(
        excluding: true,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: FftPainter(
              listenable: _fftNotifier,
              style: settings.visualizerStyle,
              gap: gap,
              capDropSpeed: settings.visualizerCapDropSpeed,
              color: settings.isVisualizerDynamicColor
                  ? (dynamicStartColor ?? settings.visualizerColor)
                  : settings.visualizerColor,
              opacity: settings.visualizerOpacity,
              useGradient: settings.isVisualizerGradientEnabled,
              startColor: settings.isVisualizerDynamicStartColor
                  ? (dynamicStartColor ?? settings.visualizerStartColor)
                  : settings.visualizerStartColor,
              endColor: settings.isVisualizerDynamicEndColor
                  ? (dynamicEndColor ?? settings.visualizerEndColor)
                  : settings.visualizerEndColor,
              gradientStop1: settings.visualizerGradientStop1,
              gradientStop2: settings.visualizerGradientStop2,
              gradientTileMode: settings.visualizerGradientTileMode,
            ),
          ),
        ),
      ),
    );
  }
}
