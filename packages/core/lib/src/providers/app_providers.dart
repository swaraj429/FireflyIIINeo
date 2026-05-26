import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:neo_database/neo_database.dart';
import 'package:neo_firefly_adapter/neo_firefly_adapter.dart';
import 'package:neo_shared/neo_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Singletons ───────────────────────────────────────────────────────────────

final _storage = const FlutterSecureStorage();

// ── Database ─────────────────────────────────────────────────────────────────

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ── API Client ────────────────────────────────────────────────────────────────

final apiClientProvider = Provider<NeoApiClient>((ref) {
  return NeoApiClient.local();
});

// ── Auth State ────────────────────────────────────────────────────────────────

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? displayName;
  final String? email;
  const AuthState({
    this.status = AuthStatus.unknown,
    this.userId,
    this.displayName,
    this.email,
  });
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    String? token = await _storage.read(key: 'neo_access_token');

    if (token == null) {
      try {
        final client = ref.read(apiClientProvider);
        final svc = AuthApiService(client);
        try {
          final resp = await svc.register(
            email: 'user@fireflyneo.com',
            password: 'password123',
            displayName: 'User',
          );
          token = resp['token'] as String;
        } catch (_) {
          final resp = await svc.login(
            email: 'user@fireflyneo.com',
            password: 'password123',
          );
          token = resp['token'] as String;
        }

        if (token != null) {
          client.setToken(token);
          await _storage.write(key: 'neo_access_token', value: token);
        }
      } catch (_) {
        // Offline or connection not ready yet
      }
    }

    if (token == null) return const AuthState(status: AuthStatus.unauthenticated);
    try {
      final client = ref.read(apiClientProvider);
      client.setToken(token);
      final svc = AuthApiService(client);
      final me = await svc.getMe();
      return AuthState(
        status: AuthStatus.authenticated,
        userId: me['id']?.toString(),
        displayName: me['display_name']?.toString(),
        email: me['email']?.toString(),
      );
    } catch (_) {
      await _storage.delete(key: 'neo_access_token');
      return const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(apiClientProvider);
      final svc = AuthApiService(client);
      final resp = await svc.login(email: email, password: password);
      final token = resp['token'] as String;
      client.setToken(token);
      await _storage.write(key: 'neo_access_token', value: token);
      return AuthState(
        status: AuthStatus.authenticated,
        userId: resp['user']?['id']?.toString(),
        displayName: resp['user']?['display_name']?.toString(),
        email: resp['user']?['email']?.toString(),
      );
    });
  }

  Future<void> register(String email, String password, String displayName) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(apiClientProvider);
      final svc = AuthApiService(client);
      final resp = await svc.register(
          email: email, password: password, displayName: displayName);
      final token = resp['token'] as String;
      client.setToken(token);
      await _storage.write(key: 'neo_access_token', value: token);
      return AuthState(
        status: AuthStatus.authenticated,
        userId: resp['user']?['id']?.toString(),
        displayName: resp['user']?['display_name']?.toString(),
        email: resp['user']?['email']?.toString(),
      );
    });
  }

  Future<void> logout() async {
    await _storage.delete(key: 'neo_access_token');
    ref.read(apiClientProvider).clearToken();
    state = const AsyncValue.data(AuthState(status: AuthStatus.unauthenticated));
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// ── Setup Check ───────────────────────────────────────────────────────────────

final isFirstLaunchProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('setup_complete') != true;
});

final setupCompleteProvider = Provider<void>((ref) {});

Future<void> markSetupComplete() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('setup_complete', true);
}

// ── Dashboard ─────────────────────────────────────────────────────────────────

class DashboardNotifier extends AsyncNotifier<DashboardSummary> {
  @override
  Future<DashboardSummary> build() => _fetch();

