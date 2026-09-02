import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/pro/app_channel.dart';
import 'package:vynody/player/pro/iap_service.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/pro/pro_models.dart';
import 'package:vynody/widgets/pro/pro_badge.dart';

/// Show the Pro Upgrade & Trial Info Dialog.
Future<void> showUpgradeToProDialog(
  BuildContext context, {
  ProFeature? initialFeature,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => UpgradeToProDialog(highlightedFeature: initialFeature),
  );
}

class UpgradeToProDialog extends ConsumerWidget {
  const UpgradeToProDialog({
    super.key,
    this.highlightedFeature,
  });

  final ProFeature? highlightedFeature;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final license = ref.watch(licenseStateProvider);
    final iapState = ref.watch(iapStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final features = [
      if (Platform.isWindows || highlightedFeature == ProFeature.wasapiExclusive)
        ProFeatureInfo.fromFeature(ProFeature.wasapiExclusive, l10n),
      ProFeatureInfo.fromFeature(ProFeature.aiLyrics, l10n),
      ProFeatureInfo.fromFeature(ProFeature.dynamicMeshBackground, l10n),
      ProFeatureInfo.fromFeature(ProFeature.customImageBackground, l10n),
      ProFeatureInfo.fromFeature(ProFeature.tagCompletion, l10n),
      ProFeatureInfo.fromFeature(ProFeature.equalizer, l10n),
      ProFeatureInfo.fromFeature(ProFeature.customThemeColor, l10n),
      ProFeatureInfo.fromFeature(ProFeature.fftVisualizer, l10n),
      ProFeatureInfo.fromFeature(ProFeature.waveformBar, l10n),
      ProFeatureInfo.fromFeature(ProFeature.lanSharing, l10n),
      ProFeatureInfo.fromFeature(ProFeature.remoteControl, l10n),
      ProFeatureInfo.fromFeature(ProFeature.transcoder, l10n),
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E24) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Banner with Gold Accents
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 20, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF2A2318), const Color(0xFF1E1E24)]
                        : [const Color(0xFFFFF7E6), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9500), Color(0xFFFFCC00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.black87,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Vynody Pro',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const ProBadge(size: 11, showInGitHubBuild: true),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppChannel.isGitHubRelease
                                ? l10n.proCommunityUnlocked
                                : (license.isInTrial
                                    ? l10n.proTrialActive(license.trialDaysRemaining)
                                    : (license.isTrialExpired
                                        ? l10n.proTrialExpired
                                        : l10n.proPermanentlyActivated)),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: license.isTrialExpired
                                  ? theme.colorScheme.error
                                  : (isDark ? Colors.white70 : Colors.black54),
                              fontWeight: license.isTrialExpired ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: l10n.close,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 2. Feature Cards List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: features.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = features[index];
                    final isHighlighted = item.feature == highlightedFeature;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? (isDark
                                ? const Color(0xFF382D1B)
                                : const Color(0xFFFFF3D6))
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : Colors.black.withValues(alpha: 0.02)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isHighlighted
                              ? const Color(0xFFFFB300).withValues(alpha: 0.6)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isHighlighted
                                  ? const Color(0xFFFFB300).withValues(alpha: 0.2)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.05)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item.icon,
                              size: 20,
                              color: isHighlighted
                                  ? const Color(0xFFFFB300)
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.description,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const Divider(height: 1),

              // 3. Footer Action Area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  children: [
                    if (!license.isPermanentlyUnlocked && (Platform.isIOS || Platform.isMacOS))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.devices_rounded,
                              size: 14,
                              color: isDark
                                  ? const Color(0xFFFFB300).withValues(alpha: 0.85)
                                  : const Color(0xFFD97706),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                l10n.proUniversalPurchaseNoticeApple,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!license.isPermanentlyUnlocked)
                      FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: const Color(0xFFFF9500),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        onPressed: iapState.isPurchasing
                            ? null
                            : () => ref.read(iapServiceProvider).buyPro(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (iapState.isPurchasing) ...[
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  l10n.connectingToStore,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ] else ...[
                              const Icon(Icons.bolt_rounded, size: 20),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  Platform.isWindows
                                      ? (license.isInTrial
                                          ? l10n.buyFullVersionWindowsTrial
                                          : l10n.buyFullVersionWindows)
                                      : (iapState.proProduct != null
                                          ? l10n.unlockProLifetimeWithPrice(iapState.proProduct!.price)
                                          : (license.isInTrial
                                              ? l10n.buyProTrialEarly
                                              : l10n.upgradeToProNow)),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.iUnderstand),
                      ),

                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        TextButton(
                          onPressed: iapState.isRestoring
                              ? null
                              : () => ref.read(iapServiceProvider).restorePurchases(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (iapState.isRestoring) ...[
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                iapState.isRestoring ? l10n.restoringPurchases : l10n.restorePurchases,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (kDebugMode) ...[
                          if (license.type == LicenseType.purchasedPro)
                            TextButton(
                              onPressed: () async {
                                final service = ref.read(proLicenseServiceProvider);
                                await service.setPurchased(false);
                              },
                              child: const Text(
                                '[Debug: 重置为未购买]',
                                style: TextStyle(fontSize: 12, color: Colors.deepOrangeAccent),
                              ),
                            )
                          else
                            TextButton(
                              onPressed: () async {
                                final service = ref.read(proLicenseServiceProvider);
                                if (license.isTrialExpired) {
                                  await service.debugResetTrial(offsetDays: 0);
                                } else {
                                  await service.debugResetTrial(offsetDays: ProConfig.trialDays + 1);
                                }
                              },
                              child: Text(
                                license.isTrialExpired ? '[Debug: 恢复${ProConfig.trialDays}天试用]' : '[Debug: 模拟试用超期]',
                                style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
