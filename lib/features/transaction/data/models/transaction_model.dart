class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.invoice,
    required this.date,
    required this.status,
    required this.total,
    required this.subtotal,
    required this.paymentMethod,
    required this.items,
  });

  final String id;
  final String invoice;
  final DateTime date;
  final String status;
  final int total;
  final int subtotal;
  final String paymentMethod;
  final List<TransactionItemModel> items;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    return TransactionModel(
      id: _asString(json['id'] ?? json['transaction_id'] ?? json['_id']),
      invoice: _asString(json['invoice'] ?? json['invoice_number']),
      date: _asDate(json['date'] ?? json['created_at'] ?? json['transaction_date']),
      status: _asString(json['status']).isEmpty ? 'unknown' : _asString(json['status']),
      total: _asInt(json['total'] ?? json['grand_total']),
      subtotal: _asInt(json['subtotal']),
      paymentMethod: _asString(json['payment_method'] ?? json['paymentMethod']),
      items: itemsRaw is List
          ? itemsRaw
                .whereType<Map<String, dynamic>>()
                .map(TransactionItemModel.fromJson)
                .toList(growable: false)
          : const [],
    );
  }
}

class TransactionItemModel {
  const TransactionItemModel({
    required this.name,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.lineTotal,
  });

  final String name;
  final int quantity;
  final int price;
  final int discount;
  final int lineTotal;

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    final qty = _asInt(json['quantity'] ?? json['qty']);
    final price = _asInt(json['price']);
    final discount = _asInt(json['discount']);
    final product = json['product'] is Map<String, dynamic>
        ? json['product'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return TransactionItemModel(
      name: _asString(json['name'] ?? json['product_name'] ?? product['name']),
      quantity: qty,
      price: price,
      discount: discount,
      lineTotal: _asInt(json['line_total'] ?? json['total'] ?? (qty * price) - discount),
    );
  }
}

String _asString(dynamic value) => value?.toString() ?? '';

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

DateTime _asDate(dynamic value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}
