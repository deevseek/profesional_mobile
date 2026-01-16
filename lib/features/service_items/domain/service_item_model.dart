class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.name,
    this.serviceId,
    this.productId,
    this.description,
    this.quantity,
    this.unitPrice,
    this.total,
    this.serviceName,
    this.productName,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? serviceId;
  final String? productId;
  final String? description;
  final int? quantity;
  final double? unitPrice;
  final double? total;
  final String? serviceName;
  final String? productName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    final serviceValue = json['service'] ?? json['service_name'] ?? json['serviceTitle'];
    final productValue = json['product'] ?? json['product_name'] ?? json['productTitle'];
    final resolvedProductName = _extractName(productValue);

    return ServiceItem(
      id: '${json['id'] ?? json['service_item_id'] ?? ''}',
      name: '${json['name'] ?? json['item_name'] ?? json['title'] ?? resolvedProductName ?? ''}',
      serviceId: _stringValue(json['service_id'] ?? json['serviceId']),
      productId: _stringValue(json['product_id'] ?? json['productId']),
      description: json['description']?.toString() ?? json['notes']?.toString(),
      quantity: _asInt(json['quantity'] ?? json['qty']),
      unitPrice: _asDouble(json['unit_price'] ?? json['unitPrice'] ?? json['price']),
      total: _asDouble(json['total'] ?? json['total_price'] ?? json['totalPrice']),
      serviceName: _extractName(serviceValue) ?? _stringValue(json['service_title']),
      productName: resolvedProductName,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      if (serviceId != null) 'service_id': serviceId,
      if (productId != null) 'product_id': productId,
      'name': name,
      if (description != null) 'description': description,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (total != null) 'total': total,
    };
  }

  ServiceItem copyWith({
    String? id,
    String? name,
    String? serviceId,
    String? productId,
    String? description,
    int? quantity,
    double? unitPrice,
    double? total,
    String? serviceName,
    String? productName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      serviceId: serviceId ?? this.serviceId,
      productId: productId ?? this.productId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      total: total ?? this.total,
      serviceName: serviceName ?? this.serviceName,
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
      final name = value['name'] ?? value['title'] ?? value['customer_name'];
      return name?.toString();
    }
    return value.toString();
  }
}

class ServiceItemPaginationMeta {
  const ServiceItemPaginationMeta({
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

  factory ServiceItemPaginationMeta.fromJson(Map<String, dynamic> json) {
    return ServiceItemPaginationMeta(
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

class ServiceItemPaginationLinks {
  const ServiceItemPaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  factory ServiceItemPaginationLinks.fromJson(Map<String, dynamic> json) {
    return ServiceItemPaginationLinks(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      prev: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}

class ServiceItemPage {
  const ServiceItemPage({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<ServiceItem> data;
  final ServiceItemPaginationMeta meta;
  final ServiceItemPaginationLinks links;

  factory ServiceItemPage.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    final metaJson = json['meta'];
    final linksJson = json['links'];

    return ServiceItemPage(
      data: dataList is List
          ? dataList.whereType<Map<String, dynamic>>().map(ServiceItem.fromJson).toList()
          : const [],
      meta: metaJson is Map<String, dynamic>
          ? ServiceItemPaginationMeta.fromJson(metaJson)
          : const ServiceItemPaginationMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 0,
              total: 0,
            ),
      links: linksJson is Map<String, dynamic>
          ? ServiceItemPaginationLinks.fromJson(linksJson)
          : const ServiceItemPaginationLinks(),
    );
  }
}
