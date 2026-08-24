import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../utils/file_selector_helper.dart';

import '../l10n/app_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/metadata/metadata_helper.dart';
import 'package:audio_core/audio_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';

class SongTagEditResult {
  const SongTagEditResult({
    required this.metadata,
    required this.savedToSourceFile,
    this.artworkBytes,
  });

  final SongMetadata metadata;
  final bool savedToSourceFile;
  final Uint8List? artworkBytes;
}

Future<SongTagEditResult?> showSongTagEditSheet(
  BuildContext context, {
  required MusicFile song,
}) {
  return showModalBottomSheet<SongTagEditResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SongTagEditSheet(song: song),
  );
}

class SongTagEditSheet extends StatefulWidget {
  const SongTagEditSheet({super.key, required this.song});

  final MusicFile song;

  @override
  State<SongTagEditSheet> createState() => _SongTagEditSheetState();
}

class _SongTagEditSheetState extends State<SongTagEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _albumController;
  late final TextEditingController _trackNumberController;

  bool _isSaving = false;
  String? _errorMessage;
  Uint8List? _artworkBytes;
  String? _artworkPath;
  bool _isArtworkModified = false;
  bool _isLoadingArtwork = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.song.title?.trim().isNotEmpty == true
          ? widget.song.title!.trim()
          : widget.song.displayName,
    );
    _artistController = TextEditingController(
      text: widget.song.artist?.trim() ?? '',
    );
    _albumController = TextEditingController(
      text: widget.song.album?.trim() ?? '',
    );
    _trackNumberController = TextEditingController(
      text: widget.song.trackNumber?.toString() ?? '',
    );
    _loadArtwork();
  }

  Future<void> _loadArtwork() async {
    setState(() {
      _isLoadingArtwork = true;
    });
    String? path = widget.song.artworkPath ?? widget.song.thumbnailPath;
    Uint8List? bytes;
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) {
        try {
          bytes = await file.readAsBytes();
        } catch (_) {}
      }
    }
    if (bytes == null) {
      bytes = await MetadataHelper.decodeEmbeddedArtwork(widget.song.path);
      if (bytes != null && bytes.isNotEmpty) {
        final md5Hex = await calculateMd5(bytes: bytes);
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$md5Hex.jpg');
        if (!tempFile.existsSync()) {
          await tempFile.writeAsBytes(bytes);
        }
        path = tempFile.path;
      }
    }
    if (mounted) {
      setState(() {
        _artworkPath = path;
        _artworkBytes = bytes;
        _isLoadingArtwork = false;
      });
    }
  }

  Future<void> _pickArtwork() async {
    try {
      final path = await FileSelectorHelper.pickFile(
        label: 'Images',
        extensions: const ['jpg', 'jpeg', 'png', 'webp', 'bmp'],
        fileType: FileType.image,
      );

      if (path != null) {
        final file = File(path);
        final bytes = await file.readAsBytes();
        setState(() {
          _artworkPath = path;
          _artworkBytes = bytes;
          _isArtworkModified = true;
        });
      }
    } catch (e) {
      debugPrint('Error picking artwork: $e');
    }
  }

  Future<void> _showArtworkOptions() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_artworkBytes == null || (_isArtworkModified && _artworkBytes!.isEmpty)) {
      await _pickArtwork();
      return;
    }

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.88) : theme.colorScheme.surface.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.photo_library_rounded, color: theme.colorScheme.primary),
                    title: Text(l10n.changeArtwork),
                    onTap: () => Navigator.of(context).pop('change'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                    title: Text(l10n.clearArtwork, style: const TextStyle(color: Colors.redAccent)),
                    onTap: () => Navigator.of(context).pop('clear'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.close_rounded),
                    title: Text(l10n.cancel),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (action == 'change') {
      await _pickArtwork();
    } else if (action == 'clear') {
      setState(() {
        _artworkBytes = Uint8List(0);
        _isArtworkModified = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _trackNumberController.dispose();
    super.dispose();
  }

  Future<void> _save({required bool writeToFile}) async {
    if (_isSaving || RemoteMediaResolver.isRemoteUri(widget.song.path)) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final trackNumberText = _trackNumberController.text.trim();
    final trackNumber = trackNumberText.isEmpty
        ? null
        : int.tryParse(trackNumberText);
    if (trackNumberText.isNotEmpty && trackNumber == null) {
      setState(() {
        _isSaving = false;
        _errorMessage = l10n.trackNumberMustBeInteger;
      });
      return;
    }

    final result = await MetadataHelper.saveSelectedSongMetadata(
      filePath: widget.song.path,
      title: _titleController.text.trim(),
      artist: _artistController.text.trim(),
      album: _albumController.text.trim(),
      trackNumber: trackNumber,
      clearTrackNumber: trackNumberText.isEmpty,
      artworkBytes: _isArtworkModified ? _artworkBytes : null,
      existingMetadata: null,
      writeToFile: writeToFile,
      fallbackMediaUri: widget.song.mediaUri,
    );

    if (result == null) {
      final reason = MetadataHelper.lastWriteError;
      final isOccupied = reason == 'file_occupied';
      if (isOccupied && mounted) {
        showToast(l10n.fileOccupiedByOtherApp);
      }
      setState(() {
        _isSaving = false;
        _errorMessage = writeToFile
            ? (isOccupied ? l10n.fileOccupiedByOtherApp : (reason != null ? '${l10n.saveToSourceFileFailed}\n($reason)' : l10n.saveToSourceFileFailed))
            : (reason != null ? '${l10n.saveFailed}\n($reason)' : l10n.saveFailed);
      });
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(
      SongTagEditResult(
        metadata: result.$1,
        artworkBytes: result.$2 ?? (_isArtworkModified ? _artworkBytes : widget.song.artworkBytes),
        savedToSourceFile: writeToFile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRemote = RemoteMediaResolver.isRemoteUri(widget.song.path);
    final canWriteToSourceFile = !isRemote && isMetadataWritable(widget.song.path);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.88,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.86) : theme.colorScheme.surface.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.editSongTagsTitle,
                                style: TextStyle(
                                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.editSongTagsDescription,
                                style: TextStyle(
                                  color: isDark ? Colors.white.withValues(alpha: 0.6) : theme.colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: _isSaving ? null : _showArtworkOptions,
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: _isLoadingArtwork
                                        ? const Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          )
                                        : _artworkPath != null && _artworkPath!.isNotEmpty
                                            ? Image.file(
                                                File(_artworkPath!),
                                                fit: BoxFit.cover,
                                              )
                                            : Icon(
                                                Icons.music_note_rounded,
                                                size: 48,
                                                color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3),
                                              ),
                                  ),
                                ),
                                if (!_isSaving)
                                  Positioned(
                                    right: 4,
                                    bottom: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.25),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.edit_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildField(
                          context: context,
                          controller: _titleController,
                          label: l10n.title,
                          icon: Icons.title_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          context: context,
                          controller: _artistController,
                          label: l10n.artistLabel,
                          icon: Icons.person_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          context: context,
                          controller: _albumController,
                          label: l10n.albumLabel,
                          icon: Icons.album_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          context: context,
                          controller: _trackNumberController,
                          label: l10n.trackNumberLabel,
                          icon: Icons.numbers_rounded,
                          keyboardType: TextInputType.number,
                          helperText: l10n.leaveBlankKeepsCurrentValue,
                        ),
                        const SizedBox(height: 16),
                        _buildReadonlyInfo(
                          context: context,
                          label: l10n.file,
                          value: widget.song.path,
                          icon: Icons.folder_open_rounded,
                        ),
                        const SizedBox(height: 10),
                        if (!canWriteToSourceFile)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              l10n.currentFileFormatCannotWriteBack,
                              style: TextStyle(
                                color: Colors.orangeAccent.withValues(
                                  alpha: 0.9,
                                ),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        if (_errorMessage != null) ...[
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        Text(
                          l10n.leaveBlankDoesNotClearOriginalValue,
                          style: TextStyle(
                            color: isDark ? Colors.white.withValues(alpha: 0.45) : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.tonal(
                          onPressed: _isSaving || isRemote
                              ? null
                              : () => _save(writeToFile: false),
                          child: Text(l10n.saveToApp),
                        ),
                        const SizedBox(height: 10),
                        FilledButton(
                          onPressed: _isSaving || !canWriteToSourceFile || isRemote
                              ? null
                              : () => _save(writeToFile: true),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.saveToSourceFileAndApp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? helperText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      enabled: !_isSaving,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : theme.colorScheme.onSurface),
      cursorColor: theme.colorScheme.primary,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(icon, color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.75) : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75)),
        helperStyle: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.4) : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.1),
        ),
      ),
    );
  }

  Widget _buildReadonlyInfo({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isDark ? Colors.white.withValues(alpha: 0.7) : theme.colorScheme.onSurfaceVariant, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.55) : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.86) : theme.colorScheme.onSurface,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
