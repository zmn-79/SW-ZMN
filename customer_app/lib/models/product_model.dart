class ProductModel {
  final String id;
  final String name;
  final double priceSell;
  final int quantity;
  final String size;
  final String storeId;
  final String storeName;
  final String? imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.priceSell,
    required this.quantity,
    required this.size,
    required this.storeId,
    required this.storeName,
    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final store = json['storeId'];

    return ProductModel(
      id: _readString(json['_id']),
      name: _readString(json['name'], fallback: 'No Name'),
      priceSell: _readDouble(json['priceSell']),
      quantity: _readInt(json['quantity']),
      size: _readString(json['size']),
      storeId: store is Map ? _readString(store['_id']) : _readString(store),
      storeName:
          store is Map
              ? _readString(store['storeName'], fallback: 'Unknown Store')
              : 'Unknown Store',
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'priceSell': priceSell,
      'quantity': quantity,
      'size': size,
      'storeId': {'_id': storeId, 'storeName': storeName},
      'imageUrl': imageUrl,
    };
  }

  static String _readString(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    return value.toString();
  }

  static double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
