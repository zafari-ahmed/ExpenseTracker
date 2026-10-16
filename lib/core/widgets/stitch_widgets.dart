import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../features/settings/presentation/providers/preferences_provider.dart';
import '../../features/settings/presentation/providers/profile_provider.dart';
import '../constants/app_currency.dart';
import '../constants/app_info.dart';
import '../theme/design_tokens.dart';

class EtMoney {
  static String format(num value, [AppCurrency? currency]) {
    final selected = currency ?? CurrencyStore.current;
    return NumberFormat.currency(
      symbol: selected.symbol,
      decimalDigits: 0,
    ).format(value);
  }
}

class EtTxnTime {
  static bool hasClock(DateTime value) =>
      value.hour != 0 ||
      value.minute != 0 ||
      value.second != 0 ||
      value.millisecond != 0;

  static String? clock(DateTime value) {
    if (!hasClock(value)) return null;
    return DateFormat('HH:mm').format(value);
  }
}

Future<bool> etConfirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final titleStyle = GoogleFonts.archivo(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.25,
  );
  final bodyStyle = GoogleFonts.archivo(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.body,
    height: 1.4,
  );
  final actionStyle = GoogleFonts.archivo(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: titleStyle),
      content: Text(message, style: bodyStyle),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('Cancel', style: actionStyle),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            'Delete',
            style: actionStyle.copyWith(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
  return confirmed == true;
}

Future<void> etInfoAlert(
  BuildContext context, {
  required String title,
  required String message,
}) {
  final titleStyle = GoogleFonts.archivo(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.25,
  );
  final bodyStyle = GoogleFonts.archivo(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.body,
    height: 1.4,
  );

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: titleStyle),
      content: Text(message, style: bodyStyle),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(
            'OK',
            style: GoogleFonts.archivo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class EtBrandMark extends StatelessWidget {
  const EtBrandMark({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(7),
      ),
      alignment: Alignment.center,
      child: Text(
        'E',
        style: GoogleFonts.archivo(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.5,
        ),
      ),
    );
  }
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
    final name = ref.watch(profileNameProvider).valueOrNull ?? 'Member';
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    final child = hasCustom
        ? Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              image: DecorationImage(
                image: FileImage(File(path)),
                fit: BoxFit.cover,
              ),
            ),
          )
        : Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Text(
              initials.isEmpty ? 'E' : initials,
              style: GoogleFonts.archivo(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.36,
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
      style: GoogleFonts.ibmPlexMono(
        color: color ?? AppColors.onSurfaceVariant,
        letterSpacing: 1.4,
        fontSize: 9,
        fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: EtLabelCaps(title)),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
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
    this.padding = const EdgeInsets.all(14),
    this.radius = AppRadii.card,
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
        border: border
            ? Border.all(
                color: isDark ? AppColors.borderDark : AppColors.outlineVariant,
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
    this.color = AppColors.primaryBright,
  });

  final List<double> values;
  final double height;
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return EtBarSpark(values: values, height: height, width: width, color: color);
  }
}

class EtBarSpark extends StatelessWidget {
  const EtBarSpark({
    required this.values,
    super.key,
    this.height = 40,
    this.width,
    this.color = AppColors.primaryBright,
    this.trackColor = AppColors.inkMuted,
  });

  final List<double> values;
  final double height;
  final double? width;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final bars = values.isEmpty ? const [0.0] : values;
    final maxV = bars.reduce(math.max);
    return SizedBox(
      width: width,
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < bars.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: maxV <= 0
                    ? 8
                    : math.max(8, height * (bars[i] / maxV)),
                decoration: BoxDecoration(
                  color: i == bars.length - 1 ? color : trackColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EtAppHeader extends StatelessWidget {
  const EtAppHeader({
    super.key,
    this.title = AppInfo.brand,
    this.greeting,
    this.subtitle,
    this.onCalendarTap,
    this.onSubtitleTap,
    this.onAvatarTap,
    this.showBrandTitle = true,
    this.showCalendar = true,
    this.trailing,
  });

  final String title;
  final String? greeting;
  final String? subtitle;
  final VoidCallback? onCalendarTap;
  final VoidCallback? onSubtitleTap;
  final VoidCallback? onAvatarTap;
  final bool showBrandTitle;
  final bool showCalendar;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margin,
        8,
        AppSpacing.margin,
        12,
      ),
      child: Row(
        children: [
          const EtBrandMark(),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.archivo(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.ink,
              ),
            ),
          ),
          if (trailing != null) trailing!,
          if (showCalendar && trailing == null)
            EtGhostIconButton(
              icon: Icons.calendar_month_outlined,
              onTap: onCalendarTap,
            ),
        ],
      ),
    );
  }
}

