class Pagination {
  final int page;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const Pagination({
    required this.page,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'],
      perPage: json['per_page'] ?? 20,
      totalItems: json['total_items'],
      totalPages: json['total_pages'],
      hasNextPage: json['has_next_page'],
      hasPreviousPage: json['has_previous_page'],
    );
  }

  Map<String, dynamic> toJson() => {
    'page': page,
    'per_page': perPage,
    'total_items': totalItems,
    'total_pages': totalPages,
    'has_next_page': hasNextPage,
    'has_previous_page': hasPreviousPage,
  };

  Pagination copyWith({
    int? page,
    int? perPage,
    int? totalItems,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) {
    return Pagination(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
    );
  }
}