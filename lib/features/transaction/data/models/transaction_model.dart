class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.invoice,
    required this.customerName,
    required this.date,
    required this.status,
    required this.total,
    required this.subtotal,
    required this.paymentMethod,
    required this.items,
  });

  final String id;
  final String invoice;
  final String customerName;
  final DateTime date;
  final String status;
  final int total;
  final int subtotal;
  final String paymentMethod;
  final List<TransactionItemModel> items;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final customer = json['customer'] is Map<String, dynamic>
        ? json['customer'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final parsedItems = itemsRaw is List
        ? itemsRaw
              .whereType<Map<String, dynamic>>()
              .map(TransactionItemModel.fromJson)
              .toList(growable: false)
        : const <TransactionItemModel>[];
    final subtotal = _asInt(json['subtotal'] ?? json['sub_total']);
    final total = _asInt(json['total'] ?? json['grand_total']);

    return TransactionModel(
      id: _asString(json['id'] ?? json['transaction_id'] ?? json['_id']),
      invoice: _asString(json['invoice'] ?? json['invoice_number']),
      customerName: _asString(
        json['customer_name'] ?? json['customerName'] ?? customer['name'] ?? customer['full_name'],
      ),
      date: _asDate(json['date'] ?? json['created_at'] ?? json['transaction_date']),
      status: _asString(json['status']).isEmpty ? 'unknown' : _asString(json['status']),
      total: total > 0 ? total : parsedItems.fold<int>(0, (sum, item) => sum + item.lineTotal),
      subtotal: subtotal > 0 ? subtotal : parsedItems.fold<int>(0, (sum, item) => sum + (item.quantity * item.price)),
      paymentMethod: _asString(json['payment_method'] ?? json['paymentMethod']),
      items: parsedItems,
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
    final product = json['product'] is Map<String, dynamic>
        ? json['product'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final price = _asInt(json['price'] ?? json['unit_price'] ?? product['price']);
    final discount = _asInt(json['discount']);
    final subtotal = _asInt(json['subtotal']);
    final total = _asInt(json['line_total'] ?? json['total']);
    final fallbackLineTotal = (qty * price) - discount;

    return TransactionItemModel(
      name: _asString(json['name'] ?? json['product_name'] ?? product['name']),
      quantity: qty,
      price: price,
      discount: discount,
      lineTotal: subtotal > 0 ? subtotal : (total > 0 ? total : fallbackLineTotal),
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
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return 0;
    }

    final asInt = int.tryParse(normalized);
    if (asInt != null) {
      return asInt;
    }

    final asDouble = double.tryParse(normalized);
    if (asDouble != null) {
      return asDouble.toInt();
    }

    final digitsOnly = normalized.replaceAll(RegExp(r'[^0-9-]'), '');
    return int.tryParse(digitsOnly) ?? 0;
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
