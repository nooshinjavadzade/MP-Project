class RatingResponse {
  final int id;
  final int mediaId;
  final int userId;
  final double rating;
  final DateTime ratedAt;
  final DateTime? updatedAt;

  const RatingResponse({
    required this.id,
    required this.mediaId,
    required this.userId,
    required this.rating,
    required this.ratedAt,
    this.updatedAt,
  });

  factory RatingResponse.fromJson(Map<String, dynamic> json) {
    return RatingResponse(
      id: json['id'],
      mediaId: json['media_id'],
      userId: json['user_id'],
      rating: (json['rating'] as num).toDouble(),
      ratedAt: DateTime.parse(json['rated_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'media_id': mediaId,
    'user_id': userId,
    'rating': rating,
    'rated_at': ratedAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  RatingResponse copyWith({
    int? id,
    int? mediaId,
    int? userId,
    double? rating,
    DateTime? ratedAt,
    DateTime? updatedAt,
  }) {
    return RatingResponse(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      ratedAt: ratedAt ?? this.ratedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}