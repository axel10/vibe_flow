import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_core/audio_core.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/settings/settings_service.dart';
import '../l10n/app_localizations.dart';

class EqualizerPanel extends ConsumerStatefulWidget {
  const EqualizerPanel({super.key});

  @override
  ConsumerState<EqualizerPanel> createState() => _EqualizerPanelState();
}

class _EqualizerPanelState extends ConsumerState<EqualizerPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bandCount = ref.read(settingsServiceProvider).equalizerBandCount;
      ref.read(audioServiceProvider).ensureEqualizerBandCount(bandCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      settingsServiceProvider.select((s) => s.equalizerBandCount),
      (previous, next) {
        ref.read(audioServiceProvider).ensureEqualizerBandCount(next);
      },
    );

    final settings = ref.watch(settingsServiceProvider);
    final bandCount = settings.equalizerBandCount;

    final audio = ref.read(audioServiceProvider);
    final snapshot = ref.watch(audioSnapshotProvider);
    final config = snapshot.equalizerConfig;
    final playbackSpeed = snapshot.playbackSpeed;
    final frequencies = audio.getEqualizerBandCenters(bandCount: bandCount);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withValues(alpha: 0.7) : theme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(audio, config, l10n),
            const SizedBox(height: 24),
            _buildEqSliders(audio, config, accentColor, bandCount, frequencies),
            const SizedBox(height: 32),
            _buildBottomControls(audio, config, accentColor, l10n),
            const SizedBox(height: 24),
            Divider(
              height: 1,
              color: isDark ? Colors.white10 : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            _buildSpeedControl(audio, playbackSpeed, accentColor, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedControl(
    AudioService audio,
    double playbackSpeed,
    Color accentColor,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final SettingsService settings = ref.watch(settingsServiceProvider);
    final limit5x = settings.playbackSpeedLimit5x;
    final maxLimit = limit5x ? 5.0 : 2.0;

    final locale = Localizations.localeOf(context);
    final isChinese = locale.languageCode == 'zh';
    final switchLabel = isChinese ? '5倍速上限' : '5x Speed Limit';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.playbackSpeed,
              style: TextStyle(
                color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                '${playbackSpeed.toStringAsFixed(2)}x',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                ),
                child: Slider(
                  value: playbackSpeed.clamp(0.5, maxLimit),
                  min: 0.5,
                  max: maxLimit,
                  divisions: limit5x ? 90 : 30,
                  activeColor: accentColor,
                  inactiveColor: isDark ? Colors.white12 : theme.colorScheme.outlineVariant,
                  onChanged: (val) => audio.setPlaybackSpeed(val),
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: playbackSpeed == 1.0 ? null : () => audio.setPlaybackSpeed(1.0),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.reset,
                style: TextStyle(
                  fontSize: 12,
                  color: playbackSpeed == 1.0
                      ? (isDark ? Colors.white30 : Colors.black26)
                      : accentColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 5.0]
                .where((speed) => speed <= maxLimit)
                .map((speed) {
              final isSelected = (playbackSpeed - speed).abs() < 0.01;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(
                    speed == 1.0 ? '1.0x (${l10n.normal})' : '${speed}x',
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? (isDark ? Colors.black : Colors.white)
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      audio.setPlaybackSpeed(speed);
                    }
                  },
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  selectedColor: accentColor,
                  backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              switchLabel,
              style: TextStyle(
                color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                height: 24,
                child: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: limit5x,
                    activeThumbColor: accentColor,
                    activeTrackColor: accentColor.withValues(alpha: 0.5),
                    onChanged: (val) {
                      settings.playbackSpeedLimit5x = val;
                      final nextMax = val ? 5.0 : 2.0;
                      if (playbackSpeed > nextMax) {
                        audio.setPlaybackSpeed(nextMax);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(
    AudioService audio,
    EqualizerConfig config,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.equalizer,
              style: TextStyle(
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              config.enabled
                  ? l10n.equalizerEnabledStatus
                  : l10n.equalizerDisabledStatus,
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.5) : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        Switch(
          value: config.enabled,
          activeThumbColor: accentColor,
          activeTrackColor: accentColor.withValues(alpha: 0.5),
          onChanged: (val) => audio.setEqualizerEnabled(val),
        ),
      ],
    );
  }

  Widget _buildEqSliders(
    AudioService audio,
    EqualizerConfig config,
    Color accentColor,
    int bandCount,
    List<double> frequencies,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const double minItemWidth = 48.0;

    return SizedBox(
      height: 220,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidthNeeded = minItemWidth * bandCount;
          final needsScroll = totalWidthNeeded > constraints.maxWidth;

          final sliders = List.generate(bandCount, (index) {
            final gain = index < config.bandGainsDb.length
                ? config.bandGainsDb[index]
                : 0.0;

            final sliderItem = Column(
              children: [
                Expanded(
                  child: _VerticalEqSlider(
                    value: gain,
                    min: -12.0,
                    max: 12.0,
                    activeColor: accentColor,
                    onChanged: (val) => audio.setEqualizerBandGain(index, val),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  frequencies.length > index
                      ? _formatFreq(frequencies[index])
                      : '',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );

            if (needsScroll) {
              return SizedBox(
                width: minItemWidth,
                child: sliderItem,
              );
            } else {
              return Expanded(child: sliderItem);
            }
          });

          if (needsScroll) {
            return ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: sliders,
                ),
              ),
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: sliders,
            );
          }
        },
      ),
    );
  }

  Widget _buildBottomControls(
    AudioService audio,
    EqualizerConfig config,
    Color accentColor,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        _buildKnobControl(
          label: l10n.bassBoost,
          value: config.bassBoostDb,
          min: 0,
          max: 100,
          accentColor: accentColor,
          onChanged: (val) => audio.setBassBoost(val),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.preampGain,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${config.preampDb.toStringAsFixed(1)} dB',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                ),
                child: Slider(
                  value: config.preampDb.clamp(-12.0, 12.0),
                  min: -12.0,
                  max: 12.0,
                  activeColor: accentColor,
                  inactiveColor: isDark ? Colors.white12 : theme.colorScheme.outlineVariant,
                  onChanged: (val) => audio.setEqualizerPreamp(val),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () => audio.resetEqualizerDefaults(),
          icon: Icon(
            Icons.refresh,
            color: isDark ? Colors.white54 : theme.colorScheme.onSurfaceVariant,
          ),
          tooltip: l10n.reset,
        ),
      ],
    );
  }

  Widget _buildKnobControl({
    required String label,
    required double value,
    required double min,
    required double max,
    required Color accentColor,
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        _Knob(
          value: value,
          min: min,
          max: max,
          size: 64,
          themeColor: accentColor,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        Text(
          '${value.toInt()}%',
          style: TextStyle(
            color: accentColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatFreq(double hz) {
    if (hz >= 1000) {
      return '${(hz / 1000).toInt()}k';
    }
    return hz.toInt().toString();
  }
}

class _VerticalEqSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  const _VerticalEqSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RotatedBox(
      quarterTurns: 3,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 6,
          thumbShape: _CustomThumbShape(color: activeColor),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
          activeTrackColor: activeColor,
          inactiveTrackColor: isDark ? Colors.white.withValues(alpha: 0.1) : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          trackShape: const RoundedRectSliderTrackShape(),
        ),
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final Color color;

  const _CustomThumbShape({required this.color});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(12, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 6, height: 24),
      const Radius.circular(3),
    );

    // Subtle glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 10, height: 28),
        const Radius.circular(4),
      ),
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawRRect(rrect, paint);

    // Middle line indicator
    canvas.drawLine(
      Offset(center.dx - 2, center.dy),
      Offset(center.dx + 2, center.dy),
      Paint()
        ..color = color
        ..strokeWidth = 2,
    );
  }
}

class _Knob extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final double size;
  final Color themeColor;
  final ValueChanged<double> onChanged;

  const _Knob({
    required this.value,
    this.min = 0,
    this.max = 100,
    required this.size,
    required this.themeColor,
    required this.onChanged,
  });

  @override
  State<_Knob> createState() => _KnobState();
}

class _KnobState extends State<_Knob> {
  double _dragValue = 0;

  @override
  void initState() {
    super.initState();
    _dragValue = widget.value;
  }

  @override
  void didUpdateWidget(_Knob oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _dragValue) {
      _dragValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        final delta = details.primaryDelta! / widget.size;
        setState(() {
          _dragValue = (_dragValue - delta * (widget.max - widget.min)).clamp(
            widget.min,
            widget.max,
          );
        });
        widget.onChanged(_dragValue);
      },
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _KnobPainter(
          context: context,
          value: _dragValue,
          min: widget.min,
          max: widget.max,
          themeColor: widget.themeColor,
        ),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
        ),
      ),
    );
  }
}

