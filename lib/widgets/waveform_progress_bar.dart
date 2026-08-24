import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';

class WaveformProgressBar extends ConsumerStatefulWidget {
  final List<double> waveform;
  final double progress;
  final Duration duration;
  final bool isPlaying;
  final Function(double) onSeek;
  final Function(double) onScrubbing;
  final Color activeColor;
  final Color inactiveColor;
  final bool isScrolling;
  final double height;
  final bool showTooltip;
  final double? barWidth;
  final double? barGap;
  final bool isWindowMinimized;
  final bool isTransitioning;

  const WaveformProgressBar({
    super.key,
    required this.waveform,
    required this.progress,
    required this.duration,
    this.isPlaying = false,
    required this.onSeek,
    required this.onScrubbing,
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.white24,
    this.isScrolling = true,
    this.height = 80,
    this.showTooltip = true,
    this.barWidth,
    this.barGap,
    this.isWindowMinimized = false,
    this.isTransitioning = false,
  });

  @override
  ConsumerState<WaveformProgressBar> createState() => _WaveformProgressBarState();
}

class _WaveformProgressBarState extends ConsumerState<WaveformProgressBar> with TickerProviderStateMixin, WidgetsBindingObserver {
  double? _hoverProgress;
  double _dragStartX = 0;
  double _dragStartProgress = 0;

  late AnimationController _animationController;
  late List<double> _animatedWaveform;
  List<double> _sourceWaveform = [];
  List<double> _targetWaveform = [];

  // Smooth progress states
  late double _smoothProgress;
  Ticker? _ticker;
  Duration? _lastFrameTime;
  bool _isDragging = false;
  bool _suspendedForBackground = false;

  // Double speed fast forward states
  bool _isDoubleSpeedLocked = false;
  bool _isDoubleSpeedActive = false;
  Offset? _longPressStartOffset;
  double _originalSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animatedWaveform = _getEffectiveWaveform(widget.waveform);
    _targetWaveform = List.from(_animatedWaveform);
    _sourceWaveform = List.from(_animatedWaveform);

    _animationController.addListener(() {
      setState(() {
        _updateAnimatedWaveform();
      });
    });

    _smoothProgress = widget.progress.clamp(0.0, 1.0);
    _ticker = createTicker(_onTick);
    _updateTickerState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _ticker?.dispose();
    if (_isDoubleSpeedActive || _isDoubleSpeedLocked) {
      try {
        ref.read(audioServiceProvider).setPlaybackSpeed(_originalSpeed);
      } catch (_) {}
    }
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    final Duration delta = _lastFrameTime != null ? elapsed - _lastFrameTime! : Duration.zero;
    _lastFrameTime = elapsed;

    if (_isDragging) {
      if (_smoothProgress != widget.progress) {
        setState(() {
          _smoothProgress = widget.progress.clamp(0.0, 1.0);
        });
      }
      return;
    }

