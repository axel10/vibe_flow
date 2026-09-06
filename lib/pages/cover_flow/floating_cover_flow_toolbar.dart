import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vynody/player/settings/settings_service.dart';

import '../../dialogs/sort_options_dialog.dart';
import '../../l10n/app_localizations.dart';

class FloatingCoverFlowToolbar extends StatefulWidget {
  const FloatingCoverFlowToolbar({
    super.key,
    required this.albumCount,
    required this.sortField,
    required this.sortAscending,
    required this.onViewModeToggled,
    required this.onShufflePressed,
    required this.onSortChanged,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchCleared,
    this.isDesktop = false,
  });

  final int albumCount;
  final AlbumSortField sortField;
  final bool sortAscending;
  final VoidCallback onViewModeToggled;
  final VoidCallback onShufflePressed;
  final void Function(AlbumSortField field, bool sortAscending) onSortChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;
  final bool isDesktop;

  @override
  State<FloatingCoverFlowToolbar> createState() =>
      _FloatingCoverFlowToolbarState();
}

class _FloatingCoverFlowToolbarState extends State<FloatingCoverFlowToolbar> {
  bool _isSearchExpanded = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isSearchExpanded = widget.searchQuery.isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant FloatingCoverFlowToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery.isNotEmpty && !_isSearchExpanded) {
      _isSearchExpanded = true;
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _expandSearch() {
    setState(() {
      _isSearchExpanded = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _collapseSearch() {
    widget.onSearchCleared();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final pillBg = isDark
        ? Colors.black.withValues(alpha: 0.65)
        : Colors.white.withValues(alpha: 0.85);
    final borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.35);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Album badge with back button
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: '${l10n.gridView} (ESC)',
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                onPressed: widget.onViewModeToggled,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.album_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '${l10n.albums} (${widget.albumCount})',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Right: Control buttons (Search, Shuffle, Sort)
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOutCubic,
                  child: _isSearchExpanded
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 8),
                            Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 100,
                                maxWidth: widget.isDesktop ? 220 : 160,
                              ),
                              child: Focus(
                                onKeyEvent: (node, event) {
                                  if (event is KeyDownEvent &&
                                      event.logicalKey ==
                                          LogicalKeyboardKey.escape) {
                                    _collapseSearch();
                                    return KeyEventResult.handled;
                                  }
                                  return KeyEventResult.ignored;
                                },
                                child: TextField(
                                  focusNode: _searchFocusNode,
                                  controller: widget.searchController,
                                  onChanged: widget.onSearchChanged,
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: (_) {
                                    _searchFocusNode.unfocus();
                                  },
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    border: InputBorder.none,
                                    hintText: l10n.searchAlbums,
                                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: widget.searchQuery.isNotEmpty
                                  ? l10n.clearSearch
                                  : l10n.closeSearch,
                              iconSize: 18,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              onPressed: () {
                                if (widget.searchQuery.isNotEmpty) {
                                  widget.onSearchCleared();
                                } else {
                                  _collapseSearch();
                                }
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                            Container(
                              width: 1,
                              height: 16,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              color: borderColor,
                            ),
                          ],
                        )
                      : IconButton(
                          tooltip: l10n.search,
                          iconSize: 20,
                          visualDensity: VisualDensity.compact,
                          onPressed: _expandSearch,
                          icon: const Icon(Icons.search_rounded),
                        ),
                ),
                IconButton(
                  tooltip: l10n.shuffleAlbumOrder,
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.onShufflePressed,
                  icon: const Icon(Icons.shuffle_rounded),
                ),
                IconButton(
                  tooltip: l10n.albumSort,
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  onPressed: () async {
                    final result = await showDialog<SortResult<AlbumSortField>>(
                      context: context,
                      builder: (context) => SortOptionsDialog<AlbumSortField>(
                        title: l10n.albumSort,
                        currentField: widget.sortField,
                        sortAscending: widget.sortAscending,
                        options: [
                          SortOptionItem(
                            value: AlbumSortField.artist,
                            label: l10n.sortArtistAsc,
                            icon: Icons.person_rounded,
                          ),
                          SortOptionItem(
                            value: AlbumSortField.title,
                            label: l10n.sortTitleAsc,
                            icon: Icons.album_rounded,
                          ),
                          SortOptionItem(
                            value: AlbumSortField.trackCount,
                            label: l10n.sortTrackCount,
                            icon: Icons.format_list_numbered_rounded,
                          ),
                          SortOptionItem(
                            value: AlbumSortField.duration,
                            label: l10n.sortDuration,
                            icon: Icons.access_time_rounded,
                          ),
                          SortOptionItem(
                            value: AlbumSortField.recentAdded,
                            label: l10n.sortRecentAdded,
                            icon: Icons.add_circle_outline_rounded,
                          ),
                        ],
                      ),
                    );
                    if (result != null) {
                      widget.onSortChanged(result.field, result.sortAscending);
                    }
                  },
                  icon: const Icon(Icons.sort_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
