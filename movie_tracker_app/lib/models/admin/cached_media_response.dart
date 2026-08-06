import '../common/pagination.dart';

class CachedMediaResponse {
  final int id;
  final String tmdbId;
  final String mediaType;
  final String title;
  final String? posterUrl;
  final DateTime lastFetchedAt;

  const CachedMediaResponse({
    required this.id,
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    this.posterUrl,
    required this.lastFetchedAt,
  });

  factory CachedMediaResponse.fromJson(Map<String, dynamic> json) {
    return CachedMediaResponse(
      id: json['id'],
      tmdbId: json['tmdb_id'],
      mediaType: json['media_type'],
      title: json['title'],
      posterUrl: json['poster_url'],
      lastFetchedAt: DateTime.parse(json['last_fetched_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tmdb_id': tmdbId,
    'media_type': mediaType,
    'title': title,
    'poster_url': posterUrl,
    'last_fetched_at': lastFetchedAt.toIso8601String(),
  };
}

class CachedMediaListResponse {
  final List<CachedMediaResponse> items;
  final Pagination pagination;

  const CachedMediaListResponse({
    required this.items,
    required this.pagination,
  });

  factory CachedMediaListResponse.fromJson(Map<String, dynamic> json) {
    return CachedMediaListResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CachedMediaResponse.fromJson(e))
              .toList() ??
          const [],
      pagination: Pagination.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'pagination': pagination.toJson(),
  };
}