    if (widget.isPlaying && widget.duration.inMicroseconds > 0) {
      final double deltaProgress = delta.inMicroseconds / widget.duration.inMicroseconds;
      double newProgress = _smoothProgress + deltaProgress;

      // Gently nudge towards the target progress to correct any time drift
      newProgress = lerpDouble(newProgress, widget.progress, 0.05) ?? newProgress;

      setState(() {
        _smoothProgress = newProgress.clamp(0.0, 1.0);
      });
    } else {
      if (_smoothProgress != widget.progress) {
        setState(() {
          _smoothProgress = widget.progress.clamp(0.0, 1.0);
        });
      }
    }
  }

  void _updateTickerState() {
    if (widget.isPlaying &&
        !_isDragging &&
        !_suspendedForBackground &&
        !widget.isWindowMinimized &&
        !widget.isTransitioning) {
      if (!_ticker!.isActive) {
        _lastFrameTime = null;
        _ticker!.start();
      }
    } else {
      if (_ticker!.isActive) {
        _ticker!.stop();
        _lastFrameTime = null;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      if (!_suspendedForBackground) {
        _suspendedForBackground = true;
        _updateTickerState();
      }
    } else if (state == AppLifecycleState.resumed || state == AppLifecycleState.inactive) {
      if (_suspendedForBackground) {
        _suspendedForBackground = false;
        _updateTickerState();
      }
    }
  }

  List<double> _getEffectiveWaveform(List<double> original) {
    if (original.isEmpty) {
      // 默认提供100个点的全0波形，使其显示为基础高度的平齐状态
      return List.filled(100, 0.0);
    }
    return original;
  }

  void _updateAnimatedWaveform() {
    final double t = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ).value;

    if (_sourceWaveform.length == _targetWaveform.length) {
      final List<double> newList = List.filled(_sourceWaveform.length, 0.0);
      for (int i = 0; i < _sourceWaveform.length; i++) {
        newList[i] = lerpDouble(_sourceWaveform[i], _targetWaveform[i], t) ?? 0.0;
      }
      _animatedWaveform = newList;
    }
  }

  List<double> _resizeWaveform(List<double> source, int newLength) {
    if (source.isEmpty) return List.filled(newLength, 0.0);
    if (source.length == newLength) return List.from(source);

    final List<double> result = List.filled(newLength, 0.0);
    for (int i = 0; i < newLength; i++) {
      double sourceIdx = i * (source.length - 1) / (math.max(1, newLength - 1));
      int idx1 = sourceIdx.floor();
      int idx2 = sourceIdx.ceil();
      double t = sourceIdx - idx1;
      result[i] = lerpDouble(source[idx1], source[idx2], t) ?? 0.0;
    }
    return result;
  }

  @override
  void didUpdateWidget(WaveformProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.waveform, oldWidget.waveform)) {
      _targetWaveform = _getEffectiveWaveform(widget.waveform);
      
      // 如果长度不一致，先将当前波形缩放到目标长度，以便进行逐点插值动画
      _sourceWaveform = _resizeWaveform(_animatedWaveform, _targetWaveform.length);
      _animatedWaveform = List.from(_sourceWaveform);
      
      _animationController.forward(from: 0);
    }

    // Check if progress or play state changed
    final double diff = (widget.progress - _smoothProgress).abs();
    final double snapThreshold = widget.duration.inMilliseconds > 0
        ? 1000.0 / widget.duration.inMilliseconds
        : 0.01;

    // Snap immediately on large leaps (seeks/song changes) or when not playing or when transitioning ended
    if (!widget.isTransitioning && (diff > snapThreshold || !widget.isPlaying || _isDragging)) {
      _smoothProgress = widget.progress.clamp(0.0, 1.0);
    } else if (oldWidget.isTransitioning && !widget.isTransitioning) {
      _smoothProgress = widget.progress.clamp(0.0, 1.0);
    }

    _updateTickerState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        // 缩放因子：决定波形的“宽度”。这里我们让每个波形点占据一定的像素宽度
        // 如果是滚动模式，我们让波形更宽一些，超出屏幕
        final double defaultBarWidth = widget.isScrolling ? 7.0 : (width / math.max(1, _animatedWaveform.length));
        final double defaultBarGap = widget.isScrolling ? 3.0 : 0.0;
        final double barWidth = widget.barWidth ?? defaultBarWidth;
        final double barGap = widget.barGap ?? defaultBarGap;
        final double totalBarWidth = barWidth + barGap;
        final double totalWaveformWidth = _animatedWaveform.length * totalBarWidth;

        return MouseRegion(
          onHover: (event) {
            if (!widget.isScrolling) {
              setState(() {
                _hoverProgress = (event.localPosition.dx / width).clamp(0.0, 1.0);
              });
            }
          },
          onExit: (event) {
            setState(() {
              _hoverProgress = null;
            });
          },
          child: GestureDetector(
            onHorizontalDragStart: (details) {
              setState(() {
                _isDragging = true;
                _dragStartX = details.localPosition.dx;
                _dragStartProgress = widget.progress;
                _smoothProgress = widget.progress.clamp(0.0, 1.0);
              });
              _updateTickerState();
            },
            onHorizontalDragUpdate: (details) {
              final double deltaX = details.localPosition.dx - _dragStartX;
              double newProgress;
              
              if (widget.isScrolling) {
                // 滚动模式下，拖动是“移动波形”
                // 移动的距离 deltaX 对应的进度变化是 deltaX / totalWaveformWidth
                // 向右拖动（deltaX > 0）意味着波形向右移，即播放进度减少
                newProgress = (_dragStartProgress - (deltaX / totalWaveformWidth)).clamp(0.0, 1.0);
              } else {
                newProgress = (details.localPosition.dx / width).clamp(0.0, 1.0);
              }
              
              widget.onScrubbing(newProgress);
              setState(() {
                _smoothProgress = newProgress;
                if (!widget.isScrolling) {
                  _hoverProgress = newProgress;
                }
              });
            },
            onHorizontalDragEnd: (details) {
              widget.onSeek(widget.progress);
              setState(() {
                _isDragging = false;
                _hoverProgress = null;
              });
              _updateTickerState();
            },
            onTapDown: (details) {
              if (!widget.isScrolling) {
                final double newProgress = (details.localPosition.dx / width).clamp(0.0, 1.0);
                widget.onScrubbing(newProgress);
                widget.onSeek(newProgress);
                setState(() {
                  _smoothProgress = newProgress;
                });
              }
            },
            onLongPressStart: (details) {
              if (!ref.read(settingsServiceProvider).enableWaveformLongPressSeek) return;
              if (details.localPosition.dx > width / 2) {
                final audioService = ref.read(audioServiceProvider);
                if (!_isDoubleSpeedLocked) {
                  _originalSpeed = ref.read(audioServiceStateProvider).playbackSpeed;
                  audioService.setPlaybackSpeed(
                    ref.read(settingsServiceProvider).waveformLongPressSeekSpeed,
                  );
                  setState(() {
                    _isDoubleSpeedActive = true;
                    _longPressStartOffset = details.localPosition;
                  });
                  showToast(AppLocalizations.of(context)!.doubleSpeedPlayingSwipeUpToLock, dismissOtherToast: true);
                } else {
                  setState(() {
                    _isDoubleSpeedActive = true;
                    _longPressStartOffset = details.localPosition;
                  });
                  showToast(AppLocalizations.of(context)!.doubleSpeedLockedSwipeDownToUnlock, dismissOtherToast: true);
                }
              }
            },
            onLongPressMoveUpdate: (details) {
              if (!_isDoubleSpeedActive || _longPressStartOffset == null) return;
              final double deltaY = details.localPosition.dy - _longPressStartOffset!.dy;
              if (!_isDoubleSpeedLocked) {
                if (deltaY < -30) {
                  setState(() {
                    _isDoubleSpeedLocked = true;
                    _longPressStartOffset = details.localPosition;
                  });
                  showToast(AppLocalizations.of(context)!.doubleSpeedLockedSwipeDownToUnlock, dismissOtherToast: true);
                }
              } else {
                if (deltaY > 30) {
                  final audioService = ref.read(audioServiceProvider);
                  audioService.setPlaybackSpeed(_originalSpeed);
                  setState(() {
                    _isDoubleSpeedLocked = false;
                    _isDoubleSpeedActive = false;
                    _longPressStartOffset = null;
                  });
                  showToast(AppLocalizations.of(context)!.doubleSpeedUnlocked, dismissOtherToast: true);
                }
              }
            },
            onLongPressEnd: (details) {
              if (_isDoubleSpeedActive) {
                if (!_isDoubleSpeedLocked) {
                  final audioService = ref.read(audioServiceProvider);
                  audioService.setPlaybackSpeed(_originalSpeed);
                }
                setState(() {
                  _isDoubleSpeedActive = false;
                  _longPressStartOffset = null;
                });
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 波形显示区
                ClipRect(
                  child: SizedBox(
                    height: widget.height,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 波形显示
                        RepaintBoundary(
                          child: CustomPaint(
                            size: Size(width, widget.height),
                            painter: WaveformPainter(
                              waveform: _animatedWaveform,
                              progress: _smoothProgress,
                              activeColor: widget.activeColor,
                              inactiveColor: widget.inactiveColor,
                              isScrolling: widget.isScrolling,
                              barWidth: barWidth,
                              barGap: barGap,
                            ),
                          ),
                        ),
                        
                        if (widget.showTooltip && _hoverProgress != null)
                          Positioned(
                            left: _hoverProgress! * width,
                            top: 10,
                            bottom: 10,
                            child: Container(
                              width: 2,
                              color: widget.activeColor.withValues(alpha: 0.3),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveform;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final bool isScrolling;
  final double barWidth;
  final double barGap;

  WaveformPainter({
    required this.waveform,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.isScrolling,
    required this.barWidth,
    required this.barGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveform.isEmpty) return;

    final double centerY = size.height / 2;
    final double maxBarHeight = size.height * 0.9;
    final double totalBarWidth = barWidth + barGap;
    
    // 计算当前进度对应的索引（浮点数，用于精确偏移）
    final double currentIdx = progress * (waveform.length - 1);
    
    // 绘制区域的中心 X (播放头位置)
    final double centerX = isScrolling ? size.width / 2 : size.width * progress;

    // 1. 绘制底色层 (全量绘制未激活颜色)
    _drawWaveformLayer(
      canvas,
      size,
      centerY,
      maxBarHeight,
      totalBarWidth,
      currentIdx,
      inactiveColor,
    );

    // 2. 绘制激活层 (使用裁剪实现像素级颜色平滑过渡，并通过 maxExclusiveX 限制绘制的索引范围)
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, centerX, size.height));
    _drawWaveformLayer(
      canvas,
      size,
      centerY,
      maxBarHeight,
      totalBarWidth,
      currentIdx,
      activeColor,
      maxExclusiveX: centerX,
    );
    canvas.restore();
  }

  void _drawWaveformLayer(
    Canvas canvas,
    Size size,
    double centerY,
    double maxBarHeight,
    double totalBarWidth,
    double currentIdx,
    Color color, {
    double? maxExclusiveX,
  }) {
    final double viewCenterX = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final double stepWidth = isScrolling ? totalBarWidth : (size.width / math.max(1, waveform.length));

    // 计算起点与终点索引，仅绘制屏幕内可见的波形条
    int startIndex = 0;
    int endIndex = waveform.length;

    if (isScrolling) {
      final double startFloat = currentIdx - (viewCenterX + barWidth) / stepWidth;
      startIndex = math.max(0, startFloat.floor());

      final double endFloat = currentIdx + (size.width - viewCenterX) / stepWidth;
      endIndex = math.min(waveform.length, endFloat.ceil() + 1);

      if (maxExclusiveX != null) {
        // 在滚动模式下，播放头 centerX 就是 viewCenterX
        // 任何 x > viewCenterX 的波形条都不需要被激活层绘制
        // viewCenterX + (i - currentIdx) * stepWidth <= viewCenterX  =>  i <= currentIdx
        endIndex = math.min(endIndex, currentIdx.ceil() + 1);
      }
    } else {
      if (maxExclusiveX != null) {
        // x = i * stepWidth <= maxExclusiveX
        // => i <= maxExclusiveX / stepWidth
        final double maxIndexFloat = maxExclusiveX / stepWidth;
        endIndex = math.min(endIndex, maxIndexFloat.ceil() + 1);
      }
    }

    for (int i = startIndex; i < endIndex; i++) {
      double x;
      if (isScrolling) {
        x = viewCenterX + (i - currentIdx) * stepWidth;
      } else {
        x = i * stepWidth;
      }

      if (x + barWidth < 0 || x > size.width) continue;
      if (maxExclusiveX != null && x > maxExclusiveX) continue;

      final double barHeight = math.max(barWidth, waveform[i] * maxBarHeight);
      final double y = centerY - barHeight / 2;

      final RRect rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        Radius.circular(barWidth / 2),
      );
      
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return !listEquals(oldDelegate.waveform, waveform) ||
        oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.isScrolling != isScrolling;
  }
}
