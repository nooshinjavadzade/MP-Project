import '../common/media_base.dart';
import '../common/pagination.dart';
import '../auth/user.dart';

class AdminReviewResponse {
  final int id;
  final int userId;
  final int mediaId;
  final String review;
  final bool containsSpoiler;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final User? user;
  final MediaBase? media;

  const AdminReviewResponse({
    required this.id,
    required this.userId,
    required this.mediaId,
    required this.review,
    required this.containsSpoiler,
    required this.createdAt,
    this.updatedAt,
    this.user,
    this.media,
  });

  String? get userName => user?.fullName ?? user?.username;
  String? get userEmail => user?.email;
  String? get mediaTitle => media?.title;

  factory AdminReviewResponse.fromJson(Map<String, dynamic> json) {
    return AdminReviewResponse(
      id: json['id'],
      userId: json['user_id'],
      mediaId: json['media_id'],
      review: json['review'],
      containsSpoiler: json['contains_spoiler'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      user: json['user'] is Map<String, dynamic>
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      media: json['media'] is Map<String, dynamic>
          ? MediaBase.fromJson(json['media'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'media_id': mediaId,
    'review': review,
    'contains_spoiler': containsSpoiler,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'user': user?.toJson(),
    'media': media?.toJson(),
  };

  AdminReviewResponse copyWith({
    int? id,
    int? userId,
    int? mediaId,
    String? review,
    bool? containsSpoiler,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    MediaBase? media,
  }) {
    return AdminReviewResponse(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mediaId: mediaId ?? this.mediaId,
      review: review ?? this.review,
      containsSpoiler: containsSpoiler ?? this.containsSpoiler,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      media: media ?? this.media,
    );
  }
}

class AdminReviewListResponse {
  final List<AdminReviewResponse> items;
  final Pagination pagination;

  const AdminReviewListResponse({
    required this.items,
    required this.pagination,
  });

  factory AdminReviewListResponse.fromJson(Map<String, dynamic> json) {
    return AdminReviewListResponse(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => AdminReviewResponse.fromJson(e))
          .toList() ??
          const [],
      pagination: Pagination.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'pagination': pagination.toJson(),
  };

  AdminReviewListResponse copyWith({
    List<AdminReviewResponse>? items,
    Pagination? pagination,
  }) {
    return AdminReviewListResponse(
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
    );
  }
}