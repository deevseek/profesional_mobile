import '../../categories/domain/category_model.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    this.categoryId,
    this.sku,
    this.costPrice,
    this.avgCost,
    this.price,
    this.pricingMode,
    this.marginPercentage,
    this.stock,
    this.warrantyDays,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.category,
  });

  final String id;
  final String name;
  final String? categoryId;
  final String? sku;
  final double? costPrice;
  final double? avgCost;
  final double? price;
  final String? pricingMode;
  final double? marginPercentage;
  final int? stock;
  final int? warrantyDays;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Category? category;

  factory Product.fromJson(Map<String, dynamic> json) {
    final categoryPayload = json['category'];
    return Product(
      id: '${json['id'] ?? json['product_id'] ?? ''}',
      categoryId: _stringValue(json['category_id'] ?? json['categoryId']),
      name: '${json['name'] ?? ''}',
      sku: _stringValue(json['sku'] ?? json['code']),
      costPrice: _asDouble(json['cost_price'] ?? json['costPrice'] ?? json['cost']),
      avgCost: _asDouble(json['avg_cost'] ?? json['avgCost']),
      price: _asDouble(json['price'] ?? json['unit_price'] ?? json['unitPrice']),
      pricingMode: _stringValue(json['pricing_mode'] ?? json['pricingMode']),
      marginPercentage: _asDouble(json['margin_percentage'] ?? json['marginPercentage']),
      stock: _asInt(json['stock'] ?? json['quantity']),
      warrantyDays: _asInt(json['warranty_days'] ?? json['warrantyDays']),
      description: json['description']?.toString(),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
      category: categoryPayload is Map<String, dynamic> ? Category.fromJson(categoryPayload) : null,
    );
  }

  Map<String, dynamic> toPayload() {
    final payload = <String, dynamic>{
      'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (_hasValue(sku)) 'sku': sku,
      if (pricingMode != null) 'pricing_mode': pricingMode,
      if (costPrice != null) 'cost_price': costPrice,
      if (price != null) 'price': price,
      if (marginPercentage != null) 'margin_percentage': marginPercentage,
      if (stock != null) 'stock': stock,
      if (warrantyDays != null) 'warranty_days': warrantyDays,
      if (description != null) 'description': description,
    };
    return payload;
  }

  Product copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? sku,
    double? costPrice,
    double? avgCost,
    double? price,
    String? pricingMode,
    double? marginPercentage,
    int? stock,
    int? warrantyDays,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    Category? category,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      sku: sku ?? this.sku,
      costPrice: costPrice ?? this.costPrice,
      avgCost: avgCost ?? this.avgCost,
      price: price ?? this.price,
      pricingMode: pricingMode ?? this.pricingMode,
      marginPercentage: marginPercentage ?? this.marginPercentage,
      stock: stock ?? this.stock,
      warrantyDays: warrantyDays ?? this.warrantyDays,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
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

  static bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
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
