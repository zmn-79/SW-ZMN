class StoreModel {
  final String id;
  final String ownerId;
  final String storeName;
  final String storeType;
  final String storeAddress;
  final String paymentMethods;
  final String description;
  final String taxNumber;
  final String commercialNumber;
  final bool isActive;

  StoreModel({
    required this.id,
    required this.ownerId,
    required this.storeName,
    required this.storeType,
    required this.storeAddress,
    required this.paymentMethods,
    required this.description,
    required this.taxNumber,
    required this.commercialNumber,
    required this.isActive,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['_id']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      storeName: json['storeName']?.toString() ?? '',
      storeType: json['storeType']?.toString() ?? '',
      storeAddress: json['storeAddress']?.toString() ?? '',
      paymentMethods: json['paymentMethods']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      taxNumber: json['taxNumber']?.toString() ?? '',
      commercialNumber: json['commercialNumber']?.toString() ?? '',
      isActive: json['isActive'] == true,
    );
  }

  StoreModel copyWith({
    String? storeName,
    String? storeType,
    String? storeAddress,
    String? paymentMethods,
    String? description,
    String? taxNumber,
    String? commercialNumber,
  }) {
    return StoreModel(
      id: id,
      ownerId: ownerId,
      storeName: storeName ?? this.storeName,
      storeType: storeType ?? this.storeType,
      storeAddress: storeAddress ?? this.storeAddress,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      description: description ?? this.description,
      taxNumber: taxNumber ?? this.taxNumber,
      commercialNumber: commercialNumber ?? this.commercialNumber,
      isActive: isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'storeType': storeType,
      'storeAddress': storeAddress,
      'paymentMethods': paymentMethods,
      'description': description,
      'taxNumber': taxNumber,
      'commercialNumber': commercialNumber,
    };
  }
}
