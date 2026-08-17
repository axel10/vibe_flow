import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:vynody/player/settings/settings_service.dart';

class ButtonItemInfo {
  final String key;
  final IconData icon;
  final String Function(AppLocalizations l10n) getLabel;

  const ButtonItemInfo({
    required this.key,
    required this.icon,
    required this.getLabel,
  });
}

const List<ButtonItemInfo> allPlaybackCandidateButtons = [
  ButtonItemInfo(
    key: 'more',
    icon: Icons.more_horiz,
    getLabel: _getMoreLabel,
  ),
  ButtonItemInfo(
    key: 'favorite',
    icon: Icons.favorite_rounded,
    getLabel: _getFavoriteLabel,
  ),
  ButtonItemInfo(
    key: 'playlist_mode',
    icon: Icons.repeat,
    getLabel: _getPlaylistModeLabel,
  ),
  ButtonItemInfo(
    key: 'shuffle',
    icon: Icons.shuffle_rounded,
    getLabel: _getShuffleLabel,
  ),
  ButtonItemInfo(
    key: 'tag_completion',
    icon: Icons.auto_fix_high_rounded,
    getLabel: _getTagCompletionLabel,
  ),
  ButtonItemInfo(
    key: 'sleep_timer',
    icon: Icons.bedtime_rounded,
    getLabel: _getSleepTimerLabel,
  ),
  ButtonItemInfo(
    key: 'equalizer',
    icon: Icons.tune_rounded,
    getLabel: _getEqualizerLabel,
  ),
  ButtonItemInfo(
    key: 'visualizer',
    icon: Icons.analytics,
    getLabel: _getVisualizerLabel,
  ),
  ButtonItemInfo(
    key: 'volume',
    icon: Icons.volume_up_rounded,
    getLabel: _getVolumeLabel,
  ),
];

String _getMoreLabel(AppLocalizations l10n) => l10n.btnMore;
String _getFavoriteLabel(AppLocalizations l10n) => l10n.btnFavorite;
String _getPlaylistModeLabel(AppLocalizations l10n) => l10n.btnPlaylistMode;
String _getShuffleLabel(AppLocalizations l10n) => l10n.btnShuffle;
String _getTagCompletionLabel(AppLocalizations l10n) => l10n.btnTagCompletion;
String _getSleepTimerLabel(AppLocalizations l10n) => l10n.btnSleepTimer;
String _getEqualizerLabel(AppLocalizations l10n) => l10n.btnEqualizer;
String _getVisualizerLabel(AppLocalizations l10n) => l10n.btnVisualizer;
String _getVolumeLabel(AppLocalizations l10n) => l10n.btnVolume;

ButtonItemInfo getButtonItemInfo(String key) {
  return allPlaybackCandidateButtons.firstWhere(
    (item) => item.key == key,
    orElse: () => allPlaybackCandidateButtons.first,
  );
}

class PlaybackButtonLayoutView extends StatefulWidget {
  const PlaybackButtonLayoutView({
    super.key,
    required this.settings,
    this.onChanged,
  });

  final SettingsService settings;
  final VoidCallback? onChanged;

  @override
  State<PlaybackButtonLayoutView> createState() =>
      _PlaybackButtonLayoutViewState();
}

class _PlaybackButtonLayoutViewState extends State<PlaybackButtonLayoutView> {
  late List<String> _topButtons;
  late String _leftButton;
  late String _rightButton;
  late String _lyricsHeaderButton;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _loadState() {
    _topButtons = List<String>.from(widget.settings.topButtonsOrder);
    _leftButton = widget.settings.mainControlsLeftButton;
    _rightButton = widget.settings.mainControlsRightButton;
    _lyricsHeaderButton = widget.settings.lyricsHeaderRightButton;
  }

  void _saveAllState() {
    widget.settings.topButtonsOrder = List<String>.from(_topButtons);
    widget.settings.mainControlsLeftButton = _leftButton;
    widget.settings.mainControlsRightButton = _rightButton;
    widget.settings.lyricsHeaderRightButton = _lyricsHeaderButton;
    widget.onChanged?.call();
  }

  void _saveTopButtons(List<String> newOrder) {
    setState(() {
      _topButtons = List<String>.from(newOrder);
    });
    _saveAllState();
  }

  void _replaceTopButtonAt(int index, String newKey) {
    if (_topButtons[index] == newKey) return;
    setState(() {
      final oldKey = _topButtons[index];
      final existingTopIdx = _topButtons.indexOf(newKey);

      if (existingTopIdx != -1) {
        _topButtons[existingTopIdx] = oldKey;
        _topButtons[index] = newKey;
      } else if (newKey == _leftButton) {
        _leftButton = oldKey;
        _topButtons[index] = newKey;
      } else if (newKey == _rightButton) {
        _rightButton = oldKey;
        _topButtons[index] = newKey;
      } else {
        _topButtons[index] = newKey;
      }
    });
    _saveAllState();
  }

  void _saveLeftButton(String newKey) {
    if (_leftButton == newKey) return;
    setState(() {
      final oldLeft = _leftButton;
      if (newKey == _rightButton) {
        _rightButton = oldLeft;
        _leftButton = newKey;
      } else {
        final topIdx = _topButtons.indexOf(newKey);
        if (topIdx != -1) {
          _topButtons[topIdx] = oldLeft;
        }
        _leftButton = newKey;
      }
    });
    _saveAllState();
  }

