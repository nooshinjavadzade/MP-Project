import 'watch_status.dart';

/// Request model for updating movie watch progress (matches MovieProgressUpdate from backend)
class ProgressUpdate {
  final int mediaId;
  final WatchStatus? status;
  final double? progress;

  const ProgressUpdate({
    required this.mediaId,
    this.status,
    this.progress,
  });

  factory ProgressUpdate.fromJson(Map<String, dynamic> json) {
    return ProgressUpdate(
      mediaId: json['media_id'],
      status: json['status'] != null
          ? WatchStatusExtension.fromString(json['status'])
          : null,
      progress: (json['progress'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'media_id': mediaId,
    if (status != null) 'status': status!.value,
    if (progress != null) 'progress': progress,
  };

  ProgressUpdate copyWith({
    int? mediaId,
    WatchStatus? status,
    double? progress,
  }) {
    return ProgressUpdate(
      mediaId: mediaId ?? this.mediaId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }
}