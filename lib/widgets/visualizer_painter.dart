import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vynody/player/settings/settings_service.dart';

class FftPainter extends CustomPainter {
  final List<double>? _values;
  final ValueListenable<List<double>>? listenable;
  final VisualizerStyle style;
  final Color color;
  final double opacity;
  final bool useGradient;
  final Color? startColor;
  final Color? endColor;
  final double? gradientStop1;
  final double? gradientStop2;
  final int? gradientTileMode;
  final double gap;
  final double capDropSpeed;

  static _GradientShaderKey? _cachedShaderKey;
  static Shader? _cachedShader;

  // Peak caps physics state for floatingBars style
  static List<double> _peakCaps = [];
  static int _lastCapTimestamp = 0;

  // Cached trigonometric lookup table for radial style
  static int _cachedRadialBarCount = 0;
  static List<double> _cachedCosTable = const [];
  static List<double> _cachedSinTable = const [];

  FftPainter({
    List<double>? values,
    this.listenable,
    this.style = VisualizerStyle.bars,
    required this.color,
    this.opacity = 0.2,
    this.useGradient = false,
    this.startColor,
    this.endColor,
    this.gradientStop1,
    this.gradientStop2,
    this.gradientTileMode,
    this.gap = 1.0,
    this.capDropSpeed = 0.20,
    Listenable? repaint,
  })  : _values = values,
        super(repaint: repaint ?? listenable);

  List<double> get values => listenable?.value ?? _values ?? const [];

  Shader _getOrCreateShader(Size size) {
    final resolvedStart = (startColor ?? color).withValues(alpha: opacity);
    final resolvedEnd = (endColor ?? color).withValues(alpha: opacity);
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

    switch (style) {
      case VisualizerStyle.bars:
        _paintBars(canvas, size, paint);
        break;
      case VisualizerStyle.smoothWave:
        _paintSmoothWave(canvas, size, paint);
        break;
      case VisualizerStyle.floatingBars:
        _paintFloatingBars(canvas, size, paint);
        break;
      case VisualizerStyle.radial:
        _paintRadial(canvas, size, paint);
        break;
      case VisualizerStyle.matrix:
        _paintMatrix(canvas, size, paint);
        break;
      case VisualizerStyle.mirroredWave:
        _paintMirroredWave(canvas, size, paint);
        break;
    }
  }

  void _paintBars(Canvas canvas, Size size, Paint paint) {
    final barCount = values.length;
    if (barCount == 0) return;
    final totalGap = gap * (barCount - 1);
    final barWidth = math.max(0.5, (size.width - totalGap) / barCount);

    final path = Path();
    for (var i = 0; i < barCount; i++) {
      final barHeight = values[i] * size.height * 0.5;
      if (barHeight <= 0.5) continue;
      final x = i * (barWidth + gap);
      final y = size.height - barHeight;

      path.addRRect(
        RRect.fromRectXY(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          2.0,
          2.0,
        ),
      );
    }
    canvas.drawPath(path, paint);
  }

  void _paintSmoothWave(Canvas canvas, Size size, Paint paint) {
    final count = values.length;
    if (count < 2) return;

    final points = <Offset>[];
    for (int i = 0; i < count; i++) {
      final x = i * (size.width / (count - 1));
      final y = size.height - (values[i] * size.height * 0.55).clamp(2.0, size.height);
      points.add(Offset(x, y));
    }

    final wavePath = Path();
    wavePath.moveTo(0, size.height);
    wavePath.lineTo(points.first.dx, points.first.dy);

    final outlinePath = Path();
    outlinePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;

      final cp1x = p1.dx + (p2.dx - p0.dx) / 6.0;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6.0;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6.0;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6.0;

      wavePath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
      outlinePath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, paint);

    // Draw illuminated crest line
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    if (useGradient && startColor != null && endColor != null) {
      strokePaint.shader = _getOrCreateShader(size);
    } else {
      strokePaint.color = color.withValues(alpha: math.min(1.0, opacity * 1.8 + 0.15));
    }