  Future<DashboardSummary> _fetch() async {
    final client = ref.read(apiClientProvider);
    final svc = AnalyticsApiService(client);
    final data = await svc.getDashboard();
    return DashboardSummary(
      netWorth: (data['net_worth'] as num?)?.toDouble() ?? 0,
      totalAssets: (data['total_assets'] as num?)?.toDouble() ?? 0,
      totalLiabilities: (data['total_liabilities'] as num?)?.toDouble() ?? 0,
      monthlyIncome: (data['monthly_income'] as num?)?.toDouble() ?? 0,
      monthlyExpenses: (data['monthly_expenses'] as num?)?.toDouble() ?? 0,
      monthlySavingsRate: (data['savings_rate'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

final dashboardProvider = AsyncNotifierProvider<DashboardNotifier, DashboardSummary>(DashboardNotifier.new);

// ── Accounts ──────────────────────────────────────────────────────────────────

class AccountsNotifier extends AsyncNotifier<List<Account>> {
  @override
  Future<List<Account>> build() => _fetch();

  Future<List<Account>> _fetch() async {
    final client = ref.read(apiClientProvider);
    final svc = AccountsApiService(client);
    final raw = await svc.listAccounts();
    return raw.map((e) => Account.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> createAccount(Map<String, dynamic> data) async {
    final client = ref.read(apiClientProvider);
    await AccountsApiService(client).createAccount(data);
    await refresh();
  }

  Future<void> deleteAccount(String id) async {
    final client = ref.read(apiClientProvider);
    await AccountsApiService(client).deleteAccount(id);
    await refresh();
  }
}

final accountsProvider = AsyncNotifierProvider<AccountsNotifier, List<Account>>(AccountsNotifier.new);

// ── Transactions ──────────────────────────────────────────────────────────────

class TransactionFilter {
  final String? type;
  final String? accountId;
  final String? categoryId;
  final String? startDate;
  final String? endDate;
  final String? search;
  final int page;
  const TransactionFilter({
    this.type,
    this.accountId,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.search,
    this.page = 1,
  });
}

class TransactionListState {
  final List<Transaction> items;
  final int totalPages;
  final int currentPage;
  final bool isLoading;
  const TransactionListState({
    this.items = const [],
    this.totalPages = 1,
    this.currentPage = 1,
    this.isLoading = false,
  });
  TransactionListState copyWith({List<Transaction>? items, int? totalPages, int? currentPage, bool? isLoading}) =>
      TransactionListState(
        items: items ?? this.items,
        totalPages: totalPages ?? this.totalPages,
        currentPage: currentPage ?? this.currentPage,
        isLoading: isLoading ?? this.isLoading,
      );
}

final transactionFilterProvider = StateProvider<TransactionFilter>((ref) => const TransactionFilter());

final transactionsProvider = AsyncNotifierProvider.autoDispose<TransactionsNotifier, TransactionListState>(TransactionsNotifier.new);

class TransactionsNotifier extends AutoDisposeAsyncNotifier<TransactionListState> {
  @override
  Future<TransactionListState> build() => _fetch(const TransactionFilter());

  Future<TransactionListState> _fetch(TransactionFilter filter) async {
    final client = ref.read(apiClientProvider);
    final svc = TransactionsApiService(client);
    final resp = await svc.listTransactions(
      page: filter.page,
      type: filter.type,
      accountId: filter.accountId,
      categoryId: filter.categoryId,
      startDate: filter.startDate,
      endDate: filter.endDate,
      search: filter.search,
    );
    final items = (resp['data'] as List<dynamic>?)
            ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return TransactionListState(
      items: items,
      totalPages: (resp['total_pages'] as num?)?.toInt() ?? 1,
      currentPage: filter.page,
    );
  }

  Future<void> applyFilter(TransactionFilter filter) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(filter));
  }

  Future<void> createTransaction(Map<String, dynamic> data) async {
    final client = ref.read(apiClientProvider);
    await TransactionsApiService(client).createTransaction(data);
    state = await AsyncValue.guard(() => _fetch(const TransactionFilter()));
  }

  Future<void> deleteTransaction(String id) async {
    final client = ref.read(apiClientProvider);
    await TransactionsApiService(client).deleteTransaction(id);
    final current = state.valueOrNull ?? const TransactionListState();
    state = AsyncValue.data(
      current.copyWith(items: current.items.where((t) => t.id != id).toList()),
    );
  }
}

// ── Categories ────────────────────────────────────────────────────────────────

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final client = ref.read(apiClientProvider);
  final raw = await CategoriesApiService(client).listCategories();
  return raw.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
});

// ── Budgets ───────────────────────────────────────────────────────────────────

final budgetsProvider = FutureProvider<List<Budget>>((ref) async {
  final client = ref.read(apiClientProvider);
  final raw = await BudgetsApiService(client).listBudgets();
  return raw.map((e) => Budget.fromJson(e as Map<String, dynamic>)).toList();
});

final budgetProgressProvider = FutureProvider<List<BudgetProgress>>((ref) async {
  final client = ref.read(apiClientProvider);
  final raw = await BudgetsApiService(client).getBudgetProgress();
  return raw.map((e) => BudgetProgress.fromJson(e as Map<String, dynamic>)).toList();
});

// ── Analytics ─────────────────────────────────────────────────────────────────

final cashflowProvider = FutureProvider.family<List<CashflowEntry>, int>((ref, months) async {
  final client = ref.read(apiClientProvider);
  final raw = await AnalyticsApiService(client).getCashflow(months: months);
  return raw.map((e) => CashflowEntry.fromJson(e as Map<String, dynamic>)).toList();
});

final categoryBreakdownProvider = FutureProvider<List<CategorySpending>>((ref) async {
  final client = ref.read(apiClientProvider);
  final raw = await CategoriesApiService(client).getCategoryBreakdown();
  return raw.map((e) => CategorySpending.fromJson(e as Map<String, dynamic>)).toList();
});

final merchantInsightsProvider = FutureProvider<List<MerchantInsight>>((ref) async {
  final client = ref.read(apiClientProvider);
  final raw = await AnalyticsApiService(client).getMerchantInsights();
  return raw.map((e) => MerchantInsight.fromJson(e as Map<String, dynamic>)).toList();
});

final netWorthHistoryProvider = FutureProvider.family<List<NetWorthEntry>, int>((ref, months) async {
  final client = ref.read(apiClientProvider);
  final raw = await AnalyticsApiService(client).getNetWorthHistory(months: months);
  return raw.map((e) => NetWorthEntry.fromJson(e as Map<String, dynamic>)).toList();
});

// ── SMS ───────────────────────────────────────────────────────────────────────

class SmsMessagesNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() => _fetch();

  Future<List<Map<String, dynamic>>> _fetch() async {
    final client = ref.read(apiClientProvider);
    final resp = await SmsApiService(client).listMessages(pendingOnly: true);
    return List<Map<String, dynamic>>.from(resp['data'] as List? ?? []);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> approve(String id, Map<String, dynamic> data) async {
    final client = ref.read(apiClientProvider);
    await SmsApiService(client).approveMessage(id, data);
    await refresh();
    ref.invalidate(dashboardProvider);
    ref.invalidate(accountsProvider);
  }

  Future<void> reject(String id) async {
    final client = ref.read(apiClientProvider);
    await SmsApiService(client).rejectMessage(id);
    await refresh();
  }
}

final smsPendingProvider = AsyncNotifierProvider<SmsMessagesNotifier, List<Map<String, dynamic>>>(SmsMessagesNotifier.new);

final smsPendingCountProvider = Provider<int>((ref) {
  return ref.watch(smsPendingProvider).valueOrNull?.length ?? 0;
});

// ── Settings ──────────────────────────────────────────────────────────────────

final themeModeProvider = StateProvider<String>((ref) => 'dark'); // dark | light | system
