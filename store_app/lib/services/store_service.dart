import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/store_model.dart';
import 'session.dart';

class StoreService {
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
  };

  static Future<StoreModel?> getMyStore() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/stores/me'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        return null;
      }

      return StoreModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      return null;
    }
  }

  static Future<StoreServiceResult> updateMyStore(StoreModel store) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/stores/me'),
        headers: _headers,
        body: jsonEncode(store.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        return StoreServiceResult.failure(
          data['message'] ?? 'Failed to update store',
        );
      }

      return StoreServiceResult.success(StoreModel.fromJson(data['data']));
    } catch (e) {
      return StoreServiceResult.failure('Error connecting to server: $e');
    }
  }
}

class StoreServiceResult {
  final bool isSuccess;
  final StoreModel? store;
  final String? errorMessage;

  StoreServiceResult._({
    required this.isSuccess,
    this.store,
    this.errorMessage,
  });

  factory StoreServiceResult.success(StoreModel store) {
    return StoreServiceResult._(isSuccess: true, store: store);
  }

  factory StoreServiceResult.failure(String message) {
    return StoreServiceResult._(isSuccess: false, errorMessage: message);
  }
}
