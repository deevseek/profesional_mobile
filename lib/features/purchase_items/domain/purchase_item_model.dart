class PurchaseItem {
  const PurchaseItem({
    required this.id,
    required this.name,
    this.purchaseId,
    this.productId,
    this.description,
    this.quantity,
    this.unitPrice,
    this.total,
    this.purchaseNumber,
    this.supplierName,
    this.productName,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? purchaseId;
  final String? productId;
  final String? description;
  final int? quantity;
  final double? unitPrice;
  final double? total;
  final String? purchaseNumber;
  final String? supplierName;
  final String? productName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    final purchaseValue =
        json['purchase'] ?? json['purchase_number'] ?? json['invoice'] ?? json['reference'];
    final productValue = json['product'] ?? json['product_name'] ?? json['productTitle'];
    final supplierValue =
        json['supplier'] ?? json['vendor'] ?? json['supplier_name'] ?? json['vendor_name'];
    final resolvedProductName = _extractName(productValue);

    return PurchaseItem(
      id: '${json['id'] ?? json['purchase_item_id'] ?? ''}',
      name:
          '${json['name'] ?? json['item_name'] ?? json['title'] ?? resolvedProductName ?? json['product_id'] ?? ''}',
      purchaseId: _stringValue(json['purchase_id'] ?? json['purchaseId']),
      productId: _stringValue(json['product_id'] ?? json['productId']),
      description: json['description']?.toString() ?? json['notes']?.toString(),
      quantity: _asInt(json['quantity'] ?? json['qty']),
      unitPrice: _asDouble(json['unit_price'] ?? json['unitPrice'] ?? json['price']),
      total:
          _asDouble(json['total'] ?? json['total_price'] ?? json['totalPrice'] ?? json['subtotal']),
      purchaseNumber: _extractName(purchaseValue) ??
          _stringValue(json['purchase_number'] ?? json['reference_number']),
      supplierName: _extractName(supplierValue) ??
          _stringValue(json['supplier_title'] ?? json['vendor_title']),
      productName: resolvedProductName,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (productId != null) 'product_id': productId,
      if (description != null) 'description': description,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'price': unitPrice,
      if (total != null) 'subtotal': total,
    };
  }

  PurchaseItem copyWith({
    String? id,
    String? name,
    String? purchaseId,
    String? productId,
    String? description,
    int? quantity,
    double? unitPrice,
    double? total,
    String? purchaseNumber,
    String? supplierName,
    String? productName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      name: name ?? this.name,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      total: total ?? this.total,
      purchaseNumber: purchaseNumber ?? this.purchaseNumber,
      supplierName: supplierName ?? this.supplierName,
      productName: productName ?? this.productName,
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

  static String? _extractName(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map) {
      final name = value['name'] ?? value['title'] ?? value['reference'] ?? value['purchase_number'];
      return name?.toString();
    }
    return value.toString();
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
