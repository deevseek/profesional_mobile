// GENERATED CODE - MANUALLY WRITTEN (flutter unavailable in environment)

part of 'login_request.dart';

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) {
  return _LoginRequest(
    email: json['email'] as String? ?? '',
    password: json['password'] as String? ?? '',
  );
}

Map<String, dynamic> _$LoginRequestToJson(_LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };
