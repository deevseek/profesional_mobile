class Employee {
  const Employee({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: '${json['id'] ?? json['employee_id'] ?? ''}',
      name: '${json['name'] ?? json['full_name'] ?? ''}',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      isActive: _parseBool(json['is_active'] ?? json['isActive'] ?? json['active']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'is_active': isActive,
    };
  }

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
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

  static bool _parseBool(dynamic value) {
    if (value == null) {
      return false;
    }
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    final normalized = value.toString().toLowerCase().trim();
    if (normalized.isEmpty) {
      return false;
    }
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
}

class EmployeePaginationMeta {
  const EmployeePaginationMeta({
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

  factory EmployeePaginationMeta.fromJson(Map<String, dynamic> json) {
    return EmployeePaginationMeta(
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

class EmployeePaginationLinks {
  const EmployeePaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  factory EmployeePaginationLinks.fromJson(Map<String, dynamic> json) {
    return EmployeePaginationLinks(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      prev: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}

class EmployeePage {
  const EmployeePage({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<Employee> data;
  final EmployeePaginationMeta meta;
  final EmployeePaginationLinks links;

  factory EmployeePage.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    final metaJson = json['meta'];
    final linksJson = json['links'];

    return EmployeePage(
      data: dataList is List
          ? dataList
              .whereType<Map<String, dynamic>>()
              .map(Employee.fromJson)
              .toList()
          : const [],
      meta: metaJson is Map<String, dynamic>
          ? EmployeePaginationMeta.fromJson(metaJson)
          : const EmployeePaginationMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 0,
              total: 0,
            ),
      links: linksJson is Map<String, dynamic>
          ? EmployeePaginationLinks.fromJson(linksJson)
          : const EmployeePaginationLinks(),
    );
  }
}
