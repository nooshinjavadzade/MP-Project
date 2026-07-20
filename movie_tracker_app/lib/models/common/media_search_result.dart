import 'pagination.dart';
import 'media_base.dart';

class MediaSearchResult {
  final List<MediaBase> items;
  final Pagination pagination;

  const MediaSearchResult({
    required this.items,
    required this.pagination,
  });

  factory MediaSearchResult.fromJson(Map<String, dynamic> json) {
    return MediaSearchResult(
      items: (json['results'] as List<dynamic>)
          .map((e) => MediaBase.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() => {
    'results': items.map((e) => e.toJson()).toList(),
    'pagination': pagination.toJson(),
  };
}