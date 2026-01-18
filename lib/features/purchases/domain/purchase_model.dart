class Purchase {
  const Purchase({
    required this.id,
    this.supplierId,
    this.invoiceNumber,
    this.purchaseDate,
    this.paymentStatus,
    this.totalAmount,
    this.notes,
    this.supplierName,
    this.items,
  });

  final String id;
  final String? supplierId;
  final String? invoiceNumber;
  final DateTime? purchaseDate;
  final String? paymentStatus;
  final double? totalAmount;
  final String? notes;
  final String? supplierName;
  final List<PurchaseLineItem>? items;

  factory Purchase.fromJson(Map<String, dynamic> json) {
    final supplierValue = json['supplier'] ?? json['supplier_name'] ?? json['vendor'];
    final itemsValue = json['items'] ?? json['purchase_items'];

    return Purchase(
      id: '${json['id'] ?? json['purchase_id'] ?? ''}',
      supplierId: _stringValue(json['supplier_id'] ?? json['supplierId']),
      invoiceNumber: _stringValue(
        json['invoice_number'] ?? json['invoiceNumber'] ?? json['reference'],
      ),
      purchaseDate: _parseDate(json['purchase_date'] ?? json['purchaseDate']),
      paymentStatus: _stringValue(json['payment_status'] ?? json['paymentStatus'] ?? json['status']),
      totalAmount: _asDouble(json['total_amount'] ?? json['totalAmount'] ?? json['amount']),
      notes: _stringValue(json['notes'] ?? json['description'] ?? json['remarks']),
      supplierName: _extractName(supplierValue),
      items: itemsValue is List
          ? itemsValue.whereType<Map<String, dynamic>>().map(PurchaseLineItem.fromJson).toList()
          : null,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      if (supplierId != null) 'supplier_id': supplierId,
      if (purchaseDate != null) 'purchase_date': _formatDate(purchaseDate!),
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (notes != null) 'notes': notes,
      if (items != null)
        'items': items!
            .map((item) => item.toPayload())
            .whereType<Map<String, dynamic>>()
            .toList(),
    };
  }

  Purchase copyWith({
    String? id,
    String? supplierId,
    String? invoiceNumber,
    DateTime? purchaseDate,
    String? paymentStatus,
    double? totalAmount,
    String? notes,
    String? supplierName,
    List<PurchaseLineItem>? items,
  }) {
    return Purchase(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      supplierName: supplierName ?? this.supplierName,
      items: items ?? this.items,
    );
  }

  static String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
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
    return double.tryParse(value.toString().replaceAll(',', ''));
  }

  static String? _extractName(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map) {
      final name = value['name'] ?? value['title'] ?? value['company_name'];
      return name?.toString();
    }
    return value.toString();
  }
}

class PurchaseLineItem {
  const PurchaseLineItem({
    required this.id,
    this.purchaseId,
    this.productId,
    this.quantity,
    this.price,
    this.subtotal,
    this.productName,
    this.productSku,
  });

  final String id;
  final String? purchaseId;
  final String? productId;
  final int? quantity;
  final double? price;
  final double? subtotal;
  final String? productName;
  final String? productSku;

  factory PurchaseLineItem.fromJson(Map<String, dynamic> json) {
    final productValue = json['product'] ?? json['product_name'];
    final productMap = productValue is Map ? productValue : null;
    return PurchaseLineItem(
      id: '${json['id'] ?? json['purchase_item_id'] ?? ''}',
      purchaseId: _stringValue(json['purchase_id'] ?? json['purchaseId']),
      productId: _stringValue(json['product_id'] ?? json['productId']),
      quantity: _asInt(json['quantity'] ?? json['qty']),
      price: _asDouble(json['price'] ?? json['unit_price'] ?? json['unitPrice']),
      subtotal: _asDouble(json['subtotal'] ?? json['total'] ?? json['total_price']),
      productName: _extractName(productValue) ?? _stringValue(json['product_name']),
      productSku: _stringValue(productMap?['sku'] ?? json['sku'] ?? json['product_sku']),
    );
  }

  Map<String, dynamic>? toPayload() {
    if (productId == null && quantity == null && price == null) {
      return null;
    }
    return {
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (price != null) 'price': price,
      if (subtotal != null) 'subtotal': subtotal,
    };
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
    return double.tryParse(value.toString().replaceAll(',', ''));
  }

  static int? _asInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  static String? _extractName(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map) {
      final name = value['name'] ?? value['title'];
      return name?.toString();
    }
    return value.toString();
  }
}

class PurchasePaginationMeta {
  const PurchasePaginationMeta({
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

  factory PurchasePaginationMeta.fromJson(Map<String, dynamic> json) {
    return PurchasePaginationMeta(
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

class PurchasePaginationLinks {
  const PurchasePaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  factory PurchasePaginationLinks.fromJson(Map<String, dynamic> json) {
    return PurchasePaginationLinks(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      prev: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}

class PurchasePage {
  const PurchasePage({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<Purchase> data;
  final PurchasePaginationMeta meta;
  final PurchasePaginationLinks links;

  factory PurchasePage.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    final metaJson = json['meta'];
    final linksJson = json['links'];

    return PurchasePage(
      data: dataList is List
          ? dataList.whereType<Map<String, dynamic>>().map(Purchase.fromJson).toList()
          : const [],
      meta: metaJson is Map<String, dynamic>
          ? PurchasePaginationMeta.fromJson(metaJson)
          : const PurchasePaginationMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 0,
              total: 0,
            ),
      links: linksJson is Map<String, dynamic>
          ? PurchasePaginationLinks.fromJson(linksJson)
          : const PurchasePaginationLinks(),
    );
  }
}
