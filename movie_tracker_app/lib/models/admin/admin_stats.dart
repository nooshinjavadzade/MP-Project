class AdminStats {
  final int totalUsers;
  final int totalMedia;
  final int totalReviews;
  final int totalRatings;
  final int totalReports;
  final int totalLists;
  final int cachedMediaCount;

  const AdminStats({
    required this.totalUsers,
    required this.totalMedia,
    required this.totalReviews,
    required this.totalRatings,
    required this.totalReports,
    required this.totalLists,
    required this.cachedMediaCount,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['total_users'] ?? 0,
      totalMedia: json['total_media'] ?? 0,
      totalReviews: json['total_reviews'] ?? 0,
      totalRatings: json['total_ratings'] ?? 0,
      totalReports: json['total_reports'] ?? 0,
      totalLists: json['total_lists'] ?? 0,
      cachedMediaCount: json['cached_media_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_users': totalUsers,
    'total_media': totalMedia,
    'total_reviews': totalReviews,
    'total_ratings': totalRatings,
    'total_reports': totalReports,
    'total_lists': totalLists,
    'cached_media_count': cachedMediaCount,
  };

  AdminStats copyWith({
    int? totalUsers,
    int? totalMedia,
    int? totalReviews,
    int? totalRatings,
    int? totalReports,
    int? totalLists,
    int? cachedMediaCount,
  }) {
    return AdminStats(
      totalUsers: totalUsers ?? this.totalUsers,
      totalMedia: totalMedia ?? this.totalMedia,
      totalReviews: totalReviews ?? this.totalReviews,
      totalRatings: totalRatings ?? this.totalRatings,
      totalReports: totalReports ?? this.totalReports,
      totalLists: totalLists ?? this.totalLists,
      cachedMediaCount: cachedMediaCount ?? this.cachedMediaCount,
    );
  }
}

class AdminActionResponse {
  final bool success;
  final String message;

  const AdminActionResponse({
    required this.success,
    required this.message,
  });

  factory AdminActionResponse.fromJson(Map<String, dynamic> json) {
    return AdminActionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
  };
}