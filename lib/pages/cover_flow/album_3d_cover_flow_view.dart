import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/models/album_summary.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/song_thumbnail.dart';
import 'album_cover_flow_quick_detail_dialog.dart';

class Album3DCoverFlowView extends ConsumerStatefulWidget {
  const Album3DCoverFlowView({
    super.key,
    required this.albums,
    this.initialIndex = 0,
    required this.isSelectionMode,
    required this.selectedAlbumIds,
    required this.bottomOffset,
    this.isHeroEnabled = true,
    required this.onToggleSelection,
    required this.onEnterSelectionMode,
    this.onExit3DView,
    this.onAlbumContextMenu,
  });

  final List<AlbumSummary> albums;
  final int initialIndex;
  final bool isSelectionMode;
  final Set<String> selectedAlbumIds;
  final double bottomOffset;
  final bool isHeroEnabled;
  final ValueChanged<String> onToggleSelection;
  final ValueChanged<String> onEnterSelectionMode;
  final VoidCallback? onExit3DView;
  final ValueChanged<AlbumSummary>? onAlbumContextMenu;

  @override
  ConsumerState<Album3DCoverFlowView> createState() =>
      Album3DCoverFlowViewState();
}

class Album3DCoverFlowViewState extends ConsumerState<Album3DCoverFlowView>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _shuffleAnimController;
  Animation<double>? _animation;
  late double _currentPage;
  late int _targetIndex;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final validIndex = widget.initialIndex.clamp(
      0,
      widget.albums.isNotEmpty ? widget.albums.length - 1 : 0,
    );
    _currentPage = validIndex.toDouble();
    _targetIndex = validIndex;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shuffleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void didUpdateWidget(covariant Album3DCoverFlowView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.albums.isEmpty) {
      _currentPage = 0.0;
      _targetIndex = 0;
    } else if (oldWidget.albums != widget.albums) {
      final oldIndex = _currentPage.round().clamp(
        0,
        oldWidget.albums.isNotEmpty ? oldWidget.albums.length - 1 : 0,
      );
      final oldAlbumId = oldWidget.albums.isNotEmpty ? oldWidget.albums[oldIndex].id : null;
      if (oldAlbumId != null) {
        final newIndex = widget.albums.indexWhere((a) => a.id == oldAlbumId);
        if (newIndex != -1) {
          _currentPage = newIndex.toDouble();
          _targetIndex = newIndex;
        } else if (_targetIndex >= widget.albums.length) {
          _targetIndex = widget.albums.length - 1;
          _currentPage = _targetIndex.toDouble();
        }
      }
    } else if (_targetIndex >= widget.albums.length) {
      _targetIndex = widget.albums.length - 1;
      _animateToPage(_targetIndex);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _shuffleAnimController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void animateShuffle(VoidCallback onMidpoint) {
    if (_shuffleAnimController.isAnimating) return;

    _animController.stop();

    final activeIndex = _currentPage.round().clamp(0, widget.albums.length - 1);
    final activeAlbumId = widget.albums.isNotEmpty ? widget.albums[activeIndex].id : null;

    bool midpointCalled = false;
    void listener() {
      if (mounted) {
        setState(() {});
      }
      if (!midpointCalled && _shuffleAnimController.value >= 0.45) {
        midpointCalled = true;
        onMidpoint();
        if (activeAlbumId != null && widget.albums.isNotEmpty) {
          final newIndex = widget.albums.indexWhere((a) => a.id == activeAlbumId);
          if (newIndex != -1) {
            _currentPage = newIndex.toDouble();
            _targetIndex = newIndex;
          } else {
            _currentPage = _currentPage.clamp(0.0, (widget.albums.length - 1).toDouble());
            _targetIndex = _currentPage.round();
          }
        }
      }
    }

    _shuffleAnimController.reset();
    _shuffleAnimController.addListener(listener);

    _shuffleAnimController.forward().then((_) {
      _shuffleAnimController.removeListener(listener);
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _animateToPage(int pageIndex, {Duration duration = const Duration(milliseconds: 350)}) {
    if (widget.albums.isEmpty) return;
    final clamped = pageIndex.clamp(0, widget.albums.length - 1);
    final target = clamped.toDouble();
    _targetIndex = clamped;

    if (_currentPage == target) return;

    _animController.stop();
    final startPage = _currentPage;
    _animController.duration = duration;
    _animation = Tween<double>(begin: startPage, end: target).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {
          _currentPage = _animation!.value;
        });
      });

    _animController.reset();
    _animController.forward();
  }

  void _onPointerScroll(PointerScrollEvent event) {
    if (widget.albums.isEmpty) return;
    if (event.scrollDelta.dy > 0 || event.scrollDelta.dx > 0) {
      _animateToPage(_targetIndex + 1);
    } else if (event.scrollDelta.dy < 0 || event.scrollDelta.dx < 0) {
      _animateToPage(_targetIndex - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.albums.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final activeIndex = _currentPage.round().clamp(0, widget.albums.length - 1);
    final activeAlbum = widget.albums[activeIndex];

    final isDark = theme.brightness == Brightness.dark;
    final navBtnBg = isDark ? Colors.black : Colors.white;
    final navBtnFg = isDark ? Colors.white : Colors.black;
    final navButtonStyle = IconButton.styleFrom(
      backgroundColor: navBtnBg,
      foregroundColor: navBtnFg,
      disabledBackgroundColor: navBtnBg.withValues(alpha: 0.35),
      disabledForegroundColor: navBtnFg.withValues(alpha: 0.35),
      elevation: 2,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final stageWidth = constraints.maxWidth;
        final stageHeight = constraints.maxHeight;

        final double minAvailable = math.min(100.0, math.max(0.0, stageHeight));
        final double availableHeight = (stageHeight - widget.bottomOffset).clamp(minAvailable, math.max(minAvailable, stageHeight));
        final isWide = stageWidth >= 780;
        final bool isImmersiveBottom = widget.bottomOffset <= 24.0;

        // Target cover size dynamically scaling with available viewport dimensions
        double targetCoverSize;
        if (isWide && isImmersiveBottom) {
          // On desktop / wide immersive view: scale smoothly from 220 up to 360 when space is ample
          targetCoverSize = (availableHeight * 0.42).clamp(220.0, 360.0);
        } else if (isWide) {
          targetCoverSize = (availableHeight * 0.38).clamp(200.0, 310.0);
        } else if (isImmersiveBottom) {
          targetCoverSize = (availableHeight * 0.38).clamp(180.0, 270.0);
        } else {
          targetCoverSize = (availableHeight * 0.35).clamp(160.0, 240.0);
        }

        final double maxCoverByWidth = stageWidth * (isWide ? 0.35 : 0.65);
        final double maxCoverRatio = isImmersiveBottom
            ? (availableHeight < 440.0 ? 0.46 : 0.50)
            : (availableHeight < 420.0 ? 0.34 : (availableHeight < 550.0 ? 0.38 : 0.44));
        final double maxAllowedCover = math.min(maxCoverByWidth, math.max(80.0, availableHeight * maxCoverRatio));
        final double minAllowedCover = math.min(130.0, maxAllowedCover);
        final double coverSize = targetCoverSize.clamp(minAllowedCover, maxAllowedCover);

        final double shuffleVal = _shuffleAnimController.value;
        double gatherFactor = 0.0;
        if (_shuffleAnimController.isAnimating || shuffleVal > 0) {
          if (shuffleVal <= 0.45) {
            final progress = (shuffleVal / 0.45).clamp(0.0, 1.0);
            gatherFactor = Curves.easeInOutCubic.transform(progress);
          } else if (shuffleVal <= 0.55) {
            gatherFactor = 1.0;
          } else {
            final progress = ((shuffleVal - 0.55) / 0.45).clamp(0.0, 1.0);
            gatherFactor = 1.0 - Curves.easeOutCubic.transform(progress);
          }
        }

        final int range = ((stageWidth / 2) / (coverSize * 0.44)).ceil().clamp(5, 16);
        final minIndex = (_currentPage - range).floor().clamp(0, widget.albums.length - 1);
        final maxIndex = (_currentPage + range).ceil().clamp(0, widget.albums.length - 1);

        final visibleIndices = List.generate(maxIndex - minIndex + 1, (i) => minIndex + i);
        visibleIndices.sort((a, b) {
          final distA = (a - _currentPage).abs();
          final distB = (b - _currentPage).abs();
          return distB.compareTo(distA);
        });

        final double topSafeOffset = isImmersiveBottom ? (stageWidth >= 780 ? 84.0 : 64.0) : 16.0;
        final double centerRatio = isImmersiveBottom
            ? (availableHeight < 500.0 ? 0.37 : (availableHeight < 750.0 ? 0.39 : 0.40))
            : (availableHeight < 420.0 ? 0.34 : (availableHeight < 550.0 ? 0.36 : 0.38));
        final double minY = topSafeOffset + coverSize * 0.5;
        final double maxY = math.max(minY, availableHeight * 0.46);
        final double stageCenterY = (availableHeight * centerRatio).clamp(minY, maxY);

        // Reflection bottom reaches around stageCenterY + coverSize * 0.88
        final double reflectionBottomY = stageCenterY + coverSize * 0.88;
        final double lowerAreaTop = math.min(reflectionBottomY, math.max(0.0, availableHeight - 70.0));
        final bool isCompactHeight = availableHeight < 460.0;

        return Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                _animateToPage(_targetIndex - 1);
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                _animateToPage(_targetIndex + 1);
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                if (widget.onExit3DView != null) {
                  widget.onExit3DView!();
                  return KeyEventResult.handled;
                }
              } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space) {
                if (widget.albums.isNotEmpty) {
                  showAlbumQuickDetailModal(context, ref, activeAlbum);
                  return KeyEventResult.handled;
                }
              }
            }
            return KeyEventResult.ignored;
          },
          child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                _onPointerScroll(pointerSignal);
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (_) {
                _animController.stop();
              },
              onHorizontalDragUpdate: (details) {
                final deltaPages = details.primaryDelta! / (coverSize * 0.7);
                setState(() {
                  _currentPage = (_currentPage - deltaPages)
                      .clamp(-0.5, widget.albums.length - 0.5);
                  _targetIndex = _currentPage.round().clamp(0, widget.albums.length - 1);
                });
              },
              onHorizontalDragEnd: (details) {
                int nearest = _currentPage.round().clamp(0, widget.albums.length - 1);
                final velocity = details.primaryVelocity ?? 0;
                if (velocity.abs() > 200) {
                  final step = velocity < 0 ? 1 : -1;
                  nearest = (_currentPage + step).round().clamp(0, widget.albums.length - 1);
                }
                _animateToPage(nearest);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.3),
                          radius: 0.85,
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.12),
                            theme.colorScheme.surface.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ...visibleIndices.map((i) {
                    final album = widget.albums[i];
                    final delta = i - _currentPage;
                    final absD = delta.abs();

                    final sign = delta.sign;
                    final baseGap = coverSize * 0.70;
                    final stepGap = coverSize * 0.38;
                    double xOffset = 0.0;
                    if (absD > 0) {
                      if (absD <= 1.0) {
                        xOffset = sign * (absD * baseGap);
                      } else {
                        xOffset = sign * (baseGap + (absD - 1.0) * stepGap);
                      }
                    }

                    final double distFromCenter = xOffset.abs();
                    final double stageHalfWidth = stageWidth / 2;
                    final double edgeFadeStart = stageHalfWidth - 80.0;
                    final double edgeFadeEnd = stageHalfWidth + coverSize * 0.5;

                    double opacity = (1.0 - (absD - 1.0) * 0.05).clamp(0.55, 1.0);

                    if (distFromCenter > edgeFadeEnd) {
                      opacity = 0.0;
                    } else if (distFromCenter > edgeFadeStart) {
                      final fadeProgress = ((edgeFadeEnd - distFromCenter) / (edgeFadeEnd - edgeFadeStart)).clamp(0.0, 1.0);
                      opacity *= (fadeProgress * fadeProgress);
                    }

                    if (opacity <= 0.001) {
                      return const SizedBox.shrink();
                    }

                    double rotationY = 0.0;
                    if (delta > 0) {
                      rotationY = -1.02 * delta.clamp(0.0, 1.0);
                    } else if (delta < 0) {
                      rotationY = 1.02 * (-delta).clamp(0.0, 1.0);
                    }

                    double scale = 1.0;
                    if (absD <= 1.0) {
                      scale = 1.06 - absD * 0.16;
                    } else {
                      scale = (0.90 - (absD - 1.0) * 0.08).clamp(0.58, 1.06);
                    }

                    if (gatherFactor > 0) {
                      xOffset *= (1.0 - gatherFactor);
                      rotationY *= (1.0 - gatherFactor * 0.85);
                      scale *= (1.0 - gatherFactor * 0.12);
                    }

                    final transform = Matrix4.identity()
                      ..setEntry(3, 2, -0.0009)
                      ..translate(xOffset, 0.0, 0.0)
                      ..rotateY(rotationY)
                      ..scale(scale, scale, 1.0);

                    final isSelected = widget.selectedAlbumIds.contains(album.id);

                    return Positioned(
                      left: (stageWidth - coverSize) / 2,
                      top: stageCenterY - (coverSize * 0.5),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: transform,
                        child: Opacity(
                          opacity: opacity,
                          child: GestureDetector(
                            onTap: () {
                              if (absD < 0.3) {
                                if (widget.isSelectionMode) {
                                  widget.onToggleSelection(album.id);
                                } else {
                                  showAlbumQuickDetailModal(context, ref, album);
                                }
                              } else {
                                _animateToPage(i);
                              }
                            },
                            onLongPress: () {
                              if (widget.isSelectionMode) {
                                widget.onToggleSelection(album.id);
                              } else {
                                widget.onEnterSelectionMode(album.id);
                              }
                            },
                            onSecondaryTapDown: (_) {
                              if (!widget.isSelectionMode) {
                                if (widget.onAlbumContextMenu != null) {
                                  widget.onAlbumContextMenu!(album);
                                }
                              }
                            },
                            child: Album3DCoverCard(
                              album: album,
                              coverSize: coverSize,
                              isSelected: isSelected,
                              isSelectionMode: widget.isSelectionMode,
                              isHeroEnabled: widget.isHeroEnabled,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  if (widget.albums.length > 1) ...[
                    Positioned(
                      left: 16,
                      top: stageCenterY - 24,
                      child: IconButton(
                        style: navButtonStyle,
                        onPressed: _targetIndex > 0
                            ? () => _animateToPage(_targetIndex - 1)
                            : null,
                        icon: const Icon(Icons.chevron_left_rounded, size: 28),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: stageCenterY - 24,
                      child: IconButton(
                        style: navButtonStyle,
                        onPressed: _targetIndex < widget.albums.length - 1
                            ? () => _animateToPage(_targetIndex + 1)
                            : null,
                        icon: const Icon(Icons.chevron_right_rounded, size: 28),
                      ),
                    ),
                  ],
                  Positioned(
                    left: 24,
                    right: 24,
                    top: lowerAreaTop,
                    bottom: widget.bottomOffset,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 580),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: MouseRegion(
                            key: ValueKey(activeAlbum.id),
                            cursor: widget.isSelectionMode
                                ? SystemMouseCursors.basic
                                : SystemMouseCursors.click,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (widget.isSelectionMode) {
                                  widget.onToggleSelection(activeAlbum.id);
                                } else {
                                  showAlbumQuickDetailModal(
                                    context,
                                    ref,
                                    activeAlbum,
                                  );
                                }
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    activeAlbum.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: (isCompactHeight
                                            ? theme.textTheme.titleMedium
                                            : theme.textTheme.titleLarge)
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: isCompactHeight ? 2 : 4),
                                  Text(
                                    '${activeAlbum.artist}  ·  ${l10n.songCount(activeAlbum.trackCount)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: (isCompactHeight
                                            ? theme.textTheme.bodySmall
                                            : theme.textTheme.bodyMedium)
                                        ?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Album3DCoverCard extends StatelessWidget {
  const Album3DCoverCard({
    super.key,
    required this.album,
    required this.coverSize,
    required this.isSelected,
    required this.isSelectionMode,
    this.isHeroEnabled = true,
  });

  final AlbumSummary album;
  final double coverSize;
  final bool isSelected;
  final bool isSelectionMode;
  final bool isHeroEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryAnimation = ModalRoute.of(context)?.secondaryAnimation;

    Widget reflectionWidget = SizedBox(
      width: coverSize,
      height: coverSize * 0.4,
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.38),
              Colors.black.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: ClipRect(
          child: OverflowBox(
            minWidth: coverSize,
            maxWidth: coverSize,
            minHeight: coverSize,
            maxHeight: coverSize,
            alignment: Alignment.topCenter,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(1.0, -1.0, 1.0),
              child: SongThumbnail(
                path: album.representativeSong.path,
                id: album.representativeSong.id,
                bytes: album.representativeSong.artworkBytes,
                size: coverSize,
                width: coverSize,
                height: coverSize,
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
      ),
    );

    if (secondaryAnimation != null) {
      reflectionWidget = AnimatedBuilder(
        animation: secondaryAnimation,
        builder: (context, child) {
          final progress = (1.0 - secondaryAnimation.value).clamp(0.0, 1.0);
          final opacity = const Interval(0.35, 1.0, curve: Curves.easeOutCubic).transform(progress);
          return Opacity(
            opacity: opacity,
            child: child,
          );
        },
        child: reflectionWidget,
      );
    }

    final coverBox = Container(
      width: coverSize,
      height: coverSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SongThumbnail(
              path: album.representativeSong.path,
              id: album.representativeSong.id,
              bytes: album.representativeSong.artworkBytes,
              size: coverSize,
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.zero,
            ),
            if (isSelectionMode) ...[
              Positioned.fill(
                child: Container(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
                      : Colors.black38,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? theme.colorScheme.primary : Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return SizedBox(
      width: coverSize,
      height: coverSize * 1.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isHeroEnabled
              ? Hero(
                  tag: 'album-cover-${album.id}',
                  child: coverBox,
                )
              : coverBox,
          reflectionWidget,
        ],
      ),
    );
  }
}
