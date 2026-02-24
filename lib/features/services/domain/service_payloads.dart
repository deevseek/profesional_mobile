class CreateServicePayload {
  const CreateServicePayload({
    required this.customerId,
    required this.device,
    required this.model,
    required this.complaint,
    this.serialNumber,
    this.accessories,
    this.deposit = 0,
    this.serviceFee = 0,
    this.warrantyDays = 0,
  });

  final String customerId;
  final String device;
  final String model;
  final String complaint;
  final String? serialNumber;
  final String? accessories;
  final int deposit;
  final int serviceFee;
  final int warrantyDays;

  Map<String, dynamic> toJson() => {
    'customer_id': customerId,
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
