import 'package:flutter/material.dart';

class SettingsDropdownOption<T> {
  final T value;
  final String label;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;

  const SettingsDropdownOption({
    required this.value,
    required this.label,
    this.leading,
    this.trailing,
    this.enabled = true,
  });
}

class SettingsDropdownTile<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final T value;
  final List<SettingsDropdownOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  const SettingsDropdownTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEffectiveEnabled = enabled && onChanged != null;

    SettingsDropdownOption<T>? selectedOption;
    for (final opt in options) {
      if (opt.value == value) {
        selectedOption = opt;
        break;
      }
    }
    selectedOption ??= options.isNotEmpty ? options.first : null;

    final sub = subtitle;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: icon != null ? Icon(icon) : null,
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: (sub != null && sub.isNotEmpty)
          ? Text(
              sub,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.48,
        ),
        child: PopupMenuButton<T>(
          enabled: isEffectiveEnabled,
          onSelected: isEffectiveEnabled ? onChanged : null,
          itemBuilder: (context) => options.map((opt) {
            final isSelected = opt.value == value;
            return PopupMenuItem<T>(
              value: opt.value,
              enabled: opt.enabled,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (opt.leading != null) ...[
                    opt.leading!,
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      opt.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? colorScheme.primary : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (opt.trailing != null) ...[
                    const SizedBox(width: 8),
                    opt.trailing!,
                  ],
                  if (isSelected) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isEffectiveEnabled
                  ? colorScheme.surfaceContainerHigh
                  : colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedOption?.leading != null) ...[
                  selectedOption!.leading!,
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    selectedOption?.label ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isEffectiveEnabled
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.38),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (selectedOption?.trailing != null) ...[
                  const SizedBox(width: 6),
                  selectedOption!.trailing!,
                ],
                const SizedBox(width: 6),
                Icon(
                  Icons.unfold_more_rounded,
                  size: 18,
                  color: isEffectiveEnabled
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface.withValues(alpha: 0.38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
