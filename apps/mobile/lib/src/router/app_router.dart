import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/setup/server_setup_screen.dart';
import '../features/setup/pin_setup_screen.dart';
import '../features/shell/home_shell.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/transactions/transactions_screen.dart';
import '../features/transactions/transaction_detail_screen.dart';
import '../features/transactions/add_transaction_screen.dart';
import '../features/transactions/edit_transaction_screen.dart';
import '../features/accounts/accounts_screen.dart';
import '../providers/local_providers.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title Screen\n(Under Active Development)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);
  final isSetup = ref.watch(isSetupProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isSplash = location == '/splash';
      final isOnboarding = location.startsWith('/onboarding');
      final isSetupRoute = location.startsWith('/setup');

      if (isSplash) return null;
      if (!isSetup && !isOnboarding && !isSetupRoute) {
        return '/onboarding';
      }
      if (isSetup && (isOnboarding || isSetupRoute)) {
        return '/home/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/setup/server',
        name: 'setup-server',
        builder: (context, state) => const ServerSetupScreen(),
      ),
      GoRoute(
        path: '/setup/pin',
        name: 'setup-pin',
        builder: (context, state) => const PinSetupScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/home/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/home/transactions',
            name: 'transactions',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TransactionsScreen(),
            ),
          ),
          GoRoute(
            path: '/home/analytics',
            name: 'analytics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlaceholderScreen(title: 'Analytics'),
            ),
          ),
          GoRoute(
            path: '/home/budgets',
            name: 'budgets',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlaceholderScreen(title: 'Budgets'),
            ),
          ),
          GoRoute(
            path: '/home/accounts',
            name: 'accounts',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AccountsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/transactions/add',
        name: 'add-transaction',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/transactions/:id',
        name: 'transaction-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => TransactionDetailScreen(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/transactions/:id/edit',
        name: 'edit-transaction',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => EditTransactionScreen(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/accounts/:id',
        name: 'account-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => PlaceholderScreen(
          title: 'Account Details (${state.pathParameters['id']})',
        ),
      ),
      GoRoute(
        path: '/budgets/:id',
        name: 'budget-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => PlaceholderScreen(
          title: 'Budget Details (${state.pathParameters['id']})',
        ),
      ),
      GoRoute(
        path: '/goals',
        name: 'goals',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlaceholderScreen(title: 'Goals'),
      ),
      GoRoute(
        path: '/recurring',
        name: 'recurring',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlaceholderScreen(title: 'Recurring'),
      ),
      GoRoute(
        path: '/merchants',
        name: 'merchants',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlaceholderScreen(title: 'Merchant Insights'),
      ),
      GoRoute(
        path: '/rules',
        name: 'rules',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlaceholderScreen(title: 'Rules'),
      ),
      GoRoute(
        path: '/sms/import',
        name: 'sms-import',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlaceholderScreen(title: 'SMS Import'),
      ),
      GoRoute(
        path: '/sms/settings',
        name: 'sms-settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlaceholderScreen(title: 'SMS Settings'),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlaceholderScreen(title: 'Settings'),
      ),
      GoRoute(
        path: '/settings/sync',
        name: 'sync-settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlaceholderScreen(title: 'Sync Settings'),
      ),
      GoRoute(
        path: '/settings/security',
        name: 'security-settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlaceholderScreen(title: 'Security Settings'),
      ),
    ],
  );
}
