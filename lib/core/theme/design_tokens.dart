import 'package:flutter/material.dart';

/// Design tokens from Stitch project "Minimal Fintech Expense Tracker".
abstract final class AppColors {
  static const Color primary = Color(0xFF2429A7);
  static const Color primaryContainer = Color(0xFF3E45BF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFC3C5FF);
  static const Color primaryFixed = Color(0xFFE0E0FF);
  static const Color inversePrimary = Color(0xFFBFC2FF);

  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFF7F8FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F2FD);
  static const Color surfaceContainer = Color(0xFFEFECF7);
  static const Color surfaceContainerHigh = Color(0xFFE9E7F1);
  static const Color surfaceContainerHighest = Color(0xFFE4E1EC);
  static const Color surfaceVariant = Color(0xFFE4E1EC);

  static const Color onSurface = Color(0xFF1B1B22);
  static const Color onSurfaceVariant = Color(0xFF767685);
  static const Color outline = Color(0xFF767685);
  static const Color outlineVariant = Color(0xFFC6C5D6);

  static const Color secondary = Color(0xFF5C5F60);
  static const Color secondaryContainer = Color(0xFFDEE0E2);
  static const Color tertiary = Color(0xFF3D3E42);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE65100);
  static const Color trendUp = Color(0xFFE57373);

  static const Color backgroundDark = Color(0xFF121317);
  static const Color surfaceDark = Color(0xFF121317);
  static const Color cardDark = Color(0xFF1C1E24);
  static const Color onSurfaceDark = Color(0xFFE5E7EB);
  static const Color onSurfaceVariantDark = Color(0xFFC6C5D6);
  static const Color primaryDark = Color(0xFFBFC2FF);
  static const Color borderDark = Color(0xFF374151);

  static const List<Color> categoryPalette = [
    Color(0xFF3E45BF),
    Color(0xFFE07A3D),
    Color(0xFF4A90A4),
    Color(0xFF8B6BB8),
    Color(0xFFC45C6A),
    Color(0xFF5A9E6F),
    Color(0xFFD4A017),
    Color(0xFF6B7C8C),
  ];

  static const List<Color> cardThemes = [
    Color(0xFF2429A7),
    Color(0xFFC62828),
    Color(0xFF455A64),
    Color(0xFF5C6BC0),
  ];

  static const Color card = surfaceContainerLowest;
  static const Color textPrimary = onSurface;
  static const Color textPrimaryDark = onSurfaceDark;
  static const Color border = outlineVariant;
}

abstract final class AppRadii {
  static const double sm = 8;
  static const double input = 14;
  static const double medium = 14;
  static const double card = 16;
  static const double summary = 20;
  static const double large = 20;
  static const double pill = 100;
  static const double fab = 18;
  static const double small = 12;
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double base = 8;
  static const double md = 16;
  static const double margin = 16;
  static const double lg = 24;
  static const double section = 32;
  static const double xl = 32;
}

abstract final class AppShadows {
  static List<BoxShadow> get level1 => [
        BoxShadow(
          color: const Color(0xFF1B1B22).withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get level2 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  /// Soft elevation without colored glow.
  static List<BoxShadow> get fab => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.16),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}

abstract final class AppCategoryStyle {
  static Color colorFor(String category) {
    final hash = category.toLowerCase().codeUnits.fold<int>(0, (a, b) => a + b);
    return AppColors.categoryPalette[hash % AppColors.categoryPalette.length];
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
      return Icons.shopping_cart_outlined;
    }
    if (key.contains('rent') || key.contains('hous') || key.contains('util')) {
      return Icons.home_outlined;
    }
    if (key.contains('entertain') || key.contains('game')) {
      return Icons.sports_esports_outlined;
    }
    if (key.contains('coffee') || key.contains('cafe')) {
      return Icons.coffee_outlined;
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
}
