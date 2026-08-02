import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../player/settings/settings_service.dart';

class CloseWindowActionResult {
  final CloseWindowAction action;
  final bool remember;

  const CloseWindowActionResult({
    required this.action,
    required this.remember,
  });
}

class CloseWindowActionDialog extends StatefulWidget {
  const CloseWindowActionDialog({super.key});

  @override
  State<CloseWindowActionDialog> createState() =>
      _CloseWindowActionDialogState();
}

class _CloseWindowActionDialogState extends State<CloseWindowActionDialog> {
  CloseWindowAction _selectedAction = CloseWindowAction.minimize;
  bool _remember = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.closeWindowDialogTitle),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.closeWindowDialogContent,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            RadioListTile<CloseWindowAction>(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(l10n.closeWindowActionMinimize),
              value: CloseWindowAction.minimize,
              groupValue: _selectedAction,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedAction = val);
                }
              },
            ),
            RadioListTile<CloseWindowAction>(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(l10n.closeWindowActionExit),
              value: CloseWindowAction.exit,
              groupValue: _selectedAction,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedAction = val);
                }
              },
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              title: Text(
                l10n.closeWindowActionRemember,
                style: theme.textTheme.bodySmall,
              ),
              value: _remember,
              onChanged: (val) {
                setState(() {
                  _remember = val ?? false;
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
              CloseWindowActionResult(
                action: _selectedAction,
                remember: _remember,
              ),
            );
          },
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