    canvas.drawPath(outlinePath, strokePaint);
  }

  void _paintFloatingBars(Canvas canvas, Size size, Paint paint) {
    final barCount = values.length;
    if (barCount == 0) return;
    final totalGap = gap * (barCount - 1);
    final barWidth = math.max(0.5, (size.width - totalGap) / barCount);

    final now = DateTime.now().millisecondsSinceEpoch;
    final dt = _lastCapTimestamp == 0 ? 0.016 : math.min(0.1, (now - _lastCapTimestamp) / 1000.0);
    _lastCapTimestamp = now;

    if (_peakCaps.length != barCount) {
      _peakCaps = List<double>.filled(barCount, 0.0);
    }

    final dropPerSec = size.height * capDropSpeed;
    final dropAmount = dropPerSec * dt;

    final capPaint = Paint()..style = PaintingStyle.fill;
    if (useGradient && startColor != null && endColor != null) {
      capPaint.shader = _getOrCreateShader(size);
    } else {
      capPaint.color = color.withValues(alpha: math.min(1.0, opacity * 2.0 + 0.2));
    }

    final barsPath = Path();
    final capsPath = Path();

    for (var i = 0; i < barCount; i++) {
      final barHeight = values[i] * size.height * 0.5;
      final x = i * (barWidth + gap);
      final y = size.height - barHeight;

      // Update peak cap with gravity drop
      double currentCap = math.max(barHeight, _peakCaps[i] - dropAmount);
      _peakCaps[i] = currentCap;

      // Draw bottom bar
      if (barHeight > 0.5) {
        barsPath.addRRect(
          RRect.fromRectXY(
            Rect.fromLTWH(x, y, barWidth, barHeight),
            2.0,
            2.0,
          ),
        );
      }

      // Draw floating cap
      final capY = size.height - currentCap - 3.5;
      if (capY >= 0 && capY <= size.height) {
        capsPath.addRRect(
          RRect.fromRectXY(
            Rect.fromLTWH(x, capY, barWidth, 2.5),
            1.5,
            1.5,
          ),
        );
      }
    }

    canvas.drawPath(barsPath, paint);
    canvas.drawPath(capsPath, capPaint);
  }

  void _paintRadial(Canvas canvas, Size size, Paint paint) {
    final barCount = values.length;
    if (barCount == 0) return;

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final minDimension = math.min(size.width, size.height);
    final maxAllowedOuterRadius = minDimension * 0.5;

    final baseRadius = minDimension * 0.16;
    final maxBassPulse = minDimension * 0.05;
    const ringPadding = 4.0;
    final maxBarLength = math.max(
      10.0,
      maxAllowedOuterRadius - (baseRadius + maxBassPulse + ringPadding),
    );

    // Calculate low-frequency bass energy to pulsate the inner ring
    double bassSum = 0;
    final bassCount = math.min(8, barCount);
    for (int i = 0; i < bassCount; i++) {
      bassSum += values[i];
    }
    final bassRatio = (bassSum / bassCount).clamp(0.0, 1.0);
    final bassPulse = bassRatio * maxBassPulse;
    final pulsingRadius = baseRadius + bassPulse;

    // Draw inner subtle ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    if (useGradient && startColor != null && endColor != null) {
      ringPaint.shader = _getOrCreateShader(size);
    } else {
      ringPaint.color = color.withValues(alpha: (opacity * 0.6).clamp(0.05, 0.4));
    }
    canvas.drawCircle(center, pulsingRadius, ringPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final barStrokeWidth =
        ((2 * math.pi * pulsingRadius) / barCount * 0.7).clamp(1.5, 6.0);
    linePaint.strokeWidth = barStrokeWidth;

    if (useGradient && startColor != null && endColor != null) {
      linePaint.shader = _getOrCreateShader(size);
    } else {
      linePaint.color = color.withValues(alpha: opacity);
    }

    final totalBars = barCount;
    final halfCount = totalBars / 2.0;

    // Precompute / reuse trigonometric lookup tables
    if (_cachedRadialBarCount != totalBars) {
      _cachedRadialBarCount = totalBars;
      final cosTable = List<double>.filled(totalBars, 0.0);
      final sinTable = List<double>.filled(totalBars, 0.0);
      for (int i = 0; i < totalBars; i++) {
        final angle = (i / totalBars) * 2 * math.pi - (math.pi / 2);
        cosTable[i] = math.cos(angle);
        sinTable[i] = math.sin(angle);
      }
      _cachedCosTable = cosTable;
      _cachedSinTable = sinTable;
    }

    final linesPath = Path();
    for (int i = 0; i < totalBars; i++) {
      // Symmetrical distribution: distance from top (-pi/2) normalized from 0.0 to 1.0
      final distFromTop = (i <= halfCount)
          ? (i / halfCount)
          : ((totalBars - i) / halfCount);

      // Low frequencies at bottom (distFromTop = 1.0) or top (distFromTop = 0.0)
      final samplePos = ((1.0 - distFromTop) * (barCount - 1))
          .clamp(0.0, (barCount - 1).toDouble());
      final idx0 = samplePos.floor();
      final idx1 = math.min(barCount - 1, idx0 + 1);
      final fract = samplePos - idx0;
      final rawVal = values[idx0] * (1.0 - fract) + values[idx1] * fract;

      // High-frequency energy compensation with smooth exponential saturation
      // to avoid flat cutoffs/truncation at high amplitudes.
      final freqRatio = (samplePos / (barCount - 1)).clamp(0.0, 1.0);
      final boost = 1.0 + math.pow(freqRatio, 0.5) * 1.5;
      final x = math.max(0.0, rawVal * boost);
      final compressed = 1.0 - math.exp(-x * 1.2);

      final len = math.max(2.0, compressed * maxBarLength);

      final cosA = _cachedCosTable[i];
      final sinA = _cachedSinTable[i];

      final innerR = pulsingRadius + ringPadding;
      final outerR = innerR + len;

      linesPath.moveTo(center.dx + cosA * innerR, center.dy + sinA * innerR);
      linesPath.lineTo(center.dx + cosA * outerR, center.dy + sinA * outerR);
    }

    canvas.drawPath(linesPath, linePaint);
  }

  void _paintMatrix(Canvas canvas, Size size, Paint paint) {
    final barCount = values.length;
    if (barCount == 0) return;
    final totalGap = gap * (barCount - 1);
    final barWidth = math.max(1.0, (size.width - totalGap) / barCount);

    final dotHeight = math.max(2.5, math.min(barWidth, 6.0));
    const dotGap = 2.5;
    final maxAvailableHeight = size.height * 0.5;
    final maxDots =
        math.max(1, (maxAvailableHeight / (dotHeight + dotGap)).floor());

    final matrixPath = Path();
    for (var i = 0; i < barCount; i++) {
      final activeCount = (values[i] * maxDots).round();
      if (activeCount <= 0) continue;
      final x = i * (barWidth + gap);

      for (int d = 0; d < activeCount; d++) {
        final y = size.height - (d + 1) * (dotHeight + dotGap);
        matrixPath.addRRect(
          RRect.fromRectXY(
            Rect.fromLTWH(x, y, barWidth, dotHeight),
            1.5,
            1.5,
          ),
        );
      }
    }
    canvas.drawPath(matrixPath, paint);
  }

  void _paintMirroredWave(Canvas canvas, Size size, Paint paint) {
    final count = values.length;
    if (count < 2) return;

    final centerY = size.height * 0.5;
    final topPoints = <Offset>[];
    final bottomPoints = <Offset>[];

    for (int i = 0; i < count; i++) {
      final x = i * (size.width / (count - 1));
      final halfH =
          (values[i] * size.height * 0.35).clamp(1.5, size.height * 0.45);
      topPoints.add(Offset(x, centerY - halfH));
      bottomPoints.add(Offset(x, centerY + halfH));
    }

    final wavePath = Path();
    wavePath.moveTo(topPoints.first.dx, topPoints.first.dy);

    final topOutline = Path();
    topOutline.moveTo(topPoints.first.dx, topPoints.first.dy);

    // Top curve forward (compute cubic control points once for both fill and outline)
    for (int i = 0; i < topPoints.length - 1; i++) {
      final p0 = i > 0 ? topPoints[i - 1] : topPoints[i];
      final p1 = topPoints[i];
      final p2 = topPoints[i + 1];
      final p3 = i + 2 < topPoints.length ? topPoints[i + 2] : p2;

      final cp1x = p1.dx + (p2.dx - p0.dx) / 6.0;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6.0;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6.0;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6.0;

      wavePath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
      topOutline.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    wavePath.lineTo(bottomPoints.last.dx, bottomPoints.last.dy);

    final bottomOutline = Path();
    bottomOutline.moveTo(bottomPoints.last.dx, bottomPoints.last.dy);

    // Bottom curve backward (compute cubic control points once for both fill and outline)
    for (int i = bottomPoints.length - 1; i > 0; i--) {
      final p0 =
          i < bottomPoints.length - 1 ? bottomPoints[i + 1] : bottomPoints[i];
      final p1 = bottomPoints[i];
      final p2 = bottomPoints[i - 1];
      final p3 = i - 2 >= 0 ? bottomPoints[i - 2] : p2;

      final cp1x = p1.dx + (p2.dx - p0.dx) / 6.0;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6.0;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6.0;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6.0;

      wavePath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
      bottomOutline.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    wavePath.close();
    canvas.drawPath(wavePath, paint);

    // Draw subtle outline highlights
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    if (useGradient && startColor != null && endColor != null) {
      strokePaint.shader = _getOrCreateShader(size);
    } else {
      strokePaint.color =
          color.withValues(alpha: math.min(1.0, opacity * 1.8 + 0.15));
    }

    canvas.drawPath(topOutline, strokePaint);
    canvas.drawPath(bottomOutline, strokePaint);
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
