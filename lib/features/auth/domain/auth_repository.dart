class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: '${json['id'] ?? json['user_id'] ?? ''}',
      name: '${json['name'] ?? json['full_name'] ?? ''}',
      email: '${json['email'] ?? ''}',
    );
  }
}

abstract class AuthRepository {
  Future<AuthUser?> login({
    required String email,
    required String password,
  });

  Future<AuthUser?> getCurrentUser();

  Future<void> logout();
}
