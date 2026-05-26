/// Generic paginated response wrapper
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
  bool get isEmpty => data.isEmpty;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['page_size'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson(dynamic Function(T) toJsonT) => {
        'data': data.map(toJsonT).toList(),
        'total': total,
        'page': page,
        'page_size': pageSize,
        'total_pages': totalPages,
      };

  PaginatedResponse<R> map<R>(R Function(T) transform) {
    return PaginatedResponse<R>(
      data: data.map(transform).toList(),
      total: total,
      page: page,
      pageSize: pageSize,
      totalPages: totalPages,
    );
  }

  static PaginatedResponse<T> empty<T>() => PaginatedResponse<T>(
        data: const [],
        total: 0,
        page: 1,
        pageSize: 50,
        totalPages: 0,
      );
}
