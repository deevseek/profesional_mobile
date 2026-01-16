class ServiceLog {
  const ServiceLog({
    required this.id,
    this.serviceId,
    this.serviceName,
    this.title,
    this.description,
    this.status,
    this.level,
    this.actor,
    this.createdAt,
  });

  final String id;
  final String? serviceId;
  final String? serviceName;
  final String? title;
  final String? description;
  final String? status;
  final String? level;
  final String? actor;
  final DateTime? createdAt;

  factory ServiceLog.fromJson(Map<String, dynamic> json) {
    final serviceValue = json['service'] ?? json['service_name'] ?? json['serviceTitle'];
    return ServiceLog(
      id: '${json['id'] ?? json['service_log_id'] ?? json['log_id'] ?? ''}',
      serviceId: _stringValue(json['service_id'] ?? json['serviceId']),
      serviceName: _extractName(serviceValue) ?? _stringValue(json['service_name']),
      title: json['title']?.toString() ?? json['action']?.toString() ?? json['event']?.toString(),
      description: json['description']?.toString() ??
          json['message']?.toString() ??
          json['notes']?.toString() ??
          json['details']?.toString(),
      status: json['status']?.toString(),
      level: json['level']?.toString() ?? json['severity']?.toString(),
      actor: _extractName(json['actor'] ?? json['user'] ?? json['performed_by']),
      createdAt: _parseDate(
        json['created_at'] ?? json['createdAt'] ?? json['logged_at'] ?? json['timestamp'],
      ),
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

  static String? _extractName(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map) {
      final name = value['name'] ?? value['title'] ?? value['customer_name'] ?? value['email'];
      return name?.toString();
    }
    return value.toString();
  }
}

class ServiceLogPaginationMeta {
  const ServiceLogPaginationMeta({
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

  factory ServiceLogPaginationMeta.fromJson(Map<String, dynamic> json) {
    return ServiceLogPaginationMeta(
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

class ServiceLogPaginationLinks {
  const ServiceLogPaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  factory ServiceLogPaginationLinks.fromJson(Map<String, dynamic> json) {
    return ServiceLogPaginationLinks(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      prev: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}

class ServiceLogPage {
  const ServiceLogPage({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<ServiceLog> data;
  final ServiceLogPaginationMeta meta;
  final ServiceLogPaginationLinks links;

  factory ServiceLogPage.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    final metaJson = json['meta'];
    final linksJson = json['links'];

    return ServiceLogPage(
      data: dataList is List
          ? dataList.whereType<Map<String, dynamic>>().map(ServiceLog.fromJson).toList()
          : const [],
      meta: metaJson is Map<String, dynamic>
          ? ServiceLogPaginationMeta.fromJson(metaJson)
          : const ServiceLogPaginationMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 0,
              total: 0,
            ),
      links: linksJson is Map<String, dynamic>
          ? ServiceLogPaginationLinks.fromJson(linksJson)
          : const ServiceLogPaginationLinks(),
    );
  }
}
