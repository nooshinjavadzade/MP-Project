class ReviewUpdate {
  final String? review;
  final bool? containsSpoiler;

  const ReviewUpdate({
    this.review,
    this.containsSpoiler,
  });

  factory ReviewUpdate.fromJson(Map<String, dynamic> json) {
    return ReviewUpdate(
      review: json['review'],
      containsSpoiler: json['contains_spoiler'],
    );
  }

  Map<String, dynamic> toJson() => {
    'review': review,
    'contains_spoiler': containsSpoiler,
  };
}