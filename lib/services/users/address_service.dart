import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:shop/config/endpoints.dart';
import 'package:shop/models/user_model.dart';

class AddressService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// ===============================
  /// Lấy access token từ storage
  /// ===============================
  static Future<String> _getAccessToken() async {
    final token = await _storage.read(key: 'access');
    if (token == null) {
      throw Exception("Access token not found");
    }
    return token;
  }

  /// ===============================
  /// GET: Danh sách address theo userId (admin / profile khác)
  /// ===============================
  static Future<List<UserAddress>> getAddressesByUserId({
    required int userId,
  }) async {
    final token = await _getAccessToken();

    final url = Uri.parse(
      ApiEndpoints.baseUrl + ApiEndpoints.addressesByUserId(userId),
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['addresses'];
      return list.map((e) => UserAddress.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception(
        'Failed to load addresses (${response.statusCode})',
      );
    }
  }

  /// ===============================
  /// GET: Address của user đang login
  /// ===============================
  static Future<List<UserAddress>> getMyAddresses() async {
    final token = await _getAccessToken();

    final url = Uri.parse(
      ApiEndpoints.baseUrl + ApiEndpoints.myAddresses,
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => UserAddress.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception(
        'Failed to load my addresses (${response.statusCode})',
      );
    }
  }

  /// ===============================
  /// POST: Thêm address mới
  /// ===============================
  static Future<UserAddress> addAddress(UserAddress address) async {
    final token = await _getAccessToken();

    final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.addAddress);

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(address.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      // Giả sử backend trả về {"data": {...}}
      return UserAddress.fromJson(data['data']);
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception(
        'Failed to add address (${response.statusCode}): ${response.body}',
      );
    }
  }

  /// ===============================
  /// PUT: Update address
  /// ===============================
  static Future<UserAddress> updateAddress({
    required UserAddress address,
  }) async {
    final token = await _getAccessToken();
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/api/accounts/addresses/${address.id}/update/',
    );

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(address.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserAddress.fromJson(data['data']);
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception(
        'Failed to update address (${response.statusCode}): ${response.body}',
      );
    }
  }

  /// ===============================
  /// DELETE: Xóa address
  /// ===============================
  static Future<void> deleteAddress({required int addressId}) async {
    final token = await _getAccessToken();
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/api/accounts/addresses/$addressId/delete/',
    );

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception(
        'Failed to delete address (${response.statusCode}): ${response.body}',
      );
    }
  }
}
