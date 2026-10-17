import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/stitch_widgets.dart';
import '../../../settings/presentation/providers/preferences_provider.dart';
import '../providers/threshold_status_provider.dart';

class ThresholdProgressSection extends ConsumerWidget {
  const ThresholdProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currencyProvider);
    final statusesAsync = ref.watch(categoryThresholdStatusesProvider);

    return statusesAsync.when(
      data: (statuses) {
        if (statuses.isEmpty) {
          return EtSurfaceCard(
            elevated: false,
            onTap: () => context.push('/settings/thresholds'),
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

        final cardWidth = (MediaQuery.sizeOf(context).width - 40) * 0.78;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EtSectionHeader(
              title: 'Category limits',
              actionLabel: 'Manage',
              onAction: () => context.push('/settings/thresholds'),
            ),
            SizedBox(
              height: 108,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: statuses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final status = statuses[index];
                  return SizedBox(
                    width: cardWidth,
                    child: _ThresholdLimitCard(
                      status: status,
                      onTap: () => context.push(
                        '/settings/thresholds/edit?categoryId=${Uri.encodeQueryComponent(status.categoryId)}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      error: (e, _) => Text('Could not load thresholds: $e'),
      loading: () => const LinearProgressIndicator(),
    );
  }

}

class _ThresholdLimitCard extends StatelessWidget {
  const _ThresholdLimitCard({required this.status, required this.onTap});

  final CategoryThresholdStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = (status.percentUsed / 100).clamp(0.0, 1.0);
    final color = _barColor(status.level);
    final isAlert = status.isHighlighted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              EtCategoryBadge(
                category: status.categoryName,
                size: 28,
                iconSize: 14,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '${status.percentUsed.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress > 1 ? 1 : progress,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.12),
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${EtMoney.format(status.spent)} / ${EtMoney.format(status.monthlyLimit)}'
            '  •  alert at ${status.notifyAtPercent}%',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
      ),
    );
  }
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
