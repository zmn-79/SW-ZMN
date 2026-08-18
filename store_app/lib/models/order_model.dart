class OrderItemModel {
  final String productId;
  final String name;
  final int quantity;
  final double priceAtOrder;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.priceAtOrder,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity:
          (json['quantity'] ?? 0) is int
              ? json['quantity']
              : int.tryParse(json['quantity'].toString()) ?? 0,
      priceAtOrder: (json['priceAtOrder'] ?? 0).toDouble(),
    );
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled;

  static OrderStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String get apiValue {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayLabel {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// الحالة التالية المسموح الانتقال لها من هذه الحالة (تسلسل منطقي للطلب)
  OrderStatus? get nextStatus {
    switch (this) {
      case OrderStatus.pending:
        return OrderStatus.confirmed;
      case OrderStatus.confirmed:
        return OrderStatus.preparing;
      case OrderStatus.preparing:
        return OrderStatus.outForDelivery;
      case OrderStatus.outForDelivery:
        return OrderStatus.delivered;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return null;
    }
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final String storeId;
  final String? customerName;
  final String? customerPhone;
  final List<OrderItemModel> items;
  final OrderStatus status;
  final double totalAmount;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.storeId,
    this.customerName,
    this.customerPhone,
    required this.items,
    required this.status,
    required this.totalAmount,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final customerField = json['customerId'];
    final bool customerIsPopulated = customerField is Map<String, dynamic>;

    return OrderModel(
      id: json['_id']?.toString() ?? '',
      customerId:
          customerIsPopulated
              ? customerField['_id']?.toString() ?? ''
              : customerField?.toString() ?? '',
      storeId: json['storeId']?.toString() ?? '',
      customerName:
          customerIsPopulated ? customerField['fullName']?.toString() : null,
      customerPhone:
          customerIsPopulated ? customerField['phone']?.toString() : null,
      items:
          (json['items'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map((item) => OrderItemModel.fromJson(item))
              .toList(),
      status: OrderStatus.fromString(json['status']?.toString() ?? 'pending'),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
    );
  }
}
