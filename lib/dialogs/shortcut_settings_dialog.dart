import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/settings/shortcut_bindings.dart';

Future<void> showShortcutSettingsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const ShortcutSettingsDialog(),
  );
}

Future<void> showSingleShortcutEditDialog(
  BuildContext context, {
  required AppShortcutAction action,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => SingleShortcutEditDialog(action: action),
  );
}

class ShortcutSettingsDialog extends ConsumerStatefulWidget {
  const ShortcutSettingsDialog({super.key});

  @override
  ConsumerState<ShortcutSettingsDialog> createState() =>
      _ShortcutSettingsDialogState();
}

class _ShortcutSettingsDialogState
    extends ConsumerState<ShortcutSettingsDialog> {
  late Map<AppShortcutAction, ShortcutBinding> _draftBindings;
  late final ScrollController _scrollController;

  List<AppShortcutAction> get _availableActions {
    return AppShortcutAction.values.where((action) {
      if (action == AppShortcutAction.toggleWasapiExclusive) {
        return Platform.isWindows;
      }
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final settings = ref.read(settingsServiceProvider);
    _draftBindings = {
      for (final action in AppShortcutAction.values)
        action: settings.shortcutBinding(action),
    };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _restoreDefaults() {
    setState(() {
      _draftBindings = {
        for (final action in AppShortcutAction.values)
          action: action.defaultBinding,
      };
    });
  }

  void _save() {
    final settings = ref.read(settingsServiceProvider);
    settings.setShortcutBindings({
      for (final action in AppShortcutAction.values)
        action: _draftBindings[action] ?? action.defaultBinding,
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.72;
    final actionsList = _availableActions;

    return AlertDialog(
      title: Text(l10n.customShortcuts),
      content: SizedBox(
        width: 760,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Scrollbar(
            controller: _scrollController,
            child: ListView.separated(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: actionsList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final action = actionsList[index];
                final binding = _draftBindings[action] ?? action.defaultBinding;
                return _ShortcutBindingRow(
                  action: action,
                  binding: binding,
                  onChanged: (nextBinding) {
                    setState(() {
                      _draftBindings[action] = nextBinding;
                    });
                  },
                  theme: theme,
                );
              },
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        OutlinedButton(
          onPressed: _restoreDefaults,
          child: Text(l10n.restoreDefault),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.confirm)),
      ],
    );
  }
}

class SingleShortcutEditDialog extends ConsumerStatefulWidget {
  final AppShortcutAction action;

  const SingleShortcutEditDialog({super.key, required this.action});

  @override
  ConsumerState<SingleShortcutEditDialog> createState() =>
      _SingleShortcutEditDialogState();
}

class _SingleShortcutEditDialogState
    extends ConsumerState<SingleShortcutEditDialog> {
  late ShortcutBinding _currentBinding;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsServiceProvider);
    _currentBinding = settings.shortcutBinding(widget.action);
  }

  void _restoreDefault() {
    setState(() {
      _currentBinding = widget.action.defaultBinding;
    });
  }

  void _save() {
    final settings = ref.read(settingsServiceProvider);
    settings.setShortcutBinding(widget.action, _currentBinding);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.action.label),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.action.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ShortcutRecorderField(
              value: _currentBinding,
              onChanged: (newBinding) {
                setState(() {
                  _currentBinding = newBinding;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        OutlinedButton(
          onPressed: _restoreDefault,
          child: Text(l10n.restoreDefault),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}

class _ShortcutBindingRow extends StatelessWidget {
  const _ShortcutBindingRow({
    required this.action,
    required this.binding,
    required this.onChanged,
    required this.theme,
  });

  final AppShortcutAction action;
  final ShortcutBinding binding;
  final ValueChanged<ShortcutBinding> onChanged;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(action.label, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(action.description, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 260,
              child: ShortcutRecorderField(
                value: binding,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShortcutRecorderField extends StatefulWidget {
  const ShortcutRecorderField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ShortcutBinding value;
  final ValueChanged<ShortcutBinding> onChanged;

  @override
  State<ShortcutRecorderField> createState() => _ShortcutRecorderFieldState();
}

class _ShortcutRecorderFieldState extends State<ShortcutRecorderField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'shortcut-recorder');
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onKeyEvent(KeyEvent event) {
    final binding = ShortcutBinding.fromKeyEvent(event);
    if (binding == null) {
      return;
    }

    widget.onChanged(binding);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final effectiveBinding = widget.value;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: false,
      onKeyEvent: _onKeyEvent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _focusNode.requestFocus(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: _isFocused
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.7)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused
                  ? theme.colorScheme.primary
                  : theme.dividerColor.withValues(alpha: 0.6),
              width: _isFocused ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isFocused ? l10n.pressShortcutCombo : l10n.clickToRecord,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _isFocused
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                effectiveBinding.displayLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
