// coverage:ignore-file
// GENERATED CODE - MANUALLY WRITTEN (flutter unavailable in environment)

part of 'login_request.dart';

mixin _$LoginRequest {
  String get email => throw UnimplementedError();
  String get password => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

class _LoginRequest implements LoginRequest {
  const _LoginRequest({required this.email, required this.password});

  @override
  final String email;
  @override
  final String password;

  @override
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _LoginRequest &&
            other.email == email &&
            other.password == password);
  }

  @override
  int get hashCode => Object.hash(email, password);
}
