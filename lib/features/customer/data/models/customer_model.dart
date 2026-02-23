class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.notes,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String notes;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: _asString(json['id'] ?? json['customer_id'] ?? json['_id']),
      name: _asString(json['name'] ?? json['customer_name']),
      phone: _asString(json['phone'] ?? json['phone_number']),
      email: _asString(json['email']),
      address: _asString(json['address']),
      notes: _asString(json['notes'] ?? json['note']),
    );
  }
}

String _asString(dynamic value) => value?.toString() ?? '';
