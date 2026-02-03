class AttendanceLog {
  const AttendanceLog({
    required this.id,
    this.userId,
    this.type,
    this.confidence,
    this.capturedAt,
    this.ipAddress,
    this.deviceInfo,
    this.createdAt,
  });

  final String id;
  final String? userId;
  final String? type;
  final double? confidence;
  final DateTime? capturedAt;
  final String? ipAddress;
  final String? deviceInfo;
  final DateTime? createdAt;

  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    return AttendanceLog(
      id: '${json['id'] ?? json['attendance_log_id'] ?? ''}',
      userId: _stringValue(json['user_id'] ?? json['userId']),
      type: _stringValue(json['type']),
      confidence: _asDouble(json['confidence']),
      capturedAt: _parseDate(json['captured_at'] ?? json['capturedAt']),
      ipAddress: _stringValue(json['ip_address'] ?? json['ipAddress']),
      deviceInfo: _stringValue(json['device_info'] ?? json['deviceInfo']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
    );
  }

  AttendanceLog copyWith({
    String? id,
    String? userId,
    String? type,
    double? confidence,
    DateTime? capturedAt,
    String? ipAddress,
    String? deviceInfo,
    DateTime? createdAt,
  }) {
    return AttendanceLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      confidence: confidence ?? this.confidence,
      capturedAt: capturedAt ?? this.capturedAt,
      ipAddress: ipAddress ?? this.ipAddress,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      createdAt: createdAt ?? this.createdAt,
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

  static String? _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.toString().trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static double? _asDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }
}

class AttendanceLogRequest {
  const AttendanceLogRequest({
    this.userId,
    this.type,
    this.confidence,
    this.capturedAt,
    this.ipAddress,
    this.deviceInfo,
  });

  final String? userId;
  final String? type;
  final double? confidence;
  final DateTime? capturedAt;
  final String? ipAddress;
  final String? deviceInfo;

  Map<String, dynamic> toPayload() {
    return {
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (confidence != null) 'confidence': confidence,
      if (capturedAt != null) 'captured_at': capturedAt!.toIso8601String(),
      if (ipAddress != null) 'ip_address': ipAddress,
      if (deviceInfo != null) 'device_info': deviceInfo,
    };
  }
}

class AttendanceLogPaginationMeta {
  const AttendanceLogPaginationMeta({
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

  factory AttendanceLogPaginationMeta.fromJson(Map<String, dynamic> json) {
    return AttendanceLogPaginationMeta(
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

class AttendanceLogPaginationLinks {
  const AttendanceLogPaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  factory AttendanceLogPaginationLinks.fromJson(Map<String, dynamic> json) {
    return AttendanceLogPaginationLinks(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      prev: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}

class AttendanceLogPage {
  const AttendanceLogPage({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<AttendanceLog> data;
  final AttendanceLogPaginationMeta meta;
  final AttendanceLogPaginationLinks links;

  factory AttendanceLogPage.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    final metaJson = json['meta'];
    final linksJson = json['links'];

    return AttendanceLogPage(
      data: dataList is List
          ? dataList.whereType<Map<String, dynamic>>().map(AttendanceLog.fromJson).toList()
          : const [],
      meta: metaJson is Map<String, dynamic>
          ? AttendanceLogPaginationMeta.fromJson(metaJson)
          : const AttendanceLogPaginationMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 0,
              total: 0,
            ),
      links: linksJson is Map<String, dynamic>
          ? AttendanceLogPaginationLinks.fromJson(linksJson)
          : const AttendanceLogPaginationLinks(),
    );
  }
}
