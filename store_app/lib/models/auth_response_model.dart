class AuthResponseModel {
  final String? token;
  final String userId;
  final String? role;
  final String? storeId;
  final String message;

  AuthResponseModel({
    this.token,
    required this.userId,
    this.role,
    this.storeId,
    required this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token']?.toString(),
      userId: json['userId']?.toString() ?? '',
      role: json['role']?.toString(),
      storeId: json['storeId']?.toString(),
      message: json['message']?.toString() ?? '',
    );
  }
}
