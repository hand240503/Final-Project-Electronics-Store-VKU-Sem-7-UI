// order_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shop/config/endpoints.dart';

final storage = FlutterSecureStorage();

class OrderService {
  // Tạo đơn hàng
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

  // Lấy danh sách orders của user
  static Future<Map<String, dynamic>> getOrdersByUser(int userId) async {
    try {
      String? token = await storage.read(key: 'access');
      if (token == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.ordersByUser(userId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['detail'] ?? 'Failed to fetch orders'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getOrderDetail(int orderId) async {
    try {
      String? token = await storage.read(key: 'access');
      if (token == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.orderDetail(orderId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['detail'] ?? 'Failed to fetch order detail'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    try {
      String? token = await storage.read(key: 'access');
      if (token == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.cancelOrder(orderId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['detail'] ?? 'Failed to cancel order'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> returnOrder(int orderId) async {
    try {
      String? token = await storage.read(key: 'access');
      if (token == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.returnOrder(orderId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

  // Hủy yêu cầu trả hàng (status = 4 -> 3)
  static Future<Map<String, dynamic>> cancelReturnRequest(int orderId) async {
    try {
      String? token = await storage.read(key: 'access');
      if (token == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.cancelReturnRequest(orderId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

  static Future<Map<String, dynamic>> getProcessedReturnOrders(int userId) async {
    try {
      String? token = await storage.read(key: 'access');
      if (token == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.orderProcess(userId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 403) {
        return {'success': false, 'message': 'Permission denied'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'User not found'};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch processed return orders'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }
}
