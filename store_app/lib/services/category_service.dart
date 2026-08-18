import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/category_model.dart';

class CategoryService {
  static Future<CategoryModel?> create({
    required String storeId,
    required String category,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/categories/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'storeId': storeId, 'category': category}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CategoryModel.fromJson(data['data']);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<CategoryModel>> getByStore(String storeId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/categories/store/$storeId'),
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
          .map((item) => CategoryModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
