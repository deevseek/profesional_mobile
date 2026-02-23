// coverage:ignore-file
// GENERATED CODE - MANUALLY WRITTEN (flutter unavailable in environment)

part of 'user_model.dart';

mixin _$UserModel {
  String get id => throw UnimplementedError();
  String get name => throw UnimplementedError();
  String get email => throw UnimplementedError();
  String get role => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

class _UserModel implements UserModel {
  const _UserModel({this.id = '', this.name = '', this.email = '', this.role = ''});

  @override
  final String id;
  @override
  final String name;
  @override
  final String email;
  @override
  final String role;

  @override
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _UserModel &&
            other.id == id &&
            other.name == name &&
            other.email == email &&
            other.role == role);
  }

  @override
  int get hashCode => Object.hash(id, name, email, role);
}
