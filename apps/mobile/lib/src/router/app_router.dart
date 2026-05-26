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
import '../features/accounts/account_detail_screen.dart';
import '../features/budgets/budgets_screen.dart';
import '../features/budgets/budget_detail_screen.dart';
import '../features/analytics/analytics_screen.dart';
import '../features/sms/sms_import_screen.dart';
import '../features/sms/sms_settings_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/sync_settings_screen.dart';
import '../features/settings/security_settings_screen.dart';
import '../features/recurring/recurring_screen.dart';
import '../features/rules/rules_screen.dart';
import '../features/goals/goals_screen.dart';
import '../features/merchants/merchant_insights_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

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
              child: AnalyticsScreen(),
            ),
          ),
          GoRoute(
            path: '/home/budgets',
            name: 'budgets',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BudgetsScreen(),
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
        builder: (context, state) => AccountDetailScreen(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/budgets/:id',
        name: 'budget-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BudgetDetailScreen(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/goals',
        name: 'goals',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: '/recurring',
        name: 'recurring',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RecurringScreen(),
      ),
      GoRoute(
        path: '/merchants',
        name: 'merchants',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MerchantInsightsScreen(),
      ),
      GoRoute(
        path: '/rules',
        name: 'rules',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RulesScreen(),
      ),
      GoRoute(
        path: '/sms/import',
        name: 'sms-import',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SmsImportScreen(),
      ),
      GoRoute(
        path: '/sms/settings',
        name: 'sms-settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SmsSettingsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/sync',
        name: 'sync-settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SyncSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/security',
        name: 'security-settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
    ],
  );
}
