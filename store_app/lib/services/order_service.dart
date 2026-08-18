import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/order_model.dart';
import 'session.dart';

class OrderService {
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
  };

  static Future<List<OrderModel>> getStoreOrders() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/orders/store-orders'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(response.body);

      if (data is! List) {
        return [];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map((item) => OrderModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<OrderModel?> updateStatus({
    required String orderId,
    required OrderStatus newStatus,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/orders/$orderId/status'),
        headers: _headers,
        body: jsonEncode({'status': newStatus.apiValue}),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);
      return OrderModel.fromJson(data['data']);
    } catch (e) {
      return null;
    }
  }
}
