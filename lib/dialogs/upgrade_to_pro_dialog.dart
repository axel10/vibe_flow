import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    final features = [
      const ProFeatureInfo(
        feature: ProFeature.aiLyrics,
        title: 'AI 歌词与逐字精修',
        description: '大模型歌词智能生成、逐字对齐、实时翻译与罗马音注音',
        icon: Icons.auto_awesome,
      ),
      const ProFeatureInfo(
        feature: ProFeature.fftVisualizer,
        title: '实时音频 FFT 频谱',
        description: '沉浸式音频可视化动效、多样式频谱与全屏氛围模式',
        icon: Icons.graphic_eq,
      ),
      const ProFeatureInfo(
        feature: ProFeature.waveformBar,
        title: '动态音频波形进度条',
        description: '实时提取音频振幅波形，高帧率动态交互进度条',
        icon: Icons.waterfall_chart,
      ),
      const ProFeatureInfo(
        feature: ProFeature.lanSharing,
        title: '局域网音乐共享与串流',
        description: '基于 Bonsoir 的跨设备无损音频流媒体共享',
        icon: Icons.hub,
      ),
      const ProFeatureInfo(
        feature: ProFeature.remoteControl,
        title: '多端远程控制',
        description: '手机、平板与电脑端无缝联动与切歌遥控',
        icon: Icons.phonelink,
      ),
      const ProFeatureInfo(
        feature: ProFeature.transcoder,
        title: '音频批量转码工具',
        description: '无损格式快速压缩转换与随身设备批量导出',
        icon: Icons.transform,
      ),
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
                                ? '社区完全版已永久解锁全部高级特性'
                                : (license.isInTrial
                                    ? '免费试用期生效中 (剩余 ${license.trialDaysRemaining} 天)'
                                    : (license.isTrialExpired
                                        ? '免费试用期已结束，升级解锁高级体验'
                                        : '已永久激活全部 Pro 功能')),
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
                      tooltip: '关闭',
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
                              const Text(
                                '正在连接商店...',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ] else ...[
                              const Icon(Icons.bolt_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                iapState.proProduct != null
                                    ? '${iapState.proProduct!.price} 永久解锁 Pro 全功能'
                                    : (license.isInTrial
                                        ? '提前购买永久解锁 Pro'
                                        : '立即升级解锁 Pro 全功能'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
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
                        child: const Text('我知道了'),
                      ),

                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                iapState.isRestoring ? '正在恢复已购记录...' : '恢复已购记录',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (kDebugMode) ...[
                          const SizedBox(width: 8),
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
                          else ...[
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
