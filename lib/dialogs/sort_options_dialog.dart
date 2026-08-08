import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class SortOptionItem<T> {
  final T value;
  final String label;
  final IconData icon;

  const SortOptionItem({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class SortResult<T> {
  final T field;
  final bool sortAscending;

  const SortResult({
    required this.field,
    required this.sortAscending,
  });
}

class SortOptionsDialog<T> extends StatefulWidget {
  const SortOptionsDialog({
    super.key,
    required this.title,
    required this.options,
    required this.currentField,
    required this.sortAscending,
  });

  final String title;
  final List<SortOptionItem<T>> options;
  final T currentField;
  final bool sortAscending;

  @override
  State<SortOptionsDialog<T>> createState() => _SortOptionsDialogState<T>();
}

class _SortOptionsDialogState<T> extends State<SortOptionsDialog<T>> {
  late T _selectedField;
  late bool _isDescending;

  @override
  void initState() {
    super.initState();
    _selectedField = widget.currentField;
    _isDescending = !widget.sortAscending;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isZh = Localizations.localeOf(context).languageCode == 'zh';

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.sort_rounded,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Text(widget.title),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...widget.options.map((option) {
              final isSelected = option.value == _selectedField;
              return RadioListTile<T>(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                dense: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                secondary: Icon(
                  option.icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  option.label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                value: option.value,
                groupValue: _selectedField,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedField = val;
                    });
                  }
                },
              );
            }),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1),
            ),
            CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                isZh ? '启用降序' : l10n.sortDescending,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: _isDescending ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                _isDescending
                    ? (isZh ? '当前为降序排列' : l10n.sortDescending)
                    : (isZh ? '当前为升序排列' : l10n.sortAscending),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value: _isDescending,
              onChanged: (val) {
                setState(() {
                  _isDescending = val ?? false;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              SortResult<T>(
                field: _selectedField,
                sortAscending: !_isDescending,
              ),
            );
          },
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
