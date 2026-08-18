import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/auth_response_model.dart';

class AuthService {
  static Future<AuthServiceResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        return AuthServiceResult.failure(data['message'] ?? 'Login failed');
      }

      return AuthServiceResult.success(AuthResponseModel.fromJson(data));
    } catch (e) {
      return AuthServiceResult.failure('Error connecting to server: $e');
    }
  }

  static Future<AuthServiceResult> register(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 201 && response.statusCode != 200) {
        return AuthServiceResult.failure(
          data['message'] ?? data['error'] ?? 'Registration failed',
          code: data['code'],
        );
      }

      return AuthServiceResult.success(AuthResponseModel.fromJson(data));
    } catch (e) {
      return AuthServiceResult.failure('Error connecting to server: $e');
    }
  }
}

class AuthServiceResult {
  final bool isSuccess;
  final AuthResponseModel? data;
  final String? errorMessage;
  final String? errorCode;

  AuthServiceResult._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
    this.errorCode,
  });

  factory AuthServiceResult.success(AuthResponseModel data) {
    return AuthServiceResult._(isSuccess: true, data: data);
  }

  factory AuthServiceResult.failure(String message, {String? code}) {
    return AuthServiceResult._(
      isSuccess: false,
      errorMessage: message,
      errorCode: code,
    );
  }
}
