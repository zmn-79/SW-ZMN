import 'dart:convert';

import '../../models/cart_model.dart';
import '../services/session.dart';
import '../utils/constants.dart';
import 'package:http/http.dart' as http;

class CartService {
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
  };

  static Future<CartModel?> getCart() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/cart'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        return null;
      }

      return CartModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      return null;
    }
  }

  static Future<CartServiceResult> addItem({
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/cart/items'),
        headers: _headers,
        body: jsonEncode({'productId': productId, 'quantity': quantity}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        return CartServiceResult.failure(
          data['message'] ?? 'Failed to add item to cart',
        );
      }

      return CartServiceResult.success(
        cart: CartModel.fromJson(data['data']),
        stockWarning: data['stockWarning'] == true,
        availableQuantity: data['availableQuantity'],
      );
    } catch (e) {
      return CartServiceResult.failure('Error connecting to server: $e');
    }
  }

  static Future<CartModel?> updateItemQuantity({
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/cart/items/$productId'),
        headers: _headers,
        body: jsonEncode({'quantity': quantity}),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);
      return CartModel.fromJson(data['data']);
    } catch (e) {
      return null;
    }
  }

  static Future<CartModel?> removeItem(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/cart/items/$productId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);
      return CartModel.fromJson(data['data']);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> clearCart() async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/cart'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class CartServiceResult {
  final bool isSuccess;
  final CartModel? cart;
  final bool stockWarning;
  final int? availableQuantity;
  final String? errorMessage;

  CartServiceResult._({
    required this.isSuccess,
    this.cart,
    this.stockWarning = false,
    this.availableQuantity,
    this.errorMessage,
  });

  factory CartServiceResult.success({
    required CartModel cart,
    bool stockWarning = false,
    int? availableQuantity,
  }) {
    return CartServiceResult._(
      isSuccess: true,
      cart: cart,
      stockWarning: stockWarning,
      availableQuantity: availableQuantity,
    );
  }

  factory CartServiceResult.failure(String message) {
    return CartServiceResult._(isSuccess: false, errorMessage: message);
  }
}
