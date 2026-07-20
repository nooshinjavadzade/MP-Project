class UserRating {
  final int mediaId;
  final double rating;
  final DateTime ratedAt;

  const UserRating({
    required this.mediaId,
    required this.rating,
    required this.ratedAt,
  });

  factory UserRating.fromJson(Map<String, dynamic> json) {
    return UserRating(
      mediaId: json['media_id'],
      rating: (json['rating'] as num).toDouble(),
      ratedAt: DateTime.parse(json['rated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'media_id': mediaId,
    'rating': rating,
    'rated_at': ratedAt.toIso8601String(),
  };
}