import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/design_tokens.dart';
import '../widgets/stitch_widgets.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final showFab = navigationShell.currentIndex == 0 ||
        navigationShell.currentIndex == 1;

    return Scaffold(
      backgroundColor: AppColors.background,
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
    );
  }
}
