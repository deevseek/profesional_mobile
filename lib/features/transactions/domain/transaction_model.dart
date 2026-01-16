class Transaction {
  const Transaction({
    required this.id,
    required this.invoiceNumber,
    this.status,
    this.customerName,
    this.totalAmount,
    this.paidAmount,
    this.paymentMethod,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String invoiceNumber;
  final String? status;
  final String? customerName;
  final double? totalAmount;
  final double? paidAmount;
  final String? paymentMethod;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final customerValue = json['customer'] ?? json['customer_name'] ?? json['customerName'];
    return Transaction(
      id: '${json['id'] ?? json['transaction_id'] ?? json['transactionId'] ?? ''}',
      invoiceNumber:
          _stringValue(json['invoice_number'] ?? json['invoiceNumber'] ?? json['invoice']) ??
              _stringValue(json['number']) ??
              '',
      status: _stringValue(json['status'] ?? json['payment_status'] ?? json['state']),
      customerName: _extractName(customerValue) ?? _stringValue(json['customer_name']),
      totalAmount: _asDouble(
        json['total_amount'] ??
            json['totalAmount'] ??
            json['amount'] ??
            json['grand_total'] ??
            json['total'],
      ),
      paidAmount: _asDouble(json['paid_amount'] ?? json['paidAmount'] ?? json['paid']),
      paymentMethod:
          _stringValue(json['payment_method'] ?? json['paymentMethod'] ?? json['method']),
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

class TransactionPaginationMeta {
  const TransactionPaginationMeta({
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

  factory TransactionPaginationMeta.fromJson(Map<String, dynamic> json) {
    return TransactionPaginationMeta(
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

class TransactionPaginationLinks {
  const TransactionPaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  factory TransactionPaginationLinks.fromJson(Map<String, dynamic> json) {
    return TransactionPaginationLinks(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      prev: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}

class TransactionPage {
  const TransactionPage({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<Transaction> data;
  final TransactionPaginationMeta meta;
  final TransactionPaginationLinks links;

  factory TransactionPage.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    final metaJson = json['meta'];
    final linksJson = json['links'];

    return TransactionPage(
      data: dataList is List
          ? dataList.whereType<Map<String, dynamic>>().map(Transaction.fromJson).toList()
          : const [],
      meta: metaJson is Map<String, dynamic>
          ? TransactionPaginationMeta.fromJson(metaJson)
          : const TransactionPaginationMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 0,
              total: 0,
            ),
      links: linksJson is Map<String, dynamic>
          ? TransactionPaginationLinks.fromJson(linksJson)
          : const TransactionPaginationLinks(),
    );
  }
}
