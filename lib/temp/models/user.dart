class UserModel {
  final String id;
  final String email;
  final String username;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
    );
  }
}