/// Generic API response wrapper with success/error handling
class ApiResponse<T> {
  final T? data;
  final String? error;
  final String? message;
  final int statusCode;
  final bool success;

  const ApiResponse._({
    this.data,
    this.error,
    this.message,
    required this.statusCode,
    required this.success,
  });

  factory ApiResponse.success({
    required T data,
    String? message,
    int statusCode = 200,
  }) {
    return ApiResponse._(
      data: data,
      message: message,
      statusCode: statusCode,
      success: true,
    );
  }

  factory ApiResponse.error({
    required String error,
    String? message,
    int statusCode = 500,
  }) {
    return ApiResponse._(
      error: error,
      message: message,
      statusCode: statusCode,
      success: false,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final isSuccess = json['success'] as bool? ?? true;
    if (isSuccess && json['data'] != null) {
      return ApiResponse._(
        data: fromJsonT(json['data']),
        message: json['message'] as String?,
        statusCode: (json['status_code'] as num?)?.toInt() ?? 200,
        success: true,
      );
    } else {
      return ApiResponse._(
        error: json['error'] as String? ?? 'Unknown error',
        message: json['message'] as String?,
        statusCode: (json['status_code'] as num?)?.toInt() ?? 500,
        success: false,
      );
    }
  }

  /// Returns data or throws [ApiResponseException] if error
  T get dataOrThrow {
    if (success && data != null) return data as T;
    throw ApiResponseException(
      error ?? 'Unknown error',
      statusCode: statusCode,
    );
  }

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String error, int statusCode) onError,
  }) {
    if (success && data != null) {
      return onSuccess(data as T);
    } else {
      return onError(error ?? 'Unknown error', statusCode);
    }
  }

  ApiResponse<R> map<R>(R Function(T) transform) {
    if (success && data != null) {
      return ApiResponse.success(
        data: transform(data as T),
        message: message,
        statusCode: statusCode,
      );
    }
    return ApiResponse.error(
      error: error ?? 'Unknown error',
      message: message,
      statusCode: statusCode,
    );
  }
}

class ApiResponseException implements Exception {
  final String message;
  final int statusCode;

  const ApiResponseException(this.message, {this.statusCode = 500});

  @override
  String toString() => 'ApiResponseException($statusCode): $message';
}
