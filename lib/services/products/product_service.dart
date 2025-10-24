import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop/config/endpoints.dart';
import 'package:shop/models/product_model.dart';

final storage = FlutterSecureStorage();

class ProductService {
  /// Lấy sản phẩm theo parent category hoặc type
  /// [parentCategoryId] = 0 nếu muốn lấy all popular/sale/best_seller
  /// [type] có thể là 'popular', 'sale', 'best_seller'
  static Future<List<ProductModel>> fetchProducts({
    int parentCategoryId = 0,
    String? type,
  }) async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.productsByCategoryParentId(parentCategoryId, type: type)}',
    );

    final token = await storage.read(key: 'access');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> productsJson = data['products'] ?? [];
      return productsJson.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
}
