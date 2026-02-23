// GENERATED CODE - MANUALLY WRITTEN (flutter unavailable in environment)

part of 'login_response.dart';

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) {
  return _LoginResponse(
    token: json['token'] as String? ?? '',
    user: UserModel.fromJson((json['user'] as Map?)?.cast<String, dynamic>() ?? {}),
  );
}

Map<String, dynamic> _$LoginResponseToJson(_LoginResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'user': instance.user.toJson(),
    };
