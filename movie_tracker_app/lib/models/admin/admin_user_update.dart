class AdminUserUpdate {
  final String? username;
  final String? email;
  final String? fullName;
  final bool? isAdmin;
  final bool? isActive;

  const AdminUserUpdate({
    this.username,
    this.email,
    this.fullName,
    this.isAdmin,
    this.isActive,
  });

  factory AdminUserUpdate.fromJson(Map<String, dynamic> json) {
    return AdminUserUpdate(
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      isAdmin: json['is_admin'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'full_name': fullName,
    'is_admin': isAdmin,
    'is_active': isActive,
  };
}