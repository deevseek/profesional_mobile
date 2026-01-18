class Finance {
  const Finance({
    required this.id,
    this.type,
    this.description,
    this.amount,
    this.reference,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? type;
  final String? description;
  final double? amount;
  final String? reference;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Finance.fromJson(Map<String, dynamic> json) {
    return Finance(
      id: '${json['id'] ?? json['finance_id'] ?? json['financeId'] ?? ''}',
      type: _stringValue(json['type'] ?? json['finance_type'] ?? json['category']),
      description: _stringValue(json['description'] ?? json['notes'] ?? json['detail']),
      amount: _asDouble(json['amount'] ?? json['total'] ?? json['value']),
      reference: _stringValue(json['reference'] ?? json['ref'] ?? json['code']),
      status: _stringValue(json['status'] ?? json['state']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
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

class FinancePaginationMeta {
  const FinancePaginationMeta({
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

  factory FinancePaginationMeta.fromJson(Map<String, dynamic> json) {
    return FinancePaginationMeta(
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

class FinancePaginationLinks {
  const FinancePaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  factory FinancePaginationLinks.fromJson(Map<String, dynamic> json) {
    return FinancePaginationLinks(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      prev: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}

class FinancePage {
  const FinancePage({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<Finance> data;
  final FinancePaginationMeta meta;
  final FinancePaginationLinks links;

  factory FinancePage.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    final metaJson = json['meta'];
    final linksJson = json['links'];

    return FinancePage(
      data: dataList is List
          ? dataList.whereType<Map<String, dynamic>>().map(Finance.fromJson).toList()
          : const [],
      meta: metaJson is Map<String, dynamic>
          ? FinancePaginationMeta.fromJson(metaJson)
          : const FinancePaginationMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 0,
              total: 0,
            ),
      links: linksJson is Map<String, dynamic>
          ? FinancePaginationLinks.fromJson(linksJson)
          : const FinancePaginationLinks(),
    );
  }
}
