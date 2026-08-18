class ProductModel {
  final String id;
  final String? storeId;
  final String? categoryId;
  final String name;
  final double priceCapital;
  final double priceSell;
  final int parcode;
  final int quantity;
  final int yearManufacture;
  final int age;
  final String size;
  final String? expiryDate;
  final String? category; // اسم الفئة (يُستخدم محليًا وقت الإضافة قبل الإرسال)
  final String? imageUrl;

  ProductModel({
    required this.id,
    this.storeId,
    this.categoryId,
    required this.name,
    this.priceCapital = 0,
    this.priceSell = 0,
    this.parcode = 0,
    this.quantity = 0,
    this.yearManufacture = 0,
    this.age = 0,
    this.size = '',
    this.expiryDate,
    this.category,
    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id']?.toString() ?? '',
      storeId: json['storeId']?.toString(),
      categoryId: json['categoryId']?.toString(),
      name: json['name']?.toString() ?? '',
      priceCapital: (json['priceCapital'] ?? 0).toDouble(),
      priceSell: (json['priceSell'] ?? 0).toDouble(),
      parcode:
          (json['parcode'] ?? 0) is int
              ? json['parcode']
              : int.tryParse(json['parcode'].toString()) ?? 0,
      quantity:
          (json['quantity'] ?? 0) is int
              ? json['quantity']
              : int.tryParse(json['quantity'].toString()) ?? 0,
      yearManufacture:
          (json['yearManufacture'] ?? 0) is int
              ? json['yearManufacture']
              : int.tryParse(json['yearManufacture'].toString()) ?? 0,
      age:
          (json['age'] ?? 0) is int
              ? json['age']
              : int.tryParse(json['age'].toString()) ?? 0,
      size: json['size']?.toString() ?? '',
      expiryDate: json['expiryDate']?.toString(),
      category: json['category']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'categoryId': categoryId,
      'name': name,
      'priceCapital': priceCapital,
      'priceSell': priceSell,
      'parcode': parcode,
      'quantity': quantity,
      'yearManufacture': yearManufacture,
      'age': age,
      'size': size,
      'expiryDate': expiryDate,
      'category': category,
    };
  }

  ProductModel copyWith({
    String? name,
    double? priceCapital,
    double? priceSell,
    int? parcode,
    int? quantity,
    int? yearManufacture,
    int? age,
    String? size,
    String? expiryDate,
    String? imageUrl,
  }) {
    return ProductModel(
      id: id,
      storeId: storeId,
      categoryId: categoryId,
      name: name ?? this.name,
      priceCapital: priceCapital ?? this.priceCapital,
      priceSell: priceSell ?? this.priceSell,
      parcode: parcode ?? this.parcode,
      quantity: quantity ?? this.quantity,
      yearManufacture: yearManufacture ?? this.yearManufacture,
      age: age ?? this.age,
      size: size ?? this.size,
      expiryDate: expiryDate ?? this.expiryDate,
      category: category,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
