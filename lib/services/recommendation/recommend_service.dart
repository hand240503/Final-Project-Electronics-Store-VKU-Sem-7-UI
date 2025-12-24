import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop/config/endpoints.dart';
import 'package:shop/models/product_model.dart';

class RecommendationService {
  /// Lấy danh sách sản phẩm phổ biến (Popular Products)
  ///
  /// Use case: Homepage, cold start, new users
  ///
  /// [limit] - Số lượng sản phẩm muốn lấy (mặc định: 10)
  ///
  /// Returns: List của ProductModel với các trường bổ sung:
  /// - rating_count: số lượng đánh giá
  /// - avg_rating: điểm trung bình
  /// - recommendation_score: điểm đề xuất
  static Future<List<ProductModel>> getPopularProducts({
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.recommendationsPopular}?limit=$limit',
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
        final results = data['results'] as List;
        return results.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load popular products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting popular products: $e');
    }
  }

  /// Lấy sản phẩm tương tự - Item-based Collaborative Filtering
  ///
  /// Use case:
  /// - Product detail page: "Sản phẩm tương tự"
  /// - "Khách hàng mua sản phẩm này cũng mua"
  ///
  /// Logic: Dựa trên behavior patterns của users
  /// - Nếu nhiều users cùng rate cao 2 products → 2 products tương tự
  ///
  /// [productId] - ID của sản phẩm gốc
  /// [limit] - Số lượng sản phẩm tương tự (mặc định: 10)
  ///
  /// Returns: Map với keys:
  /// - product_id: ID sản phẩm gốc
  /// - product_name: Tên sản phẩm gốc
  /// - count: Số lượng sản phẩm tương tự
  /// - algorithm: "item_based_collaborative_filtering"
  /// - results: List ProductModel (có thêm similarity_score)
  static Future<Map<String, dynamic>> getSimilarProducts({
    required int productId,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.similarProducts(productId)}?limit=$limit',
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

        // Parse products
        final results = data['results'] as List;
        final products = results.map((json) => ProductModel.fromJson(json)).toList();

        return {
          'product_id': data['product_id'],
          'product_name': data['product_name'],
          'count': data['count'],
          'algorithm': data['algorithm'],
          'results': products,
        };
      } else if (response.statusCode == 404) {
        throw Exception('Product not found');
      } else {
        throw Exception('Failed to load similar products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting similar products: $e');
    }
  }

  /// Smart Recommendations - Hybrid Approach (CF + Popular)
  ///
  /// Use case: Đảm bảo luôn có recommendations ngay cả khi CF không đủ data
  ///
  /// Logic:
  /// 1. Ưu tiên similar products (collaborative filtering)
  /// 2. Nếu không đủ, bổ sung popular products
  /// 3. Đảm bảo luôn trả về đủ số lượng
  ///
  /// [productId] - ID của sản phẩm gốc
  /// [limit] - Số lượng recommendations (mặc định: 10)
  ///
  /// Returns: Map với keys:
  /// - product_id: ID sản phẩm gốc
  /// - product_name: Tên sản phẩm gốc
  /// - strategy: "hybrid"
  /// - similar_count: Số sản phẩm từ CF
  /// - popular_count: Số sản phẩm từ popular
  /// - total: Tổng số sản phẩm
  /// - results: List ProductModel (có thêm similarity_score hoặc recommendation_score)
  static Future<Map<String, dynamic>> getProductRecommendations({
    required int productId,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.productRecommendations(productId)}?limit=$limit',
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

        // Parse products
        final results = data['results'] as List;
        final products = results.map((json) => ProductModel.fromJson(json)).toList();

        return {
          'product_id': data['product_id'],
          'product_name': data['product_name'],
          'strategy': data['strategy'],
          'similar_count': data['similar_count'],
          'popular_count': data['popular_count'],
          'total': data['total'],
          'results': products,
        };
      } else if (response.statusCode == 404) {
        throw Exception('Product not found');
      } else {
        throw Exception('Failed to load recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting recommendations: $e');
    }
  }

  /// Lấy thống kê về recommendation system
  ///
  /// Returns: Map với keys:
  /// - total_similarities: Tổng số similarities
  /// - avg_similarity: Điểm similarity trung bình
  /// - max_similarity: Điểm similarity cao nhất
  /// - total_products: Tổng số sản phẩm
  /// - products_with_similarities: Số sản phẩm có similarities
  /// - coverage: Phần trăm coverage
  static Future<Map<String, dynamic>> getRecommendationStats() async {
    try {
      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.recommendationStats}',
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
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting stats: $e');
    }
  }
}
