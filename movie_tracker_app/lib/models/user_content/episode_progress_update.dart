import 'watch_status.dart';

/// Request model for updating episode watch progress
class EpisodeProgressUpdate {
  final WatchStatus? status;

  const EpisodeProgressUpdate({
    this.status,
  });

  factory EpisodeProgressUpdate.fromJson(Map<String, dynamic> json) {
    return EpisodeProgressUpdate(
      status: json['status'] != null
          ? WatchStatusExtension.fromString(json['status'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (status != null) 'status': status!.value,
  };

  EpisodeProgressUpdate copyWith({
    WatchStatus? status,
  }) {
    return EpisodeProgressUpdate(status: status ?? this.status);
  }
}