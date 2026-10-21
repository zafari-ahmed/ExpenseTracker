import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/stitch_widgets.dart';

final hideAddFabProvider = StateProvider<bool>((ref) => false);

Future<T?> runWithHiddenAddFab<T>(
  WidgetRef ref,
  Future<T?> Function() action,
) async {
  ref.read(hideAddFabProvider.notifier).state = true;
  try {
    return await action();
  } finally {
    ref.read(hideAddFabProvider.notifier).state = false;
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideFab = ref.watch(hideAddFabProvider);
    final onListTab = navigationShell.currentIndex == 0 ||
        navigationShell.currentIndex == 1;
    final showFab = onListTab && !hideFab;

    final onDashboard = navigationShell.currentIndex == 0;

    return PopScope(
      canPop: onDashboard,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || onDashboard) return;
        navigationShell.goBranch(0);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: navigationShell,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: showFab
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: EtAddFab(
                  onPressed: () => context.push('/transactions/new'),
                ),
              )
            : null,
        bottomNavigationBar: EtBottomNav(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
        ),
      ),
    );
  }
}
