// coverage:ignore-file
// GENERATED CODE - MANUALLY WRITTEN (flutter unavailable in environment)

part of 'login_response.dart';

mixin _$LoginResponse {
  String get token => throw UnimplementedError();
  UserModel get user => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

class _LoginResponse implements LoginResponse {
  const _LoginResponse({required this.token, required this.user});

  @override
  final String token;
  @override
  final UserModel user;

  @override
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _LoginResponse && other.token == token && other.user == user);
  }

  @override
  int get hashCode => Object.hash(token, user);
}