class _KnobPainter extends CustomPainter {
  final BuildContext context;
  final double value;
  final double min;
  final double max;
  final Color themeColor;

  _KnobPainter({
    required this.context,
    required this.value,
    required this.min,
    required this.max,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 6.0;

    // Background circle
    canvas.drawCircle(
      center,
      radius - strokeWidth / 2,
      Paint()
        ..color = isDark
            ? Colors.white.withValues(alpha: 0.05)
            : theme.colorScheme.onSurface.withValues(alpha: 0.05)
        ..style = PaintingStyle.fill,
    );

    // Track
    final trackPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : theme.colorScheme.onSurface.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = 0.75 * math.pi;
    const sweepAngleTotal = 1.5 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngleTotal,
      false,
      trackPaint,
    );

    // Active track
    final normalized = (value - min) / (max - min);
    final activePaint = Paint()
      ..color = themeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngleTotal * normalized,
      false,
      activePaint,
    );

    // Dot indicator
    final angle = startAngle + sweepAngleTotal * normalized;
    final dotPos = Offset(
      center.dx + (radius - 12) * math.cos(angle),
      center.dy + (radius - 12) * math.sin(angle),
    );

    canvas.drawCircle(
      dotPos,
      4,
      Paint()..color = isDark ? Colors.white : theme.colorScheme.onSurface,
    );

    // Inner hub
    canvas.drawCircle(
      center,
      radius - 18,
      Paint()
        ..color = isDark
            ? Colors.white10
            : theme.colorScheme.onSurface.withValues(alpha: 0.05)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _KnobPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.themeColor != themeColor || oldDelegate.context != context;
}
