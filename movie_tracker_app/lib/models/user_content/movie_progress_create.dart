import 'watch_status.dart';

/// Request model for creating/updating movie watch progress
class MovieProgressCreate {
  final WatchStatus status;
  final double progress;

  const MovieProgressCreate({
    required this.status,
    this.progress = 0.0,
  });

  factory MovieProgressCreate.fromJson(Map<String, dynamic> json) {
    return MovieProgressCreate(
      status: WatchStatusExtension.fromString(json['status']),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status.value,
    'progress': progress,
  };

  MovieProgressCreate copyWith({
    WatchStatus? status,
    double? progress,
  }) {
    return MovieProgressCreate(
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }
}