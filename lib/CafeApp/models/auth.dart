class Auth {
  final String id;
  final String? username;
  final String email;
  final String? avatarUrl;
  final DateTime? createdAt;

  final String? phone;

  final String role;
  final bool isActive;

  /// pending / approved / rejected
  final String accountStatus;

  Auth({
    required this.id,
    this.username,
    required this.email,
    this.avatarUrl,
    this.createdAt,
    this.phone,
    this.role = 'user',
    this.isActive = true,
    this.accountStatus = 'pending',
  });

  factory Auth.fromJson(
      Map<String, dynamic> json,
      ) {
    return Auth(
      id: json['id'] ?? '',

      username:
      json['username'],

      email:
      json['email'] ?? '',

      avatarUrl:
      json['avatar_url'],

      createdAt:
      json['created_at'] !=
          null
          ? DateTime.tryParse(
        json[
        'created_at'],
      )
          : null,

      phone:
      json['phone'],

      role:
      json['role'] ??
          'user',

      isActive:
      json['is_active'] ??
          true,

      accountStatus:
      json[
      'account_status'] ??
          'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username':
      username,
      'email': email,
      'avatar_url':
      avatarUrl,

      'created_at':
      createdAt
          ?.toIso8601String(),

      'phone': phone,

      'role': role,

      'is_active':
      isActive,

      'account_status':
      accountStatus,
    };
  }

  Auth copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    String? phone,
    String? role,
    bool? isActive,
    String? accountStatus,
  }) {
    return Auth(
      id: id ?? this.id,

      username:
      username ??
          this.username,

      email:
      email ??
          this.email,

      avatarUrl:
      avatarUrl ??
          this.avatarUrl,

      createdAt:
      createdAt ??
          this.createdAt,

      phone:
      phone ??
          this.phone,

      role:
      role ??
          this.role,

      isActive:
      isActive ??
          this.isActive,

      accountStatus:
      accountStatus ??
          this.accountStatus,
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

  bool get isApproved =>
      accountStatus ==
          'approved';

  bool get isPending =>
      accountStatus ==
          'pending';

  bool get isRejected =>
      accountStatus ==
          'rejected';

  @override
  String toString() {
    return '''
Auth(
  id: $id,
  username: $username,
  email: $email,
  avatarUrl: $avatarUrl,
  phone: $phone,
  role: $role,
  isActive: $isActive,
  accountStatus: $accountStatus,
  createdAt: $createdAt
)
''';
  }
}