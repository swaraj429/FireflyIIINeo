import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _tokenKey = 'neo_access_token';
const _serverUrlKey = 'neo_server_url';
const _defaultPort = 9090;

/// Singleton Dio client for the Neo backend API.
class NeoApiClient {
  static NeoApiClient? _instance;
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  NeoApiClient._({required String baseUrl, String? token})
      : _storage = const FlutterSecureStorage() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ));
    _dio.interceptors.add(_AuthInterceptor(_storage, _dio));
  }

  factory NeoApiClient.local({String? token}) {
    _instance ??= NeoApiClient._(
      baseUrl: 'http://127.0.0.1:$_defaultPort/api',
      token: token,
    );
    return _instance!;
  }

  factory NeoApiClient.remote({required String serverUrl, String? token}) {
    _instance = NeoApiClient._(baseUrl: '$serverUrl/api', token: token);
    return _instance!;
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _storage.write(key: _tokenKey, value: token);
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
    _storage.delete(key: _tokenKey);
  }

  Dio get dio => _dio;
}

/// Refreshes the auth token on 401, queues requests while refreshing.
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<_PendingRequest> _queue = [];

  _AuthInterceptor(this._storage, this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired — clear and propagate; let UI handle re-login
      await _storage.delete(key: _tokenKey);
      _dio.options.headers.remove('Authorization');
    }
    handler.next(err);
  }
}

class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  _PendingRequest(this.options, this.handler);
}

// ── Auth ───────────────────────────────────────────────────────────────────

class AuthApiService {
  final Dio _dio;
  AuthApiService(NeoApiClient client) : _dio = client.dio;

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'display_name': displayName,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> pinLogin({required String pin}) async {
    final res = await _dio.post('/auth/pin-login', data: {'pin': pin});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post('/auth/change-password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }
}

// ── Accounts ──────────────────────────────────────────────────────────────

class AccountsApiService {
  final Dio _dio;
  AccountsApiService(NeoApiClient client) : _dio = client.dio;

  Future<List<dynamic>> listAccounts({String? type}) async {
    final res = await _dio.get('/accounts', queryParameters: {
      if (type != null) 'type': type,
    });
    return (res.data as Map<String, dynamic>)['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> createAccount(Map<String, dynamic> data) async {
    final res = await _dio.post('/accounts', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAccount(String id) async {
    final res = await _dio.get('/accounts/$id');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateAccount(String id, Map<String, dynamic> data) async {
    final res = await _dio.put('/accounts/$id', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteAccount(String id) async => _dio.delete('/accounts/$id');
}

// ── Transactions ──────────────────────────────────────────────────────────

class TransactionsApiService {
  final Dio _dio;
  TransactionsApiService(NeoApiClient client) : _dio = client.dio;

  Future<Map<String, dynamic>> listTransactions({
    int page = 1,
    int limit = 50,
    String? type,
    String? accountId,
    String? categoryId,
    String? startDate,
    String? endDate,
    String? search,
  }) async {
    final res = await _dio.get('/transactions', queryParameters: {
      'page': page,
      'limit': limit,
      if (type != null) 'type': type,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (startDate != null) 'start': startDate,
      if (endDate != null) 'end': endDate,
      if (search != null) 'q': search,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> data) async {
    final res = await _dio.post('/transactions', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateTransaction(String id, Map<String, dynamic> data) async {
    final res = await _dio.put('/transactions/$id', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteTransaction(String id) async => _dio.delete('/transactions/$id');

  Future<List<dynamic>> searchTransactions(String query) async {
    final res = await _dio.get('/transactions/search', queryParameters: {'q': query});
    return (res.data as Map<String, dynamic>)['data'] as List<dynamic>;
  }
}

// ── Categories ────────────────────────────────────────────────────────────

class CategoriesApiService {
  final Dio _dio;
  CategoriesApiService(NeoApiClient client) : _dio = client.dio;

  Future<List<dynamic>> listCategories() async {
    final res = await _dio.get('/categories');
    return (res.data as Map<String, dynamic>)['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    final res = await _dio.post('/categories', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCategory(String id, Map<String, dynamic> data) async {
    final res = await _dio.put('/categories/$id', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteCategory(String id) async => _dio.delete('/categories/$id');

  Future<List<dynamic>> getCategoryBreakdown({String? startDate, String? endDate}) async {
    final res = await _dio.get('/analytics/category-breakdown', queryParameters: {
      if (startDate != null) 'start': startDate,
      if (endDate != null) 'end': endDate,
    });
    return res.data as List<dynamic>;
  }
}

// ── Budgets ───────────────────────────────────────────────────────────────

class BudgetsApiService {
  final Dio _dio;
  BudgetsApiService(NeoApiClient client) : _dio = client.dio;

  Future<List<dynamic>> listBudgets() async {
    final res = await _dio.get('/budgets');
    return (res.data as Map<String, dynamic>)['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> createBudget(Map<String, dynamic> data) async {
    final res = await _dio.post('/budgets', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateBudget(String id, Map<String, dynamic> data) async {
    final res = await _dio.put('/budgets/$id', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteBudget(String id) async => _dio.delete('/budgets/$id');

  Future<List<dynamic>> getBudgetProgress() async {
    final res = await _dio.get('/analytics/budget-progress');
    return res.data as List<dynamic>;
  }
}

// ── Analytics ─────────────────────────────────────────────────────────────

class AnalyticsApiService {
  final Dio _dio;
  AnalyticsApiService(NeoApiClient client) : _dio = client.dio;

  Future<Map<String, dynamic>> getDashboard() async {
    final res = await _dio.get('/analytics/dashboard');
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getCashflow({int months = 12}) async {
    final res = await _dio.get('/analytics/cashflow', queryParameters: {'months': months});
    return res.data as List<dynamic>;
  }

  Future<List<dynamic>> getMerchantInsights({int limit = 20}) async {
    final res = await _dio.get('/analytics/merchant-insights', queryParameters: {'limit': limit});
    return res.data as List<dynamic>;
  }

  Future<List<dynamic>> getSpendingHeatmap({int? year}) async {
    final res = await _dio.get('/analytics/spending-heatmap', queryParameters: {
      if (year != null) 'year': year,
    });
    return res.data as List<dynamic>;
  }

  Future<List<dynamic>> getNetWorthHistory({int months = 12}) async {
    final res = await _dio.get('/analytics/net-worth-history', queryParameters: {'months': months});
    return res.data as List<dynamic>;
  }
}

// ── SMS ───────────────────────────────────────────────────────────────────

class SmsApiService {
  final Dio _dio;
  SmsApiService(NeoApiClient client) : _dio = client.dio;

  Future<Map<String, dynamic>> ingestSms(Map<String, dynamic> data) async {
    final res = await _dio.post('/sms/ingest', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> listMessages({bool pendingOnly = false, int page = 1}) async {
    final res = await _dio.get('/sms/messages', queryParameters: {
      'page': page,
      if (pendingOnly) 'pending': true,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> approveMessage(String id, Map<String, dynamic> data) async {
    final res = await _dio.post('/sms/messages/$id/approve', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<void> rejectMessage(String id) async => _dio.post('/sms/messages/$id/reject');
  Future<void> deleteMessage(String id) async => _dio.delete('/sms/messages/$id');
}
