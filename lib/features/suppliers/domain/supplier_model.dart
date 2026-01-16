class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: '${json['id'] ?? json['supplier_id'] ?? ''}',
      name: '${json['name'] ?? json['company_name'] ?? ''}',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      postalCode: json['postal_code']?.toString() ?? json['zip']?.toString(),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (postalCode != null) 'postal_code': postalCode,
    };
  }

  Supplier copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    final parsed = DateTime.tryParse(value.toString());
    return parsed?.toLocal();
  }
}

class SupplierPaginationMeta {
  const SupplierPaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  factory SupplierPaginationMeta.fromJson(Map<String, dynamic> json) {
    return SupplierPaginationMeta(
      currentPage: _asInt(json['current_page']) ?? 1,
      lastPage: _asInt(json['last_page']) ?? 1,
      perPage: _asInt(json['per_page']) ?? _asInt(json['perPage']) ?? 0,
      total: _asInt(json['total']) ?? 0,
      from: _asInt(json['from']),
      to: _asInt(json['to']),
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }
}

class SupplierPaginationLinks {
  const SupplierPaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  factory SupplierPaginationLinks.fromJson(Map<String, dynamic> json) {
    return SupplierPaginationLinks(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      prev: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}

class SupplierPage {
  const SupplierPage({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<Supplier> data;
  final SupplierPaginationMeta meta;
  final SupplierPaginationLinks links;

  factory SupplierPage.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    final metaJson = json['meta'];
    final linksJson = json['links'];

    return SupplierPage(
      data: dataList is List
          ? dataList
              .whereType<Map<String, dynamic>>()
              .map(Supplier.fromJson)
              .toList()
          : const [],
      meta: metaJson is Map<String, dynamic>
          ? SupplierPaginationMeta.fromJson(metaJson)
          : const SupplierPaginationMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 0,
              total: 0,
            ),
      links: linksJson is Map<String, dynamic>
          ? SupplierPaginationLinks.fromJson(linksJson)
          : const SupplierPaginationLinks(),
    );
  }
}
