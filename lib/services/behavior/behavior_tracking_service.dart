import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop/config/endpoints.dart';

final storage = FlutterSecureStorage();

class BehaviorTrackingService {
  // ===================== EVENT TYPES =====================
  static const String eventDetails = 'details';
  static const String eventMoreDetails = 'moreDetails';
  static const String eventAddToCart = 'addToCart';
  static const String eventBuy = 'buy';

  // ===================== DEVICE TYPES =====================
  static const String deviceMobile = 'mobile';
  static const String deviceTablet = 'tablet';
  static const String deviceDesktop = 'desktop';

  // ===================== PLATFORMS =====================
  static const String platformAndroid = 'android';
  static const String platformIOS = 'ios';
  static const String platformWeb = 'web';

  // ===================== MAIN TRACKING METHOD =====================

  /// Track user behavior
  ///
  /// [productId] - ID sản phẩm
  /// [event] - Loại event: details, moreDetails, addToCart, buy
  /// [metadata] - Dữ liệu bổ sung (optional)
  static Future<Map<String, dynamic>?> trackBehavior({
    required int productId,
    required String event,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Get token
      final token = await storage.read(key: 'access');

      // Get or create session_id
      String? sessionId = await storage.read(key: 'session_id');
      if (sessionId == null) {
        sessionId = _generateSessionId();
        await storage.write(key: 'session_id', value: sessionId);
      }

      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.trackBehavior}',
      );

      final headers = {
        'Content-Type': 'application/json',
      };

      // Add auth token if available
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = {
        'product_id': productId,
        'event': event,
        'session_id': sessionId,
        'device_type': deviceMobile,
        'platform': _getPlatform(),
        if (metadata != null) 'metadata': metadata,
      };

      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout'),
          );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print(
            '✅ Behavior tracked: ${data['data']['event']} on product ${data['data']['product_name']}');
        return data;
      } else {
        print('❌ Error tracking behavior: ${response.statusCode}');
        print('   Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception tracking behavior: $e');
      return null;
    }
  }

  // ===================== CONVENIENCE METHODS =====================

  /// Track khi user xem chi tiết sản phẩm
  /// Gọi method này trong initState() của ProductDetailScreen
  static Future<void> trackViewDetails(int productId) async {
    await trackBehavior(
      productId: productId,
      event: eventDetails,
    );
  }

  /// Track khi user xem chi tiết mở rộng
  /// Gọi khi user scroll xuống phần mô tả, xem thêm ảnh, v.v.
  static Future<void> trackViewMoreDetails(int productId) async {
    await trackBehavior(
      productId: productId,
      event: eventMoreDetails,
    );
  }

  /// Track khi user thêm sản phẩm vào giỏ hàng
  ///
  /// Example:
  /// ```dart
  /// await BehaviorTrackingService.trackAddToCart(
  ///   productId: productId,
  ///   variantId: variantId,
  ///   quantity: 1,
  ///   price: 1000000,
  /// );
  /// ```
  static Future<void> trackAddToCart({
    required int productId,
    int? variantId,
    int? quantity,
    double? price,
  }) async {
    final metadata = <String, dynamic>{};
    if (variantId != null) metadata['variant_id'] = variantId;
    if (quantity != null) metadata['quantity'] = quantity;
    if (price != null) metadata['price'] = price;

    await trackBehavior(
      productId: productId,
      event: eventAddToCart,
      metadata: metadata.isNotEmpty ? metadata : null,
    );
  }

  /// Track khi user mua sản phẩm
  /// Gọi method này sau khi thanh toán thành công
  ///
  /// Example:
  /// ```dart
  /// await BehaviorTrackingService.trackBuy(
  ///   productId: productId,
  ///   variantId: variantId,
  ///   quantity: 2,
  ///   price: 2000000,
  ///   orderId: 'ORDER_123',
  /// );
  /// ```
  static Future<void> trackBuy({
    required int productId,
    int? variantId,
    int? quantity,
    double? price,
    String? orderId,
  }) async {
    final metadata = <String, dynamic>{};
    if (variantId != null) metadata['variant_id'] = variantId;
    if (quantity != null) metadata['quantity'] = quantity;
    if (price != null) metadata['price'] = price;
    if (orderId != null) metadata['order_id'] = orderId;

    await trackBehavior(
      productId: productId,
      event: eventBuy,
      metadata: metadata.isNotEmpty ? metadata : null,
    );
  }

  // ===================== ANALYTICS METHODS =====================

  /// Lấy lịch sử tương tác của user
  /// Yêu cầu user phải đăng nhập
  static Future<List<Map<String, dynamic>>?> getUserInteractions({
    int limit = 50,
  }) async {
    try {
      final token = await storage.read(key: 'access');

      if (token == null || token.isEmpty) {
        print('⚠️  User not logged in. Cannot get interactions.');
        return null;
      }

      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.userInteractions}?limit=$limit',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> interactions = data['interactions'] ?? [];
        return interactions.map((e) => e as Map<String, dynamic>).toList();
      } else {
        print('❌ Error getting interactions: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Exception getting interactions: $e');
      return null;
    }
  }

  /// Lấy thống kê tương tác của sản phẩm
  /// Public API - không cần đăng nhập
  static Future<Map<String, dynamic>?> getProductInteractions(
    int productId, {
    String? event,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.productInteractions(productId, event: event)}',
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('❌ Error getting product interactions: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Exception getting product interactions: $e');
      return null;
    }
  }

  /// Lấy danh sách sản phẩm trending
  /// Public API - không cần đăng nhập
  static Future<List<Map<String, dynamic>>?> getTrendingProducts({
    int days = 7,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.trendingProducts(days: days, limit: limit)}',
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> products = data['trending_products'] ?? [];
        return products.map((e) => e as Map<String, dynamic>).toList();
      } else {
        print('❌ Error getting trending products: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Exception getting trending products: $e');
      return null;
    }
  }

  // ===================== HELPER METHODS =====================

  /// Generate unique session ID
  static String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _randomString(8);
    return 'flutter_${timestamp}_$random';
  }

  /// Generate random string
  static String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      length,
      (index) => chars[(random + index) % chars.length],
    ).join();
  }

  /// Get current platform
  static String _getPlatform() {
    if (Platform.isAndroid) {
      return platformAndroid;
    } else if (Platform.isIOS) {
      return platformIOS;
    } else {
      return platformWeb;
    }
  }

  // ===================== BATCH TRACKING =====================

  /// Track multiple products at once (for checkout)
  ///
  /// Example:
  /// ```dart
  /// await BehaviorTrackingService.trackBuyBatch(
  ///   products: [
  ///     {'product_id': 1, 'quantity': 2, 'price': 1000000},
  ///     {'product_id': 2, 'quantity': 1, 'price': 500000},
  ///   ],
  ///   orderId: 'ORDER_123',
  /// );
  /// ```
  static Future<void> trackBuyBatch({
    required List<Map<String, dynamic>> products,
    String? orderId,
  }) async {
    for (var product in products) {
      await trackBuy(
        productId: product['product_id'] as int,
        variantId: product['variant_id'] as int?,
        quantity: product['quantity'] as int?,
        price: product['price'] as double?,
        orderId: orderId,
      );
    }

    print('✅ Tracked purchase for ${products.length} products');
  }
}
