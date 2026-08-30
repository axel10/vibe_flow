import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:window_manager/window_manager.dart';

import '../../models/music_file.dart';
import '../../player/audio/audio_riverpod.dart';
import '../../player/audio/playback_source.dart';
import '../../player/remote/remote_server_models.dart';
import '../../player/remote/remote_server_riverpod.dart';
import '../../player/remote/clients/subsonic_client.dart';
import '../../player/remote/proxy/remote_media_resolver.dart';
import '../../player/remote/services/remote_download_service.dart';
import '../../widgets/remote_artwork_widget.dart';
import '../../widgets/desktop_window_title_bar.dart';
import '../../widgets/mini_player_wrapper.dart';
import '../../widgets/playing_equalizer_icon.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_snack_bar.dart';
import '../../utils/remote_context_menu_utils.dart';
import 'navidrome_artist_detail_page.dart';
import 'remote_download_manager_page.dart';

/// Standalone Full-Page for Navidrome Playlist Detail (used in portrait / mobile navigation)
class NavidromePlaylistDetailPage extends ConsumerWidget {
  final RemoteServer server;
  final String password;
  final String playlistId;
  final String playlistName;
  final String? coverArtId;
  final int? songCount;
  final int? duration;
  final bool isStarred;
  final VoidCallback? onPlaylistModified;

  const NavidromePlaylistDetailPage({
    super.key,
    required this.server,
    required this.password,
    required this.playlistId,
    required this.playlistName,
    this.coverArtId,
    this.songCount,
    this.duration,
    this.isStarred = false,
    this.onPlaylistModified,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMacOS = Platform.isMacOS;
    final bool showCustomTitleBar =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    Widget content = Scaffold(
      appBar: AppBar(
        title: Text(playlistName),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: ref.watch(activeDownloadsCountProvider) > 0,
              label: Text('${ref.watch(activeDownloadsCountProvider)}'),
              child: const Icon(Icons.download_rounded),
            ),
            tooltip: 'Download Manager',
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => const RemoteDownloadManagerPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: NavidromePlaylistDetailContent(
        server: server,
        password: password,
        playlistId: playlistId,
        playlistName: playlistName,
        coverArtId: coverArtId,
        songCount: songCount,
        duration: duration,
        isStarred: isStarred,
        onPlaylistModified: onPlaylistModified,
        onDeleted: () {
          Navigator.of(context).pop();
        },
      ),
    );

    if (showCustomTitleBar || isMacOS) {
      content = Material(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            if (showCustomTitleBar)
              DesktopWindowTitleBar(brightness: theme.brightness)
            else
              const DragToMoveArea(child: SizedBox(height: 32)),
            Expanded(child: content),
          ],
        ),
      );
    }

    return MiniPlayerWrapper(child: content);
  }
}

/// Embedded Content Widget for Navidrome Playlist Detail (used in landscape split view or full page)
class NavidromePlaylistDetailContent extends ConsumerStatefulWidget {
  final RemoteServer server;
  final String password;
  final String playlistId;
  final String playlistName;
  final String? coverArtId;
  final int? songCount;
  final int? duration;
  final bool isStarred;
  final VoidCallback? onPlaylistModified;
  final VoidCallback? onDeleted;

  const NavidromePlaylistDetailContent({
    super.key,
    required this.server,
    required this.password,
    required this.playlistId,
    required this.playlistName,
    this.coverArtId,
    this.songCount,
    this.duration,
    this.isStarred = false,
    this.onPlaylistModified,
    this.onDeleted,
  });

  @override
  ConsumerState<NavidromePlaylistDetailContent> createState() =>
      _NavidromePlaylistDetailContentState();
}

