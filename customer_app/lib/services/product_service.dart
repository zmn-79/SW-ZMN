import 'dart:convert';

import '../../models/product_model.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class PaginatedProducts {
  final List<ProductModel> products;
  final int page;
  final int totalPages;
  final bool hasMore;

  PaginatedProducts({
    required this.products,
    required this.page,
    required this.totalPages,
    required this.hasMore,
  });

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List<dynamic>? ?? [];

    return PaginatedProducts(
      products:
          rawProducts
              .whereType<Map<String, dynamic>>()
              .map(ProductModel.fromJson)
              .toList(),
      page: json['page'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      hasMore: json['hasMore'] == true,
    );
  }

  factory PaginatedProducts.empty() {
    return PaginatedProducts(
      products: [],
      page: 1,
      totalPages: 1,
      hasMore: false,
    );
  }
}

class ProductService {
  Future<PaginatedProducts> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final uri = Uri.parse(
      '${AppConstants.baseUrl}/products',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid products response');
    }

    return PaginatedProducts.fromJson(data);
  }

  Future<List<ProductModel>> getProductsByStore(String storeId) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/products/store/$storeId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load store products');
    }

    final data = jsonDecode(response.body);

    if (data is! List) {
      throw Exception('Invalid store products response');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
  }
}
