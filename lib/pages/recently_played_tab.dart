import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'package:vynody/player/library/library_insights_service.dart';
import '../widgets/library_ranked_song_list.dart';

class RecentlyPlayedTab extends ConsumerStatefulWidget {
  const RecentlyPlayedTab({super.key});

  @override
  ConsumerState<RecentlyPlayedTab> createState() => _RecentlyPlayedTabState();
}

class _RecentlyPlayedTabState extends ConsumerState<RecentlyPlayedTab> {
  LibraryTimeRange _selectedRange = LibraryTimeRange.allTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncItems = ref.watch(recentlyPlayedSongsProvider(_selectedRange));

    return asyncItems.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (items) => LibraryRankedSongList(
        title: l10n.recentlyPlayed,
        subtitle: l10n.recentlyPlayedDescription,
        items: items,
        selectedRange: _selectedRange,
        onRangeChanged: (value) {
          setState(() {
            _selectedRange = value;
          });
        },
        emptyText: _selectedRange == LibraryTimeRange.allTime
            ? l10n.noRecentlyPlayedSongs
            : l10n.noRecentlyPlayedInRange,
        trailingBuilder: (context, entry) => InsightMetricText(
          primary: formatRelativeInsightDate(context, entry.lastPlayedAt),
          secondary: l10n.playCountLabel(entry.playCount),
        ),
      ),
    );
  }
}
