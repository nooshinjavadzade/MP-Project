class LikeToggleResponse {
  final bool liked;

  const LikeToggleResponse({required this.liked});

  factory LikeToggleResponse.fromJson(Map<String, dynamic> json) {
    return LikeToggleResponse(liked: json['liked']);
  }

  Map<String, dynamic> toJson() => {'liked': liked};

  LikeToggleResponse copyWith({
    bool? liked,
  }) {
    return LikeToggleResponse(liked: liked ?? this.liked);
  }
}