class StoreModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String storeName;
  final String storeType;
  final String storeAddress;
  final String paymentMethods;
  final String description;
  final String taxNumber;
  final String commercialNumber;

  const StoreModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.storeName,
    required this.storeType,
    required this.storeAddress,
    required this.paymentMethods,
    required this.description,
    required this.taxNumber,
    required this.commercialNumber,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: _readString(json['_id']),
      fullName: _readString(json['ownerId']?['fullName']),
      email: _readString(json['ownerId']?['email']),
      phone: _readString(json['ownerId']?['phone']),
      storeName: _readString(json['storeName'], fallback: 'Unknown Store'),
      storeType: _readString(json['storeType']),
      storeAddress: _readString(json['storeAddress']),
      paymentMethods: _readString(json['paymentMethods']),
      description: _readString(json['description']),
      taxNumber: _readString(json['taxNumber']),
      commercialNumber: _readString(json['commercialNumber']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'storeName': storeName,
      'storeType': storeType,
      'storeAddress': storeAddress,
      'paymentMethods': paymentMethods,
      'description': description,
      'taxNumber': taxNumber,
      'commercialNumber': commercialNumber,
    };
  }

  static String _readString(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }

    return value.toString();
  }
}
