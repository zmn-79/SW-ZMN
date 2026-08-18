import 'dart:convert';

import 'package:customer_app/models/store_model.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class StoreService {
  Future<StoreModel> getStoreById(String storeId) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/users/$storeId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load store');
    }

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid store response');
    }

    return StoreModel.fromJson(data);
  }
}
