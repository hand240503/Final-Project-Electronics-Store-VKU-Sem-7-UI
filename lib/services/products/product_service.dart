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

  static Future<ProductDetailModel?> fetchProductDetail(int id) async {
    final response = await http.get(Uri.parse(ApiEndpoints.productDetail(id)));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProductDetailModel.fromJson(data);
    } else {
      print("Error: ${response.statusCode}");
      return null;
    }
  }

  /// Tìm kiếm sản phẩm
  static Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiEndpoints.baseUrl}${ApiEndpoints.searchProducts}?q=${Uri.encodeComponent(query)}',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        return results.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  /// Lấy danh sách reviews của sản phẩm
  static Future<Map<String, dynamic>> getProductReviews(int productId) async {
    try {
      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.getReviews(productId)}',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'product_id': data['product_id'],
          'product_name': data['product_name'],
          'average_rating': (data['average_rating'] ?? 0).toDouble(),
          'total_reviews': data['total_reviews'] ?? 0,
          'reviews': (data['reviews'] as List).map((json) => ReviewModel.fromJson(json)).toList(),
        };
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting reviews: $e');
    }
  }

  /// Tạo hoặc cập nhật rating/review cho sản phẩm
  static Future<Map<String, dynamic>> createOrUpdateRating({
    required int orderId,
    required int rating,
    String? comment,
  }) async {
    try {
      final token = await storage.read(key: 'access');

      if (token == null) {
        throw Exception('Bạn cần đăng nhập để đánh giá sản phẩm');
      }

      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.createRating(orderId)}',
      );

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'rating': rating,
              'comment': comment ?? '',
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Đánh giá thành công',
          'order_id': data['order_id'],
          'order_code': data['order_code'],
          'rating': data['rating'],
          'comment': data['comment'],
          'total_products_reviewed': data['total_products_reviewed'] ?? 0,
          'created': data['created'] ?? 0,
          'updated': data['updated'] ?? 0,
          'created_reviews': data['created_reviews'] ?? [],
          'updated_reviews': data['updated_reviews'] ?? [],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Có lỗi xảy ra khi đánh giá sản phẩm');
      }
    } catch (e) {
      throw Exception('Error creating rating: $e');
    }
  }

  /// Xóa review của người dùng
  static Future<Map<String, dynamic>> deleteReview(int reviewId) async {
    try {
      final token = await storage.read(key: 'access');

      if (token == null) {
        throw Exception('Bạn cần đăng nhập để xóa đánh giá');
      }

      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.deleteRating(reviewId)}',
      );

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Có lỗi xảy ra khi xóa đánh giá');
      }
    } catch (e) {
      throw Exception('Error deleting review: $e');
    }
  }
}
