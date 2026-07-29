import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/stitch_widgets.dart';
import '../providers/threshold_status_provider.dart';

class ThresholdProgressSection extends ConsumerWidget {
  const ThresholdProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusesAsync = ref.watch(categoryThresholdStatusesProvider);

    return statusesAsync.when(
      data: (statuses) {
        if (statuses.isEmpty) {
          return EtSurfaceCard(
            elevated: false,
            onTap: () => context.go('/settings'),
            child: const Row(
              children: [
                Icon(Icons.speed_outlined, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No category thresholds set',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Set a monthly limit in Settings to track Fuel, Food, etc.',
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.outline),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EtSectionHeader(
              title: 'Category limits',
              actionLabel: 'Manage',
              onAction: () => context.go('/settings'),
            ),
            ...statuses.map((status) {
              final progress = (status.percentUsed / 100).clamp(0.0, 1.0);
              final color = _barColor(status.level);
              final isAlert = status.isHighlighted;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isAlert
                        ? (status.level == ThresholdLevel.exceeded
                            ? AppColors.errorContainer.withValues(alpha: 0.4)
                            : const Color(0xFFFFF6E8))
                        : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(
                      color: isAlert
                          ? color.withValues(alpha: 0.35)
                          : AppColors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          EtCategoryBadge(
                            category: status.categoryName,
                            size: 34,
                            iconSize: 16,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  status.categoryName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                if (isAlert)
                                  Text(
                                    status.level == ThresholdLevel.exceeded
                                        ? 'Exceeded monthly limit'
                                        : 'Nearing monthly limit',
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '${status.percentUsed.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress > 1 ? 1 : progress,
                          minHeight: 8,
                          backgroundColor: color.withValues(alpha: 0.12),
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${EtMoney.format(status.spent)} / ${EtMoney.format(status.monthlyLimit)}'
                        '  •  alert at ${status.notifyAtPercent}%',
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
      error: (e, _) => Text('Could not load thresholds: $e'),
      loading: () => const LinearProgressIndicator(),
    );
  }

  Color _barColor(ThresholdLevel level) {
    switch (level) {
      case ThresholdLevel.exceeded:
        return AppColors.error;
      case ThresholdLevel.warning:
        return AppColors.warning;
      case ThresholdLevel.ok:
        return AppColors.success;
    }
  }
}
