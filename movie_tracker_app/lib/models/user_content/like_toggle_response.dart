class LikeToggleResponse {
  final bool liked;

  const LikeToggleResponse({required this.liked});

  factory LikeToggleResponse.fromJson(Map<String, dynamic> json) {
    return LikeToggleResponse(liked: json['liked']);
  }

  Map<String, dynamic> toJson() => {'liked': liked};
}