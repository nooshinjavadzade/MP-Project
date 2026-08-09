import 'top_media_item.dart';
import 'pagination.dart';

/// Paginated response for top/trending media lists
class TopMediaListResponse {
  final List<TopMediaItem> items;
  final Pagination pagination;
  final String timeWindow;
  final DateTime generatedAt;

  const TopMediaListResponse({
    required this.items,
    required this.pagination,
    required this.timeWindow,
    required this.generatedAt,
  });

  factory TopMediaListResponse.fromJson(Map<String, dynamic> json) {
    return TopMediaListResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => TopMediaItem.fromJson(item))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination']),
      timeWindow: json['time_window'],
      generatedAt: DateTime.parse(json['generated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
    'pagination': pagination.toJson(),
    'time_window': timeWindow,
    'generated_at': generatedAt.toIso8601String(),
  };
}