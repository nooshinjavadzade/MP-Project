import 'media_base.dart';

/// Represents a single item in a top/trending media list with ranking metadata
class TopMediaItem {
  final int rank;
  final MediaBase media;
  final double score;
  final int ratingCount;
  final int reviewCount;
  final int watchCount;
  final String? trendDirection;
  final int? weekChange;

  const TopMediaItem({
    required this.rank,
    required this.media,
    required this.score,
    required this.ratingCount,
    required this.reviewCount,
    required this.watchCount,
    this.trendDirection,
    this.weekChange,
  });

  factory TopMediaItem.fromJson(Map<String, dynamic> json) {
    return TopMediaItem(
      rank: json['rank'],
      media: MediaBase.fromJson(json['media']),
      score: (json['score'] as num).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
      reviewCount: json['review_count'] ?? 0,
      watchCount: json['watch_count'] ?? 0,
      trendDirection: json['trend_direction'],
      weekChange: json['week_change'],
    );
  }

  Map<String, dynamic> toJson() => {
    'rank': rank,
    'media': media.toJson(),
    'score': score,
    'rating_count': ratingCount,
    'review_count': reviewCount,
    'watch_count': watchCount,
    'trend_direction': trendDirection,
    'week_change': weekChange,
  };
}