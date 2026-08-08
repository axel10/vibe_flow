import 'dart:ui' show ImageFilter;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class VolumeSliderOverlay extends StatelessWidget {
  const VolumeSliderOverlay({
    super.key,
    required this.volume,
    this.isMuted = false,
    this.onToggleMute,
    required this.onVolumeChanged,
    required this.onDismiss,
    required this.isLandscape,
    required this.getVolumeIcon,
    required this.onDrag,
    required this.onScroll,
    required this.onInteraction,
  });

  final double volume;
  final bool isMuted;
  final VoidCallback? onToggleMute;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onDismiss;
  final bool isLandscape;
  final IconData Function(double) getVolumeIcon;
  final void Function(double) onDrag;
  final void Function(double) onScroll;
  final VoidCallback onInteraction;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDismiss,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: isLandscape ? 100 : 160),
                  child: GestureDetector(
                    onTap: () {}, // Prevent dismissal
                    child: Container(
                      width: 280,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Content and background blur (clipped)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                child: Container(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final width = constraints.maxWidth;
                                      final height = constraints.maxHeight;

                                      final percent = isMuted ? 0.0 : (volume / 100.0).clamp(0.0, 1.0);
                                      final fillWidth = percent * width;

                                      Widget buildContent({required Color color}) {
                                        return SizedBox(
                                          width: width,
                                          height: height,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                GestureDetector(
                                                  behavior: HitTestBehavior.opaque,
                                                  onTap: () {
                                                    onInteraction();
                                                    onToggleMute?.call();
                                                  },
                                                  child: Icon(
                                                    isMuted ? Icons.volume_off : getVolumeIcon(volume),
                                                    color: color,
                                                    size: 20,
                                                  ),
                                                ),
                                                Text(
                                                  isMuted ? '0%' : '${volume.round()}%',
                                                  style: TextStyle(
                                                    color: color,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      return Listener(
                                        onPointerSignal: (pointerSignal) {
                                          if (pointerSignal is PointerScrollEvent) {
                                            onInteraction();
                                            onScroll(pointerSignal.scrollDelta.dy);
                                          }
                                        },
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onHorizontalDragUpdate: (details) {
                                            onInteraction();
                                            final box = context.findRenderObject() as RenderBox;
                                            final localPos = box.globalToLocal(details.globalPosition);
                                            final nextPercent = (localPos.dx / width).clamp(0.0, 1.0);
                                            onVolumeChanged(nextPercent * 100.0);
                                          },
                                          onVerticalDragUpdate: (details) {
                                            onInteraction();
                                            onDrag(details.primaryDelta ?? 0);
                                          },
                                          onTapDown: (details) {
                                            onInteraction();
                                            final box = context.findRenderObject() as RenderBox;
                                            final localPos = box.globalToLocal(details.globalPosition);
                                            if (localPos.dx < 48 && onToggleMute != null) {
                                              onToggleMute!();
                                            } else {
                                              final nextPercent = (localPos.dx / width).clamp(0.0, 1.0);
                                              onVolumeChanged(nextPercent * 100.0);
                                            }
                                          },
                                          child: Stack(
                                            children: [
                                              // Active Fill
                                              Container(
                                                width: fillWidth,
                                                height: height,
                                                color: Colors.white,
                                              ),

                                              // Base content (shown on unfilled area, using white70 or black87)
                                              buildContent(
                                                color: Colors.white,
                                              ),

                                              // Masked content (shown on filled area, using black87)
                                              ClipRect(
                                                clipper: _VolumeRectClipper(fillWidth),
                                                child: buildContent(
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Border Overlay (placed outside ClipRRect so it's not clipped)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VolumeRectClipper extends CustomClipper<Rect> {
  final double width;
  _VolumeRectClipper(this.width);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, width, size.height);
  }

  @override
  bool shouldReclip(_VolumeRectClipper oldClipper) {
    return oldClipper.width != width;
  }
}


class VolumeHUD extends StatelessWidget {
  const VolumeHUD({super.key, required this.volume, this.isMuted = false});

  final double volume;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Material(
          type: MaterialType.transparency,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isMuted ? Icons.volume_off : (volume > 0 ? Icons.volume_up : Icons.volume_off),
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.volume,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      isMuted ? '0%' : '${volume.round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
