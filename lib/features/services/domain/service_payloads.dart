class CreateServicePayload {
  const CreateServicePayload({
    required this.customerId,
    required this.deviceName,
    required this.deviceType,
    required this.complaint,
    required this.estimatedCost,
    required this.technicianId,
  });

  final String customerId;
  final String deviceName;
  final String deviceType;
  final String complaint;
  final int estimatedCost;
  final String technicianId;

  Map<String, dynamic> toJson() => {
    'customer_id': customerId,
    'device_name': deviceName,
    'device_type': deviceType,
    'complaint': complaint,
    'estimated_cost': estimatedCost,
    'technician_id': technicianId,
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
