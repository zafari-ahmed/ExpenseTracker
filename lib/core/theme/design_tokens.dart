import 'package:flutter/material.dart';

/// Command Deck tokens from design-v2 (Expense Deck, direction 1b).
abstract final class AppColors {
  static const Color ink = Color(0xFF0E1116);
  static const Color inkMuted = Color(0xFF2B313C);
  static const Color background = Color(0xFFF1F2F5);
  static const Color surface = Color(0xFFF1F2F5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F2F5);
  static const Color surfaceContainer = Color(0xFFE4E7EC);
  static const Color surfaceContainerHigh = Color(0xFFE4E7EC);
  static const Color surfaceContainerHighest = Color(0xFFDDE1E8);
  static const Color surfaceVariant = Color(0xFFE4E7EC);

  static const Color primary = Color(0xFF4F3FD6);
  static const Color primaryBright = Color(0xFF8B82F5);
  static const Color primaryContainer = Color(0xFF4F3FD6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFEEE9FF);
  static const Color primaryFixed = Color(0xFFEEE9FF);
  static const Color inversePrimary = Color(0xFFB8B0FF);
  static const Color primaryTint = Color(0xFFEEE9FF);

  static const Color onSurface = Color(0xFF0E1116);
  static const Color onSurfaceVariant = Color(0xFF6B7480);
  static const Color body = Color(0xFF3F4855);
  static const Color soft = Color(0xFF9AA3B0);
  static const Color outline = Color(0xFF6B7480);
  static const Color outlineVariant = Color(0xFFDDE1E8);
  static const Color hairline = Color(0xFFEBEEF2);

  static const Color secondary = Color(0xFF3F4855);
  static const Color secondaryContainer = Color(0xFFE4E7EC);
  static const Color tertiary = Color(0xFF3F4855);

  static const Color error = Color(0xFFC44A2A);
  static const Color errorContainer = Color(0xFFFFE8E1);
  static const Color onErrorContainer = Color(0xFF8A2E16);
  static const Color success = Color(0xFF2A8A4A);
  static const Color successBright = Color(0xFF3DBA6E);
  static const Color warning = Color(0xFF8A6414);
  static const Color trendUp = Color(0xFFC44A2A);

  static const Color teal = Color(0xFF1A7A8A);
  static const Color tealTint = Color(0xFFE4F3F5);
  static const Color amber = Color(0xFF8A6414);
  static const Color amberTint = Color(0xFFF6EFD4);
  static const Color magenta = Color(0xFF9A3A78);
  static const Color magentaTint = Color(0xFFF6E6F0);
  static const Color greenTint = Color(0xFFE6F5EA);

  static const Color backgroundDark = Color(0xFF0E1116);
  static const Color surfaceDark = Color(0xFF0E1116);
  static const Color cardDark = Color(0xFF161A21);
  static const Color onSurfaceDark = Color(0xFFF1F2F5);
  static const Color onSurfaceVariantDark = Color(0xFF9AA3B0);
  static const Color primaryDark = Color(0xFFB8B0FF);
  static const Color borderDark = Color(0xFF2B313C);

  static const List<Color> categoryPalette = [
    Color(0xFF4F3FD6),
    Color(0xFF1A7A8A),
    Color(0xFF8A6414),
    Color(0xFF9A3A78),
    Color(0xFF2A8A4A),
    Color(0xFFC44A2A),
    Color(0xFF3F4855),
    Color(0xFF6B7480),
  ];

  static const List<Color> categoryTints = [
    Color(0xFFEEE9FF),
    Color(0xFFE4F3F5),
    Color(0xFFF6EFD4),
    Color(0xFFF6E6F0),
    Color(0xFFE6F5EA),
    Color(0xFFFFE8E1),
    Color(0xFFF1F2F5),
    Color(0xFFE4E7EC),
  ];

  static const List<Color> cardThemes = [
    Color(0xFF0E1116),
    Color(0xFF4F3FD6),
    Color(0xFF1A7A8A),
    Color(0xFF2A8A4A),
  ];

