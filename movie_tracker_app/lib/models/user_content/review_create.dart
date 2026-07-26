class ReviewCreate {
  final String review;
  final bool containsSpoiler;

  const ReviewCreate({
    required this.review,
    this.containsSpoiler = false,
  });

  factory ReviewCreate.fromJson(Map<String, dynamic> json) {
    return ReviewCreate(
      review: json['review'],
      containsSpoiler: json['contains_spoiler'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'review': review,
    'contains_spoiler': containsSpoiler,
  };
}

class ReviewResponse {
  final int id;
  final int mediaId;
  final int userId;
  final String review;
  final bool containsSpoiler;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReviewResponse({
    required this.id,
    required this.mediaId,
    required this.userId,
    required this.review,
    required this.containsSpoiler,
    required this.createdAt,
    this.updatedAt,
  });

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
  };
}