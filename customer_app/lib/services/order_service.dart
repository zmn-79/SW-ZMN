import 'dart:convert';

import '../../models/order_model.dart';
import '../services/session.dart';
import '../utils/constants.dart';
import 'package:http/http.dart' as http;

class OrderService {
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
  };

  static Future<CheckoutResult> checkout() async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/orders/checkout'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 409 && data['code'] == 'INSUFFICIENT_STOCK') {
        return CheckoutResult.stockIssue(
          message: data['message'] ?? 'Some items are no longer available',
          issues: data['issues'] ?? [],
        );
      }

      if (response.statusCode != 201) {
        return CheckoutResult.failure(data['message'] ?? 'Checkout failed');
      }

      final orders =
          (data['data'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map((item) => OrderModel.fromJson(item))
              .toList();

      return CheckoutResult.success(orders);
    } catch (e) {
      return CheckoutResult.failure('Error connecting to server: $e');
    }
  }

  static Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/orders/my-orders'),
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
}

class CheckoutResult {
  final bool isSuccess;
  final List<OrderModel> orders;
  final bool hasStockIssue;
  final List<dynamic> stockIssues;
  final String? errorMessage;

  CheckoutResult._({
    required this.isSuccess,
    this.orders = const [],
    this.hasStockIssue = false,
    this.stockIssues = const [],
    this.errorMessage,
  });

  factory CheckoutResult.success(List<OrderModel> orders) {
    return CheckoutResult._(isSuccess: true, orders: orders);
  }

  factory CheckoutResult.failure(String message) {
    return CheckoutResult._(isSuccess: false, errorMessage: message);
  }

  factory CheckoutResult.stockIssue({
    required String message,
    required List<dynamic> issues,
  }) {
    return CheckoutResult._(
      isSuccess: false,
      hasStockIssue: true,
      stockIssues: issues,
      errorMessage: message,
    );
  }
}
