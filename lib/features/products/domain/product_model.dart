class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    this.description,
    this.pricingMode,
    this.price,
    this.cost,
    this.stock,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String sku;
  final String? description;
  final String? pricingMode;
  final double? price;
  final double? cost;
  final int? stock;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: '${json['id'] ?? json['product_id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      sku: '${json['sku'] ?? json['code'] ?? ''}',
      description: json['description']?.toString(),
      pricingMode: json['pricing_mode']?.toString() ?? json['pricingMode']?.toString(),
      price: _asDouble(json['price'] ?? json['unit_price'] ?? json['unitPrice']),
      cost: _asDouble(json['cost'] ?? json['unit_cost'] ?? json['unitCost']),
      stock: _asInt(json['stock'] ?? json['quantity']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'name': name,
      'sku': sku,
      if (description != null) 'description': description,
      if (pricingMode != null) 'pricing_mode': pricingMode,
      if (price != null) 'price': price,
      if (cost != null) 'cost': cost,
      if (stock != null) 'stock': stock,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? description,
    String? pricingMode,
    double? price,
    double? cost,
    int? stock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      pricingMode: pricingMode ?? this.pricingMode,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stock: stock ?? this.stock,
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
}

class ProductPaginationMeta {
  const ProductPaginationMeta({
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

  factory ProductPaginationMeta.fromJson(Map<String, dynamic> json) {
    return ProductPaginationMeta(
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

class ProductPaginationLinks {
  const ProductPaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  factory ProductPaginationLinks.fromJson(Map<String, dynamic> json) {
    return ProductPaginationLinks(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      prev: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}

class ProductPage {
  const ProductPage({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<Product> data;
  final ProductPaginationMeta meta;
  final ProductPaginationLinks links;

  factory ProductPage.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    final metaJson = json['meta'];
    final linksJson = json['links'];

    return ProductPage(
      data: dataList is List
          ? dataList.whereType<Map<String, dynamic>>().map(Product.fromJson).toList()
          : const [],
      meta: metaJson is Map<String, dynamic>
          ? ProductPaginationMeta.fromJson(metaJson)
          : const ProductPaginationMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 0,
              total: 0,
            ),
      links: linksJson is Map<String, dynamic>
          ? ProductPaginationLinks.fromJson(linksJson)
          : const ProductPaginationLinks(),
    );
  }
}
