import '../auth/user.dart';
import '../common/media_base.dart';

class ReviewResponse {
  final int id;
  final int mediaId;
  final int userId;
  final String review;
  final bool containsSpoiler;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final User? user;
  final MediaBase? media;

  const ReviewResponse({
    required this.id,
    required this.mediaId,
    required this.userId,
    required this.review,
    required this.containsSpoiler,
    required this.createdAt,
    this.updatedAt,
    this.user,
    this.media,
  });

  String get userName {
    if (user?.fullName != null && user!.fullName!.trim().isNotEmpty) {
      return user!.fullName!;
    }
    if (user?.username != null && user!.username.trim().isNotEmpty) {
      return user!.username;
    }
    return 'کاربر #$userId';
  }

  String get userEmail => user?.email ?? 'بدون ایمیل';
  String get mediaTitle => media?.title ?? 'مدیا #$mediaId';

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      id: json['id'],
      mediaId: json['media_id'],
      userId: json['user_id'],
      review: json['review'],
      containsSpoiler: json['contains_spoiler'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      media: json['media'] != null ? MediaBase.fromJson(json['media']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'media_id': mediaId,
    'user_id': userId,
    'review': review,
    'contains_spoiler': containsSpoiler,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'user': user?.toJson(),
    'media': media?.toJson(),
  };

  ReviewResponse copyWith({
    int? id,
    int? mediaId,
    int? userId,
    String? review,
    bool? containsSpoiler,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    MediaBase? media,
  }) {
    return ReviewResponse(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      userId: userId ?? this.userId,
      review: review ?? this.review,
      containsSpoiler: containsSpoiler ?? this.containsSpoiler,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      media: media ?? this.media,
    );
  }
}