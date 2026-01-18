class PurchaseItem {
  const PurchaseItem({
    required this.id,
    this.purchaseId,
    this.productId,
    this.quantity,
    this.price,
    this.subtotal,
    this.purchaseInvoiceNumber,
    this.purchaseDate,
    this.paymentStatus,
    this.purchaseTotalAmount,
    this.productName,
    this.productSku,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? purchaseId;
  final String? productId;
  final int? quantity;
  final double? price;
  final double? subtotal;
  final String? purchaseInvoiceNumber;
  final DateTime? purchaseDate;
  final String? paymentStatus;
  final double? purchaseTotalAmount;
  final String? productName;
  final String? productSku;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    final purchaseValue = json['purchase'];
    final productValue = json['product'];
    final purchaseMap = purchaseValue is Map ? purchaseValue : null;
    final productMap = productValue is Map ? productValue : null;

    return PurchaseItem(
      id: '${json['id'] ?? json['purchase_item_id'] ?? ''}',
      purchaseId: _stringValue(json['purchase_id'] ?? json['purchaseId']),
      productId: _stringValue(json['product_id'] ?? json['productId']),
      quantity: _asInt(json['quantity'] ?? json['qty']),
      price: _asDouble(json['price'] ?? json['unit_price'] ?? json['unitPrice']),
      subtotal: _asDouble(json['subtotal'] ?? json['total'] ?? json['total_price']),
      purchaseInvoiceNumber: _stringValue(
        purchaseMap?['invoice_number'] ?? json['invoice_number'] ?? json['reference_number'],
      ),
      purchaseDate: _parseDate(purchaseMap?['purchase_date'] ?? json['purchase_date']),
      paymentStatus: _stringValue(purchaseMap?['payment_status'] ?? json['payment_status']),
      purchaseTotalAmount: _asDouble(purchaseMap?['total_amount'] ?? json['total_amount']),
      productName:
          _stringValue(productMap?['name'] ?? json['product_name'] ?? json['name'] ?? json['title']),
      productSku: _stringValue(productMap?['sku'] ?? json['sku'] ?? json['product_sku']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (price != null) 'price': price,
    };
  }

  PurchaseItem copyWith({
    String? id,
    String? purchaseId,
    String? productId,
    int? quantity,
    double? price,
    double? subtotal,
    String? purchaseInvoiceNumber,
    DateTime? purchaseDate,
    String? paymentStatus,
    double? purchaseTotalAmount,
    String? productName,
    String? productSku,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      subtotal: subtotal ?? this.subtotal,
      purchaseInvoiceNumber: purchaseInvoiceNumber ?? this.purchaseInvoiceNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      purchaseTotalAmount: purchaseTotalAmount ?? this.purchaseTotalAmount,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
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

  static double? _asDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
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
    return int.tryParse(value.toString().replaceAll(',', ''));
  }

  static String? _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.toString().trim();
    return trimmed.isEmpty ? null : trimmed;
  }

}

class PurchaseItemPaginationMeta {
  const PurchaseItemPaginationMeta({
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

  factory PurchaseItemPaginationMeta.fromJson(Map<String, dynamic> json) {
    return PurchaseItemPaginationMeta(
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

class PurchaseItemPaginationLinks {
  const PurchaseItemPaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  factory PurchaseItemPaginationLinks.fromJson(Map<String, dynamic> json) {
    return PurchaseItemPaginationLinks(
      first: json['first']?.toString() ?? json['first_page_url']?.toString(),
      last: json['last']?.toString() ?? json['last_page_url']?.toString(),
      prev: json['prev']?.toString() ?? json['prev_page_url']?.toString(),
      next: json['next']?.toString() ?? json['next_page_url']?.toString(),
    );
  }
}

class PurchaseItemPage {
  const PurchaseItemPage({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<PurchaseItem> data;
  final PurchaseItemPaginationMeta meta;
  final PurchaseItemPaginationLinks links;

  factory PurchaseItemPage.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    final metaJson = json['meta'];
    final linksJson = json['links'];

    return PurchaseItemPage(
      data: dataList is List
          ? dataList.whereType<Map<String, dynamic>>().map(PurchaseItem.fromJson).toList()
          : const [],
      meta: metaJson is Map<String, dynamic>
          ? PurchaseItemPaginationMeta.fromJson(metaJson)
          : PurchaseItemPaginationMeta.fromJson(json),
      links: linksJson is Map<String, dynamic>
          ? PurchaseItemPaginationLinks.fromJson(linksJson)
          : PurchaseItemPaginationLinks.fromJson(json),
    );
  }
}