  void _saveRightButton(String newKey) {
    if (_rightButton == newKey) return;
    setState(() {
      final oldRight = _rightButton;
      if (newKey == _leftButton) {
        _leftButton = oldRight;
        _rightButton = newKey;
      } else {
        final topIdx = _topButtons.indexOf(newKey);
        if (topIdx != -1) {
          _topButtons[topIdx] = oldRight;
        }
        _rightButton = newKey;
      }
    });
    _saveAllState();
  }

  void _saveLyricsHeaderButton(String key) {
    setState(() {
      _lyricsHeaderButton = key;
    });
    _saveAllState();
  }

  void _resetToDefault() {
    widget.settings.resetPlaybackButtonsToDefault();
    setState(() {
      _loadState();
    });
    _saveAllState();
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // 1. 7 按钮行排序
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.topButtonsRowTitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: _resetToDefault,
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.restart_alt_rounded, size: 16),
              label: Text(l10n.resetButtonOrder),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildSectionCard(
          context: context,
          child: Column(
            children: [
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: _topButtons.length,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final list = List<String>.from(_topButtons);
                  final item = list.removeAt(oldIndex);
                  list.insert(newIndex, item);
                  _saveTopButtons(list);
                },
                itemBuilder: (context, index) {
                  final key = _topButtons[index];
                  final info = getButtonItemInfo(key);
                  return Container(
                    key: ValueKey('top_btn_$key'),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            info.icon,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${index + 1}.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        info.getLabel(l10n),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuButton<String>(
                            tooltip: '替换按键',
                            icon: Icon(
                              Icons.swap_horiz_rounded,
                              size: 18,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                            onSelected: (newKey) {
                              _replaceTopButtonAt(index, newKey);
                            },
                            itemBuilder: (context) => allPlaybackCandidateButtons.map((btn) {
                              return PopupMenuItem<String>(
                                value: btn.key,
                                child: Row(
                                  children: [
                                    Icon(btn.icon, size: 18, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Text(btn.getLabel(l10n)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          ReorderableDragStartListener(
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.drag_handle,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 2. 5 按钮行左右按钮设置
        Text(
          l10n.mainButtonsRowTitle,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        _buildSectionCard(
          context: context,
          child: Column(
            children: [
              // 预览条形图
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPreviewButton(context, _leftButton, l10n, isAccent: true),
                    _buildPreviewIcon(context, Icons.skip_previous_rounded),
                    _buildPreviewIcon(context, Icons.play_arrow_rounded, isLarge: true),
                    _buildPreviewIcon(context, Icons.skip_next_rounded),
                    _buildPreviewButton(context, _rightButton, l10n, isAccent: true),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildDropdownTile(
                context: context,
                label: l10n.mainControlsLeftButton,
                value: _leftButton,
                onChanged: (val) {
                  if (val != null) _saveLeftButton(val);
                },
              ),
              const Divider(height: 12),
              _buildDropdownTile(
                context: context,
                label: l10n.mainControlsRightButton,
                value: _rightButton,
                onChanged: (val) {
                  if (val != null) _saveRightButton(val);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 3. 歌词模式标题栏右侧按钮
        Text(
          l10n.lyricsHeaderRightButtonTitle,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        _buildSectionCard(
          context: context,
          child: _buildDropdownTile(
            context: context,
            label: l10n.lyricsHeaderRightButtonTitle,
            value: _lyricsHeaderButton,
            onChanged: (val) {
              if (val != null) _saveLyricsHeaderButton(val);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPreviewIcon(BuildContext context, IconData icon, {bool isLarge = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Icon(
      icon,
      size: isLarge ? 28 : 22,
      color: isDark ? Colors.white70 : Colors.black87,
    );
  }

  Widget _buildPreviewButton(
    BuildContext context,
    String key,
    AppLocalizations l10n, {
    bool isAccent = false,
  }) {
    final info = getButtonItemInfo(key);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isAccent ? theme.colorScheme.primaryContainer : Colors.transparent,
      ),
      child: Icon(
        info.icon,
        size: 20,
        color: isAccent ? theme.colorScheme.primary : theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildDropdownTile({
    required BuildContext context,
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedInfo = getButtonItemInfo(value);

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        PopupMenuButton<String>(
          onSelected: onChanged,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(selectedInfo.icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  selectedInfo.getLabel(l10n),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 20,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ],
            ),
          ),
          itemBuilder: (context) => allPlaybackCandidateButtons.map((item) {
            final isSelected = item.key == value;
            return PopupMenuItem<String>(
              value: item.key,
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 18,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? Colors.white70 : Colors.black.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.getLabel(l10n),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

void showPlaybackButtonLayoutDialog(
  BuildContext context,
  SettingsService settings,
) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final l10n = AppLocalizations.of(context)!;
  final screenWidth = MediaQuery.of(context).size.width;
  final double horizontalInset = (screenWidth * 0.05).clamp(12.0, 40.0);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor:
          isDark ? const Color(0xFF101114) : theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding:
          EdgeInsets.symmetric(horizontal: horizontalInset, vertical: 24.0),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      title: Text(
        l10n.playbackButtonLayoutTitle,
        style: TextStyle(
          color: isDark ? Colors.white : theme.colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 600,
        height: 520,
        child: PlaybackButtonLayoutView(settings: settings),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.confirm,
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
      ],
    ),
  );
}
