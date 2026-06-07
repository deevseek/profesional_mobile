import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    required this.date,
    required this.status,
    required this.subtotal,
    required this.discount,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.paymentMethod,
    required this.paidAmount,
    required this.changeAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.customer,
    required this.items,
  });

  final String id;
  final String invoiceNumber;
  final String customerId;
  final String customerName;
  final DateTime date;
  final String status;
  final int subtotal;
  final int discount;
  final double taxRate;
  final int taxAmount;
  final int total;
  final String paymentMethod;
  final int paidAmount;
  final int changeAmount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final TransactionCustomerModel? customer;
  final List<TransactionItemModel> items;

  String get invoice => invoiceNumber;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final unwrapped = unwrapDataMap(json);
    final transactionMap = parseMap(unwrapped['transaction']);
    final data = transactionMap.isEmpty ? unwrapped : transactionMap;
    final customerMap = parseMap(data['customer']);
    final parsedCustomer = customerMap.isEmpty ? null : TransactionCustomerModel.fromJson(customerMap);
    final parsedItems = parseMapList(data['items'] ?? data['transaction_items'])
        .map(TransactionItemModel.fromJson)
        .toList(growable: false);
    final subtotal = parseInt(data['subtotal'] ?? data['sub_total']);
    final total = parseInt(data['total'] ?? data['grand_total'] ?? data['total_amount']);
    final createdAt = parseDateTime(data['created_at'] ?? data['date'] ?? data['transaction_date']) ?? DateTime.now();
    final paidAmount = parseInt(data['paid_amount'] ?? data['paid']);

    return TransactionModel(
      id: parseString(data['id'] ?? data['transaction_id'] ?? data['_id']),
      invoiceNumber: parseString(data['invoice_number'] ?? data['invoice'] ?? data['number']),
      customerId: parseString(data['customer_id'] ?? parsedCustomer?.id),
      customerName: parseString(
        data['customer_name'] ?? data['customerName'] ?? parsedCustomer?.name,
        fallback: '-',
      ),
      date: parseDateTime(data['date'] ?? data['created_at'] ?? data['transaction_date']) ?? createdAt,
      status: parseString(data['status'], fallback: 'success'),
      subtotal: subtotal > 0
          ? subtotal
          : parsedItems.fold<int>(0, (sum, item) => sum + (item.quantity * item.price)),
      discount: parseInt(data['discount'] ?? data['discount_amount']),
      taxRate: parseDouble(data['tax_rate'] ?? data['taxPercent']),
      taxAmount: parseInt(data['tax_amount'] ?? data['tax']),
      total: total > 0 ? total : parsedItems.fold<int>(0, (sum, item) => sum + item.lineTotal),
      paymentMethod: parseString(data['payment_method'] ?? data['paymentMethod']),
      paidAmount: paidAmount,
      changeAmount: parseInt(data['change_amount'] ?? data['change'] ?? data['return_amount']),
      createdAt: createdAt,
      updatedAt: parseDateTime(data['updated_at']),
      customer: parsedCustomer,
      items: parsedItems,
    );
  }
}

class TransactionCustomerModel {
  const TransactionCustomerModel({required this.id, required this.name, required this.phone});

  final String id;
  final String name;
  final String phone;

  factory TransactionCustomerModel.fromJson(Map<String, dynamic> json) {
    return TransactionCustomerModel(
      id: parseString(json['id'] ?? json['customer_id']),
      name: parseString(json['name'] ?? json['full_name'], fallback: '-'),
      phone: parseString(json['phone'] ?? json['phone_number'] ?? json['wa']),
    );
  }
}

class TransactionItemModel {
  const TransactionItemModel({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.hpp,
    required this.subtotalHpp,
    required this.lineTotal,
    required this.product,
  });

  final String id;
  final String transactionId;
  final String productId;
  final String name;
  final int quantity;
  final int price;
  final int discount;
  final int hpp;
  final int subtotalHpp;
  final int lineTotal;
  final TransactionProductModel? product;

  int get total => lineTotal;

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    final productMap = parseMap(json['product']);
    final parsedProduct = productMap.isEmpty ? null : TransactionProductModel.fromJson(productMap);
    final qty = parseInt(json['quantity'] ?? json['qty']);
    final price = parseInt(json['price'] ?? json['unit_price'] ?? parsedProduct?.price);
    final discount = parseInt(json['discount'] ?? json['discount_amount']);
    final subtotal = parseInt(json['subtotal']);
    final total = parseInt(json['line_total'] ?? json['total']);
    final fallbackLineTotal = ((qty * price) - discount).clamp(0, qty * price).toInt();

    return TransactionItemModel(
      id: parseString(json['id'] ?? json['transaction_item_id']),
      transactionId: parseString(json['transaction_id']),
      productId: parseString(json['product_id'] ?? parsedProduct?.id),
      name: parseString(json['name'] ?? json['product_name'] ?? parsedProduct?.name, fallback: '-'),
      quantity: qty,
      price: price,
      discount: discount,
      hpp: parseInt(json['hpp'] ?? json['cost_price'] ?? parsedProduct?.costPrice),
      subtotalHpp: parseInt(json['subtotal_hpp']),
      lineTotal: total > 0 ? total : (subtotal > 0 ? subtotal : fallbackLineTotal),
      product: parsedProduct,
    );
  }
}

class TransactionProductModel {
  const TransactionProductModel({
    required this.id,
    required this.name,
    required this.warrantyDays,
    required this.costPrice,
    required this.avgCost,
    required this.price,
  });

  final String id;
  final String name;
  final int warrantyDays;
  final int costPrice;
  final int avgCost;
  final int price;

  factory TransactionProductModel.fromJson(Map<String, dynamic> json) {
    return TransactionProductModel(
      id: parseString(json['id'] ?? json['product_id']),
      name: parseString(json['name'], fallback: '-'),
      warrantyDays: parseInt(json['warranty_days']),
      costPrice: parseInt(json['cost_price'] ?? json['costPrice']),
      avgCost: parseInt(json['avg_cost'] ?? json['avgCost']),
      price: parseInt(json['price']),
    );
  }
}
