import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../features/settings/presentation/providers/profile_provider.dart';
import '../theme/design_tokens.dart';

class EtMoney {
  static final NumberFormat currency =
      NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

  static String format(num value) => currency.format(value);
}

class EtAvatar extends ConsumerWidget {
  const EtAvatar({super.key, this.size = 40, this.onTap});

  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathAsync = ref.watch(profileImagePathProvider);
    final path = pathAsync.asData?.value;
    final hasCustom = path != null && File(path).existsSync();

    final child = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceContainerHigh,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
          width: 2,
        ),
        image: DecorationImage(
          image: hasCustom
              ? FileImage(File(path))
              : const AssetImage(AppAssets.avatar) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }
}

class EtLabelCaps extends StatelessWidget {
  const EtLabelCaps(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color ?? AppColors.onSurfaceVariant,
            letterSpacing: 0.8,
            fontSize: 11,
          ),
    );
  }
}

class EtSectionHeader extends StatelessWidget {
  const EtSectionHeader({
    required this.title,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: EtLabelCaps(actionLabel!, color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}

class EtSurfaceCard extends StatelessWidget {
  const EtSurfaceCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadii.summary,
    this.onTap,
    this.color,
    this.border = true,
    this.elevated = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;
  final bool border;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ??
            (isDark ? AppColors.cardDark : AppColors.surfaceContainerLowest),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: (!elevated || isDark) ? null : AppShadows.level1,
        border: border
            ? Border.all(
                color: (isDark ? AppColors.borderDark : AppColors.outlineVariant)
                    .withValues(alpha: 0.28),
              )
            : null,
      ),
      child: child,
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      ),
    );
  }
}

class EtSparkline extends StatelessWidget {
  const EtSparkline({
    required this.values,
    super.key,
    this.height = 36,
    this.width = 72,
    this.color = AppColors.primary,
  });

  final List<double> values;
  final double height;
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          values: values.isEmpty ? const [0, 0] : values,
          color: color,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).abs() < 0.001 ? 1.0 : (maxV - minV);

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * (i / (values.length - 1));
      final y = size.height - ((values[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.02),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class EtAppHeader extends StatelessWidget {
  const EtAppHeader({
    super.key,
    this.title = 'ExpenseTracker',
    this.greeting,
    this.subtitle,
    this.onCalendarTap,
    this.onSubtitleTap,
    this.onAvatarTap,
    this.showBrandTitle = true,
    this.showCalendar = true,
  });

  final String title;
  final String? greeting;
  final String? subtitle;
  final VoidCallback? onCalendarTap;
  final VoidCallback? onSubtitleTap;
  final VoidCallback? onAvatarTap;
  final bool showBrandTitle;
  final bool showCalendar;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margin,
        AppSpacing.sm,
        AppSpacing.margin,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          EtAvatar(onTap: onAvatarTap),
          const SizedBox(width: 12),
          Expanded(
            child: showBrandTitle && greeting == null
                ? Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (greeting != null)
                        Text(
                          greeting!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                        ),
                      if (subtitle != null)
                        InkWell(
                          onTap: onSubtitleTap ?? onCalendarTap,
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  subtitle!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 22,
                                      ),
                                ),
                              ),
                              Icon(Icons.expand_more, color: primary, size: 22),
                            ],
                          ),
                        )
                      else if (showBrandTitle)
                        Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                    ],
                  ),
          ),
          if (showCalendar)
            Material(
              color: isDark
                  ? AppColors.cardDark
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onCalendarTap,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.calendar_month_outlined, color: primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EtCategoryBadge extends StatelessWidget {
  const EtCategoryBadge({
    required this.category,
    super.key,
    this.size = 44,
    this.iconSize = 22,
    this.square = true,
  });

  final String category;
  final double size;
  final double iconSize;
  final bool square;

  @override
  Widget build(BuildContext context) {
    final color = AppCategoryStyle.colorFor(category);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(square ? 12 : size / 2),
      ),
      child: Icon(
        AppCategoryStyle.iconFor(category),
        color: color,
        size: iconSize,
      ),
    );
  }
}

class EtTransactionTile extends StatelessWidget {
  const EtTransactionTile({
    required this.place,
    required this.category,
    required this.amount,
    required this.subtitle,
    super.key,
    this.badge,
    this.onTap,
    this.onDelete,
    this.showAccent = false,
  });

  final String place;
  final String category;
  final double amount;
  final String subtitle;
  final String? badge;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showAccent;

  @override
  Widget build(BuildContext context) {
    final accent = AppCategoryStyle.colorFor(category);

    return EtSurfaceCard(
      radius: AppRadii.card,
      padding: EdgeInsets.zero,
      border: false,
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (showAccent)
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadii.card),
                    bottomLeft: Radius.circular(AppRadii.card),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    EtCategoryBadge(
                      category: category,
                      square: !showAccent,
                      size: showAccent ? 42 : 44,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  place,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (badge != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.pill),
                                  ),
                                  child: Text(
                                    badge!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          fontSize: 10,
                                        ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '-${EtMoney.format(amount)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                    ),
                    if (onDelete != null)
                      IconButton(
                        tooltip: 'Delete',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: onDelete,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EtBottomNav extends StatelessWidget {
  const EtBottomNav({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _items = [
    (Icons.grid_view_rounded, 'Dashboard'),
    (Icons.receipt_long_outlined, 'Transactions'),
    (Icons.bar_chart_rounded, 'Analytics'),
    (Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavTab(
                    icon: _items[i].$1,
                    label: _items[i].$2,
                    selected: selectedIndex == i,
                    onTap: () => onDestinationSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : const Color(0xFF9AA0AE);

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 28 : 0,
            height: 3,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class EtAddFab extends StatelessWidget {
  const EtAddFab({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.fab),
        boxShadow: AppShadows.fab,
      ),
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadii.fab),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadii.fab),
          child: const SizedBox(
            width: 58,
            height: 58,
            child: Icon(Icons.add_rounded, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}

class EtFilterChipBar extends StatelessWidget {
  const EtFilterChipBar({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<DateTime?> etPickMonth(BuildContext context, DateTime current) async {
  var selected = DateTime(current.year, current.month);
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select month',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setModalState(() {
                        selected = DateTime(selected.year, selected.month - 1);
                      }),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        DateFormat('MMMM yyyy').format(selected),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setModalState(() {
                        selected = DateTime(selected.year, selected.month + 1);
                      }),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx, selected),
                    child: const Text('Apply'),
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

String etGreeting([String name = 'Alex']) {
  final hour = DateTime.now().hour;
  final prefix = hour < 12
      ? 'Good Morning'
      : hour < 17
          ? 'Good Afternoon'
          : 'Good Evening';
  return '$prefix, $name';
}
