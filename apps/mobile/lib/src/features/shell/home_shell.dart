import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/sms_provider.dart';

class HomeShell extends ConsumerStatefulWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_rounded,
      activeIcon: Icons.dashboard_rounded,
      route: '/home/dashboard',
    ),
    _NavItem(
      label: 'Transactions',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      route: '/home/transactions',
    ),
    _NavItem(
      label: 'Analytics',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      route: '/home/analytics',
    ),
    _NavItem(
      label: 'Budgets',
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      route: '/home/budgets',
    ),
    _NavItem(
      label: 'Accounts',
      icon: Icons.credit_card_outlined,
      activeIcon: Icons.credit_card_rounded,
      route: '/home/accounts',
    ),
  ];

  void _onTabSelected(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
      context.go(_navItems[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingSmsCount = ref.watch(pendingSmsCountProvider);

    // Sync selected index with current route
    final location = GoRouterState.of(context).matchedLocation;
    final routeIndex = _navItems.indexWhere(
      (item) => location.startsWith(item.route),
    );
    if (routeIndex != -1 && routeIndex != _selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => setState(() => _selectedIndex = routeIndex),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: widget.child,
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/transactions/add'),
              backgroundColor: const Color(0xFF9B72CF),
              foregroundColor: Colors.white,
              elevation: 8,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : FloatingActionButton(
              onPressed: () => context.go('/transactions/add'),
              backgroundColor: const Color(0xFF9B72CF),
              foregroundColor: Colors.white,
              elevation: 8,
              child: const Icon(Icons.add_rounded, size: 28),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTabSelected,
        backgroundColor: const Color(0xFF0F0F1A),
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFF6750A4).withOpacity(0.2),
        shadowColor: Colors.black26,
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        animationDuration: const Duration(milliseconds: 400),
        destinations: _navItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == _selectedIndex;

          Widget iconWidget = Icon(
            isSelected ? item.activeIcon : item.icon,
            color: isSelected
                ? const Color(0xFF9B72CF)
                : Colors.white.withOpacity(0.4),
          );

          // Badge for SMS-related notifications (could be tied to any tab)
          if (index == 0 && pendingSmsCount > 0) {
            iconWidget = Badge(
              label: Text(pendingSmsCount.toString()),
              backgroundColor: const Color(0xFFEF5350),
              child: iconWidget,
            );
          }

          return NavigationDestination(
            icon: iconWidget,
            selectedIcon: Icon(
              item.activeIcon,
              color: const Color(0xFF9B72CF),
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}
