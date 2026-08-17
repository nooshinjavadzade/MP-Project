import '../common/media_base.dart';

class PersonalListCreate {
  final String name;
  final String? description;

  const PersonalListCreate({
    required this.name,
    this.description,
  });

  factory PersonalListCreate.fromJson(Map<String, dynamic> json) {
    return PersonalListCreate(
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
  };
}

class PersonalListUpdate {
  final String? name;
  final String? description;

  const PersonalListUpdate({
    this.name,
    this.description,
  });

  factory PersonalListUpdate.fromJson(Map<String, dynamic> json) {
    return PersonalListUpdate(
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
  };

  PersonalListUpdate copyWith({
    String? name,
    String? description,
  }) {
    return PersonalListUpdate(
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}

class PersonalListItemAdd {
  final int mediaId;

  const PersonalListItemAdd({required this.mediaId});

  factory PersonalListItemAdd.fromJson(Map<String, dynamic> json) {
    return PersonalListItemAdd(mediaId: json['media_id']);
  }

  Map<String, dynamic> toJson() => {'media_id': mediaId};

  PersonalListItemAdd copyWith({
    int? mediaId,
  }) {
    return PersonalListItemAdd(mediaId: mediaId ?? this.mediaId);
  }
}

class PersonalListResponse {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PersonalListResponse({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.isDefault,
    required this.createdAt,
    this.updatedAt,
  });

  factory PersonalListResponse.fromJson(Map<String, dynamic> json) {
    return PersonalListResponse(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      isDefault: json['is_default'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'description': description,
    'is_default': isDefault,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  PersonalListResponse copyWith({
    int? id,
    int? userId,
    String? name,
    String? description,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonalListResponse(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PersonalListItemResponse {
  final int id;
  final int listId;
  final int mediaId;
  final MediaBase media;
  final DateTime addedAt;

  const PersonalListItemResponse({
    required this.id,
    required this.listId,
    required this.mediaId,
    required this.media,
    required this.addedAt,
  });

  factory PersonalListItemResponse.fromJson(Map<String, dynamic> json) {
    return PersonalListItemResponse(
      id: json['id'],
      listId: json['list_id'],
      mediaId: json['media_id'],
      media: MediaBase.fromJson(json['media']),
      addedAt: DateTime.parse(json['added_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'list_id': listId,
    'media_id': mediaId,
    'media': media.toJson(),
    'added_at': addedAt.toIso8601String(),
  };

  PersonalListItemResponse copyWith({
    int? id,
    int? listId,
    int? mediaId,
    MediaBase? media,
    DateTime? addedAt,
  }) {
    return PersonalListItemResponse(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      mediaId: mediaId ?? this.mediaId,
      media: media ?? this.media,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

class PersonalListWithItems extends PersonalListResponse {
  final List<PersonalListItemResponse> items;
  final int itemCount;

  const PersonalListWithItems({
    required super.id,
    required super.userId,
    required super.name,
    super.description,
    required super.isDefault,
    required super.createdAt,
    super.updatedAt,
    this.items = const [],
    this.itemCount = 0,
  });

  factory PersonalListWithItems.fromJson(Map<String, dynamic> json) {
    return PersonalListWithItems(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      isDefault: json['is_default'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PersonalListItemResponse.fromJson(e))
              .toList() ??
          const [],
      itemCount: json['item_count'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'items': items.map((e) => e.toJson()).toList(),
    'item_count': itemCount,
  };

  PersonalListWithItems copyWith({
    int? id,
    int? userId,
    String? name,
    String? description,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PersonalListItemResponse>? items,
    int? itemCount,
  }) {
    return PersonalListWithItems(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}