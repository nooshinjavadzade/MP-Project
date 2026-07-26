import 'media_base.dart';
import 'pagination.dart';

class MediaSearchResult {
  final List<MediaBase> items;
  final Pagination pagination;

  const MediaSearchResult({required this.items, required this.pagination});

  factory MediaSearchResult.fromJson(Map<String, dynamic> json) {
    return MediaSearchResult(
      items: (json['items'] as List<dynamic>)
          .map((e) => MediaBase.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'pagination': pagination.toJson(),
  };
}