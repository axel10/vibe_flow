import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import '../l10n/app_localizations.dart';
import '../models/music_file.dart';
import '../player/audio/audio_riverpod.dart';
import '../player/remote/clients/subsonic_client.dart';
import '../player/remote/proxy/remote_media_resolver.dart';
import '../player/remote/remote_server_models.dart';
import '../utils/song_context_menu_utils.dart';

class RemoteAddToPlaylistDialog {
  static Future<void> show(
    BuildContext context, {
    required WidgetRef ref,
    required RemoteServer server,
    required String password,
    required List<MusicFile> songs,
  }) async {
    if (songs.isEmpty) return;
    final client = SubsonicClient(server: server, password: password);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Extract Subsonic track IDs
    final List<String> songIds = [];
    for (final song in songs) {
      final trackId = RemoteMediaResolver.extractSubsonicTrackId(song);
      if (trackId != null && trackId.isNotEmpty && trackId != 'null') {
        songIds.add(trackId);
      }
    }

    if (songIds.isEmpty) {
      showToast(l10n.emptyList);
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _RemotePlaylistDialogContent(
          client: client,
          songs: songs,
          songIds: songIds,
          theme: theme,
          l10n: l10n,
          ref: ref,
        );
      },
    );
  }
}

class _RemotePlaylistDialogContent extends StatefulWidget {
  final SubsonicClient client;
  final List<MusicFile> songs;
  final List<String> songIds;
  final ThemeData theme;
  final AppLocalizations l10n;
  final WidgetRef ref;

  const _RemotePlaylistDialogContent({
    required this.client,
    required this.songs,
    required this.songIds,
    required this.theme,
    required this.l10n,
    required this.ref,
  });

  @override
  State<_RemotePlaylistDialogContent> createState() =>
      _RemotePlaylistDialogContentState();
}

class _RemotePlaylistDialogContentState
    extends State<_RemotePlaylistDialogContent> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _serverPlaylists = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchServerPlaylists();
  }

  Future<void> _fetchServerPlaylists() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await widget.client.getPlaylists();
      if (mounted) {
        setState(() {
          _serverPlaylists = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addToExistingPlaylist(
    String playlistId,
    String playlistName,
  ) async {
    try {
      final ok = await widget.client.updatePlaylist(
        playlistId: playlistId,
        songIdsToAdd: widget.songIds,
      );
      if (ok) {
        showToast(
          widget.l10n.addedTracksToPlaylistSuccess(widget.songs.length, playlistName),
        );
        if (mounted) Navigator.pop(context);
      } else {
        showToast(widget.l10n.addToPlaylistFailed);
      }
    } catch (e) {
      showToast(widget.l10n.errorAddingToPlaylist(e.toString()));
    }
  }

  Future<void> _showCreatePlaylistDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (createCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        title: Text(widget.l10n.createNewServerPlaylist),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: widget.l10n.playlistName,
              hintText: widget.l10n.enterPlaylistName,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(createCtx),
            child: Text(widget.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(createCtx);

              try {
                final created = await widget.client.createPlaylist(
                  name: name,
                  songIds: widget.songIds,
                );
                if (created != null) {
                  showToast(
                    widget.l10n.createdPlaylistWithTracksSuccess(name, widget.songs.length),
                  );
                  if (mounted) Navigator.pop(context);
                } else {
                  showToast(widget.l10n.createServerPlaylistFailed);
                }
              } catch (e) {
                showToast(widget.l10n.errorCreatingPlaylist(e.toString()));
              }
            },
            child: Text(widget.l10n.createPlaylist),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.playlist_add_rounded,
              color: widget.theme.colorScheme.onPrimaryContainer,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.l10n.addToServerPlaylist,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
          minWidth: 320,
        ),
        child: SizedBox(
          height: 340,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.l10n.errorWithMessage(_error!), textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _fetchServerPlaylists,
                            child: Text(widget.l10n.retry),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            widget.l10n.serverPlaylists,
                            style: widget.theme.textTheme.labelMedium?.copyWith(
                              color: widget.theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _serverPlaylists.isEmpty
                              ? Center(
                                  child: Text(
                                    widget.l10n.noServerPlaylistsFound,
                                    style: TextStyle(
                                      color: widget
                                          .theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _serverPlaylists.length,
                                  itemBuilder: (context, index) {
                                    final pl = _serverPlaylists[index];
                                    final name =
                                        pl['name'] as String? ?? widget.l10n.playlist;
                                    final id = pl['id'] as String? ?? '';
                                    final count = pl['songCount'] as int? ?? 0;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.orange
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.queue_music_rounded,
                                            color: Colors.orange,
                                            size: 20,
                                          ),
                                        ),
                                        title: Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        subtitle: Text(
                                          widget.l10n.songCount(count),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        onTap: () =>
                                            _addToExistingPlaylist(id, name),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // Open local playlist dialog
            final playlistService = widget.ref.read(playlistServiceProvider);
            showAddSongsToPlaylistDialog(
              context,
              playlistService,
              widget.songs,
            );
          },
          child: Text(widget.l10n.addToLocalPlaylist),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: _showCreatePlaylistDialog,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(widget.l10n.createNewList),
        ),
      ],
    );
  }
}
