import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({
    required this.location,
    required this.child,
    super.key,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      key: const Key('main-navigation-shell'),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex(location),
        backgroundColor: theme.colorScheme.card,
        indicatorColor: theme.colorScheme.accent,
        destinations: const [
          NavigationDestination(
            key: Key('app-nav-journey'),
            icon: Icon(LucideIcons.map),
            selectedIcon: Icon(LucideIcons.mapPinned),
            label: 'Journey',
          ),
          NavigationDestination(
            key: Key('app-nav-review'),
            icon: Icon(LucideIcons.rotateCcw),
            selectedIcon: Icon(LucideIcons.refreshCcwDot),
            label: 'Review',
          ),
          NavigationDestination(
            key: Key('app-nav-settings'),
            icon: Icon(LucideIcons.settings),
            selectedIcon: Icon(LucideIcons.settings2),
            label: 'Settings',
          ),
        ],
        onDestinationSelected: (index) {
          context.go(switch (index) {
            0 => '/',
            1 => '/review',
            _ => '/settings',
          });
        },
      ),
    );
  }
}

int _selectedIndex(String location) {
  if (location.startsWith('/review')) return 1;
  if (location.startsWith('/settings')) return 2;
  return 0;
}
