class CreateServicePayload {
  const CreateServicePayload({
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerAddress,
    required this.device,
    required this.model,
    required this.complaint,
    this.serialNumber,
    this.accessories,
    this.deposit = 0,
    this.serviceFee = 0,
    this.warrantyDays = 0,
  });

  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerAddress;
  final String device;
  final String model;
  final String complaint;
  final String? serialNumber;
  final String? accessories;
  final int deposit;
  final int serviceFee;
  final int warrantyDays;

  Map<String, dynamic> toJson() => {
    if (customerId != null && customerId!.isNotEmpty) 'customer_id': customerId,
    if (customerName != null && customerName!.isNotEmpty) 'customer_name': customerName,
    if (customerPhone != null && customerPhone!.isNotEmpty) 'customer_phone': customerPhone,
    if (customerEmail != null && customerEmail!.isNotEmpty) 'customer_email': customerEmail,
    if (customerAddress != null && customerAddress!.isNotEmpty) 'customer_address': customerAddress,
    'device': device,
    'model': model,
    'complaint': complaint,
    if (serialNumber != null && serialNumber!.isNotEmpty) 'serial_number': serialNumber,
    if (accessories != null && accessories!.isNotEmpty) 'accessories': accessories,
    'deposit': deposit,
    'service_fee': serviceFee,
    'warranty_days': warrantyDays,
  };
}

class AddServiceItemPayload {
  const AddServiceItemPayload({
    required this.productId,
    required this.qty,
    required this.price,
  });

  final String productId;
  final int qty;
  final int price;

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'qty': qty,
    'price': price,
  };
}
