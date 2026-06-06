// GENERATED CODE - MANUALLY WRITTEN (flutter unavailable in environment)

part of 'user_model.dart';

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel(
    id: (json['id'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    role: (json['role'] ?? '').toString(),
  );
}

Map<String, dynamic> _$UserModelToJson(_UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role': instance.role,
};
