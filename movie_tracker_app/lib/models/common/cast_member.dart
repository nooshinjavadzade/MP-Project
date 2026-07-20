class CastMember {
  final String id;
  final String name;
  final String role;
  final String? profileImageUrl;

  const CastMember({
    required this.id,
    required this.name,
    required this.role,
    this.profileImageUrl,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'].toString(),
      name: json['name'],
      role: json['role'],
      profileImageUrl: json['profile_image_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'profile_image_url': profileImageUrl,
  };

  CastMember copyWith({
    String? id,
    String? name,
    String? role,
    String? profileImageUrl,
  }) {
    return CastMember(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}