import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_core/audio_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/metadata/metadata_helper.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';
import 'package:vynody/player/settings/track_artwork_theme_service.dart';
import 'package:vynody/utils/memory_trace.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vynody/widgets/playback_ui_tuning.dart';

class CoverCarousel extends StatefulWidget {
  const CoverCarousel({
    super.key,
    required this.playlist,
    required this.currentIndex,
    required this.audioService,
    this.onPageChanged,
    this.onAnimationComplete,
    this.isLandscape = false,
    this.isNext,
    this.displaySize,
    this.cacheWidthSize,
  });

  final List<MusicFile> playlist;
  final int currentIndex;
  final AudioService audioService;
  final Function(int)? onPageChanged;
  final void Function(Uint8List? artworkBytes, String? sourcePath)?
  onAnimationComplete;
  final bool isLandscape;
  final bool? isNext;
  final double? displaySize;
  final double? cacheWidthSize;

  @override
  State<CoverCarousel> createState() => _CoverCarouselState();
}

class _CoverCarouselState extends State<CoverCarousel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late int _currentPage;
  bool _isDragging = false;
  final Map<int, int> _indexOverrides = {};
  final Map<String, ({Uint8List? bytes, String? path})> _loadedCoversByPath = {};
  MusicFile? _oldSongBeforePlaylistChange;
  double? _oldPageBeforePlaylistChange;

  static const double _swipeThreshold = 0.2;
  static const double _resistanceFactor = 0.2;

  void _logCarouselTrace(String message) {
    if (!kDebugMode) return;
    // debugPrint('[CoverCarousel][Trace] $message');
  }

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: widget.currentIndex.toDouble(),
      lowerBound: -1000.5,
      upperBound: widget.playlist.length.toDouble() + 1000.5,
    );
  }

  bool _isPlaylistSame(List<MusicFile> list1, List<MusicFile> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].path != list2[i].path) return false;
    }
    return true;
  }

  @override
  void didUpdateWidget(CoverCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _logCarouselTrace(
      'didUpdateWidget currentIndex ${oldWidget.currentIndex} -> ${widget.currentIndex} '
      'currentPage=$_currentPage animValue=${_animationController.value}',
    );

    final bool playlistChanged = !_isPlaylistSame(oldWidget.playlist, widget.playlist);

    if (widget.currentIndex != oldWidget.currentIndex || playlistChanged) {
      if (playlistChanged) {
        _oldSongBeforePlaylistChange = null;
        _oldPageBeforePlaylistChange = null;
        _indexOverrides.clear();
        _currentPage = widget.currentIndex;
        _animationController.value = widget.currentIndex.toDouble();
        _notifyAnimationComplete(widget.currentIndex);
      } else if (widget.currentIndex != _currentPage) {
        final diff = (widget.currentIndex - _currentPage).abs();
        if (diff == 1) {
          _currentPage = widget.currentIndex;
          _animateToPage(widget.currentIndex);
        } else {
          _indexOverrides.clear();
          _currentPage = widget.currentIndex;
          _animationController.value = widget.currentIndex.toDouble();
          _notifyAnimationComplete(widget.currentIndex);
        }
      }
    }
  }

  void _animateToPage(
    int page, {
    double? velocity,
  }) {
    _logCarouselTrace(
      '_animateToPage page=$page velocity=$velocity '
      'currentVal=${_animationController.value} currentPage=$_currentPage',
    );
    final double currentVal = _animationController.value;
    final int targetPage = page.clamp(0, widget.playlist.length - 1);
    final double diff = targetPage - currentVal;

    if (diff == 0) {
      if (_currentPage != targetPage) {
        setState(() {
          _currentPage = targetPage;
        });
        widget.onPageChanged?.call(targetPage);
      }
      _notifyAnimationComplete(targetPage);
      return;
    }

    if (_currentPage != targetPage) {
      setState(() {
        _currentPage = targetPage;
      });
      widget.onPageChanged?.call(targetPage);
    }

    if (diff.abs() > 2.5) {
      _indexOverrides.clear();
      _animationController.value = targetPage.toDouble();
      _notifyAnimationComplete(targetPage);
      return;
    }

    _animationController
        .animateTo(
          targetPage.toDouble(),
          duration: Duration(
            milliseconds: velocity != null && velocity.abs() > 400
                ? 250
                : 350,
          ),
          curve: Curves.easeOutCubic,
        )
        .then((_) {
          if (mounted && !_isDragging) {
            _logCarouselTrace(
              '_animateToPage complete -> page=$targetPage '
              'currentVal=${_animationController.value}',
            );
            _oldSongBeforePlaylistChange = null;
            _oldPageBeforePlaylistChange = null;
            _notifyAnimationComplete(targetPage);
          }
        });
  }

  void _notifyAnimationComplete(int page) {
    if (page < 0 || page >= widget.playlist.length) return;
    final currentSong = widget.playlist[page];
    String safeDecode(String uri) {
      try {
        return Uri.decodeFull(uri);
      } catch (_) {
        return uri;
      }
    }
    final decodedCurrent = safeDecode(currentSong.path);
    final loadedEntry = _loadedCoversByPath[currentSong.path] ??
        _loadedCoversByPath[decodedCurrent] ??
        _loadedCoversByPath.entries
            .firstWhereOrNull((e) => safeDecode(e.key) == decodedCurrent)
            ?.value;
    final loadedBytes = loadedEntry?.bytes ?? currentSong.artworkBytes;
    _logCarouselTrace(
      '_notifyAnimationComplete page=$page song=${currentSong.path} '
      'loadedBytes=${loadedBytes?.length ?? 0} '
      'artBytes=${currentSong.artworkBytes?.length ?? 0} '
      'artPath=${currentSong.artworkPath ?? '-'}',
    );

    if (loadedBytes != null) {
      widget.onAnimationComplete?.call(loadedBytes, currentSong.path);
      return;
    }

    if (currentSong.artworkBytes == null && currentSong.artworkPath == null) {
      widget.onAnimationComplete?.call(null, currentSong.path);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.playlist.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          onHorizontalDragStart: (details) {
            _isDragging = true;
            if (_animationController.isAnimating) {
              _animationController.stop();
            }
          },
          onHorizontalDragUpdate: (details) {
            if (!_isDragging) return;

            final delta = details.primaryDelta ?? 0;
            double adjustedDelta = delta;

            if (delta > 0 && _animationController.value <= 0) {
              adjustedDelta *= _resistanceFactor;
            } else if (delta < 0 &&
                _animationController.value >= widget.playlist.length - 1) {
              adjustedDelta *= _resistanceFactor;
            }

            _animationController.value -= adjustedDelta / width;
          },
          onHorizontalDragEnd: (details) {
            if (!_isDragging) return;

            final velocity = details.primaryVelocity ?? 0;
            final currentVal = _animationController.value;
            int targetPage;

            if (velocity.abs() > 400) {
              if (velocity < 0) {
                targetPage = math.max(_currentPage, currentVal.floor()) + 1;
              } else {
                targetPage = math.min(_currentPage, currentVal.ceil()) - 1;
              }
            } else {
              final diff = currentVal - _currentPage;
              if (diff > _swipeThreshold) {
                targetPage = math.max(_currentPage, currentVal.floor()) + 1;
              } else if (diff < -_swipeThreshold) {
                targetPage = math.min(_currentPage, currentVal.ceil()) - 1;
              } else {
                targetPage = currentVal.round();
              }
            }

            targetPage = targetPage.clamp(0, widget.playlist.length - 1);

            _isDragging = false;
            _animateToPage(targetPage, velocity: velocity);
          },
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [..._buildItems(width)],
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildItems(double width) {
    final double value = _animationController.value;
    final int center = value.round();

    // Prune _loadedCoversByPath to release memory of non-visible/far covers
    if (_loadedCoversByPath.length > 20) {
      final activePaths = widget.playlist.map((s) => s.path).toSet();
      _loadedCoversByPath.removeWhere((path, _) => !activePaths.contains(path));
    }

    final List<int> indices = [];

    indices.add(center);
    indices.add(center - 1);
    indices.add(center + 1);

    final List<int> uniqueIndices = indices.toSet().toList();
    uniqueIndices.sort((a, b) {
      final distA = (a - value).abs();
      final distB = (b - value).abs();
      return distB.compareTo(distA);
    });

    return uniqueIndices
        .where((idx) {
          if (_oldSongBeforePlaylistChange != null &&
              _oldPageBeforePlaylistChange != null &&
              idx == _oldPageBeforePlaylistChange!.round()) {
            return true;
          }
          final actualIdx = _indexOverrides[idx] ?? idx;
          return actualIdx >= 0 && actualIdx < widget.playlist.length;
        })
        .map((index) {
          final actualIndex = _indexOverrides[index] ?? index;
          final bool isOldSongSlot = _oldSongBeforePlaylistChange != null &&
              _oldPageBeforePlaylistChange != null &&
              index == _oldPageBeforePlaylistChange!.round();
          final musicFile = isOldSongSlot
              ? _oldSongBeforePlaylistChange!
              : widget.playlist[actualIndex];
          return _CoverItem(
            key: ValueKey('track_${musicFile.path}_slot_$index'),
            audioService: widget.audioService,
            musicFile: musicFile,
            animation: _animationController,
            itemIndex: index,
            width: width,
            displaySize: widget.displaySize,
            cacheWidthSize: widget.cacheWidthSize,
            onArtworkLoaded: (bytes, path) {
              if (bytes != null) {
                _loadedCoversByPath[musicFile.path] = (bytes: bytes, path: path);
                widget.audioService.setCachedArtwork(
                  musicFile.path,
                  bytes,
                  thumbnailPath: path,
                );
              }
              _logCarouselTrace(
                'onArtworkLoaded slot=$index actual=$actualIndex '
                'path=${musicFile.path} '
                'bytes=${bytes?.length ?? 0} sourcePath=${path ?? '-'} '
                'currentIndex=${widget.currentIndex}',
              );
              // 如果是当前播放曲目的封面加载完成，且轮播动画已静止，通知背景更新
              // 否则，由 _notifyAnimationComplete 在动画结束时统一通知，以维持背景延迟切换效果
              final isSettled = (_animationController.value - index).abs() < 0.01 &&
                  !_animationController.isAnimating &&
                  !_isDragging;
              if (musicFile.path == widget.playlist[widget.currentIndex].path && bytes != null && isSettled) {
                widget.onAnimationComplete?.call(
                  bytes,
                  musicFile.path,
                );
              }
            },
          );
        })
        .toList();
  }
}

class _CoverItem extends ConsumerStatefulWidget {
  const _CoverItem({
    super.key,
    required this.audioService,
    required this.musicFile,
    required this.animation,
    required this.itemIndex,
    required this.width,
    this.displaySize,
    this.cacheWidthSize,
    this.onArtworkLoaded,
  });

  final AudioService audioService;
  final MusicFile musicFile;
  final Animation<double> animation;
  final int itemIndex;
  final double width;
  final double? displaySize;
  final double? cacheWidthSize;
  final void Function(Uint8List? bytes, String? path)? onArtworkLoaded;

  @override
  ConsumerState<_CoverItem> createState() => _CoverItemState();
}

class _CoverItemState extends ConsumerState<_CoverItem> {
  Uint8List? _artworkBytes;
  bool _isLoaded = false;
  bool _hasLoadedHighRes = false;
  Timer? _loadTimer;

  bool get _isSettled {
    final double pageOffset = widget.animation.value - widget.itemIndex;
    return pageOffset.abs() < 0.01 && !widget.animation.isAnimating;
  }

  void _handleAnimationUpdate() {
    if (!mounted) return;
    if (_isSettled && !_hasLoadedHighRes) {
      _loadHighResArtwork();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.animation.addListener(_handleAnimationUpdate);
    _loadArtwork();
  }

  @override
  void didUpdateWidget(_CoverItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeListener(_handleAnimationUpdate);
      widget.animation.addListener(_handleAnimationUpdate);
    }
    // If the path changed, we must reset everything
    if (oldWidget.musicFile.path != widget.musicFile.path) {
      _artworkBytes = null;
      _isLoaded = false;
      _hasLoadedHighRes = false;
      _loadArtwork();
    }
    // If the path is the same but artwork appeared or is currently missing, try loading again
    else if (widget.musicFile.artworkBytes != oldWidget.musicFile.artworkBytes ||
        widget.musicFile.artworkPath != oldWidget.musicFile.artworkPath ||
        widget.musicFile.thumbnailPath != oldWidget.musicFile.thumbnailPath ||
        _artworkBytes == null) {
      _loadArtwork();
    }
  }

  @override
  void dispose() {
    widget.animation.removeListener(_handleAnimationUpdate);
    _loadTimer?.cancel();
    super.dispose();
  }

  void _loadArtwork() {
    _loadTimer?.cancel();

    // Check if we can load instantly (already in cache or available)
    final cachedBytes = widget.audioService.getCachedArtwork(
      widget.musicFile.path,
    );
    final hasPriorityBytes = widget.audioService.currentMusic?.path == widget.musicFile.path &&
        widget.audioService.currentMusic?.artworkBytes != null;

    if (cachedBytes != null || hasPriorityBytes) {
      _loadArtworkAsync();
    } else {
      _loadTimer = Timer(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        _loadArtworkAsync();
      });
    }
  }

  Future<void> _loadArtworkAsync() async {
    _isLoaded = true;
    if (kDebugMode) {
      debugPrint(
        '[CoverCarousel][Trace] _loadArtworkAsync start path=${widget.musicFile.path} '
        'currentMusic=${widget.audioService.currentMusic?.path ?? '-'}',
      );
    }
    MemoryTrace.snapshot(
      'coverCarousel:loadArtwork:start',
      details: <String, Object?>{
        'path': widget.musicFile.path,
        'slot': widget.itemIndex,
      },
    );

    // 1. If we have original HD bytes in cache, use them.
    final cachedBytes = widget.audioService.getCachedArtwork(
      widget.musicFile.path,
    );
    if (cachedBytes != null) {
      if (!mounted) return;
      setState(() {
        _artworkBytes = cachedBytes;
        _hasLoadedHighRes = true;
      });
      widget.onArtworkLoaded?.call(cachedBytes, null);
      return;
    }

    // 2. If currentMusic has artworkBytes, use them.
    if (widget.audioService.currentMusic?.path == widget.musicFile.path &&
        widget.audioService.currentMusic?.artworkBytes != null) {
      if (!mounted) return;
      final bytes = widget.audioService.currentMusic!.artworkBytes!;
      setState(() {
        _artworkBytes = bytes;
        _hasLoadedHighRes = true;
      });
      widget.onArtworkLoaded?.call(bytes, null);
      return;
    }

    final bool isLowMidEnd = ref.read(isLowMidEndDeviceProvider);

    // 3. Try thumbnailPath next ONLY on Android low/mid-end devices to smooth Hero transitions
    if (isLowMidEnd) {
      final scanner = ref.read(scannerServiceProvider);
      final thumbPath = widget.musicFile.thumbnailPath ??
          scanner.metadataMap[widget.musicFile.path]?.thumbnailPath;
      if (thumbPath != null && File(thumbPath).existsSync()) {
        try {
          final bytes = await File(thumbPath).readAsBytes();
          if (!mounted) return;
          setState(() {
            _artworkBytes = bytes;
          });
          widget.onArtworkLoaded?.call(bytes, null);

          if (_isSettled) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _isSettled && !_hasLoadedHighRes) {
                _loadHighResArtwork();
              }
            });
          }
          return;
        } catch (e) {
          debugPrint('Error loading thumbnail from $thumbPath: $e');
        }
      }
    }

    // 4. On non-Android low-mid devices or if no thumbnail exists, trigger high-res load immediately
    _loadHighResArtwork();
  }

  Future<void> _loadHighResArtwork() async {
    if (_hasLoadedHighRes && _artworkBytes != null) return;
    _hasLoadedHighRes = true;

    final highResPath = widget.musicFile.artworkPath;
    if (highResPath != null && File(highResPath).existsSync()) {
      try {
        final bytes = await File(highResPath).readAsBytes();
        if (!mounted) return;
        setState(() {
          _artworkBytes = bytes;
        });
        widget.onArtworkLoaded?.call(bytes, null);
        return;
      } catch (e) {
        debugPrint('Error loading high res artwork from $highResPath: $e');
      }
    }

    // Try system query (on_audio_query)
    if (Platform.isAndroid || Platform.isIOS) {
      if (widget.musicFile.id != null) {
        var hasPermission = true;
        if (Platform.isAndroid) {
          try {
            final deviceInfo = DeviceInfoPlugin();
            final androidInfo = await deviceInfo.androidInfo;
            if (androidInfo.version.sdkInt >= 33) {
              hasPermission = await Permission.audio.isGranted;
            } else {
              hasPermission = await Permission.storage.isGranted;
            }
          } catch (_) {
            hasPermission = false;
          }
        }

        final isSystemMedia = widget.musicFile.mediaUri != null || widget.musicFile.path.startsWith('content://');

        if (hasPermission && isSystemMedia) {
          try {
            final bytes = await MetadataHelper.safeQueryArtwork(
              widget.musicFile.id!,
              size: 800,
              hasPermission: hasPermission,
            );
            if (bytes != null && bytes.isNotEmpty) {
              if (!mounted) return;
              setState(() {
                _artworkBytes = bytes;
              });
              widget.onArtworkLoaded?.call(bytes, null);

              final scanner = ref.read(scannerServiceProvider);
              final existingMeta = scanner.metadataMap[widget.musicFile.path];
              if (existingMeta?.thumbnailPath == null ||
                  existingMeta!.thumbnailPath!.isEmpty ||
                  !File(existingMeta.thumbnailPath!).existsSync()) {
                final md5Hex = await calculateMd5(bytes: bytes);
                final supportDir = await getApplicationSupportDirectory();
                final thumbnailsDir = Directory('${supportDir.path}/thumbnails');
                if (!thumbnailsDir.existsSync()) {
                  await thumbnailsDir.create(recursive: true);
                }
                final file = File('${thumbnailsDir.path}/${md5Hex}_thumb.jpg');
                if (!file.existsSync()) {
                  await file.writeAsBytes(bytes);
                }
                unawaited(scanner.updateSongThumbnailPath(widget.musicFile.path, file.path));
              }
              return;
            }
          } catch (e) {
            debugPrint('[CoverCarousel] Error querying system artwork: $e');
          }
        }
      }
    }

    // Try remote track cover loading
    if (RemoteMediaResolver.isRemoteUri(widget.musicFile.path)) {
      final thumbPath = widget.musicFile.thumbnailPath;
      if (thumbPath != null && File(thumbPath).existsSync()) {
        try {
          final bytes = await File(thumbPath).readAsBytes();
          if (!mounted) return;
          setState(() {
            _artworkBytes = bytes;
          });
          widget.onArtworkLoaded?.call(bytes, thumbPath);
          return;
        } catch (_) {}
      }

      try {
        final themeService = TrackArtworkThemeService();
        final res = await themeService.getTrackArtworkTheme(
          widget.musicFile.path,
          controller: widget.audioService.player,
        );
        if (res?.thumbnailPath != null && File(res!.thumbnailPath!).existsSync()) {
          final bytes = await File(res.thumbnailPath!).readAsBytes();
          if (!mounted) return;
          setState(() {
            _artworkBytes = bytes;
          });
          widget.onArtworkLoaded?.call(bytes, res.thumbnailPath);
          return;
        }
      } catch (e) {
        debugPrint('[CoverCarousel] Failed to load remote artwork: $e');
      }
    }

    // Try extracting embedded artwork as last resort (if file can be accessed)
    final canAccessFile =
        await MetadataHelper.canAccessAudioFile(widget.musicFile.path);
    if (canAccessFile) {
      final embeddedBytes = await MetadataHelper.decodeEmbeddedArtwork(
        widget.musicFile.path,
      );
      if (embeddedBytes != null) {
        if (!mounted) return;
        setState(() {
          _artworkBytes = embeddedBytes;
        });
        widget.onArtworkLoaded?.call(embeddedBytes, null);
        return;
      }
    }

    // Fallback: If high-res artwork failed or is missing, try thumbnailPath if present
    if (_artworkBytes == null) {
      final scanner = ref.read(scannerServiceProvider);
      final thumbPath = widget.musicFile.thumbnailPath ??
          scanner.metadataMap[widget.musicFile.path]?.thumbnailPath;
      if (thumbPath != null && File(thumbPath).existsSync()) {
        try {
          final bytes = await File(thumbPath).readAsBytes();
          if (!mounted) return;
          setState(() {
            _artworkBytes = bytes;
          });
          widget.onArtworkLoaded?.call(bytes, thumbPath);
        } catch (e) {
          debugPrint('Error loading fallback thumbnail from $thumbPath: $e');
        }
      }
    }

    if (_artworkBytes == null) {
      _hasLoadedHighRes = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        final double pageOffset = widget.animation.value - widget.itemIndex;
        final double opacity = (1 - pageOffset.abs() * 1.2).clamp(0.0, 1.0);
        final double scale = (1 - (pageOffset.abs() * 0.3)).clamp(0.8, 1.0);
        final double rotationY = pageOffset * -0.3;

        // Round translation to nearest physical pixel to avoid blurriness
        final double rawTranslateX = pageOffset * -widget.width;
        final double translateX =
            (rawTranslateX * devicePixelRatio).round() / devicePixelRatio;

        // Snapping scale to 1.0 and rotation to 0.0 when very close to 0 to ensure pixel-perfect rendering
        final bool isCentered = pageOffset.abs() < 0.001;
        final double effectiveScale = isCentered ? 1.0 : scale;
        final double effectiveRotationY = isCentered ? 0.0 : rotationY;

        // Only apply perspective if there is actual rotation
        final double perspective = effectiveRotationY != 0 ? 0.001 : 0.0;
        final bool isAnimating = widget.animation.isAnimating || !isCentered;

        return RepaintBoundary(
          child: Opacity(
            opacity: opacity,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, perspective)
                ..translateByDouble(translateX, 0, 0, 1.0)
                ..rotateY(effectiveRotationY)
                ..scaleByDouble(
                  effectiveScale,
                  effectiveScale,
                  effectiveScale,
                  1.0,
                ),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        widget.displaySize != null
                            ? math.min(24.0, widget.displaySize! * 0.2)
                            : 24.0,
                      ),
                      color: Colors.black26,
                      boxShadow: isAnimating
                          ? const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ]
                          : [
                              // Deep soft ambient shadow
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: (0.07 + 0.12 * (1 - pageOffset.abs())),
                                ),
                                blurRadius: 3 * scale,
                                spreadRadius: 2 * scale,
                                offset: Offset(0, 2 * scale),
                              ),
                              // Crisp contact shadow
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: (0.10 + 0.08 * (1 - pageOffset.abs())),
                                ),
                                blurRadius: 16 * scale,
                                spreadRadius: -4 * scale,
                                offset: Offset(0, 8 * scale),
                              ),
                            ],
                    ),
                    clipBehavior: isAnimating ? Clip.hardEdge : Clip.antiAlias,
                    child: _buildCoverImage(isCentered, isAnimating),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoverImage(bool isCentered, bool isAnimating) {
    final bool isLowMidEnd = ref.read(isLowMidEndDeviceProvider);
    final int finalCacheWidth = PlaybackArtworkTuning.calculateCoverCacheWidth(
      context,
      logicalSize: widget.cacheWidthSize,
      isLowMidEnd: isLowMidEnd,
    );

    final cachedBytes = widget.audioService.getCachedArtwork(
      widget.musicFile.path,
    );
    if (cachedBytes != null) {
      return Image.memory(
        cachedBytes,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        cacheWidth: finalCacheWidth,
        filterQuality: isCentered ? FilterQuality.low : FilterQuality.medium,
      );
    }

    if (widget.audioService.currentMusic?.path == widget.musicFile.path &&
        widget.audioService.currentMusic?.artworkBytes != null) {
      return Image.memory(
        widget.audioService.currentMusic!.artworkBytes!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        cacheWidth: finalCacheWidth,
        filterQuality: isCentered ? FilterQuality.low : FilterQuality.medium,
      );
    }

    if (_artworkBytes != null) {
      return Image.memory(
        _artworkBytes!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        cacheWidth: finalCacheWidth,
        filterQuality: isCentered ? FilterQuality.low : FilterQuality.medium,
      );
    } else {
      final thumbPath = widget.musicFile.thumbnailPath;
      if (thumbPath != null) {
        final file = File(thumbPath);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            gaplessPlayback: true,
            cacheWidth: finalCacheWidth,
            filterQuality: isCentered
                ? FilterQuality.low
                : FilterQuality.medium,
          );
        }
      }

      final imagePath = widget.musicFile.artworkPath;
      if (imagePath != null) {
        final file = File(imagePath);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            gaplessPlayback: true,
            cacheWidth: finalCacheWidth,
            filterQuality: isCentered
                ? FilterQuality.low
                : FilterQuality.medium,
          );
        }
      }
    }

    if (!_isLoaded) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24),
      );
    }

    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.1),
        ),
        child: const Icon(Icons.music_note, size: 40, color: Colors.white54),
      ),
    );
  }
}
