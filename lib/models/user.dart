class User {
  User({
    required this.id,
    this.phone,
    this.fullName,
    this.role,
    this.city,
    this.extra = const {},
  });

  final String id;
  final String? phone;
  final String? fullName;
  final String? role;
  final String? city;
  final Map<String, dynamic> extra;

  factory User.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    Map<String, dynamic> p = {};
    if (profile is Map<String, dynamic>) p = profile;

    return User(
      id: (json['id'] ?? json['user_id'] ?? '') as String,
      phone: json['phone'] as String?,
      fullName: (json['full_name'] ?? p['full_name']) as String?,
      role: json['role'] as String?,
      city: (json['city'] ?? p['city']) as String?,
      extra: Map<String, dynamic>.from(json)
        ..removeWhere((k, _) => ['id', 'user_id', 'phone', 'full_name', 'role', 'city', 'profile'].contains(k)),
    );
  }

  User copyWith({
    String? id,
    String? phone,
    String? fullName,
    String? role,
    String? city,
    Map<String, dynamic>? extra,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      city: city ?? this.city,
      extra: extra ?? this.extra,
    );
  }
}
