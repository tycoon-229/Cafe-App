class AuthModel {
  final String id;
  final String? username;
  final String email;
  final String? avatarUrl;
  final DateTime? createdAt;

  // new fields
  final String? phone;
  final String? cafeName;
  final String? address;
  final String? description;

  final String role;
  final bool isActive;

  AuthModel({
    required this.id,
    this.username,
    required this.email,
    this.avatarUrl,
    this.createdAt,

    this.phone,
    this.cafeName,
    this.address,
    this.description,

    this.role = 'user',
    this.isActive = true,
  });

  factory AuthModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AuthModel(
      id: json['id'] ?? '',
      username: json['username'],
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'],

      createdAt:
      json['created_at'] != null
          ? DateTime.tryParse(
        json['created_at'],
      )
          : null,

      phone: json['phone'],
      cafeName:
      json['cafe_name'],
      address:
      json['address'],
      description:
      json['description'],

      role:
      json['role'] ??
          'user',

      isActive:
      json['is_active'] ??
          true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url':
      avatarUrl,
      'created_at':
      createdAt
          ?.toIso8601String(),

      'phone': phone,
      'cafe_name':
      cafeName,
      'address':
      address,
      'description':
      description,

      'role': role,
      'is_active':
      isActive,
    };
  }

  AuthModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,

    String? phone,
    String? cafeName,
    String? address,
    String? description,

    String? role,
    bool? isActive,
  }) {
    return AuthModel(
      id: id ?? this.id,
      username:
      username ??
          this.username,
      email:
      email ?? this.email,
      avatarUrl:
      avatarUrl ??
          this.avatarUrl,
      createdAt:
      createdAt ??
          this.createdAt,

      phone:
      phone ??
          this.phone,

      cafeName:
      cafeName ??
          this.cafeName,

      address:
      address ??
          this.address,

      description:
      description ??
          this.description,

      role:
      role ??
          this.role,

      isActive:
      isActive ??
          this.isActive,
    );
  }

  bool get hasProfile {
    return username != null &&
        username!
            .trim()
            .isNotEmpty;
  }

  bool get isAdmin =>
      role == 'admin';

  bool get isUser =>
      role == 'user';

  @override
  String toString() {
    return '''
AuthModel(
  id: $id,
  username: $username,
  email: $email,
  avatarUrl: $avatarUrl,
  phone: $phone,
  cafeName: $cafeName,
  address: $address,
  description: $description,
  role: $role,
  isActive: $isActive,
  createdAt: $createdAt
)
''';
  }
}