  static const Color card = surfaceContainerLowest;
  static const Color textPrimary = onSurface;
  static const Color textPrimaryDark = onSurfaceDark;
  static const Color border = outlineVariant;

  static Color themeForCardIcon(String cardIcon) {
    if (!cardIcon.startsWith('theme:')) return ink;
    final raw = cardIcon.substring(6).split('|').first;
    final index = int.tryParse(raw) ?? 0;
    return cardThemes[index.clamp(0, cardThemes.length - 1)];
  }
}

abstract final class AppRadii {
  static const double sm = 6;
  static const double input = 11;
  static const double medium = 12;
  static const double card = 14;
  static const double summary = 14;
  static const double large = 16;
  static const double pill = 100;
  static const double fab = 12;
  static const double small = 9;
  static const double icon = 8;
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double base = 8;
  static const double md = 16;
  static const double margin = 20;
  static const double lg = 24;
  static const double section = 12;
  static const double xl = 32;
}

abstract final class AppShadows {
  static List<BoxShadow> get level1 => const [];

  static List<BoxShadow> get level2 => [
        BoxShadow(
          color: const Color(0xFF0E1116).withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get fab => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.28),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}

abstract final class AppCategoryStyle {
  static int _indexFor(String category) {
    final hash = category.toLowerCase().codeUnits.fold<int>(0, (a, b) => a + b);
    return hash % AppColors.categoryPalette.length;
  }

  static Color colorFor(String category) {
    final key = category.toLowerCase();
    if (key.contains('food') || key.contains('dining') || key.contains('restaurant')) {
      return AppColors.primary;
    }
    if (key.contains('fuel') || key.contains('gas') || key.contains('transport')) {
      return AppColors.teal;
    }
    if (key.contains('bill') || key.contains('util') || key.contains('electric')) {
      return AppColors.amber;
    }
    if (key.contains('health') || key.contains('pharm') || key.contains('medic')) {
      return AppColors.magenta;
    }
    if (key.contains('groc')) {
      return AppColors.success;
    }
    return AppColors.categoryPalette[_indexFor(category)];
  }

  static Color tintFor(String category) {
    final color = colorFor(category);
    if (color == AppColors.primary) return AppColors.primaryTint;
    if (color == AppColors.teal) return AppColors.tealTint;
    if (color == AppColors.amber) return AppColors.amberTint;
    if (color == AppColors.magenta) return AppColors.magentaTint;
    if (color == AppColors.success) return AppColors.greenTint;
    return AppColors.categoryTints[_indexFor(category)];
  }

  static IconData iconFor(String category) {
    final key = category.toLowerCase();
    if (key.contains('food') || key.contains('dining') || key.contains('restaurant')) {
      return Icons.restaurant_outlined;
    }
    if (key.contains('fuel') || key.contains('gas') || key.contains('transport')) {
      return Icons.local_gas_station_outlined;
    }
    if (key.contains('shop') || key.contains('retail')) {
      return Icons.shopping_bag_outlined;
    }
    if (key.contains('grocer')) {
      return Icons.shopping_basket_outlined;
    }
    if (key.contains('bill') || key.contains('util') || key.contains('electric')) {
      return Icons.bolt_outlined;
    }
    if (key.contains('rent') || key.contains('hous')) {
      return Icons.home_outlined;
    }
    if (key.contains('entertain') || key.contains('game')) {
      return Icons.sports_esports_outlined;
    }
    if (key.contains('coffee') || key.contains('cafe') || key.contains('chaaye')) {
      return Icons.local_cafe_outlined;
    }
    if (key.contains('health') || key.contains('pharm') || key.contains('medic')) {
      return Icons.medication_outlined;
    }
    if (key.contains('travel')) {
      return Icons.flight_outlined;
    }
    return Icons.payments_outlined;
  }
}

abstract final class AppAssets {
  static const avatar = 'assets/images/avatar.jpg';
  static const splashShield = 'assets/images/splash_shield.jpg';
  static const splashBranded = 'assets/images/splash_branded.png';
  static const splashBrandedDark = 'assets/images/splash_branded_dark.png';
}
