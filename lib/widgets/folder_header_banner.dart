import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vynody/l10n/app_localizations.dart';

class FolderHeaderBanner extends StatelessWidget {
  const FolderHeaderBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.songsCount,
    required this.totalDuration,
    required this.coverWidget,
    required this.actionButtons,
    this.actionButtonsScrollable = false,
    required this.isSearching,
    required this.searchController,
    required this.searchQuery,
    required this.searchHintText,
    required this.onSearchQueryChanged,
    required this.onToggleSearch,
    this.heroTag,
    this.isHeroModeEnabled = true,
  });

  final String title;
  final String subtitle;
  final int songsCount;
  final Duration totalDuration;
  final Widget coverWidget;
  final List<Widget> actionButtons;
  final bool actionButtonsScrollable;
  final bool isSearching;
  final TextEditingController searchController;
  final String searchQuery;
  final String searchHintText;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<bool> onToggleSearch;
  final String? heroTag;
  final bool isHeroModeEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    final seconds = totalDuration.inSeconds.remainder(60);

    final String durationText;
    if (l10n.localeName == 'zh') {
      if (hours > 0) {
        durationText = '$hours小时$minutes分钟';
      } else if (minutes > 0) {
        durationText = '$minutes分钟$seconds秒';
      } else {
        durationText = '$seconds秒';
      }
    } else {
      if (hours > 0) {
        durationText = '${hours}h ${minutes}m';
      } else if (minutes > 0) {
        durationText = '${minutes}m ${seconds}s';
      } else {
        durationText = '${seconds}s';
      }
    }

    Widget resolvedCover = coverWidget;
    if (heroTag != null) {
      resolvedCover = HeroMode(
        enabled: isHeroModeEnabled,
        child: Hero(
          tag: heroTag!,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: coverWidget,
          ),
        ),
      );
    } else {
      resolvedCover = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: coverWidget,
      );
    }

    Widget buildInfoColumn() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.left,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '${l10n.songCount(songsCount)} | $durationText',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    Widget buildSearchTextField({bool compact = false}) {
      return TextField(
        controller: searchController,
        autofocus: true,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: searchHintText,
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: () {
                    searchController.clear();
                    onSearchQueryChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.8),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: compact ? 6 : 8,
          ),
          isDense: true,
        ),
        onChanged: onSearchQueryChanged,
      );
    }

    Widget buildSearchIconButton() {
      final isLargeScreen = MediaQuery.of(context).size.width >= 1000;
      return IconButton(
        onPressed: () {
          onToggleSearch(true);
        },
        icon: Icon(Icons.search_rounded, size: isLargeScreen ? 18 : 16),
        tooltip: l10n.search,
        style: IconButton.styleFrom(
          minimumSize: Size(isLargeScreen ? 38 : 32, isLargeScreen ? 38 : 32),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 540 && MediaQuery.of(context).size.width >= 900;

        if (isWideScreen) {
          return Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                resolvedCover,
                const SizedBox(width: 16),
                Expanded(
                  child: buildInfoColumn(),
                ),
                const SizedBox(width: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSearching
                      ? Row(
                          key: const ValueKey('wide-search-active'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 260,
                              child: buildSearchTextField(compact: true),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              onPressed: () {
                                searchController.clear();
                                onSearchQueryChanged('');
                                onToggleSearch(false);
                              },
                              style: IconButton.styleFrom(
                                minimumSize: const Size(32, 32),
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          key: const ValueKey('wide-actions-normal'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (actionButtonsScrollable)
                              Flexible(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: actionButtons,
                                  ),
                                ),
                              )
                            else
                              ...actionButtons,
                            const SizedBox(width: 8),
                            buildSearchIconButton(),
                          ],
                        ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  resolvedCover,
                  const SizedBox(width: 16),
                  Expanded(
                    child: buildInfoColumn(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSearching
                    ? Row(
                        key: const ValueKey('search-active-row'),
                        children: [
                          Expanded(
                            child: buildSearchTextField(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              searchController.clear();
                              onSearchQueryChanged('');
                              onToggleSearch(false);
                            },
                          ),
                        ],
                      )
                    : Row(
                        key: const ValueKey('actions-normal-row'),
                        children: [
                          if (actionButtonsScrollable)
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: actionButtons,
                                ),
                              ),
                            )
                          else ...[
                            ...actionButtons,
                            const Spacer(),
                          ],
                          const SizedBox(width: 8),
                          buildSearchIconButton(),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FolderPlayActionButtons extends StatelessWidget {
  const FolderPlayActionButtons({
    super.key,
    required this.onPlayAll,
    required this.onShufflePlay,
    required this.totalSongsCount,
  });

  final FutureOr<void> Function()? onPlayAll;
  final FutureOr<void> Function()? onShufflePlay;
  final int totalSongsCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWiderScreen = screenWidth > 480;
    final isLargeScreen = screenWidth >= 1000;
    final isDisabled = totalSongsCount == 0 || (onPlayAll == null && onShufflePlay == null);

    final playAllButton = isWiderScreen
        ? FilledButton.tonalIcon(
            onPressed: isDisabled ? null : () => onPlayAll?.call(),
            icon: Icon(Icons.play_arrow_rounded, size: isLargeScreen ? 18 : 16),
            label: Text(l10n.playAll),
            style: FilledButton.styleFrom(
              minimumSize: Size(0, isLargeScreen ? 38 : 32),
              padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 16 : 12),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              textStyle: TextStyle(
                fontSize: isLargeScreen ? 13.0 : 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : Tooltip(
            message: l10n.playAll,
            child: FilledButton.tonal(
              onPressed: isDisabled ? null : () => onPlayAll?.call(),
              style: FilledButton.styleFrom(
                minimumSize: const Size(32, 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              child: const Icon(Icons.play_arrow_rounded, size: 16),
            ),
          );

    final shuffleButton = isWiderScreen
        ? FilledButton.tonalIcon(
            onPressed: isDisabled ? null : () => onShufflePlay?.call(),
            icon: Icon(Icons.shuffle_rounded, size: isLargeScreen ? 18 : 16),
            label: Text(l10n.shuffle),
            style: FilledButton.styleFrom(
              minimumSize: Size(0, isLargeScreen ? 38 : 32),
              padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 16 : 12),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              textStyle: TextStyle(
                fontSize: isLargeScreen ? 13.0 : 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : Tooltip(
            message: l10n.shuffle,
            child: FilledButton.tonal(
              onPressed: isDisabled ? null : () => onShufflePlay?.call(),
              style: FilledButton.styleFrom(
                minimumSize: const Size(32, 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              child: const Icon(Icons.shuffle_rounded, size: 16),
            ),
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        playAllButton,
        const SizedBox(width: 8),
        shuffleButton,
      ],
    );
  }
}
