// ignore_for_file: type=lint
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ─── Tables ──────────────────────────────────────────────────────────────────

class AccountsTable extends Table {
  TextColumn get id => text()();
  IntColumn get userId => integer().withDefault(const Constant(1))();
  TextColumn get name => text()();
  TextColumn get type => text()(); // asset, expense, revenue, liability, cash
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
  TextColumn get currencyCode => text().withDefault(const Constant('INR'))();
  TextColumn get iban => text().nullable()();
  TextColumn get accountNumber => text().nullable()();
  TextColumn get bankName => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  IntColumn get order => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class TransactionsTable extends Table {
  TextColumn get id => text()();
  IntColumn get userId => integer().withDefault(const Constant(1))();
  TextColumn get type => text()(); // withdrawal, deposit, transfer
  TextColumn get description => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get amount => real()();
  TextColumn get currencyCode => text().withDefault(const Constant('INR'))();
  RealColumn get foreignAmount => real().nullable()();
  TextColumn get foreignCurrency => text().nullable()();
  TextColumn get sourceAccountId => text()();
  TextColumn get destAccountId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get budgetId => text().nullable()();
  TextColumn get merchantName => text().withDefault(const Constant(''))();
  TextColumn get notes => text().nullable()();
  TextColumn get tags => text().withDefault(const Constant('[]'))(); // JSON
  BoolColumn get reconciled => boolean().withDefault(const Constant(false))();
  TextColumn get internalRef => text().withDefault(const Constant(''))();
  BoolColumn get smsSource => boolean().withDefault(const Constant(false))();
  TextColumn get smsSender => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CategoriesTable extends Table {
  TextColumn get id => text()();
  IntColumn get userId => integer().withDefault(const Constant(1))();
  TextColumn get name => text()();
  TextColumn get color => text().withDefault(const Constant('#6C63FF'))();
  TextColumn get icon => text().withDefault(const Constant('category'))();
  TextColumn get parentId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class BudgetsTable extends Table {
  TextColumn get id => text()();
  IntColumn get userId => integer().withDefault(const Constant(1))();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get period => text().withDefault(const Constant('monthly'))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get categoryId => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class TagsTable extends Table {
  TextColumn get id => text()();
  IntColumn get userId => integer().withDefault(const Constant(1))();
  TextColumn get name => text()();
  TextColumn get color => text().withDefault(const Constant('#6C63FF'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class BillsTable extends Table {
  TextColumn get id => text()();
  IntColumn get userId => integer().withDefault(const Constant(1))();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get currencyCode => text().withDefault(const Constant('INR'))();
  TextColumn get period => text().withDefault(const Constant('monthly'))();
  DateTimeColumn get nextDueDate => dateTime()();
  TextColumn get accountId => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SmsMessagesTable extends Table {
  TextColumn get id => text()();
  IntColumn get userId => integer().withDefault(const Constant(1))();
  TextColumn get sender => text()();
  TextColumn get body => text()();
  DateTimeColumn get receivedAt => dateTime()();
  BoolColumn get parsed => boolean().withDefault(const Constant(false))();
  TextColumn get transactionId => text().nullable()();
  RealColumn get parsedAmount => real().nullable()();
  TextColumn get parsedMerchant => text().withDefault(const Constant(''))();
  TextColumn get parsedType => text().withDefault(const Constant(''))();
  TextColumn get duplicateOf => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueueTable extends Table {
  TextColumn get id => text()();
  TextColumn get operation => text()(); // create, update, delete
  TextColumn get resource => text()(); // accounts, transactions, etc.
  TextColumn get resourceId => text()();
  TextColumn get payload => text()(); // JSON
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttempt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

// ─── Database ────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  AccountsTable,
  TransactionsTable,
  CategoriesTable,
  BudgetsTable,
  TagsTable,
  BillsTable,
  SmsMessagesTable,
  SyncQueueTable,
  SettingsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ── Settings helpers ────────────────────────────────────────────────────────
  Future<String?> getSetting(String key) async {
    final row = await (select(settingsTable)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(settingsTable).insertOnConflictUpdate(
      SettingsTableCompanion.insert(
        key: key,
        value: value,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteSetting(String key) async {
    await (delete(settingsTable)..where((t) => t.key.equals(key))).go();
  }

  // ── Accounts ────────────────────────────────────────────────────────────────
  Stream<List<AccountsTableData>> watchAllAccounts() =>
      (select(accountsTable)..where((t) => t.active.equals(true))..orderBy([(t) => OrderingTerm(expression: t.order)])).watch();

  Future<AccountsTableData?> getAccountById(String id) =>
      (select(accountsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertAccount(AccountsTableCompanion account) =>
      into(accountsTable).insertOnConflictUpdate(account);

  Future<void> deleteAccount(String id) =>
      (delete(accountsTable)..where((t) => t.id.equals(id))).go();

  Future<double> getTotalAssets() async {
    final expr = accountsTable.currentBalance.sum();
    final query = selectOnly(accountsTable)
      ..addColumns([expr])
      ..where(accountsTable.type.isIn(['asset', 'cash']) & accountsTable.active.equals(true));
    final result = await query.getSingle();
    return result.read(expr) ?? 0.0;
  }

  // ── Transactions ────────────────────────────────────────────────────────────
  Stream<List<TransactionsTableData>> watchRecentTransactions(int limit) =>
      (select(transactionsTable)..orderBy([(t) => OrderingTerm.desc(t.date)])..limit(limit)).watch();

  Future<List<TransactionsTableData>> searchTransactions(String query) =>
      (select(transactionsTable)
        ..where((t) =>
            t.description.like('%$query%') |
            t.merchantName.like('%$query%') |
            t.notes.like('%$query%'))
        ..orderBy([(t) => OrderingTerm.desc(t.date)])
        ..limit(100))
          .get();

  Future<void> upsertTransaction(TransactionsTableCompanion tx) =>
      into(transactionsTable).insertOnConflictUpdate(tx);

  Future<void> deleteTransaction(String id) =>
      (delete(transactionsTable)..where((t) => t.id.equals(id))).go();

  // ── SMS ─────────────────────────────────────────────────────────────────────
  Stream<List<SmsMessagesTableData>> watchPendingSms() =>
      (select(smsMessagesTable)
        ..where((t) => t.parsed.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.receivedAt)]))
          .watch();

  Future<void> upsertSmsMessage(SmsMessagesTableCompanion msg) =>
      into(smsMessagesTable).insertOnConflictUpdate(msg);

  // ── Sync Queue ───────────────────────────────────────────────────────────────
  Future<List<SyncQueueTableData>> getPendingSyncItems() =>
      (select(syncQueueTable)..where((t) => t.attempts.isSmallerThanValue(5))..orderBy([(t) => OrderingTerm(expression: t.createdAt)])).get();

  Future<void> enqueueSyncItem(SyncQueueTableCompanion item) =>
      into(syncQueueTable).insertOnConflictUpdate(item);

  Future<void> deleteSyncItem(String id) =>
      (delete(syncQueueTable)..where((t) => t.id.equals(id))).go();

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'firefly_neo.db');
  }
}
