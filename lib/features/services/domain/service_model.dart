class Service {
  const Service({
    required this.id,
    required this.customerName,
    this.status,
    this.title,
    this.description,
    this.scheduledAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String customerName;
  final String? status;
  final String? title;
  final String? description;
  final DateTime? scheduledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: '${json['id'] ?? json['service_id'] ?? ''}',
      customerName: '${json['customer_name'] ?? json['customerName'] ?? json['customer'] ?? ''}',
      status: json['status']?.toString(),
      title: json['title']?.toString() ?? json['service_title']?.toString(),
      description: json['description']?.toString() ?? json['notes']?.toString(),
      scheduledAt: _parseDate(json['scheduled_at'] ?? json['scheduledAt']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'customer_name': customerName,
      if (status != null) 'status': status,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (scheduledAt != null) 'scheduled_at': scheduledAt!.toIso8601String(),
    };
  }

  Service copyWith({
    String? id,
    String? customerName,
    String? status,
    String? title,
    String? description,
    DateTime? scheduledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
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

class ServicePaginationMeta {
  const ServicePaginationMeta({
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

  factory ServicePaginationMeta.fromJson(Map<String, dynamic> json) {
    return ServicePaginationMeta(
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

class ServicePaginationLinks {
  const ServicePaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  factory ServicePaginationLinks.fromJson(Map<String, dynamic> json) {
    return ServicePaginationLinks(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      prev: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}

class ServicePage {
  const ServicePage({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<Service> data;
  final ServicePaginationMeta meta;
  final ServicePaginationLinks links;

  factory ServicePage.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    final metaJson = json['meta'];
    final linksJson = json['links'];

    return ServicePage(
      data: dataList is List
          ? dataList.whereType<Map<String, dynamic>>().map(Service.fromJson).toList()
          : const [],
      meta: metaJson is Map<String, dynamic>
          ? ServicePaginationMeta.fromJson(metaJson)
          : const ServicePaginationMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 0,
              total: 0,
            ),
      links: linksJson is Map<String, dynamic>
          ? ServicePaginationLinks.fromJson(linksJson)
          : const ServicePaginationLinks(),
    );
  }
}
