import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/playback_source.dart';
import 'package:vynody/player/library/playlist_service.dart';
import '../widgets/song_tile.dart';
import 'package:vynody/utils/file_selector_helper.dart';
import 'package:vynody/utils/song_context_menu_utils.dart';
import 'package:vynody/utils/deleted_song_snack.dart';
import 'package:vynody/utils/playlist_name.dart';
import 'package:vynody/utils/selection_utils.dart';
import '../widgets/library_selection_panel.dart';
import '../widgets/library_selection_scope.dart';

class PlaylistTab extends ConsumerStatefulWidget {
  const PlaylistTab({super.key});

  @override
  ConsumerState<PlaylistTab> createState() => _PlaylistTabState();
}

class _PlaylistTabState extends ConsumerState<PlaylistTab> {
  final Set<int> _selectedIndices = {};
  int? _lastAnchorIndex;
  final ScrollController _scrollController = ScrollController();
  late final LibrarySelectionScopeController _librarySelectionScopeController;

  @override
  void initState() {
    super.initState();
    _librarySelectionScopeController = ref.read(
      librarySelectionScopeProvider.notifier,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Future.microtask(() {
      _librarySelectionScopeController.clear();
    });
    super.dispose();
  }

  void _toggleSelectionMode() {
    final isSelectionMode =
        ref.read(librarySelectionScopeProvider) ==
        LibrarySelectionScope.playlist;
    final nextMode = !isSelectionMode;
    _librarySelectionScopeController.setScope(
      nextMode ? LibrarySelectionScope.playlist : LibrarySelectionScope.none,
    );
    setState(() {
      if (isSelectionMode) {
        _selectedIndices.clear();
      }
    });
  }

  void _cancelSelection() {
    _librarySelectionScopeController.clear();
    setState(() {
      _selectedIndices.clear();
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _reorderSelectedIndices(int oldIndex, int newIndex) {
    if (_selectedIndices.isEmpty) return;

    final updated = <int>{};
    for (final index in _selectedIndices) {
      if (index == oldIndex) {
        updated.add(newIndex);
      } else if (oldIndex < newIndex) {
        if (index > oldIndex && index <= newIndex) {
          updated.add(index - 1);
        } else {
          updated.add(index);
        }
      } else if (newIndex < oldIndex) {
        if (index >= newIndex && index < oldIndex) {
          updated.add(index + 1);
        } else {
          updated.add(index);
        }
      } else {
        updated.add(index);
      }
    }

    _selectedIndices
      ..clear()
      ..addAll(updated);
  }

  void _showAddToPlaylistDialog(
    BuildContext context,
    List<MusicFile> selectedSongs,
  ) {
    final playlistService = ref.read(playlistServiceProvider);
    showAddSongsToPlaylistDialog(
      context,
      playlistService,
      selectedSongs,
      onPlaylistCreatedOrUpdated: () {
        _cancelSelection();
      },
    );
  }

  bool _isFavoritePlaylist(Playlist playlist) {
    return playlist.id == PlaylistService.favoritePlaylistId;
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.createPlaylist),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.playlistName,
              hintText: AppLocalizations.of(context)!.enterPlaylistName,
              errorText: errorText,
            ),
            onChanged: (val) {
              if (errorText != null) {
                setState(() {
                  errorText = null;
                });
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  final playlistService = ref.read(playlistServiceProvider);
                  if (playlistService.playlistExists(name)) {
                    setState(() {
                      errorText = AppLocalizations.of(
                        context,
                      )!.playlistNameExists;
                    });
                    return;
                  }
                  await playlistService.createPlaylist(name);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.createPlaylist),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenamePlaylistDialog(BuildContext context, Playlist playlist) {
    final controller = TextEditingController(text: playlist.name);
    String? errorText;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.renamePlaylist),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.playlistName,
              errorText: errorText,
            ),
            onChanged: (val) {
              if (errorText != null) {
                setState(() {
                  errorText = null;
                });
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  final playlistService = ref.read(playlistServiceProvider);
                  if (playlistService.playlistExists(
                    name,
                    excludeId: playlist.id,
                  )) {
                    setState(() {
                      errorText = AppLocalizations.of(
                        context,
                      )!.playlistNameExists;
                    });
                    return;
                  }
                  playlistService.renamePlaylist(playlist.id, name);
                  Navigator.pop(context);
                }
              },
              child: Text(AppLocalizations.of(context)!.confirm),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeletePlaylistDialog(BuildContext context, Playlist playlist) {
    if (_isFavoritePlaylist(playlist)) {
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deletePlaylist),
        content: Text(
          AppLocalizations.of(context)!.confirmDeletePlaylist(playlist.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(playlistServiceProvider).deletePlaylist(playlist.id);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _importM3uPlaylist(BuildContext context) async {
    try {
      final filePaths = await FileSelectorHelper.pickFiles(
        extensions: ['m3u', 'm3u8'],
        label: 'M3U Playlist',
      );
      if (filePaths == null || filePaths.isEmpty || !context.mounted) return;

      final playlistService = ref.read(playlistServiceProvider);
      final scannerRoots = ref.read(scannerServiceProvider).rootPaths;
      final l10n = AppLocalizations.of(context)!;
      final imported = await playlistService.importPlaylistsFromM3u(
        filePaths,
        rootPaths: scannerRoots,
      );

      if (!context.mounted) return;
      if (imported.isNotEmpty) {
        final last = imported.last;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.importPlaylistSuccess(last.name, last.songs.length),
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.importPlaylistFailed(e.toString())),
        ),
      );
    }
  }

  Future<void> _exportPlaylistAsM3u(
    BuildContext context,
    Playlist playlist,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (playlist.songs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noSongsInPlaylist),
        ),
      );
      return;
    }

    try {
      final playlistService = ref.read(playlistServiceProvider);
      final scannerRoots = ref.read(scannerServiceProvider).rootPaths;
      final m3uContent = playlistService.exportPlaylistToM3u(
        playlist,
        rootPaths: scannerRoots,
      );
      final bytes = Uint8List.fromList(utf8.encode(m3uContent));
      final safeName = playlist.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final suggestedName = '$safeName.m3u8';

      final savedPath = await FileSelectorHelper.saveFile(
        suggestedName: suggestedName,
        extensions: ['m3u8', 'm3u'],
        label: 'M3U8 Playlist',
        bytes: bytes,
      );

      if (savedPath != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportPlaylistSuccess),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.exportPlaylistFailed(e.toString())),
        ),
      );
    }
  }

  void _showPlaylistOptions(BuildContext context, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_upload_outlined),
              title: Text(AppLocalizations.of(context)!.exportPlaylistAsM3u),
              onTap: () {
                Navigator.pop(context);
                _exportPlaylistAsM3u(context, playlist);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(AppLocalizations.of(context)!.rename),
              enabled: !_isFavoritePlaylist(playlist),
              onTap: () {
                if (_isFavoritePlaylist(playlist)) return;
                Navigator.pop(context);
                _showRenamePlaylistDialog(context, playlist);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text(AppLocalizations.of(context)!.delete),
              enabled: !_isFavoritePlaylist(playlist),
              onTap: () {
                if (_isFavoritePlaylist(playlist)) return;
                Navigator.pop(context);
                _showDeletePlaylistDialog(context, playlist);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaylistSelector(BuildContext context) {
    final playlistService = ref.read(playlistServiceProvider);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ...playlistService.playlists.map(
                      (playlist) => ListTile(
                        leading: Icon(
                          _isFavoritePlaylist(playlist)
                              ? Icons.favorite_rounded
                              : Icons.playlist_play,
                          color: _isFavoritePlaylist(playlist)
                              ? Colors.redAccent
                              : null,
                        ),
                        title: Text(localizedPlaylistName(context, playlist)),
                        subtitle: Text(
                          AppLocalizations.of(
                            context,
                          )!.songCount(playlist.songs.length),
                        ),
                        trailing:
                            playlist.id == playlistService.currentPlaylist?.id
                            ? const Icon(Icons.check, color: Colors.blue)
                            : null,
                        onTap: () {
                          playlistService.setCurrentPlaylist(playlist.id);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.add),
                title: Text(AppLocalizations.of(context)!.createNewPlaylist),
                onTap: () {
                  Navigator.pop(context);
                  _showCreatePlaylistDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlaylistManager(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => _PlaylistManagerSheet(
        onImportM3u: () => _importM3uPlaylist(context),
        onShowOptions: (playlist) => _showPlaylistOptions(context, playlist),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Playlist? currentPlaylist) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasSongs = currentPlaylist?.songs.isNotEmpty == true;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final horizontalPadding = isPortrait ? 12.0 : 16.0;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.playlist,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showPlaylistSelector(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  currentPlaylist == null
                                      ? l10n.emptyList
                                      : localizedPlaylistName(
                                          context,
                                          currentPlaylist,
                                        ),
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.arrow_drop_down,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasSongs) ...[
                  IconButton(
                    tooltip: l10n.clearPlaylist,
                    onPressed: () {
                      if (currentPlaylist != null) {
                        ref
                            .read(playlistServiceProvider)
                            .clearPlaylist(currentPlaylist.id);
                      }
                    },
                    icon: const Icon(Icons.clear_all),
                  ),
                  const SizedBox(width: 8),
                ],
                PopupMenuButton<String>(
                  tooltip: l10n.managePlaylists,
                  onSelected: (value) {
                    if (value == 'create') {
                      _showCreatePlaylistDialog(context);
                    } else if (value == 'manage') {
                      _showPlaylistManager(context);
                    } else if (value == 'import') {
                      _importM3uPlaylist(context);
                    } else if (value == 'export' && currentPlaylist != null) {
                      _exportPlaylistAsM3u(context, currentPlaylist);
                    }
                  },
                  itemBuilder: (context) => [
                    buildContextMenuItem<String>(
                      value: 'create',
                      label: l10n.createPlaylist,
                      icon: Icons.add_rounded,
                      context: context,
                    ),
                    buildContextMenuItem<String>(
                      value: 'manage',
                      label: l10n.managePlaylists,
                      icon: Icons.list_rounded,
                      context: context,
                    ),
                    buildContextMenuItem<String>(
                      value: 'import',
                      label: l10n.importPlaylist,
                      icon: Icons.file_download_outlined,
                      context: context,
                    ),
                    if (currentPlaylist != null && currentPlaylist.songs.isNotEmpty)
                      buildContextMenuItem<String>(
                        value: 'export',
                        label: l10n.exportPlaylist,
                        icon: Icons.file_upload_outlined,
                        context: context,
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

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_add,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.emptyList,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (Platform.isWindows)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  l10n.dragToAddMusic,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSelectionMode =
        ref.watch(librarySelectionScopeProvider) ==
        LibrarySelectionScope.playlist;
    final audio = ref.read(audioServiceProvider);
    final currentIndex = ref.watch(audioCurrentIndexProvider);
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final playlistService = ref.watch(playlistServiceProvider);
    final currentPlaylist = playlistService.currentPlaylist;

    if (currentPlaylist == null || currentPlaylist.songs.isEmpty) {
      return Column(
        children: [
          _buildHeader(context, currentPlaylist),
          Expanded(child: _buildEmptyState(context)),
        ],
      );
    }

    final Playlist activePlaylist = currentPlaylist;
    final selectedSongs = _selectedIndices
        .map((i) => activePlaylist.songs[i])
        .toList();

    void toggleSelectAll() {
      setState(() {
        if (_selectedIndices.length == activePlaylist.songs.length) {
          _selectedIndices.clear();
        } else {
          _selectedIndices.clear();
          _selectedIndices.addAll(
            List.generate(activePlaylist.songs.length, (i) => i),
          );
        }
      });
    }

    return Stack(
      children: [
        CustomScrollView(
            controller: _scrollController,
            cacheExtent: 1000,
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, activePlaylist)),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom:
                      (currentMusic != null ? 140.0 : 40.0) +
                      (isSelectionMode ? 220.0 : 0.0),
                ),
                sliver: SliverReorderableList(
                  itemCount: activePlaylist.songs.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    setState(() {
                      _reorderSelectedIndices(oldIndex, newIndex);
                    });
                    playlistService.reorderSongsInPlaylist(
                      activePlaylist.id,
                      oldIndex,
                      newIndex,
                    );
                  },
                  itemBuilder: (context, index) {
                    final song = activePlaylist.songs[index];
                    final isMissing = song.isMissing;
                    final isCurrent =
                        currentIndex == index &&
                        currentMusic?.path == song.path;
                    final isSelected = _selectedIndices.contains(index);

                    void handleShowMenu(
                      BuildContext menuContext,
                      Offset position,
                    ) {
                      final songsToAdd = _selectedIndices.isNotEmpty
                          ? _selectedIndices
                                .map((i) => activePlaylist.songs[i])
                                .toList()
                          : <MusicFile>[song];

                      showSongContextMenu(
                        menuContext,
                        position,
                        song: song,
                        songs: songsToAdd,
                        mode: SongContextMenuMode.full,
                        onAddToPlaylist: () async {
                          _showAddToPlaylistDialog(menuContext, songsToAdd);
                        },
                        onPlayNext: () => ref
                            .read(audioServiceProvider)
                            .enqueueNext(songsToAdd),
                        onAddToQueue: () => ref
                            .read(audioServiceProvider)
                            .appendToQueue(songsToAdd),
                        onRemoveFromPlaylist: isSelectionMode
                            ? null
                            : () {
                                playlistService.removeSongsFromPlaylist(
                                  activePlaylist.id,
                                  [index],
                                );
                              },
                      );
                    }

                    return Align(
                      key: ObjectKey(song),
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                          ),
                          child: SongTile(
                            song: song,
                            isCurrent: isCurrent,
                            isSelected: isSelected,
                            isSelectionMode: isSelectionMode,
                            dragHandle: ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle),
                            ),
                            onTap: () {
                              if (isMissing) {
                                showDeletedSongSnack(
                                  context,
                                  ref,
                                  skipped: false,
                                );
                                return;
                              }

                              final isShift = ModifierKeyUtils.isRangeSelectPressed;
                              final isCtrl = ModifierKeyUtils.isDiscreteSelectPressed;

                              if (isShift) {
                                if (!isSelectionMode) {
                                  _toggleSelectionMode();
                                }
                                final anchor = _lastAnchorIndex ?? index;
                                final range = ModifierKeyUtils.getIndexRange(anchor, index);
                                setState(() {
                                  for (final i in range) {
                                    if (i >= 0 && i < activePlaylist.songs.length) {
                                      _selectedIndices.add(i);
                                    }
                                  }
                                });
                              } else if (isCtrl) {
                                if (!isSelectionMode) {
                                  _toggleSelectionMode();
                                }
                                _toggleSelection(index);
                                _lastAnchorIndex = index;
                              } else {
                                if (isSelectionMode) {
                                  _toggleSelection(index);
                                  _lastAnchorIndex = index;
                                } else {
                                  _lastAnchorIndex = index;
                                  audio.playPlaylist(
                                    activePlaylist.songs,
                                    initialIndex: index,
                                    source: PlaybackSource(
                                      type: PlaybackSourceType.playlist,
                                      id: activePlaylist.id,
                                      name: activePlaylist.name,
                                    ),
                                  );
                                }
                              }
                            },
                            onLongPress: () {
                              _lastAnchorIndex = index;
                              if (!isSelectionMode) {
                                _toggleSelectionMode();
                                _toggleSelection(index);
                              }
                            },
                            onSecondaryTapDown: (details) {
                              handleShowMenu(context, details.globalPosition);
                            },
                            onMorePressed: (buttonContext) {
                              final renderObject = buttonContext.findRenderObject();
                              final renderBox = renderObject is RenderBox
                                  ? renderObject
                                  : null;
                              if (renderBox == null) return;
                              final Offset offset = renderBox.localToGlobal(
                                Offset.zero,
                              );
                              handleShowMenu(buttonContext, offset);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              reverseDuration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0, 1.0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(position: offsetAnimation, child: child);
              },
              child: isSelectionMode
                  ? LibrarySelectionPanel(
                      key: const ValueKey('library-selection-panel'),
                      selectedSongs: selectedSongs,
                      allSongs: activePlaylist.songs,
                      onToggleSelectAll: toggleSelectAll,
                      onCancel: _cancelSelection,
                      replaceFavoritesWithSongDetails: true,
                      onDelete: () {
                        final indices = _selectedIndices.toList()..sort();
                        playlistService.removeSongsFromPlaylist(
                          activePlaylist.id,
                          indices,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.deletedSongs(indices.length)),
                          ),
                        );
                        _cancelSelection();
                      },
                    )
                  : const SizedBox.shrink(
                      key: ValueKey('library-selection-panel-hidden'),
                    ),
            ),
          ),
        ],
      );
  }
}

class _PlaylistManagerSheet extends ConsumerStatefulWidget {
  final VoidCallback onImportM3u;
  final void Function(Playlist playlist) onShowOptions;

  const _PlaylistManagerSheet({
    required this.onImportM3u,
    required this.onShowOptions,
  });

  @override
  ConsumerState<_PlaylistManagerSheet> createState() =>
      _PlaylistManagerSheetState();
}

class _PlaylistManagerSheetState extends ConsumerState<_PlaylistManagerSheet> {
  bool _isSelectionMode = false;
  final Set<String> _selectedPlaylistIds = {};

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isFavoritePlaylist(Playlist playlist) {
    return playlist.id == PlaylistService.favoritePlaylistId;
  }

  void _showBatchDeleteConfirmDialog(
    BuildContext context,
    Set<String> playlistIds,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final count = playlistIds.length;
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deletePlaylists),
        content: Text(l10n.confirmDeletePlaylists(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final idsToDelete = Set<String>.from(playlistIds);
              await ref
                  .read(playlistServiceProvider)
                  .deletePlaylists(idsToDelete);
              if (mounted) {
                setState(() {
                  _selectedPlaylistIds.clear();
                  _isSelectionMode = false;
                });
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.playlistsDeleted(count)),
                  ),
                );
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final playlistService = ref.watch(playlistServiceProvider);
    final playlists = playlistService.playlists;

    final deletablePlaylists =
        playlists.where((p) => !_isFavoritePlaylist(p)).toList();
    final isAllSelected = deletablePlaylists.isNotEmpty &&
        _selectedPlaylistIds.length >= deletablePlaylists.length;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isSelectionMode) ...[
              ListTile(
                title: Text(
                  l10n.managePlaylists,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: deletablePlaylists.isNotEmpty
                    ? IconButton(
                        tooltip: l10n.batchDelete,
                        icon: const Icon(Icons.checklist_rounded),
                        onPressed: () {
                          setState(() {
                            _isSelectionMode = true;
                          });
                        },
                      )
                    : null,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.file_download_outlined),
                title: Text(l10n.importPlaylist),
                onTap: () {
                  Navigator.pop(context);
                  widget.onImportM3u();
                },
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    final isFav = _isFavoritePlaylist(playlist);
                    return ListTile(
                      leading: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.playlist_play,
                        color: isFav ? Colors.redAccent : null,
                      ),
                      title: Text(localizedPlaylistName(context, playlist)),
                      subtitle: Text(
                        '${l10n.songCount(playlist.songs.length)} · ${_formatDate(playlist.updatedAt)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onShowOptions(playlist);
                        },
                      ),
                      onTap: () {
                        playlistService.setCurrentPlaylist(playlist.id);
                        Navigator.pop(context);
                      },
                      onLongPress: isFav
                          ? null
                          : () {
                              setState(() {
                                _isSelectionMode = true;
                                _selectedPlaylistIds.add(playlist.id);
                              });
                            },
                    );
                  },
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: l10n.cancel,
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        setState(() {
                          _isSelectionMode = false;
                          _selectedPlaylistIds.clear();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.selectedPlaylistsCount(_selectedPlaylistIds.length),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (deletablePlaylists.isNotEmpty)
                      IconButton(
                        tooltip:
                            isAllSelected ? l10n.deselectAll : l10n.selectAll,
                        icon: Icon(
                          isAllSelected
                              ? Icons.deselect_rounded
                              : Icons.select_all_rounded,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isAllSelected) {
                              _selectedPlaylistIds.clear();
                            } else {
                              _selectedPlaylistIds.addAll(
                                deletablePlaylists.map((p) => p.id),
                              );
                            }
                          });
                        },
                      ),
                    IconButton(
                      tooltip: l10n.delete,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: _selectedPlaylistIds.isNotEmpty
                            ? Colors.redAccent
                            : null,
                      ),
                      onPressed: _selectedPlaylistIds.isNotEmpty
                          ? () => _showBatchDeleteConfirmDialog(
                                context,
                                _selectedPlaylistIds,
                              )
                          : null,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    final isFav = _isFavoritePlaylist(playlist);
                    final isSelected =
                        _selectedPlaylistIds.contains(playlist.id);

                    if (isFav) {
                      return ListTile(
                        enabled: false,
                        leading: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.grey,
                        ),
                        title: Text(
                          localizedPlaylistName(context, playlist),
                          style: TextStyle(color: theme.disabledColor),
                        ),
                        subtitle: Text(
                          '${l10n.songCount(playlist.songs.length)} · ${_formatDate(playlist.updatedAt)}',
                          style: TextStyle(color: theme.disabledColor),
                        ),
                      );
                    }

                    return ListTile(
                      selected: isSelected,
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedPlaylistIds.add(playlist.id);
                            } else {
                              _selectedPlaylistIds.remove(playlist.id);
                            }
                          });
                        },
                      ),
                      title: Text(localizedPlaylistName(context, playlist)),
                      subtitle: Text(
                        '${l10n.songCount(playlist.songs.length)} · ${_formatDate(playlist.updatedAt)}',
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedPlaylistIds.remove(playlist.id);
                          } else {
                            _selectedPlaylistIds.add(playlist.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

