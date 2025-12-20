import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop/config/endpoints.dart';
import 'package:shop/services/auth/auth_service.dart';

class CartService {
  final FlutterSecureStorage storage;
  final AuthService authService;

  CartService({required this.storage}) : authService = AuthService(storage: storage);

  /// ================= ADD TO CART =================
  Future<Map<String, dynamic>?> addToCart({
    required int productId,
    int? variantId,
    int quantity = 1,
  }) async {
    final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.addToCart);
    return await _postWithTokenRetry(url, {
      'product_id': productId,
      if (variantId != null) 'variant_id': variantId,
      'quantity': quantity,
    });
  }

  /// ================= GET CART =================
  Future<Map<String, dynamic>?> getCartByUserId(int userId) async {
    final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.cartByUserId(userId));
    return await _getWithTokenRetry(url);
  }

  /// ================= UPDATE CART ITEM =================
  Future<Map<String, dynamic>?> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.updateCartItem(cartItemId));
    return await _postWithTokenRetry(url, {'quantity': quantity});
  }

  /// ================= DELETE CART ITEM =================
  Future<Map<String, dynamic>?> deleteCartItem({required int cartItemId}) async {
    final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.deleteCartItem(cartItemId));
    return await _deleteWithTokenRetry(url);
  }

  /// ================= CHECKOUT =================
  // Future<Map<String, dynamic>?> checkout({
  //   required Map<String, dynamic> address,
  // }) async {
  //   final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.checkout);
  //   return await _postWithTokenRetry(url, {'address': address});
  // }

  /// ================= PRIVATE METHODS =================
  Future<Map<String, dynamic>?> _postWithTokenRetry(Uri url, Map<String, dynamic> body) async {
    String? accessToken = await storage.read(key: 'access');

    http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    // Nếu token hết hạn, refresh và thử lại
    if (response.statusCode == 401) {
      await authService.refreshToken();
      accessToken = await storage.read(key: 'access');

      response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    return null;
  }

  Future<Map<String, dynamic>?> _getWithTokenRetry(Uri url) async {
    String? accessToken = await storage.read(key: 'access');

    http.Response response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
    );

    // Nếu token hết hạn, refresh và thử lại
    if (response.statusCode == 401) {
      await authService.refreshToken();
      accessToken = await storage.read(key: 'access');

      response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  Future<Map<String, dynamic>?> _deleteWithTokenRetry(Uri url) async {
    String? accessToken = await storage.read(key: 'access');

    http.Response response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
    );

    // Nếu token hết hạn, refresh và thử lại
    if (response.statusCode == 401) {
      await authService.refreshToken();
      accessToken = await storage.read(key: 'access');

      response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );
    }

    if (response.statusCode == 200 || response.statusCode == 204) {
      // DELETE thành công có thể trả về 200 hoặc 204 (No Content)
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {'success': true};
    }

    return null;
  }
}