class _NavidromePlaylistDetailContentState
    extends ConsumerState<NavidromePlaylistDetailContent> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _playlistData;
  List<MusicFile> _tracks = [];
  late String _currentName;
  final ScrollController _scrollController = ScrollController();
  final Set<String> _starredSongIds = {};

  bool get _isStarredView =>
      widget.isStarred || widget.playlistId == 'starred_songs';

  @override
  void initState() {
    super.initState();
    _currentName = widget.playlistName;
    _loadPlaylistDetails();
  }

  @override
  void didUpdateWidget(NavidromePlaylistDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playlistId != widget.playlistId ||
        oldWidget.isStarred != widget.isStarred ||
        oldWidget.server.id != widget.server.id) {
      _currentName = widget.playlistName;
      _loadPlaylistDetails();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaylistDetails({bool forceRefresh = false}) async {
    final session = ref.read(activeRemoteSessionProvider);
    final isSameServer =
        session != null && session.server.id == widget.server.id;

    if (!forceRefresh && isSameServer) {
      final cached = session.navidromePlaylistDetailsCache[widget.playlistId];
      if (cached != null) {
        setState(() {
          _playlistData = cached.playlistData;
          _currentName =
              cached.playlistData['name'] as String? ?? widget.playlistName;
          _tracks = cached.tracks;
          _starredSongIds
            ..clear()
            ..addAll(cached.starredSongIds);
          _isLoading = false;
          _error = null;
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = SubsonicClient(
        server: widget.server,
        password: widget.password,
      );

      if (_isStarredView) {
        final songList = await client.getStarredSongs();
        final List<MusicFile> parsedTracks = [];
        final Set<String> starred = {};
        int totalDur = 0;

        for (final item in songList) {
          final song = RemoteMediaResolver.buildMusicFileFromSubsonic(
            item,
            widget.server,
          );
          parsedTracks.add(song);
          final trackId = item['id']?.toString() ?? song.id.toString();
          starred.add(trackId);
          if (item['duration'] is int) {
            totalDur += item['duration'] as int;
          }
        }

        if (!mounted) return;
        final data = {
          'name': widget.playlistName,
          'songCount': parsedTracks.length,
          'duration': totalDur,
        };
        setState(() {
          _playlistData = data;
          _currentName = widget.playlistName;
          _tracks = parsedTracks;
          _starredSongIds
            ..clear()
            ..addAll(starred);
          _isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final activeSession = ref.read(activeRemoteSessionProvider);
          if (activeSession != null &&
              activeSession.server.id == widget.server.id) {
            ref
                .read(activeRemoteSessionProvider.notifier)
                .updateNavidromePlaylistDetail(
                  playlistId: widget.playlistId,
                  playlistData: data,
                  tracks: parsedTracks,
                  starredSongIds: starred,
                );
          }
        });
        return;
      }

      final pl = await client.getPlaylist(widget.playlistId);
      if (pl == null) {
        if (!mounted) return;
        setState(() {
          _error = 'Playlist details not found on server';
          _isLoading = false;
        });
        return;
      }

      final songList = pl['entry'] as List?;
      final List<MusicFile> parsedTracks = [];
      final Set<String> starred = {};

      if (songList != null) {
        for (final item in songList) {
          if (item is Map<String, dynamic>) {
            final song = RemoteMediaResolver.buildMusicFileFromSubsonic(
              item,
              widget.server,
            );
            parsedTracks.add(song);
            if (item['starred'] != null) {
              final trackId = item['id']?.toString() ?? song.id.toString();
              starred.add(trackId);
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _playlistData = pl;
        _currentName = pl['name'] as String? ?? widget.playlistName;
        _tracks = parsedTracks;
        _starredSongIds
          ..clear()
          ..addAll(starred);
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final activeSession = ref.read(activeRemoteSessionProvider);
        if (activeSession != null &&
            activeSession.server.id == widget.server.id) {
          ref
              .read(activeRemoteSessionProvider.notifier)
              .updateNavidromePlaylistDetail(
                playlistId: widget.playlistId,
                playlistData: pl,
                tracks: parsedTracks,
                starredSongIds: starred,
              );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _playAll({bool shuffle = false}) async {
    if (_tracks.isEmpty) return;
    final audioService = ref.read(audioServiceProvider);
    final playlist = List<MusicFile>.from(_tracks);
    if (shuffle) {
      playlist.shuffle();
    }
    await audioService.playPlaylist(
      playlist,
      source: PlaybackSource(
        type: PlaybackSourceType.playlist,
        id: 'remote-${widget.server.id}-${widget.playlistId}',
        name: _currentName,
      ),
    );
    showToast('Playing ${_tracks.length} tracks');
  }

  Future<void> _downloadAll() async {
    if (_tracks.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(remoteDownloadTasksProvider.notifier);

    await notifier.enqueueSubsonicTracks(
      server: widget.server,
      password: widget.password,
      songs: _tracks,
      collectionName: _currentName,
    );

    if (mounted) {
      AppSnackBar.show(
        context,
        ref,
        SnackBar(
          content: Text(l10n.batchAddedToDownloadQueue(_tracks.length)),
          action: SnackBarAction(
            label: l10n.viewDownloadProgress,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => const RemoteDownloadManagerPage(),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  Future<void> _removeTrackAt(int index) async {
    if (index < 0 || index >= _tracks.length) return;
    final songToRemove = _tracks[index];

    final client = SubsonicClient(
      server: widget.server,
      password: widget.password,
    );

    final success = await client.updatePlaylist(
      playlistId: widget.playlistId,
      songIndexesToRemove: [index],
    );

    if (success) {
      setState(() {
        _tracks.removeAt(index);
      });
      final activeSession = ref.read(activeRemoteSessionProvider);
      if (activeSession != null &&
          activeSession.server.id == widget.server.id &&
          _playlistData != null) {
        ref
            .read(activeRemoteSessionProvider.notifier)
            .updateNavidromePlaylistDetail(
              playlistId: widget.playlistId,
              playlistData: _playlistData!,
              tracks: _tracks,
              starredSongIds: _starredSongIds,
            );
      }
      widget.onPlaylistModified?.call();
      showToast('Removed "${songToRemove.displayName}" from playlist');
    } else {
      showToast('Failed to remove track');
    }
  }

  void _showRenameDialog() {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _currentName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.renamePlaylist),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.playlistName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != _currentName) {
                final client = SubsonicClient(
                  server: widget.server,
                  password: widget.password,
                );
                final ok = await client.updatePlaylist(
                  playlistId: widget.playlistId,
                  name: newName,
                );
                if (ok && mounted) {
                  setState(() {
                    _currentName = newName;
                    if (_playlistData != null) {
                      _playlistData = Map<String, dynamic>.from(_playlistData!)
                        ..['name'] = newName;
                    }
                  });
                  final activeSession = ref.read(activeRemoteSessionProvider);
                  if (activeSession != null &&
                      activeSession.server.id == widget.server.id &&
                      _playlistData != null) {
                    ref
                        .read(activeRemoteSessionProvider.notifier)
                        .updateNavidromePlaylistDetail(
                          playlistId: widget.playlistId,
                          playlistData: _playlistData!,
                          tracks: _tracks,
                          starredSongIds: _starredSongIds,
                        );
                  }
                  widget.onPlaylistModified?.call();
                }
              }
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deletePlaylist),
        content: Text(l10n.confirmDeletePlaylist(_currentName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final client = SubsonicClient(
                server: widget.server,
                password: widget.password,
              );
              final ok = await client.deletePlaylist(widget.playlistId);
              if (ok) {
                final activeSession = ref.read(activeRemoteSessionProvider);
                if (activeSession != null &&
                    activeSession.server.id == widget.server.id) {
                  ref
                      .read(activeRemoteSessionProvider.notifier)
                      .removeNavidromePlaylistDetail(widget.playlistId);
                }
                showToast('Playlist deleted');
                widget.onPlaylistModified?.call();
                widget.onDeleted?.call();
              } else {
                showToast('Failed to delete playlist');
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '0 min';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '$minutes min';
  }

  String _formatTrackDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '--:--';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final isAudioPlaying = ref.watch(audioIsPlayingProvider);
    final bottomOffset = MiniPlayerUiTuning.getListBottomPadding(
      context,
      hasPlayingMusic: currentMusic != null,
    );

    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text('Error: $_error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadPlaylistDetails,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final coverId = widget.coverArtId ?? _playlistData?['coverArt'] as String?;
    final count = _tracks.isNotEmpty ? _tracks.length : (widget.songCount ?? 0);
    final totalDuration = _playlistData?['duration'] as int? ?? widget.duration ?? 0;
    final comment = _playlistData?['comment'] as String?;
    final owner = _playlistData?['owner'] as String?;

    final headerColor = theme.colorScheme.secondaryContainer.withValues(alpha: 0.65);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Header Section
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [headerColor, theme.colorScheme.surface],
              ),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 460;
                      final double imageSize = isNarrow ? 120 : 160;

                      final coverWidget = Hero(
                        tag: 'navidrome_playlist_${widget.playlistId}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: imageSize,
                            height: imageSize,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: _isStarredView
                                ? Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFE53935),
                                          Color(0xFFE91E63),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.favorite_rounded,
                                        size: 64,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : coverId != null && coverId.isNotEmpty
                                    ? RemoteArtworkWidget(
                                        server: widget.server,
                                        password: widget.password,
                                        coverArtId: coverId,
                                        size: imageSize,
                                        borderRadius: BorderRadius.circular(16),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.deepPurple.shade400,
                                              Colors.indigo.shade600,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.playlist_play_rounded,
                                            size: 64,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                          ),
                        ),
                      );

                      final infoContent = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _isStarredView
                                  ? Colors.redAccent.withValues(alpha: 0.15)
                                  : theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _isStarredView ? 'FAVORITES' : 'PLAYLIST',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _isStarredView
                                    ? Colors.redAccent
                                    : theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _currentName,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                l10n.songCount(count),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (totalDuration > 0) ...[
                                Text(
                                  '•',
                                  style: TextStyle(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                Text(
                                  _formatDuration(totalDuration),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              if (owner != null && owner.isNotEmpty && !_isStarredView) ...[
                                Text(
                                  '•',
                                  style: TextStyle(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                Text(
                                  'by $owner',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (comment != null && comment.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              comment,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      );

                      return isNarrow
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(child: coverWidget),
                                const SizedBox(height: 16),
                                infoContent,
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                coverWidget,
                                const SizedBox(width: 20),
                                Expanded(child: infoContent),
                              ],
                            );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),

        // Action Toolbar
        SliverToBoxAdapter(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FilledButton.icon(
                      onPressed: _tracks.isNotEmpty ? () => _playAll() : null,
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: Text(l10n.playAll),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: l10n.shufflePlay,
                      onPressed: _tracks.isNotEmpty
                          ? () => _playAll(shuffle: true)
                          : null,
                      icon: const Icon(Icons.shuffle_rounded, size: 18),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Download All',
                      onPressed: _tracks.isNotEmpty ? _downloadAll : null,
                      icon: const Icon(Icons.download_rounded, size: 18),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      tooltip: l10n.managePlaylists,
                      iconSize: 20,
                      style: IconButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.more_vert_rounded),
                      onSelected: (value) {
                        if (value == 'rename') {
                          _showRenameDialog();
                        } else if (value == 'delete') {
                          _showDeleteDialog();
                        } else if (value == 'refresh') {
                          _loadPlaylistDetails();
                        }
                      },
                      itemBuilder: (ctx) => [
                        if (!_isStarredView)
                          PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_rounded, size: 18),
                                const SizedBox(width: 12),
                                Text(l10n.renamePlaylist),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'refresh',
                          child: Row(
                            children: [
                              Icon(Icons.refresh_rounded, size: 18),
                              SizedBox(width: 12),
                              Text('Refresh'),
                            ],
                          ),
                        ),
                        if (!_isStarredView) ...[
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.deletePlaylist,
                                  style: const TextStyle(color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: Divider(height: 1, indent: 16, endIndent: 16),
        ),

        // Songs List
        if (_tracks.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.music_off_rounded,
                      size: 56,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.emptyList,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.only(top: 8, bottom: bottomOffset),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = _tracks[index];
                  final isCurrent = currentMusic?.path == song.path;
                  final trackDuration = song.durationMillis != null
                      ? _formatTrackDuration(song.durationMillis! ~/ 1000)
                      : '--:--';

                  final trackId = RemoteMediaResolver.extractSubsonicTrackId(song) ??
                      (song.id != null && song.id! > 0 ? song.id.toString() : '');
                  final isStarred = _starredSongIds.contains(trackId);

                  String? trackCoverId;
                  if (song.artworkPath != null) {
                    trackCoverId = song.artworkPath!
                        .replaceFirst('subsonic-cover://${widget.server.id}/', '');
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        final audio = ref.read(audioServiceProvider);
                        await audio.playPlaylist(
                          _tracks,
                          initialIndex: index,
                          source: PlaybackSource(
                            type: PlaybackSourceType.playlist,
                            id: 'remote-${widget.server.id}-${widget.playlistId}',
                            name: _currentName,
                          ),
                        );
                      },
                      onSecondaryTapDown: (details) {
                        showRemoteSongContextMenu(
                          context: context,
                          globalPosition: details.globalPosition,
                          ref: ref,
                          server: widget.server,
                          password: widget.password,
                          song: song,
                          playlist: _tracks,
                          onRemoveFromPlaylist: () => _removeTrackAt(index),
                          onViewArtist: () {
                            if (song.artist != null && song.artist!.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NavidromeArtistDetailPage(
                                    server: widget.server,
                                    password: widget.password,
                                    artistId: '',
                                    artistName: song.artist!,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1080),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: Row(
                              children: [
                                // Track index / Playing equalizer
                                SizedBox(
                                  width: 36,
                                  child: Center(
                                    child: isCurrent
                                        ? PlayingEqualizerIcon(
                                            color: theme.colorScheme.primary,
                                            size: 16,
                                            isPlaying: isAudioPlaying,
                                          )
                                        : Text(
                                            '${index + 1}',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant
                                                  .withValues(alpha: 0.7),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // Track artwork
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    color: theme.colorScheme.surfaceContainerHighest,
                                    child: trackCoverId != null &&
                                            trackCoverId.isNotEmpty
                                        ? RemoteArtworkWidget(
                                            server: widget.server,
                                            password: widget.password,
                                            coverArtId: trackCoverId,
                                            size: 40,
                                            borderRadius: BorderRadius.circular(6),
                                          )
                                        : const Icon(Icons.music_note_rounded, size: 20),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Title & Artist/Album
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.displayName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: isCurrent
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: isCurrent
                                              ? theme.colorScheme.primary
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${song.artist ?? l10n.unknownArtist} • ${song.album ?? l10n.unknownAlbum}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Duration
                                Text(
                                  trackDuration,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.7),
                                  ),
                                ),

                                // Star button
                                IconButton(
                                  iconSize: 18,
                                  visualDensity: VisualDensity.compact,
                                  icon: Icon(
                                    isStarred
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isStarred ? Colors.redAccent : null,
                                  ),
                                  onPressed: () async {
                                    final client = SubsonicClient(
                                      server: widget.server,
                                      password: widget.password,
                                    );
                                    if (isStarred) {
                                      final ok = await client.unstar(id: trackId);
                                      if (ok) {
                                        setState(() {
                                          _starredSongIds.remove(trackId);
                                        });
                                      }
                                    } else {
                                      final ok = await client.star(id: trackId);
                                      if (ok) {
                                        setState(() {
                                          _starredSongIds.add(trackId);
                                        });
                                      }
                                    }
                                  },
                                ),

                                // More options
                                Builder(
                                  builder: (btnContext) => IconButton(
                                    iconSize: 18,
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.more_vert_rounded),
                                    onPressed: () {
                                      final renderBox =
                                          btnContext.findRenderObject() as RenderBox?;
                                      final offset = renderBox?.localToGlobal(
                                            Offset.zero,
                                          ) ??
                                          Offset.zero;
                                      showRemoteSongContextMenu(
                                        context: context,
                                        globalPosition: offset,
                                        ref: ref,
                                        server: widget.server,
                                        password: widget.password,
                                        song: song,
                                        playlist: _tracks,
                                        onRemoveFromPlaylist: () => _removeTrackAt(index),
                                        onViewArtist: () {
                                          if (song.artist != null && song.artist!.isNotEmpty) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => NavidromeArtistDetailPage(
                                                  server: widget.server,
                                                  password: widget.password,
                                                  artistId: '',
                                                  artistName: song.artist!,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _tracks.length,
              ),
            ),
          ),
      ],
    );
  }
}
