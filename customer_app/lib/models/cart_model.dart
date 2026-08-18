class CartItemModel {
  final String productId;
  final String storeId;
  final int quantity;
  final double priceAtAdd;

  // بيانات إضافية للعرض، جاية من الـ populate في السيرفر
  final String? productName;
  final String? imageUrl;
  final String? storeName;
  final int? availableQuantity;

  CartItemModel({
    required this.productId,
    required this.storeId,
    required this.quantity,
    required this.priceAtAdd,
    this.productName,
    this.storeName,
    this.availableQuantity,
    this.imageUrl,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productField = json['productId'];
    final storeField = json['storeId'];

    final bool productIsPopulated = productField is Map<String, dynamic>;
    final bool storeIsPopulated = storeField is Map<String, dynamic>;

    return CartItemModel(
      productId:
          productIsPopulated
              ? productField['_id']?.toString() ?? ''
              : productField?.toString() ?? '',
      storeId:
          storeIsPopulated
              ? storeField['_id']?.toString() ?? ''
              : storeField?.toString() ?? '',
      quantity:
          (json['quantity'] ?? 0) is int
              ? json['quantity']
              : int.tryParse(json['quantity'].toString()) ?? 0,
      priceAtAdd: (json['priceAtAdd'] ?? 0).toDouble(),
      productName: productIsPopulated ? productField['name']?.toString() : null,
      storeName: storeIsPopulated ? storeField['storeName']?.toString() : null,
      availableQuantity: productIsPopulated ? productField['quantity'] : null,
      imageUrl:
          productIsPopulated ? productField['imageUrl']?.toString() : null,
    );
  }

  double get subtotal => priceAtAdd * quantity;
}

class CartModel {
  final String customerId;
  final List<CartItemModel> items;

  CartModel({required this.customerId, required this.items});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      customerId: json['customerId']?.toString() ?? '',
      items:
          (json['items'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map((item) => CartItemModel.fromJson(item))
              .toList(),
    );
  }

  double get totalAmount => items.fold(0, (sum, item) => sum + item.subtotal);

  int get totalItemsCount => items.fold(0, (sum, item) => sum + item.quantity);
}
