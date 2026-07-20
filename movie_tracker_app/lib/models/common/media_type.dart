enum MediaType {
  movie,
  series,
}

extension MediaTypeExtension on MediaType {
  String get value {
    switch (this) {
      case MediaType.movie:
        return 'movie';
      case MediaType.series:
        return 'series';
    }
  }

  static MediaType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'movie':
        return MediaType.movie;
      case 'series':
        return MediaType.series;
      default:
        throw ArgumentError('Unknown media type: $value');
    }
  }
}