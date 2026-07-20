class PersonalListModel {
  final int id;
  final String name;
  final String? description;
  final List<int> mediaIds;
  final DateTime createdAt;

  const PersonalListModel({
    required this.id,
    required this.name,
    this.description,
    this.mediaIds = const [],
    required this.createdAt,
  });

  factory PersonalListModel.fromJson(Map<String, dynamic> json) {
    return PersonalListModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      mediaIds: List<int>.from(json['media_ids'] ?? const []),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'media_ids': mediaIds,
    'created_at': createdAt.toIso8601String(),
  };
}