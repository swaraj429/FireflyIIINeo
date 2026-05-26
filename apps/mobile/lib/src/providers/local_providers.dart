import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_core/neo_core.dart';
import 'package:neo_shared/neo_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Compatibility Adapter layer to resolve missing providers

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authProvider).valueOrNull ?? const AuthState();
});

final isSetupProvider = Provider<bool>((ref) {
  return ref.watch(isFirstLaunchProvider).valueOrNull == false;
});

final transactionDetailProvider = Provider.family<AsyncValue<Transaction>, String>((ref, id) {
  final txs = ref.watch(transactionsProvider).valueOrNull?.items ?? [];
  final tx = txs.firstWhere((t) => t.id == id, orElse: () => Transaction(
    id: '',
    description: '',
    amount: 0,
    date: DateTime(1970),
    type: TransactionType.withdrawal,
    createdAt: DateTime(1970),
    updatedAt: DateTime(1970),
    sourceAccountId: '',
  ));
  return AsyncValue.data(tx);
});

class SettingsState {}
class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => SettingsState();

  Future<void> setOnboardingComplete() async {
    await markSetupComplete();
    ref.invalidate(isFirstLaunchProvider);
  }

  Future<void> setServerConfigured() async {
    // Mock server configuration complete
  }

  Future<void> setSetupComplete(bool val) async {
    await markSetupComplete();
    ref.invalidate(isFirstLaunchProvider);
  }
}
final settingsNotifierProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class MockAuthNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> setupPin(String pin) async {
    // Mock setting pin
  }

  Future<void> enableBiometrics() async {
    // Mock enable biometrics
  }
}
final authNotifierProvider = NotifierProvider<MockAuthNotifier, void>(MockAuthNotifier.new);

final pendingSmsCountProvider = smsPendingCountProvider;

typedef TransactionDetail = Transaction;

extension TransactionDetailExtension on Transaction {
  String? get categoryName => null;
  int? get categoryColor => null;
  String? get categoryIcon => null;
  String? get merchant => merchantName;
  String? get accountName => 'Main Account';
  String? get toAccount => null;
  bool get isFromSms => smsSource != null;
}

class AccountItem {
  final String id;
  final String name;
  final String type;
  final double balance;
  const AccountItem({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
  });
}

final accountsListProvider = Provider<AsyncValue<List<AccountItem>>>((ref) {
  final accountsAsync = ref.watch(accountsProvider);
  return accountsAsync.when(
    data: (list) => AsyncValue.data(list.map((a) => AccountItem(
      id: a.id,
      name: a.name,
      type: a.type.name,
      balance: a.currentBalance,
    )).toList()),
    error: (e, s) => AsyncValue.error(e, s),
    loading: () => const AsyncValue.loading(),
  );
});

class MockTransactionsPaginationNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addTransaction({
    required String type,
    required double amount,
    required DateTime date,
    required String accountId,
    String? toAccountId,
    String? categoryId,
    required String merchant,
    required String description,
    required List<String> tags,
    required String notes,
  }) async {
    final data = {
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
      'source_account_id': accountId,
      if (toAccountId != null) 'destination_account_id': toAccountId,
      if (categoryId != null) 'category_id': categoryId,
      'merchant_name': merchant,
      'description': description,
      'tags': tags,
      'notes': notes,
    };
    await ref.read(transactionsProvider.notifier).createTransaction(data);
  }
}

final transactionsPaginationProvider = NotifierProvider<MockTransactionsPaginationNotifier, void>(MockTransactionsPaginationNotifier.new);

