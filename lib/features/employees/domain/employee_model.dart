class Employee {
  const Employee({
    required this.id,
    required this.name,
    this.position,
    this.email,
    this.phone,
    this.address,
    this.joinDate,
    this.baseSalary,
    this.isActive = true,
    this.faceRecognitionSignature,
    this.faceRecognitionRegisteredAt,
    this.faceRecognitionScanPath,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? position;
  final String? email;
  final String? phone;
  final String? address;
  final DateTime? joinDate;
  final double? baseSalary;
  final bool isActive;
  final String? faceRecognitionSignature;
  final DateTime? faceRecognitionRegisteredAt;
  final String? faceRecognitionScanPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: '${json['id'] ?? json['employee_id'] ?? ''}',
      name: '${json['name'] ?? json['full_name'] ?? ''}',
      position: json['position']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      joinDate: _parseDate(json['join_date'] ?? json['joinDate']),
      baseSalary: _parseDouble(json['base_salary'] ?? json['baseSalary']),
      isActive: _parseBool(json['is_active'] ?? json['isActive'] ?? json['active']),
      faceRecognitionSignature: json['face_recognition_signature']?.toString(),
      faceRecognitionRegisteredAt:
          _parseDate(json['face_recognition_registered_at'] ?? json['faceRecognitionRegisteredAt']),
      faceRecognitionScanPath: json['face_recognition_scan_path']?.toString(),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'name': name,
      if (position != null) 'position': position,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (joinDate != null) 'join_date': joinDate!.toIso8601String(),
      if (baseSalary != null) 'base_salary': baseSalary,
      'is_active': isActive,
      if (faceRecognitionSignature != null)
        'face_recognition_signature': faceRecognitionSignature,
      if (faceRecognitionRegisteredAt != null)
        'face_recognition_registered_at': faceRecognitionRegisteredAt!.toIso8601String(),
      if (faceRecognitionScanPath != null)
        'face_recognition_scan_path': faceRecognitionScanPath,
    };
  }

  Employee copyWith({
    String? id,
    String? name,
    String? position,
    String? email,
    String? phone,
    String? address,
    DateTime? joinDate,
    double? baseSalary,
    bool? isActive,
    String? faceRecognitionSignature,
    DateTime? faceRecognitionRegisteredAt,
    String? faceRecognitionScanPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      joinDate: joinDate ?? this.joinDate,
      baseSalary: baseSalary ?? this.baseSalary,
      isActive: isActive ?? this.isActive,
      faceRecognitionSignature: faceRecognitionSignature ?? this.faceRecognitionSignature,
      faceRecognitionRegisteredAt:
          faceRecognitionRegisteredAt ?? this.faceRecognitionRegisteredAt,
      faceRecognitionScanPath: faceRecognitionScanPath ?? this.faceRecognitionScanPath,
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

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
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
