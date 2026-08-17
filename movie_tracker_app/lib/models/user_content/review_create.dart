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

  ReviewCreate copyWith({
    String? review,
    bool? containsSpoiler,
  }) {
    return ReviewCreate(
      review: review ?? this.review,
      containsSpoiler: containsSpoiler ?? this.containsSpoiler,
    );
  }
}