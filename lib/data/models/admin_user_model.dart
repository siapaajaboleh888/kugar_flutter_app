class AdminUser {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final DateTime? createdAt;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'user',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  AdminUser copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    DateTime? createdAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
