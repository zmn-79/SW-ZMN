class UserProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;

  UserProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['_id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  UserProfileModel copyWith({String? fullName, String? phone, String? email}) {
    return UserProfileModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role,
    );
  }

  Map<String, dynamic> toJson() {
    return {'fullName': fullName, 'phone': phone};
  }
}
