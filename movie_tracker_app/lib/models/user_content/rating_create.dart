class RatingCreate {
  final double rating;

  const RatingCreate({required this.rating});

  factory RatingCreate.fromJson(Map<String, dynamic> json) {
    return RatingCreate(rating: (json['rating'] as num).toDouble());
  }

  Map<String, dynamic> toJson() => {'rating': rating};
}