import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:customer_app/utils/constants.dart';
import 'package:customer_app/models/user_profile_model.dart';
import 'package:customer_app/services/session.dart';

class UserService {
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
  };

  static Future<UserProfileModel?> getMyProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/users/me'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        return null;
      }

      return UserProfileModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      return null;
    }
  }

  static Future<UserServiceResult> updateMyProfile(
    UserProfileModel profile,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/users/me'),
        headers: _headers,
        body: jsonEncode(profile.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        return UserServiceResult.failure(
          data['message'] ?? 'Failed to update profile',
        );
      }

      return UserServiceResult.success(UserProfileModel.fromJson(data['data']));
    } catch (e) {
      return UserServiceResult.failure('Error connecting to server: $e');
    }
  }
}

class UserServiceResult {
  final bool isSuccess;
  final UserProfileModel? profile;
  final String? errorMessage;

  UserServiceResult._({
    required this.isSuccess,
    this.profile,
    this.errorMessage,
  });

  factory UserServiceResult.success(UserProfileModel profile) {
    return UserServiceResult._(isSuccess: true, profile: profile);
  }

  factory UserServiceResult.failure(String message) {
    return UserServiceResult._(isSuccess: false, errorMessage: message);
  }
}
