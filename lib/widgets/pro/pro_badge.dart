import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/player/pro/app_channel.dart';
import 'package:vynody/player/pro/pro_license_service.dart';

/// A compact, elegant badge indicating a Pro tier feature.
class ProBadge extends ConsumerWidget {
  const ProBadge({
    super.key,
    this.size = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
    this.showInGitHubBuild = false,
  });

  final double size;
  final EdgeInsetsGeometry padding;
  final bool showInGitHubBuild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If running on GitHub release and showInGitHubBuild is false, hide badge
    if (AppChannel.isGitHubRelease && !showInGitHubBuild) {
      return const SizedBox.shrink();
    }

    final isUnlocked = ref.watch(isProUnlockedProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Gradient colors for a premium gold look
    final goldGradient = LinearGradient(
      colors: isUnlocked
          ? (isDark
              ? [const Color(0xFFE5A93C), const Color(0xFFF3C766)]
              : [const Color(0xFFC88A1A), const Color(0xFFE5A93C)])
          : (isDark
              ? [const Color(0xFFFF9500), const Color(0xFFFFCC00)]
              : [const Color(0xFFE65100), const Color(0xFFFF9800)]),
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: goldGradient,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: isDark ? 0.25 : 0.15),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        'PRO',
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.9),
          fontSize: size,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
          height: 1.1,
        ),
      ),
    );
  }
}
