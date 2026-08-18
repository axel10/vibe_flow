import 'package:flutter/material.dart';

class FftPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double opacity;
  final bool useGradient;
  final Color? startColor;
  final Color? endColor;
  final double? gradientStop1;
  final double? gradientStop2;
  final int? gradientTileMode;
  final double gap;

  static _GradientShaderKey? _cachedShaderKey;
  static Shader? _cachedShader;

  FftPainter({
    required this.values,
    required this.color,
    this.opacity = 0.2,
    this.useGradient = false,
    this.startColor,
    this.endColor,
    this.gradientStop1,
    this.gradientStop2,
    this.gradientTileMode,
    this.gap = 1.0,
  });

  Shader _getOrCreateShader(Size size) {
    final resolvedStart = startColor!.withValues(alpha: opacity);
    final resolvedEnd = endColor!.withValues(alpha: opacity);
    final key = _GradientShaderKey(
      startColor: resolvedStart,
      endColor: resolvedEnd,
      stop1: gradientStop1,
      stop2: gradientStop2,
      tileMode: gradientTileMode,
      width: size.width,
      height: size.height,
    );

    if (_cachedShaderKey == key && _cachedShader != null) {
      return _cachedShader!;
    }

    final shader = LinearGradient(
      colors: [resolvedStart, resolvedEnd],
      stops: gradientStop1 != null && gradientStop2 != null
          ? [gradientStop1!, gradientStop2!]
          : null,
      tileMode: gradientTileMode != null
          ? TileMode.values[gradientTileMode!]
          : TileMode.clamp,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    _cachedShaderKey = key;
    _cachedShader = shader;
    return shader;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;

    if (useGradient && startColor != null && endColor != null) {
      paint.shader = _getOrCreateShader(size);
    } else {
      paint.color = color.withValues(alpha: opacity);
    }

    final barCount = values.length;
    final totalGap = gap * (barCount - 1);
    final barWidth = (size.width - totalGap) / barCount;

    for (var i = 0; i < barCount; i++) {
      final barHeight = values[i] * size.height * 0.5;
      final x = i * (barWidth + gap);
      final y = size.height - barHeight;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FftPainter oldDelegate) => true;
}

@immutable
class _GradientShaderKey {
  final Color startColor;
  final Color endColor;
  final double? stop1;
  final double? stop2;
  final int? tileMode;
  final double width;
  final double height;

  const _GradientShaderKey({
    required this.startColor,
    required this.endColor,
    this.stop1,
    this.stop2,
    this.tileMode,
    required this.width,
    required this.height,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GradientShaderKey &&
          runtimeType == other.runtimeType &&
          startColor == other.startColor &&
          endColor == other.endColor &&
          stop1 == other.stop1 &&
          stop2 == other.stop2 &&
          tileMode == other.tileMode &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(
        startColor,
        endColor,
        stop1,
        stop2,
        tileMode,
        width,
        height,
      );
}
