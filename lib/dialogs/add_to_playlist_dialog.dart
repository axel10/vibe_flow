import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/music_file.dart';
import '../player/library/playlist_service.dart';
import '../utils/app_snack_bar.dart';
import '../utils/playlist_name.dart';
import '../widgets/song_thumbnail.dart';

/// A modern, responsive dialog for adding songs to a playlist.
class AddToPlaylistDialog extends StatefulWidget {
  final PlaylistService playlistService;
  final List<MusicFile> songs;
  final VoidCallback? onPlaylistCreatedOrUpdated;

  const AddToPlaylistDialog({
    super.key,
    required this.playlistService,
    required this.songs,
    this.onPlaylistCreatedOrUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required PlaylistService playlistService,
    required List<MusicFile> songs,
    VoidCallback? onPlaylistCreatedOrUpdated,
  }) async {
    if (songs.isEmpty) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AddToPlaylistDialog(
        playlistService: playlistService,
        songs: songs,
        onPlaylistCreatedOrUpdated: onPlaylistCreatedOrUpdated,
      ),
    );
  }

  @override
  State<AddToPlaylistDialog> createState() => _AddToPlaylistDialogState();
}

class _AddToPlaylistDialogState extends State<AddToPlaylistDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isFavorite(Playlist playlist) {
    return playlist.id == PlaylistService.favoritePlaylistId;
  }

  Future<void> _addSongsToPlaylist(Playlist playlist) async {
    await widget.playlistService.addSongsToPlaylist(playlist.id, widget.songs);
    if (!mounted) return;
    Navigator.pop(context);
    widget.onPlaylistCreatedOrUpdated?.call();

    final plName = localizedPlaylistName(context, playlist);
    AppSnackBar.show(
      context,
      null,
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.addedToPlaylist(
            widget.songs.length,
            plName,
          ),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _showCreatePlaylistDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final nameController = TextEditingController();
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          void submit() async {
            final name = nameController.text.trim();
            if (name.isEmpty) return;

            if (widget.playlistService.playlistExists(name)) {
              setDialogState(() {
                errorText = l10n.playlistNameExists;
              });
              return;
            }

            final newPlaylist = await widget.playlistService.createPlaylist(name);
            await widget.playlistService.addSongsToPlaylist(newPlaylist.id, widget.songs);

            if (dialogCtx.mounted) {
              Navigator.pop(dialogCtx);
            }
            if (mounted) {
              Navigator.pop(context);
              widget.onPlaylistCreatedOrUpdated?.call();
              AppSnackBar.show(
                context,
                null,
                SnackBar(
                  content: Text(l10n.createdPlaylist(name, widget.songs.length)),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.playlist_add_rounded,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            l10n.createPlaylist,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: l10n.playlistName,
                        hintText: l10n.enterPlaylistName,
                        errorText: errorText,
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (val) {
                        if (errorText != null) {
                          setDialogState(() {
                            errorText = null;
                          });
                        }
                      },
                      onSubmitted: (_) => submit(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: Text(l10n.cancel),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: submit,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: Text(l10n.createPlaylist),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeadingIcon(Playlist playlist, ThemeData theme) {
    if (_isFavorite(playlist)) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.favorite_rounded,
          color: Colors.redAccent,
          size: 22,
        ),
      );
    }

    if (playlist.songs.isNotEmpty) {
      final firstSong = playlist.songs.first;
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: SongThumbnail(
            path: firstSong.path,
            id: firstSong.id,
            thumbnailPath: firstSong.thumbnailPath,
            size: 44,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.queue_music_rounded,
        color: theme.colorScheme.onPrimaryContainer,
        size: 22,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final allPlaylists = widget.playlistService.playlists;

    final filteredPlaylists = _searchQuery.isEmpty
        ? allPlaylists
        : allPlaylists.where((p) {
            final name = localizedPlaylistName(context, p).toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
          minWidth: 320,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.playlist_add_rounded,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.addToPlaylist,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              l10n.songCount(widget.songs.length),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar (shown when there are multiple playlists)
              if (allPlaylists.length >= 5) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.search,
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      isDense: true,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Playlist List Content
              SizedBox(
                height: 280,
                child: filteredPlaylists.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.queue_music_rounded,
                                size: 40,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.emptyList,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredPlaylists.length,
                        itemBuilder: (context, index) {
                          final playlist = filteredPlaylists[index];
                          final name = localizedPlaylistName(context, playlist);
                          final songCount = playlist.songs.length;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _addSongsToPlaylist(playlist),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      _buildLeadingIcon(playlist, theme),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              l10n.songCount(songCount),
                                              style: TextStyle(
                                                color: theme.colorScheme.onSurfaceVariant,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.add_circle_outline_rounded,
                                        size: 20,
                                        color: theme.colorScheme.primary.withValues(alpha: 0.75),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),

              // Bottom Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _showCreatePlaylistDialog,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(l10n.createNewList),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
