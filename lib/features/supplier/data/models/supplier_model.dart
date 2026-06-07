import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

class SupplierModel {
  const SupplierModel({required this.id, required this.name, required this.phone, required this.email, required this.address});
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  factory SupplierModel.fromJson(Map<String, dynamic> json) => SupplierModel(id: parseString(json['id']), name: parseString(json['name'], fallback: '-'), phone: parseString(json['phone']), email: parseString(json['email']), address: parseString(json['address']));
  Map<String, dynamic> toJson() => {'name': name, 'phone': phone, 'email': email, 'address': address};
}
