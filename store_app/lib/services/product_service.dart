import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../utils/constants.dart';
import '../models/product_model.dart';
import 'session.dart';

class ProductService {
  static Future<ProductModel?> create(ProductModel product) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/products/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ProductModel.fromJson(data['data']);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<ProductModel>> getByStore(String storeId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/products/store/$storeId'),
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
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<ProductModel?> update(ProductModel product) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/products/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProductModel.fromJson(data['data']);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> delete(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/products/$productId'),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<ProductModel?> uploadImage({
    required String productId,
    required File imageFile,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.baseUrl}/products/$productId/image',
      );
      final request = http.MultipartRequest('POST', uri);

      if (Session.token != null) {
        request.headers['Authorization'] = 'Bearer ${Session.token}';
      }

      final extension = imageFile.path.split('.').last.toLowerCase();
      final mimeType =
          {
            'jpg': 'image/jpeg',
            'jpeg': 'image/jpeg',
            'png': 'image/png',
            'webp': 'image/webp',
            'heic': 'image/heic',
            'gif': 'image/gif',
          }[extension] ??
          'image/jpeg';

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);
      return ProductModel.fromJson(data['data']);
    } catch (e) {
      return null;
    }
  }
}
