class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'] as String?,
      error: json['error'] as String?,
    );
  }

  bool get isSuccess => success && error == null;
  bool get isError => !success || error != null;
}

class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      data: (json['data'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

class DocumentSummaryResponse {
  final int totalDocuments;
  final int issuedDocuments;
  final int availableDocuments;
  final int categoriesCount;
  final List<CategorySummary> categories;

  DocumentSummaryResponse({
    required this.totalDocuments,
    required this.issuedDocuments,
    required this.availableDocuments,
    required this.categoriesCount,
    required this.categories,
  });

  factory DocumentSummaryResponse.fromJson(Map<String, dynamic> json) {
    // Support both snake_case (backend) and camelCase field names
    final documents = json['documents'] as List? ?? [];

    return DocumentSummaryResponse(
      totalDocuments: json['total_documents'] as int? ??
                      json['totalDocuments'] as int? ?? 0,
      issuedDocuments: json['issued_count'] as int? ??
                       json['issuedDocuments'] as int? ?? 0,
      availableDocuments: json['pullable_count'] as int? ??
                          json['availableDocuments'] as int? ?? 0,
      categoriesCount: documents.length,
      categories: documents
          .map((e) => CategorySummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CategorySummary {
  final String category;
  final int count;
  final int issuedCount;
  final int availableCount;
  final List<dynamic> documents;

  CategorySummary({
    required this.category,
    required this.count,
    required this.issuedCount,
    required this.availableCount,
    required this.documents,
  });

  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    final docs = json['documents'] as List? ?? [];
    final issuedDocs = docs.where((d) => d['issued'] == true).length;
    final availableDocs = docs.where((d) => d['issued'] != true).length;

    return CategorySummary(
      category: json['category'] as String? ?? '',
      count: docs.length,
      issuedCount: issuedDocs,
      availableCount: availableDocs,
      documents: docs,
    );
  }
}
