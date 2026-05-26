/// API endpoint constants for FireflyIII Neo backend
abstract class ApiConstants {
  ApiConstants._();

  static const int defaultPort = 9090;
  static const String basePathPrefix = '/api';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String pinLogin = '/auth/pin-login';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String changePassword = '/auth/change-password';
  static const String setPin = '/auth/set-pin';

  // Accounts
  static const String accounts = '/accounts';
  static String accountById(String id) => '/accounts/$id';

  // Transactions
  static const String transactions = '/transactions';
  static String transactionById(String id) => '/transactions/$id';

  // Categories
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // Budgets
  static const String budgets = '/budgets';
  static String budgetById(String id) => '/budgets/$id';

  // Tags
  static const String tags = '/tags';
  static String tagById(String id) => '/tags/$id';

  // Bills
  static const String bills = '/bills';
  static String billById(String id) => '/bills/$id';

  // Rules
  static const String rules = '/rules';
  static String ruleById(String id) => '/rules/$id';
  static String applyRule(String id) => '/rules/$id/apply';

  // SMS
  static const String smsIngest = '/sms/ingest';
  static const String smsMessages = '/sms/messages';
  static String smsMessageById(String id) => '/sms/messages/$id';
  static String approveSms(String id) => '/sms/messages/$id/approve';
  static String rejectSms(String id) => '/sms/messages/$id/reject';

  // Analytics
  static const String analytics = '/analytics';
  static const String dashboard = '/analytics/dashboard';
  static const String cashflow = '/analytics/cashflow';
  static const String categoryBreakdown = '/analytics/category-breakdown';
  static const String merchantInsights = '/analytics/merchant-insights';
  static const String budgetProgress = '/analytics/budget-progress';
  static const String incomeVsExpenses = '/analytics/income-vs-expenses';
  static const String spendingHeatmap = '/analytics/spending-heatmap';
  static const String netWorthHistory = '/analytics/net-worth-history';

  // Settings
  static const String settings = '/settings';
  static String settingByKey(String key) => '/settings/$key';

  // Sync
  static const String syncStatus = '/sync/status';
  static const String syncTrigger = '/sync/trigger';

  // Health
  static const String health = '/health';

  // Helpers
  static String buildBaseUrl({
    String host = 'localhost',
    int port = defaultPort,
    bool secure = false,
  }) {
    final scheme = secure ? 'https' : 'http';
    return '$scheme://$host:$port$basePathPrefix';
  }
}
