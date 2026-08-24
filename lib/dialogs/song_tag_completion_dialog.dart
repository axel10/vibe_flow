import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vynody/utils/clean_helper.dart';
import 'package:vynody/player/metadata/acoustid_service.dart';
import 'package:vynody/player/metadata/metadata_helper.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/metadata/musicbrainz_tag_completion_service.dart';
import '../pages/main_layout.dart';
import 'song_tag_completion_widgets.dart';
import 'song_tag_musicbrainz_cards.dart';
import 'song_tag_acoustid_cards.dart';
import 'song_tag_completion_riverpod.dart';
import 'package:vynody/utils/app_snack_bar.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';

enum _SummaryCondition { title, artist, album, duration }

class SongTagCompletionSheet extends ConsumerStatefulWidget {
  const SongTagCompletionSheet({
    super.key,
    required this.songPath,
    required this.currentTitle,
    required this.currentArtist,
    required this.currentAlbum,
    required this.durationMillis,
  });

  final String songPath;
  final String? currentTitle;
  final String? currentArtist;
  final String? currentAlbum;
  final int? durationMillis;

  @override
  ConsumerState<SongTagCompletionSheet> createState() =>
      _SongTagCompletionSheetState();
}

class _SongTagCompletionSheetState
    extends ConsumerState<SongTagCompletionSheet> {
  final TextEditingController _musicBrainzSearchController =
      TextEditingController();
  final FocusNode _musicBrainzSearchFocusNode = FocusNode();
  late final SongTagCompletionController _controller;

  bool _isMusicBrainzSearchExpanded = false;
  SongMetadata? _fileMetadata;
  final Set<String> _expandedAcoustIDIds = <String>{};
  final Set<String> _expandedReleaseGroupIds = <String>{};
  final Set<String> _expandedMusicBrainzRecordingIds = <String>{};
  String? _lastAcoustIDClientErrorMessage;
  final Set<_SummaryCondition> _disabledSummaryConditions =
      <_SummaryCondition>{};
  final Map<_SummaryCondition, String> _editedSummaryConditionTexts =
      <_SummaryCondition, String>{};

  @override
  void initState() {
    super.initState();
    _controller = ref.read(
      songTagCompletionControllerProvider(widget.songPath),
    );
    _musicBrainzSearchController.addListener(_onMusicBrainzSearchChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    _musicBrainzSearchController.removeListener(_onMusicBrainzSearchChanged);
    _musicBrainzSearchController.dispose();
    _musicBrainzSearchFocusNode.dispose();
    super.dispose();
  }

  void _onMusicBrainzSearchChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    try {
      final metadata = await MetadataHelper.readMetadataFromFile(
        widget.songPath,
      );
      if (!mounted) return;
      setState(() {
        _fileMetadata = metadata;
      });
    } catch (e) {
      debugPrint('Error reading file tags: $e');
    }

    if (!mounted) return;
    _loadMatches();
    _loadAcoustIDResult();
  }

  String get _displayTitle {
    final fileTitle = _fileMetadata?.title.trim();
    if (fileTitle != null && fileTitle.isNotEmpty) {
      return fileTitle;
    }
    final title = widget.currentTitle?.trim();
    if (title != null && title.isNotEmpty) {
      return title;
    }
    return CleanHelper.deriveCleanTitleFromFileName(widget.songPath);
  }

  bool _isSummaryConditionEnabled(_SummaryCondition condition) {
    return !_disabledSummaryConditions.contains(condition);
  }

  String? _summaryConditionSourceText(_SummaryCondition condition) {
    switch (condition) {
      case _SummaryCondition.title:
        return _displayTitle;
      case _SummaryCondition.artist:
        return _preferredMetadataText(
          _fileMetadata?.artist,
          widget.currentArtist,
        );
      case _SummaryCondition.album:
        return _preferredMetadataText(
          _fileMetadata?.album,
          widget.currentAlbum,
        );
      case _SummaryCondition.duration:
        final duration = _fileMetadata?.duration ?? widget.durationMillis;
        if (duration == null) return null;
        final minutes = duration ~/ 60000;
        final seconds = (duration ~/ 1000) % 60;
        return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String? _summaryConditionText(_SummaryCondition condition) {
    final edited = _editedSummaryConditionTexts[condition];
    if (_hasMeaningfulText(edited)) return edited!.trim();
    return _summaryConditionSourceText(condition);
  }

  bool _canEditSummaryCondition(_SummaryCondition condition) {
    return condition != _SummaryCondition.duration;
  }

  String get _musicBrainzSearchQuery =>
      _musicBrainzSearchController.text.trim().toLowerCase();

  bool get _hasMusicBrainzSearchQuery => _musicBrainzSearchQuery.isNotEmpty;

  String? _preferredMetadataText(String? primary, String? fallback) {
    if (_hasMeaningfulText(primary)) return primary!.trim();
    if (_hasMeaningfulText(fallback)) return fallback!.trim();
    return null;
  }

  List<MusicBrainzTrackMatch> _filteredMusicBrainzMatches(
    SongTagCompletionController controller,
  ) {
    if (!_hasMusicBrainzSearchQuery) return controller.musicBrainzMatches;

    final query = _musicBrainzSearchQuery;
    return controller.musicBrainzMatches
        .where((match) => _musicBrainzMatchMatchesQuery(match, query))
        .toList(growable: false);
  }

  bool _musicBrainzMatchMatchesQuery(
    MusicBrainzTrackMatch match,
    String query,
  ) {
    if (_musicBrainzReleaseTitleMatches(match.title, query) ||
        _musicBrainzReleaseTitleMatches(match.artist, query) ||
        (match.album != null &&
            _musicBrainzReleaseTitleMatches(match.album!, query))) {
      return true;
    }

    return match.releases.any(
      (release) =>
          _musicBrainzReleaseTitleMatches(release.title, query) ||
          (release.country != null &&
              _musicBrainzReleaseTitleMatches(release.country!, query)) ||
          (release.dateLabel != null &&
              _musicBrainzReleaseTitleMatches(release.dateLabel!, query)),
    );
  }

  bool _musicBrainzReleaseTitleMatches(String title, String query) {
    return title.trim().toLowerCase().contains(query);
  }

  String _musicBrainzLoadingSubtitle(
    AppLocalizations l10n,
    SongTagCompletionController controller,
  ) {
    if (controller.acoustidResults.isNotEmpty) {
      return l10n.musicBrainzLoadingWithResults;
    }
    return l10n.musicBrainzLoadingHint;
  }

  String _musicBrainzEmptySubtitle(
    AppLocalizations l10n,
    SongTagCompletionController controller, {
    required bool isFilteredSearch,
  }) {
    final errorMessage = controller.musicBrainzErrorMessage;
    if (errorMessage != null && errorMessage.isNotEmpty) {
      final lower = errorMessage.toLowerCase();
      if (lower.contains('socketexception') ||
          lower.contains('connection') ||
          lower.contains('network') ||
          lower.contains('timeout') ||
          lower.contains('dioexception')) {
        return l10n.musicBrainzNetworkErrorHint;
      }
      return errorMessage;
    }

    if (isFilteredSearch) {
      return l10n.musicBrainzFilteredEmptyHint;
    }

    return l10n.musicBrainzEmptyHint;
  }

  bool _hasMeaningfulText(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    final lower = trimmed.toLowerCase();
    return lower != 'unknown' &&
        lower != 'unknown artist' &&
        lower != 'unknown album';
  }

  void _toggleMusicBrainzSearchPanel() {
    setState(() {
      _isMusicBrainzSearchExpanded = !_isMusicBrainzSearchExpanded;
    });

    if (_isMusicBrainzSearchExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _musicBrainzSearchFocusNode.requestFocus();
      });
    } else {
      _musicBrainzSearchFocusNode.unfocus();
    }
  }

  void _clearMusicBrainzSearch() {
    if (_musicBrainzSearchController.text.isEmpty) return;
    _musicBrainzSearchController.clear();
  }

  Future<void> _editSummaryCondition(_SummaryCondition condition) async {
    if (!_canEditSummaryCondition(condition)) return;

    final initialValue = _summaryConditionText(condition) ?? '';

    final editedValue = await showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        return _EditSummaryConditionDialog(initialValue: initialValue);
      },
    );

    if (!mounted || editedValue == null) return;
    final trimmed = editedValue.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      final sourceValue = _summaryConditionSourceText(condition)?.trim() ?? '';
      if (trimmed == sourceValue) {
        _editedSummaryConditionTexts.remove(condition);
      } else {
        _editedSummaryConditionTexts[condition] = trimmed;
      }
    });

    await _loadMatches();
  }

  Future<void> _toggleSummaryCondition(_SummaryCondition condition) async {
    if (!mounted) return;
    setState(() {
      if (_disabledSummaryConditions.contains(condition)) {
        _disabledSummaryConditions.remove(condition);
      } else {
        _disabledSummaryConditions.add(condition);
      }
    });

    await _loadMatches();
  }

  Future<void> _loadMatches() async {
    if (!mounted) return;
    final title = _summaryConditionText(_SummaryCondition.title);
    final artist = _summaryConditionText(_SummaryCondition.artist);
    final album = _summaryConditionText(_SummaryCondition.album);

    await _controller.loadMusicBrainzMatches(
      title: title,
      artist: artist,
      album: album,
      durationMillis: _fileMetadata?.duration ?? widget.durationMillis,
      enableTitleQuery: _isSummaryConditionEnabled(_SummaryCondition.title),
      enableArtistQuery: _isSummaryConditionEnabled(_SummaryCondition.artist),
      enableAlbumQuery: _isSummaryConditionEnabled(_SummaryCondition.album),
      enableDurationQuery: _isSummaryConditionEnabled(
        _SummaryCondition.duration,
      ),
    );

    if (!mounted) return;
    setState(() {
      _expandedMusicBrainzRecordingIds.clear();
    });
  }

  Future<void> _loadAcoustIDResult() async {
    final l10n = AppLocalizations.of(context)!;
    _lastAcoustIDClientErrorMessage = null;
    final durationSec = (_fileMetadata?.duration ?? widget.durationMillis ?? 0);
    await _controller.loadAcoustIDResult(durationMillis: durationSec);

    final acoustidErrorMessage = _controller.acoustidClientErrorMessage;
    if (mounted &&
        acoustidErrorMessage != null &&
        acoustidErrorMessage != _lastAcoustIDClientErrorMessage) {
      _lastAcoustIDClientErrorMessage = acoustidErrorMessage;
      AppSnackBar.show(
        context,
        ref,
        SnackBar(
          content: Text(acoustidErrorMessage),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: l10n.goToSettings,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pushReplacement(
                buildMainLayoutRoute(args: const [], initialIndex: 4),
              );
            },
          ),
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _expandedAcoustIDIds.clear();
      _expandedReleaseGroupIds.clear();
      _expandedMusicBrainzRecordingIds.clear();
    });
  }

  Future<void> _applyAcoustIDSelection({
    required AcoustIDResult trackResult,
    required AcoustIDRecording recording,
    required String albumTitle,
    required String sourceLabel,
    required String fallbackTitle,
    required int? fallbackDurationMillis,
    String? releaseId,
    String? releaseGroupId,
    String? coverLargeUrl,
    String? coverThumbnailUrl,
    Map<String, dynamic>? raw,
    String? country,
    String? releaseDate,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (RemoteMediaResolver.isRemoteUri(widget.songPath)) {
      showToast(l10n.remoteSongCannotEditTags);
      return;
    }
    final shouldSaveToSource = ref.read(settingsServiceProvider).tagCompletionSaveToSourceFile && isMetadataWritable(widget.songPath);
    final result = await _controller.applyAcoustIDSelection(
      trackResult: trackResult,
      recording: recording,
      albumTitle: albumTitle,
      sourceLabel: sourceLabel,
      fallbackTitle: fallbackTitle,
      fallbackDurationMillis: fallbackDurationMillis,
      releaseId: releaseId,
      releaseGroupId: releaseGroupId,
      coverLargeUrl: coverLargeUrl,
      coverThumbnailUrl: coverThumbnailUrl,
      raw: raw,
      country: country,
      releaseDate: releaseDate,
      existingMetadata: _fileMetadata,
      writeToFile: shouldSaveToSource,
    );
    if (!mounted) return;
    if (result == null) {
      final isOccupied = MetadataHelper.lastWriteError == 'file_occupied';
      showToast(
        isOccupied ? l10n.fileOccupiedByOtherApp : (_controller.errorMessage ?? l10n.saveFailed),
      );
      return;
    }
    Navigator.of(context).pop((result, shouldSaveToSource));
  }

  Future<void> _applyAcoustIDReleaseGroup(
    AcoustIDResult trackResult,
    AcoustIDRecording recording,
    AcoustIDReleaseGroup releaseGroup,
  ) async {
    await _applyAcoustIDSelection(
      trackResult: trackResult,
      recording: recording,
      albumTitle: releaseGroup.title,
      sourceLabel: 'AcoustID release-group',
      fallbackTitle: _displayTitle,
      fallbackDurationMillis: _fileMetadata?.duration ?? widget.durationMillis,
      releaseGroupId: releaseGroup.id,
      coverLargeUrl: releaseGroup.largeUrl,
      coverThumbnailUrl: releaseGroup.thumbnailUrl,
      raw: {
        'track': trackResult.raw,
        'recording': recording.raw,
        'releaseGroup': releaseGroup.raw,
      },
    );
  }

  Future<void> _applyAcoustIDRelease(
    AcoustIDResult trackResult,
    AcoustIDRecording recording,
    AcoustIDReleaseGroup releaseGroup,
    AcoustIDRelease release,
  ) async {
    await _applyAcoustIDSelection(
      trackResult: trackResult,
      recording: recording,
      albumTitle: release.title,
      sourceLabel: 'AcoustID release',
      fallbackTitle: _displayTitle,
      fallbackDurationMillis: _fileMetadata?.duration ?? widget.durationMillis,
      releaseId: release.id,
      releaseGroupId: releaseGroup.id,
      coverLargeUrl: release.largeUrl,
      coverThumbnailUrl: release.thumbnailUrl,
      country: release.country,
      releaseDate: release.dateLabel,
      raw: {
        'track': trackResult.raw,
        'recording': recording.raw,
        'releaseGroup': releaseGroup.raw,
        'release': release.raw,
      },
    );
  }

  Future<void> _applyMusicBrainzRelease(
    MusicBrainzTrackMatch match,
    MusicBrainzReleaseMatch release,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (RemoteMediaResolver.isRemoteUri(widget.songPath)) {
      showToast(l10n.remoteSongCannotEditTags);
      return;
    }
    final shouldSaveToSource = ref.read(settingsServiceProvider).tagCompletionSaveToSourceFile && isMetadataWritable(widget.songPath);
    final result = await _controller.applyMusicBrainzRelease(
      match: match,
      release: release,
      fallbackDurationMillis: _fileMetadata?.duration ?? widget.durationMillis,
      existingMetadata: _fileMetadata,
      writeToFile: shouldSaveToSource,
    );

    if (!mounted) return;
    if (result == null) {
      final isOccupied = MetadataHelper.lastWriteError == 'file_occupied';
      showToast(
        isOccupied ? l10n.fileOccupiedByOtherApp : (_controller.errorMessage ?? l10n.saveFailed),
      );
      return;
    }
    Navigator.of(context).pop((result, shouldSaveToSource));
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    SongTagCompletionController controller,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tagCompletion,
                      style: TextStyle(
                        color: isDark ? Colors.white : theme.colorScheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.tagCompletionDescription,
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
                onPressed: _toggleMusicBrainzSearchPanel,
                icon: Icon(
                  _isMusicBrainzSearchExpanded
                      ? Icons.search_off_rounded
                      : Icons.search_rounded,
                  color: _hasMusicBrainzSearchQuery
                      ? const Color(0xFF46D27A)
                      : (isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant),
                ),
                tooltip: _isMusicBrainzSearchExpanded
                    ? l10n.closeSearch
                    : l10n.searchReleaseTitles,
              ),
              IconButton(
                onPressed: controller.isMusicBrainzLoading
                    ? null
                    : _loadMatches,
                icon: Icon(
                  Icons.refresh_rounded,
                  color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                ),
                tooltip: l10n.refreshResults,
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close_rounded,
                  color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                ),
                tooltip: l10n.close,
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _isMusicBrainzSearchExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextField(
                      controller: _musicBrainzSearchController,
                      focusNode: _musicBrainzSearchFocusNode,
                      style: TextStyle(color: isDark ? Colors.white : theme.colorScheme.onSurface),
                      cursorColor: theme.colorScheme.primary,
                      decoration: InputDecoration(
                        hintText: l10n.filterMusicBrainzReleaseTitle,
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.35) : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark ? Colors.white.withValues(alpha: 0.45) : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        suffixIcon: _hasMusicBrainzSearchQuery
                            ? IconButton(
                                onPressed: _clearMusicBrainzSearch,
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: isDark ? Colors.white.withValues(alpha: 0.55) : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                ),
                                tooltip: l10n.clearSearch,
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    AppLocalizations l10n,
    SongTagCompletionController controller,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final summaryItems = <Widget>[
      SongTagSummaryChip(
        label: l10n.localTitle,
        value: _summaryConditionText(_SummaryCondition.title) ?? _displayTitle,
        enabled: _isSummaryConditionEnabled(_SummaryCondition.title),
        onTap: () => _toggleSummaryCondition(_SummaryCondition.title),
        onEdit: () => _editSummaryCondition(_SummaryCondition.title),
      ),
      if ((_fileMetadata?.artist ?? widget.currentArtist ?? '')
          .trim()
          .isNotEmpty)
        SongTagSummaryChip(
          label: l10n.artistLabel,
          value:
              _summaryConditionText(_SummaryCondition.artist) ??
              (_fileMetadata?.artist ?? widget.currentArtist!).trim(),
          enabled: _isSummaryConditionEnabled(_SummaryCondition.artist),
          onTap: () => _toggleSummaryCondition(_SummaryCondition.artist),
          onEdit: () => _editSummaryCondition(_SummaryCondition.artist),
        ),
      if ((_fileMetadata?.album ?? widget.currentAlbum ?? '').trim().isNotEmpty)
        SongTagSummaryChip(
          label: l10n.albumLabel,
          value:
              _summaryConditionText(_SummaryCondition.album) ??
              (_fileMetadata?.album ?? widget.currentAlbum!).trim(),
          enabled: _isSummaryConditionEnabled(_SummaryCondition.album),
          onTap: () => _toggleSummaryCondition(_SummaryCondition.album),
          onEdit: () => _editSummaryCondition(_SummaryCondition.album),
        ),
      if (_fileMetadata?.duration != null || widget.durationMillis != null)
        SongTagSummaryChip(
          label: l10n.durationLabel,
          value:
              '${((_fileMetadata?.duration ?? widget.durationMillis!) ~/ 60000).toString().padLeft(2, '0')}:${(((_fileMetadata?.duration ?? widget.durationMillis!) ~/ 1000) % 60).toString().padLeft(2, '0')}',
          enabled: _isSummaryConditionEnabled(_SummaryCondition.duration),
          onTap: () => _toggleSummaryCondition(_SummaryCondition.duration),
        ),
    ];

    final rows = <Widget>[];
    for (int i = 0; i < summaryItems.length; i += 2) {
      final item1 = summaryItems[i];
      final item2 = i + 1 < summaryItems.length ? summaryItems[i + 1] : null;
      if (i > 0) {
        rows.add(const SizedBox(height: 8));
      }
      rows.add(
        Row(
          children: [
            Flexible(child: item1),
            if (item2 != null) ...[
              const SizedBox(width: 8),
              Flexible(child: item2),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.queryConditions,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.68) : theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    SongTagCompletionController controller,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filteredMusicBrainzMatches = _filteredMusicBrainzMatches(controller);
    final hasFilteredMusicBrainzMatches = filteredMusicBrainzMatches.isNotEmpty;
    final hasAnyResults =
        controller.acoustidResults.isNotEmpty || hasFilteredMusicBrainzMatches;
    final isMusicBrainzFilteringEmpty =
        controller.musicBrainzMatches.isNotEmpty &&
        _hasMusicBrainzSearchQuery &&
        filteredMusicBrainzMatches.isEmpty;

    if (controller.isMusicBrainzLoading &&
        controller.acoustidResults.isEmpty &&
        !hasFilteredMusicBrainzMatches) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 38,
                height: 38,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.musicBrainzLoading,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _musicBrainzLoadingSubtitle(l10n, controller),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.6) : theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!controller.isMusicBrainzLoading &&
        controller.musicBrainzErrorMessage != null &&
        controller.acoustidResults.isEmpty &&
        !hasFilteredMusicBrainzMatches) {
      return SongTagEmptyState(
        icon: Icons.wifi_off_rounded,
        title: l10n.musicBrainzQueryFailed,
        subtitle: _musicBrainzEmptySubtitle(
          l10n,
          controller,
          isFilteredSearch: isMusicBrainzFilteringEmpty,
        ),
        actionLabel: l10n.retry,
        onAction: () {
          _loadMatches();
          _loadAcoustIDResult();
        },
      );
    }

    final children = <Widget>[];

    if (controller.isMusicBrainzLoading) {
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _musicBrainzLoadingSubtitle(l10n, controller),
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.72) : theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (controller.acoustidResults.isNotEmpty ||
          hasFilteredMusicBrainzMatches) {
        children.add(const SizedBox(height: 10));
      }
    }

    if (controller.isAcoustIDLoading) {
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isDark ? Colors.white.withValues(alpha: 0.5) : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      );
    } else if (controller.acoustidResults.isNotEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
          child: Text(
            l10n.acoustidRecognitionRecords,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.72) : theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      for (var i = 0; i < controller.acoustidResults.length; i++) {
        final result = controller.acoustidResults[i];
        final trackKey = result.id.isNotEmpty ? result.id : 'track_$i';
        children.add(
          SongTagAcoustIDResultCard(
            result: result,
            index: i,
            displayTitle: _displayTitle,
            isApplying: controller.isApplying,
            isExpanded: _expandedAcoustIDIds.contains(trackKey),
            onToggleExpanded: () {
              setState(() {
                if (_expandedAcoustIDIds.contains(trackKey)) {
                  _expandedAcoustIDIds.remove(trackKey);
                } else {
                  _expandedAcoustIDIds.add(trackKey);
                }
              });
            },
            isReleaseGroupExpanded: (releaseGroupId) =>
                _expandedReleaseGroupIds.contains(releaseGroupId),
            onToggleReleaseGroupExpanded: (releaseGroupId) {
              setState(() {
                if (_expandedReleaseGroupIds.contains(releaseGroupId)) {
                  _expandedReleaseGroupIds.remove(releaseGroupId);
                } else {
                  _expandedReleaseGroupIds.add(releaseGroupId);
                }
              });
            },
            onApplyReleaseGroup: _applyAcoustIDReleaseGroup,
            onApplyRelease: _applyAcoustIDRelease,
          ),
        );
        if (i < controller.acoustidResults.length - 1) {
          children.add(const SizedBox(height: 8));
        }
      }
      children.add(const SizedBox(height: 10));
    }

    if (!controller.isMusicBrainzLoading) {
      if (!hasAnyResults) {
        return Center(
          child: SongTagEmptyState(
            icon: Icons.search_off_rounded,
            title: _hasMusicBrainzSearchQuery
                ? l10n.noMatchingRelease
                : l10n.noMatchingResults,
            subtitle: _musicBrainzEmptySubtitle(
              l10n,
              controller,
              isFilteredSearch: isMusicBrainzFilteringEmpty,
            ),
            actionLabel: _hasMusicBrainzSearchQuery
                ? l10n.clearSearch
                : l10n.searchAgain,
            onAction: () {
              if (_hasMusicBrainzSearchQuery) {
                _clearMusicBrainzSearch();
              } else {
                _loadMatches();
                _loadAcoustIDResult();
              }
            },
          ),
        );
      }

      if (hasFilteredMusicBrainzMatches) {
        if (children.isNotEmpty) {
          children.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
              child: Text(
                l10n.musicBrainzRecordings,
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.72) : theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }

        for (var i = 0; i < filteredMusicBrainzMatches.length; i++) {
          final match = filteredMusicBrainzMatches[i];
          final recordingKey = match.recordingId.isNotEmpty
              ? match.recordingId
              : 'recording_$i';
          children.add(
            SongTagMusicBrainzRecordingCard(
              match: match,
              index: i,
              displayTitle: _displayTitle,
              service: controller.service,
              isApplying: controller.isApplying,
              isExpanded: _expandedMusicBrainzRecordingIds.contains(
                recordingKey,
              ),
              onToggleExpanded: () {
                setState(() {
                  if (_expandedMusicBrainzRecordingIds.contains(recordingKey)) {
                    _expandedMusicBrainzRecordingIds.remove(recordingKey);
                  } else {
                    _expandedMusicBrainzRecordingIds.add(recordingKey);
                  }
                });
              },
              onApplyRelease: _applyMusicBrainzRelease,
            ),
          );
          if (i < filteredMusicBrainzMatches.length - 1) {
            children.add(const SizedBox(height: 8));
          }
        }
      }
    }

    if (children.isEmpty) {
      return Center(
        child: SongTagEmptyState(
          icon: Icons.search_off_rounded,
          title: l10n.noMatchingResults,
          subtitle: l10n.noMatchingResultHint,
          actionLabel: l10n.searchAgain,
          onAction: () {
            _loadMatches();
            _loadAcoustIDResult();
          },
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(
      songTagCompletionControllerProvider(widget.songPath),
    );
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.88,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.82) : theme.colorScheme.surface.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, l10n, controller),
                    _buildSummary(context, l10n, controller),
                    const SizedBox(height: 14),
                    Expanded(child: _buildBody(context, l10n, controller)),
                  ],
                ),
                if (controller.isApplying)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.35),
                      child: const Center(child: CircularProgressIndicator()),
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

class _EditSummaryConditionDialog extends StatefulWidget {
  const _EditSummaryConditionDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_EditSummaryConditionDialog> createState() =>
      _EditSummaryConditionDialogState();
}

class _EditSummaryConditionDialogState
    extends State<_EditSummaryConditionDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canSave = _controller.text.trim().isNotEmpty;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF171717) : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        l10n.editQueryCondition,
        style: TextStyle(color: isDark ? Colors.white : theme.colorScheme.onSurface),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        style: TextStyle(color: isDark ? Colors.white : theme.colorScheme.onSurface),
        cursorColor: theme.colorScheme.primary,
        decoration: InputDecoration(
          hintText: l10n.enterNewQueryText,
          hintStyle: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.35) : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
        ),
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        onChanged: (_) => setState(() {}),
        onSubmitted: canSave ? (_) => _submit() : null,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancel,
            style: TextStyle(color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant),
          ),
        ),
        FilledButton(
          onPressed: canSave ? _submit : null,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
