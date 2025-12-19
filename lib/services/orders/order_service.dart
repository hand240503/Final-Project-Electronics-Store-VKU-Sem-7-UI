// order_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shop/config/endpoints.dart';

final storage = FlutterSecureStorage();

class OrderService {
  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderPayload) async {
    try {
      String? token = await storage.read(key: 'access');
      if (token == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.addOrder),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderPayload),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['detail'] ?? 'Failed to create order'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
