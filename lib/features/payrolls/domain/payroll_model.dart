class Payroll {
  const Payroll({
    required this.id,
    this.employeeName,
    this.period,
    this.reference,
    this.status,
    this.grossAmount,
    this.netAmount,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? employeeName;
  final String? period;
  final String? reference;
  final String? status;
  final double? grossAmount;
  final double? netAmount;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Payroll.fromJson(Map<String, dynamic> json) {
    final employeeValue = json['employee'] ?? json['employee_name'] ?? json['employeeName'];
    return Payroll(
      id: '${json['id'] ?? json['payroll_id'] ?? json['payrollId'] ?? ''}',
      employeeName: _extractName(employeeValue) ?? _stringValue(json['employee_name']),
      period: _stringValue(
        json['period'] ??
            json['pay_period'] ??
            json['payPeriod'] ??
            json['month'] ??
            json['salary_period'],
      ),
      reference: _stringValue(json['reference'] ?? json['ref'] ?? json['code']),
      status: _stringValue(json['status'] ?? json['state'] ?? json['payment_status']),
      grossAmount: _asDouble(
        json['gross_amount'] ??
            json['grossAmount'] ??
            json['total'] ??
            json['amount'] ??
            json['gross'],
      ),
      netAmount: _asDouble(
        json['net_amount'] ??
            json['netAmount'] ??
            json['net'] ??
            json['paid_amount'] ??
            json['paidAmount'],
      ),
      notes: _stringValue(json['notes'] ?? json['description'] ?? json['remarks']),
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

  static String? _extractName(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map) {
      final name = value['name'] ?? value['full_name'] ?? value['email'];
      return name?.toString();
    }
    return value.toString();
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

class PayrollPaginationMeta {
  const PayrollPaginationMeta({
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

  factory PayrollPaginationMeta.fromJson(Map<String, dynamic> json) {
    return PayrollPaginationMeta(
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

class PayrollPaginationLinks {
  const PayrollPaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  factory PayrollPaginationLinks.fromJson(Map<String, dynamic> json) {
    return PayrollPaginationLinks(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      prev: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}

class PayrollPage {
  const PayrollPage({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<Payroll> data;
  final PayrollPaginationMeta meta;
  final PayrollPaginationLinks links;

  factory PayrollPage.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    final metaJson = json['meta'];
    final linksJson = json['links'];

    return PayrollPage(
      data: dataList is List
          ? dataList.whereType<Map<String, dynamic>>().map(Payroll.fromJson).toList()
          : const [],
      meta: metaJson is Map<String, dynamic>
          ? PayrollPaginationMeta.fromJson(metaJson)
          : const PayrollPaginationMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 0,
              total: 0,
            ),
      links: linksJson is Map<String, dynamic>
          ? PayrollPaginationLinks.fromJson(linksJson)
          : const PayrollPaginationLinks(),
    );
  }
}
