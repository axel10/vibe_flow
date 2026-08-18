import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vynody/widgets/app_tooltip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_core/audio_core.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/utils/playback_utils.dart';
import '../l10n/app_localizations.dart';

class MiniArtwork extends ConsumerWidget {
  const MiniArtwork({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        image: (currentMusic?.thumbnailPath != null && File(currentMusic!.thumbnailPath!).existsSync())
            ? DecorationImage(
                image: ResizeImage(
                  FileImage(File(currentMusic.thumbnailPath!)),
                  width: 120,
                  height: 120,
                  allowUpscaling: false,
                ),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.low,
              )
            : (currentMusic?.artworkPath != null && File(currentMusic!.artworkPath!).existsSync())
            ? DecorationImage(
                image: ResizeImage(
                  FileImage(File(currentMusic.artworkPath!)),
                  width: 120,
                  height: 120,
                  allowUpscaling: false,
                ),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.low,
              )
            : null,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[200],
      ),
      child:
          (currentMusic?.artworkPath == null &&
              currentMusic?.thumbnailPath == null)
          ? Icon(
              Icons.music_note,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black54,
              size: 20,
            )
          : null,
    );
  }
}

class MiniControlButton extends StatelessWidget {
  const MiniControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.iconSize = 24.0,
    this.padding = const EdgeInsets.all(6.0),
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Widget buttonWidget = IconButton(
      icon: Icon(icon, color: isDark ? Colors.white : Colors.black87, size: iconSize),
      padding: padding,
      constraints: const BoxConstraints(),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return AppTooltip(
        message: tooltip!,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}


class MiniInlineVolumeControl extends StatelessWidget {
  const MiniInlineVolumeControl({
    super.key,
    required this.volume,
    this.isMuted = false,
    required this.showSlider,
    required this.onTap,
    required this.onChanged,
    this.onScroll,
    this.tooltip,
    this.iconSize = 18.0,
  });

  final double volume;
  final bool isMuted;
  final bool showSlider;
  final VoidCallback? onTap;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onScroll;
  final String? tooltip;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final buttonTooltip = tooltip ?? l10n?.volume ?? 'Volume';

    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent && onScroll != null) {
          onScroll!(pointerSignal.scrollDelta.dy);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniControlButton(
            icon: getVolumeIcon(volume, isMuted: isMuted),
            onPressed: onTap,
            tooltip: buttonTooltip,
            iconSize: iconSize,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: showSlider
                ? SizedBox(
                    key: const ValueKey('mini-inline-volume-slider'),
                    width: 118,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2.5,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                        activeTrackColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                        inactiveTrackColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.white24
                            : Colors.black12,
                        thumbColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        overlayColor:
                            (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black)
                                .withValues(alpha: 0.15),
                      ),
                      child: Slider(
                        value: (isMuted ? 0.0 : volume).clamp(0.0, 100.0),
                        min: 0,
                        max: 100,
                        onChanged: onChanged,
                      ),
                    ),
                  )
                : const SizedBox(
                    key: ValueKey('mini-inline-volume-slider-collapsed'),
                  ),
          ),
        ],
      ),
    );
  }
}

class MiniSpectrumBackground extends ConsumerWidget {
  final AudioService audio;

  const MiniSpectrumBackground({super.key, required this.audio});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(audioIsPlayingProvider);
    if (!isPlaying) return const SizedBox.shrink();

    // 使用独立的 FFT 流（专用于迷你播放器）
    final fftStream = audio.miniPlayerFftStream;
    if (fftStream == null) return const SizedBox.shrink();

    return StreamBuilder<FftFrame>(
      stream: fftStream,
      builder: (context, snapshot) {
        final frame = snapshot.data;
        if (frame == null) return const SizedBox.shrink();
        return RepaintBoundary(
          child: CustomPaint(
            painter: _MiniSpectrumPainter(
              values: frame.values,
              color:
                  (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withValues(alpha: 0.15),
            ),
          ),
        );
      },
    );
  }
}

class _MiniSpectrumPainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _MiniSpectrumPainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // displayCount 控制迷你播放器显示的频段（条形图）数量
    // 增加此数值会让频谱更细腻，减小则更简约
    const int displayCount = 64;
    final double barWidth = size.width / displayCount;
    const double gap = 3.0;

    for (int i = 0; i < displayCount; i++) {
      // 从频率数据中采样
      // 这里将采样范围限制在低中频段（values.length / 1.5），因为这些频段的跳动在视觉上更活跃
      int index = (i * values.length / (displayCount * 1.5)).floor();
      if (index >= values.length) index = values.length - 1;

      double value = values[index];

      // Amplify and clamp height
      double barHeight = (value * size.height * 1.2).clamp(3.0, size.height);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            i * barWidth + gap / 2,
            (size.height - barHeight) / 2, // Symmetric vertical centering
            barWidth - gap,
            barHeight,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniSpectrumPainter oldDelegate) => true;
}
