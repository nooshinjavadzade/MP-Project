import 'media_type.dart';

/// Query parameters for fetching top/trending media lists
class TopMediaQuery {
  final MediaType? mediaType;
  final String? genre;
  final String? timeWindow;
  final int page;
  final int perPage;

  const TopMediaQuery({
    this.mediaType,
    this.genre,
    this.timeWindow,
    this.page = 1,
    this.perPage = 20,
  });

  factory TopMediaQuery.fromJson(Map<String, dynamic> json) {
    return TopMediaQuery(
      mediaType: json['media_type'] != null
          ? MediaTypeExtension.fromString(json['media_type'])
          : null,
      genre: json['genre'],
      timeWindow: json['time_window'],
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 20,
    );
  }

  Map<String, dynamic> toJson() => {
    if (mediaType != null) 'media_type': mediaType!.value,
    if (genre != null) 'genre': genre,
    if (timeWindow != null) 'time_window': timeWindow,
    'page': page,
    'per_page': perPage,
  };

  /// Convert to query parameters for HTTP requests
  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (mediaType != null) params['media_type'] = mediaType!.value;
    if (genre != null) params['genre'] = genre!;
    if (timeWindow != null) params['time_window'] = timeWindow!;
    return params;
  }

  TopMediaQuery copyWith({
    MediaType? mediaType,
    String? genre,
    String? timeWindow,
    int? page,
    int? perPage,
  }) {
    return TopMediaQuery(
      mediaType: mediaType ?? this.mediaType,
      genre: genre ?? this.genre,
      timeWindow: timeWindow ?? this.timeWindow,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }
}