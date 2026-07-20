import 'episode_model.dart';

class SeasonModel {
  final int seasonNumber;
  final String? title;
  final List<EpisodeModel> episodes;

  const SeasonModel({
    required this.seasonNumber,
    this.title,
    this.episodes = const [],
  });

  factory SeasonModel.fromJson(Map<String, dynamic> json) {
    return SeasonModel(
      seasonNumber: json['season_number'],
      title: json['title'],
      episodes: (json['episodes'] as List<dynamic>?)
          ?.map((e) => EpisodeModel.fromJson(e))
          .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'season_number': seasonNumber,
    'title': title,
    'episodes': episodes.map((e) => e.toJson()).toList(),
  };

  SeasonModel copyWith({
    int? seasonNumber,
    String? title,
    List<EpisodeModel>? episodes,
  }) {
    return SeasonModel(
      seasonNumber: seasonNumber ?? this.seasonNumber,
      title: title ?? this.title,
      episodes: episodes ?? this.episodes,
    );
  }
}