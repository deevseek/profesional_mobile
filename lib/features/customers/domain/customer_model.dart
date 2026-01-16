class Customer {
  const Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: '${json['id'] ?? json['customer_id'] ?? ''}',
      name: '${json['name'] ?? json['full_name'] ?? ''}',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toPayload({
    bool includeNulls = false,
    bool includeName = true,
  }) {
    final payload = <String, dynamic>{};
    final sanitizedName = _sanitize(name);
    if (includeName && sanitizedName != null) {
      payload['name'] = sanitizedName;
    }

    final sanitizedEmail = _sanitize(email);
    final sanitizedPhone = _sanitize(phone);
    final sanitizedAddress = _sanitize(address);

    if (includeNulls) {
      payload['email'] = sanitizedEmail;
      payload['phone'] = sanitizedPhone;
      payload['address'] = sanitizedAddress;
    } else {
      if (sanitizedEmail != null) {
        payload['email'] = sanitizedEmail;
      }
      if (sanitizedPhone != null) {
        payload['phone'] = sanitizedPhone;
      }
      if (sanitizedAddress != null) {
        payload['address'] = sanitizedAddress;
      }
    }

    return payload;
  }

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
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

  static String? _sanitize(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}

class CustomerPaginationMeta {
  const CustomerPaginationMeta({
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

  factory CustomerPaginationMeta.fromJson(Map<String, dynamic> json) {
    return CustomerPaginationMeta(
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

class CustomerPaginationLinks {
  const CustomerPaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  factory CustomerPaginationLinks.fromJson(Map<String, dynamic> json) {
    return CustomerPaginationLinks(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      prev: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}

class CustomerPage {
  const CustomerPage({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<Customer> data;
  final CustomerPaginationMeta meta;
  final CustomerPaginationLinks links;

  factory CustomerPage.fromJson(Map<String, dynamic> json) {
    final dataSource = json['data'];
    final dataList = _extractList(dataSource) ?? _extractList(json['customers']);
    final metaJson = _extractMeta(json, dataSource);
    final linksJson = _extractLinks(json, dataSource);

    return CustomerPage(
      data: dataList is List
          ? dataList
              .whereType<Map<String, dynamic>>()
              .map(Customer.fromJson)
              .toList()
          : const [],
      meta: metaJson is Map<String, dynamic>
          ? CustomerPaginationMeta.fromJson(metaJson)
          : const CustomerPaginationMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 0,
              total: 0,
            ),
      links: linksJson is Map<String, dynamic>
          ? CustomerPaginationLinks.fromJson(linksJson)
          : const CustomerPaginationLinks(),
    );
  }

  static dynamic _extractList(dynamic source) {
    if (source is List) {
      return source;
    }
    if (source is Map<String, dynamic>) {
      final nested = source['data'] ?? source['customers'];
      if (nested is List) {
        return nested;
      }
    }
    return null;
  }

  static Map<String, dynamic>? _extractMeta(
    Map<String, dynamic> json,
    dynamic dataSource,
  ) {
    final meta = json['meta'];
    if (meta is Map<String, dynamic>) {
      return meta;
    }
    if (dataSource is Map<String, dynamic>) {
      final nestedMeta = dataSource['meta'];
      if (nestedMeta is Map<String, dynamic>) {
        return nestedMeta;
      }
    }
    return null;
  }

  static Map<String, dynamic>? _extractLinks(
    Map<String, dynamic> json,
    dynamic dataSource,
  ) {
    final links = json['links'];
    if (links is Map<String, dynamic>) {
      return links;
    }
    if (dataSource is Map<String, dynamic>) {
      final nestedLinks = dataSource['links'];
      if (nestedLinks is Map<String, dynamic>) {
        return nestedLinks;
      }
    }
    return null;
  }
}
