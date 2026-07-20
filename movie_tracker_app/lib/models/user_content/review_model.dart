class ReviewModel {
  final int id;
  final int mediaId;
  final String review;
  final bool containsSpoiler;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReviewModel({
    required this.id,
    required this.mediaId,
    required this.review,
    this.containsSpoiler = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      mediaId: json['media_id'],
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
    'review': review,
    'contains_spoiler': containsSpoiler,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}