class EtPageHeader extends StatelessWidget {
  const EtPageHeader({
    required this.title,
    super.key,
    this.onBack,
    this.actions,
    this.closeInsteadOfBack = false,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool closeInsteadOfBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.maybePop(context),
            icon: Icon(
              closeInsteadOfBack ? Icons.close : Icons.arrow_back,
              color: AppColors.ink,
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.archivo(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.ink,
              ),
            ),
          ),
          ...?actions,
        ],
      ),
    );
  }
}

class EtGhostIconButton extends StatelessWidget {
  const EtGhostIconButton({
    required this.icon,
    super.key,
    this.onTap,
    this.size = 34,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: 19, color: AppColors.body),
        ),
      ),
    );
  }
}

class EtCategoryBadge extends StatelessWidget {
  const EtCategoryBadge({
    required this.category,
    super.key,
    this.size = 32,
    this.iconSize = 18,
    this.square = true,
  });

  final String category;
  final double size;
  final double iconSize;
  final bool square;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppCategoryStyle.tintFor(category),
        borderRadius: BorderRadius.circular(square ? 8 : size / 2),
      ),
      child: Icon(
        AppCategoryStyle.iconFor(category),
        color: AppCategoryStyle.colorFor(category),
        size: iconSize,
      ),
    );
  }
}

class EtTransactionTile extends ConsumerWidget {
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
    this.compact = false,
  });

  final String place;
  final String category;
  final double amount;
  final String subtitle;
  final String? badge;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showAccent;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currencyProvider);
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          EtCategoryBadge(category: category, size: 32, iconSize: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.archivo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    letterSpacing: 0.4,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            EtMoney.format(amount),
            style: GoogleFonts.archivo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: AppColors.ink,
            ),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Delete',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: onDelete,
            ),
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

class EtTxnGroup extends StatelessWidget {
  const EtTxnGroup({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return EtSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.hairline),
            children[i],
          ],
        ],
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
    (Icons.space_dashboard_outlined, Icons.space_dashboard, 'DASH'),
    (Icons.receipt_long_outlined, Icons.receipt_long, 'TXNS'),
    (Icons.bar_chart_outlined, Icons.bar_chart, 'STATS'),
    (Icons.settings_outlined, Icons.settings, 'SETUP'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.background)
            .withValues(alpha: 0.92),
        border: const Border(
          top: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavTab(
                    icon: selectedIndex == i ? _items[i].$2 : _items[i].$1,
                    label: _items[i].$3,
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
    final color = selected ? AppColors.primary : AppColors.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              color: color,
              fontSize: 9,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w500,
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
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppRadii.fab),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadii.fab),
        child: const SizedBox(
          width: 52,
          height: 52,
          child: Icon(Icons.add_rounded, color: Colors.white, size: 26),
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
          return Center(
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                height: 36,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.ink
                      : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: selected
                      ? null
                      : Border.all(color: AppColors.outlineVariant),
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.archivo(
                    color: selected ? Colors.white : AppColors.body,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EtSegmented extends StatelessWidget {
  const EtSegmented({
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
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selectedIndex == i
                        ? AppColors.surfaceContainerLowest
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: selectedIndex == i
                        ? [
                            BoxShadow(
                              color: AppColors.ink.withValues(alpha: 0.08),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: GoogleFonts.archivo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selectedIndex == i
                          ? AppColors.ink
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<DateTime?> etPickMonth(BuildContext context, DateTime current) async {
  var selected = DateTime(current.year, current.month);
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: AppColors.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  style: GoogleFonts.archivo(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
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
                        DateFormat('MMMM yyyy').format(selected).toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: AppColors.ink,
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

String etGreeting([String name = 'Member']) {
  final hour = DateTime.now().hour;
  final prefix = hour < 12
      ? 'Good Morning'
      : hour < 17
          ? 'Good Afternoon'
          : 'Good Evening';
  return '$prefix, $name';
}
