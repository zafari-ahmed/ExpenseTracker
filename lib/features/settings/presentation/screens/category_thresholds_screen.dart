import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/stitch_widgets.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/data/models/category_threshold_model.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../dashboard/presentation/providers/threshold_status_provider.dart';

class CategoryThresholdsScreen extends ConsumerWidget {
  const CategoryThresholdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final thresholdsAsync = ref.watch(thresholdsProvider);
    final statusesAsync = ref.watch(categoryThresholdStatusesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Category thresholds'),
        backgroundColor: AppColors.background,
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) {
          final thresholds = thresholdsAsync.valueOrNull ?? const [];
          final statuses = statusesAsync.valueOrNull ?? const [];
          if (categories.isEmpty) {
            return const Center(
              child: Text('Add a category first to set a monthly limit.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.margin,
              8,
              AppSpacing.margin,
              32,
            ),
            itemCount: categories.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Text(
                  'Tap a category to set its monthly limit and alert percent.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                );
              }
              final category = categories[index - 1];
              final threshold = _findThreshold(thresholds, category.id);
              final status = _findStatus(statuses, category.id);
              return _CategoryThresholdRow(
                category: category,
                threshold: threshold,
                status: status,
                onTap: () => context.push(
                  '/settings/thresholds/edit?categoryId=${Uri.encodeQueryComponent(category.id)}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryThresholdRow extends StatelessWidget {
  const _CategoryThresholdRow({
    required this.category,
    required this.threshold,
    required this.status,
    required this.onTap,
  });

  final CategoryModel category;
  final CategoryThresholdModel? threshold;
  final CategoryThresholdStatus? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasLimit = (threshold?.monthlyLimit ?? 0) > 0;
    final currentStatus = status;
    final currentThreshold = threshold;
    final subtitle = !hasLimit
        ? 'No monthly limit'
        : currentStatus != null
            ? '${EtMoney.format(currentStatus.spent)} of ${EtMoney.format(currentStatus.monthlyLimit)} · alert ${currentThreshold!.notifyAtPercent}%'
            : '${EtMoney.format(currentThreshold!.monthlyLimit)} · alert ${currentThreshold.notifyAtPercent}%';

    final barColor = currentStatus == null
        ? AppColors.soft
        : currentStatus.level == ThresholdLevel.exceeded
            ? AppColors.error
            : currentStatus.level == ThresholdLevel.warning
                ? AppColors.warning
                : AppColors.success;

    return EtSurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          EtCategoryBadge(category: category.name, size: 36, iconSize: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                if (currentStatus != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (currentStatus.percentUsed / 100).clamp(0.0, 1.0),
                      minHeight: 6,
                      color: barColor,
                      backgroundColor: AppColors.surfaceContainerHigh,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (currentStatus != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                '${currentStatus.percentUsed.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: barColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          const Icon(Icons.chevron_right, color: AppColors.outline),
        ],
      ),
    );
  }
}

class CategoryThresholdEditScreen extends ConsumerStatefulWidget {
  const CategoryThresholdEditScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  ConsumerState<CategoryThresholdEditScreen> createState() =>
      _CategoryThresholdEditScreenState();
}

class _CategoryThresholdEditScreenState
    extends ConsumerState<CategoryThresholdEditScreen> {
  final _limitCtrl = TextEditingController();
  double _percent = 80;
  bool _hydrated = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _limitCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    super.dispose();
  }

  void _hydrate(CategoryThresholdModel? threshold) {
    if (_hydrated) return;
    _hydrated = true;
    final limitText = '${threshold?.monthlyLimit ?? 0}';
    final percent = (threshold?.notifyAtPercent ?? 80).toDouble();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _limitCtrl.text = limitText;
      setState(() => _percent = percent);
    });
  }

  Future<void> _remove({
    required CategoryModel category,
    required CategoryThresholdModel? existing,
  }) async {
    if (_saving) return;
    _limitCtrl.clear();
    if (existing == null) {
      setState(() {});
      return;
    }

    final confirmed = await etConfirmDelete(
      context,
      title: 'Remove threshold?',
      message: 'This turns off the monthly limit for ${category.name}.',
    );
    if (!confirmed || !mounted) return;

    setState(() => _saving = true);
    await ref.read(categoryMutationsProvider).deleteThreshold(category.id);
    ref.invalidate(categoryThresholdStatusesProvider);
    if (!mounted) return;
    await etInfoAlert(
      context,
      title: 'Threshold removed',
      message: '${category.name} monthly limit has been removed.',
    );
    if (!mounted) return;
    context.go('/settings');
  }

  Future<void> _save({
    required CategoryModel category,
    required CategoryThresholdModel? existing,
  }) async {
    if (_saving) return;
    setState(() => _saving = true);

    final limit = double.tryParse(_limitCtrl.text.trim()) ?? 0;
    final threshold = existing ??
        (CategoryThresholdModel()..categoryId = category.id);
    threshold
      ..monthlyLimit = limit
      ..notifyAtPercent = _percent.toInt();

    await ref.read(categoryMutationsProvider).upsertThreshold(threshold);
    ref.invalidate(categoryThresholdStatusesProvider);

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Threshold updated'),
        content: Text(
          '${category.name} monthly limit has been saved.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    context.go('/settings');
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final thresholdsAsync = ref.watch(thresholdsProvider);
    final statusesAsync = ref.watch(categoryThresholdStatusesProvider);

    return categoriesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (categories) {
        final matched = categories.where((c) => c.id == widget.categoryId);
        if (matched.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Category threshold')),
            body: const Center(child: Text('Category not found.')),
          );
        }
        final category = matched.first;

        return thresholdsAsync.when(
          loading: () => Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(category.name),
              backgroundColor: AppColors.background,
            ),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            appBar: AppBar(title: Text(category.name)),
            body: Center(child: Text('Error: $e')),
          ),
          data: (thresholds) {
            final existing = _findThreshold(thresholds, category.id);
            _hydrate(existing);
            final status = _findStatus(
              statusesAsync.valueOrNull ?? const [],
              category.id,
            );

            final barColor = status == null
                ? AppColors.primary
                : status.level == ThresholdLevel.exceeded
                    ? AppColors.error
                    : status.level == ThresholdLevel.warning
                        ? AppColors.warning
                        : AppColors.success;

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: Text(category.name),
                backgroundColor: AppColors.background,
              ),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  8,
                  AppSpacing.margin,
                  32,
                ),
                children: [
                  Text(
                    'Set a monthly limit and the percent at which you want an alert.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  EtSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            EtCategoryBadge(
                              category: category.name,
                              size: 40,
                              iconSize: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                category.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            if (status != null)
                              Text(
                                '${status.percentUsed.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: barColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                          ],
                        ),
                        if (status != null) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value:
                                  (status.percentUsed / 100).clamp(0.0, 1.0),
                              minHeight: 8,
                              color: barColor,
                              backgroundColor: AppColors.surfaceContainerHigh,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${EtMoney.format(status.spent)} of ${EtMoney.format(status.monthlyLimit)} this period',
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextField(
                          controller: _limitCtrl,
                          decoration: InputDecoration(
                            labelText: 'Monthly limit',
                            helperText: 'Tap X to remove this threshold',
                            suffixIcon: _limitCtrl.text.trim().isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Remove threshold',
                                    onPressed: _saving
                                        ? null
                                        : () => _remove(
                                              category: category,
                                              existing: existing,
                                            ),
                                    icon: const Icon(Icons.close),
                                  ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Alert at ${_percent.toInt()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Slider(
                          min: 50,
                          max: 100,
                          divisions: 10,
                          value: _percent,
                          label: '${_percent.toInt()}%',
                          onChanged: (value) =>
                              setState(() => _percent = value),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _saving
                                ? null
                                : () => _save(
                                      category: category,
                                      existing: existing,
                                    ),
                            child: Text(
                              _saving ? 'Saving…' : 'Save threshold',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

CategoryThresholdModel? _findThreshold(
  List<CategoryThresholdModel> thresholds,
  String categoryId,
) {
  for (final item in thresholds) {
    if (item.categoryId == categoryId) return item;
  }
  return null;
}

CategoryThresholdStatus? _findStatus(
  List<CategoryThresholdStatus> statuses,
  String categoryId,
) {
  for (final item in statuses) {
    if (item.categoryId == categoryId) return item;
  }
  return null;
}
