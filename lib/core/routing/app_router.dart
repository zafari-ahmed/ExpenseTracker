import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cards/presentation/screens/card_form_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/cards/presentation/screens/card_setup_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/startup_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/needs_review_screen.dart';
import '../../features/cards/presentation/screens/sms_config_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/transactions/presentation/screens/transaction_entry_screen.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'startup',
        builder: (context, state) => const StartupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                name: 'transactions',
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                name: 'analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/cards',
        name: 'cards',
        builder: (context, state) => const CardSetupScreen(),
      ),
      GoRoute(
        path: '/cards/form',
        name: 'card-form',
        builder: (context, state) => CardFormScreen(
          cardId: state.uri.queryParameters['cardId'],
        ),
      ),
      GoRoute(
        path: '/cards/sms-config',
        name: 'sms-config',
        builder: (context, state) {
          final cardId = state.uri.queryParameters['cardId'] ?? '';
          return SmsConfigScreen(cardId: cardId);
        },
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/transactions/new',
        name: 'transaction-new',
        builder: (context, state) => const TransactionEntryScreen(),
      ),
      GoRoute(
        path: '/needs-review',
        name: 'needs-review',
        builder: (context, state) => const NeedsReviewScreen(),
      ),
    ],
  );
});
