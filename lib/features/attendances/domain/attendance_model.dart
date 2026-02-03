class Attendance {
  const Attendance({
    required this.id,
    this.employeeId,
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.method,
    this.status,
    this.lateMinutes,
    this.note,
    this.employee,
  });

  final String id;
  final String? employeeId;
  final DateTime? attendanceDate;
  final String? checkInTime;
  final String? checkOutTime;
  final String? method;
  final String? status;
  final int? lateMinutes;
  final String? note;
  final AttendanceEmployee? employee;

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: '${json['id'] ?? json['attendance_id'] ?? ''}',
      employeeId: _stringValue(json['employee_id'] ?? json['employeeId']),
      attendanceDate: _parseDate(json['attendance_date'] ?? json['attendanceDate']),
      checkInTime: _stringValue(json['check_in_time'] ?? json['checkInTime']),
      checkOutTime: _stringValue(json['check_out_time'] ?? json['checkOutTime']),
      method: _stringValue(json['method']),
      status: _stringValue(json['status']),
      lateMinutes: _asInt(json['late_minutes'] ?? json['lateMinutes']),
      note: _stringValue(json['note'] ?? json['notes']),
      employee: json['employee'] is Map<String, dynamic>
          ? AttendanceEmployee.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
    );
  }

  Attendance copyWith({
    String? id,
    String? employeeId,
    DateTime? attendanceDate,
    String? checkInTime,
    String? checkOutTime,
    String? method,
    String? status,
    int? lateMinutes,
    String? note,
    AttendanceEmployee? employee,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      method: method ?? this.method,
      status: status ?? this.status,
      lateMinutes: lateMinutes ?? this.lateMinutes,
      note: note ?? this.note,
      employee: employee ?? this.employee,
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

class AttendanceEmployee {
  const AttendanceEmployee({
    required this.id,
    this.user,
  });

  final String id;
  final AttendanceUser? user;

  factory AttendanceEmployee.fromJson(Map<String, dynamic> json) {
    return AttendanceEmployee(
      id: '${json['id'] ?? json['employee_id'] ?? ''}',
      user: json['user'] is Map<String, dynamic>
          ? AttendanceUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AttendanceUser {
  const AttendanceUser({
    required this.id,
    this.name,
  });

  final String id;
  final String? name;

  factory AttendanceUser.fromJson(Map<String, dynamic> json) {
    return AttendanceUser(
      id: '${json['id'] ?? json['user_id'] ?? ''}',
      name: json['name']?.toString(),
    );
  }
}

class AttendanceRequest {
  const AttendanceRequest({
    required this.attendanceType,
    required this.employeeId,
    required this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.note,
    this.faceRecognitionSnapshot,
    this.locationLatitude,
    this.locationLongitude,
  });

  final String attendanceType;
  final String employeeId;
  final DateTime attendanceDate;
  final String? checkInTime;
  final String? checkOutTime;
  final String? note;
  final String? faceRecognitionSnapshot;
  final double? locationLatitude;
  final double? locationLongitude;

  Map<String, dynamic> toPayload() {
    return {
      'attendance_type': attendanceType,
      'employee_id': employeeId,
      'attendance_date': _formatDate(attendanceDate),
      if (checkInTime != null) 'check_in_time': checkInTime,
      if (checkOutTime != null) 'check_out_time': checkOutTime,
      if (note != null) 'note': note,
      if (faceRecognitionSnapshot != null)
        'face_recognition_snapshot': faceRecognitionSnapshot,
      if (locationLatitude != null) 'location_latitude': locationLatitude,
      if (locationLongitude != null) 'location_longitude': locationLongitude,
    };
  }
}

class AttendanceUpdateRequest {
  const AttendanceUpdateRequest({
    this.attendanceType,
    this.employeeId,
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.note,
    this.faceRecognitionSnapshot,
    this.locationLatitude,
    this.locationLongitude,
  });

  final String? attendanceType;
  final String? employeeId;
  final DateTime? attendanceDate;
  final String? checkInTime;
  final String? checkOutTime;
  final String? note;
  final String? faceRecognitionSnapshot;
  final double? locationLatitude;
  final double? locationLongitude;

  Map<String, dynamic> toPayload() {
    return {
      if (attendanceType != null) 'attendance_type': attendanceType,
      if (employeeId != null) 'employee_id': employeeId,
      if (attendanceDate != null) 'attendance_date': _formatDate(attendanceDate!),
      if (checkInTime != null) 'check_in_time': checkInTime,
      if (checkOutTime != null) 'check_out_time': checkOutTime,
      if (note != null) 'note': note,
      if (faceRecognitionSnapshot != null)
        'face_recognition_snapshot': faceRecognitionSnapshot,
      if (locationLatitude != null) 'location_latitude': locationLatitude,
      if (locationLongitude != null) 'location_longitude': locationLongitude,
    };
  }
}

class AttendancePaginationMeta {
  const AttendancePaginationMeta({
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

  factory AttendancePaginationMeta.fromJson(Map<String, dynamic> json) {
    return AttendancePaginationMeta(
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

class AttendancePaginationLinks {
  const AttendancePaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  factory AttendancePaginationLinks.fromJson(Map<String, dynamic> json) {
    return AttendancePaginationLinks(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      prev: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}

class AttendancePage {
  const AttendancePage({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<Attendance> data;
  final AttendancePaginationMeta meta;
  final AttendancePaginationLinks links;

  factory AttendancePage.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    final metaJson = json['meta'];
    final linksJson = json['links'];

    return AttendancePage(
      data: dataList is List
          ? dataList.whereType<Map<String, dynamic>>().map(Attendance.fromJson).toList()
          : const [],
      meta: metaJson is Map<String, dynamic>
          ? AttendancePaginationMeta.fromJson(metaJson)
          : const AttendancePaginationMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 0,
              total: 0,
            ),
      links: linksJson is Map<String, dynamic>
          ? AttendancePaginationLinks.fromJson(linksJson)
          : const AttendancePaginationLinks(),
    );
  }
}

String _formatDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
