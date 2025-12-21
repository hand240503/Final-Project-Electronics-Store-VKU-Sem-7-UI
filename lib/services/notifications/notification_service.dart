// services/notification_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop/config/endpoints.dart';
import 'package:shop/models/notification_model.dart';

final storage = FlutterSecureStorage();

class NotificationService {
  /// Lấy token từ storage
  static Future<String?> _getToken() async {
    return await storage.read(key: 'access');
  }

  /// Lấy headers với token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Lấy danh sách tất cả notifications
  static Future<List<NotificationModel>> fetchNotifications() async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.notifications}',
    );

    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> notificationsJson = data['notifications'] ?? [];
      return notificationsJson
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load notifications: ${response.statusCode}');
    }
  }

  /// Lấy danh sách notifications chưa đọc
  static Future<List<NotificationModel>> fetchUnreadNotifications() async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.notificationsUnread}',
    );

    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> notificationsJson = data['notifications'] ?? [];
      return notificationsJson
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load unread notifications: ${response.statusCode}');
    }
  }

  /// Lấy số lượng notifications chưa đọc
  static Future<int> fetchUnreadCount() async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.notificationsUnreadCount}',
    );

    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['unread_count'] as int;
    } else {
      throw Exception('Failed to load unread count: ${response.statusCode}');
    }
  }

  /// Đánh dấu một notification đã đọc
  static Future<NotificationModel> markAsRead(int notificationId) async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.notificationMarkRead(notificationId)}',
    );

    final headers = await _getHeaders();
    final response = await http.post(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return NotificationModel.fromJson(data['notification']);
    } else {
      throw Exception('Failed to mark as read: ${response.statusCode}');
    }
  }

  /// Đánh dấu tất cả notifications đã đọc
  static Future<bool> markAllAsRead() async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.notificationsMarkAllRead}',
    );

    final headers = await _getHeaders();
    final response = await http.post(url, headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to mark all as read: ${response.statusCode}');
    }
  }

  /// Xóa một notification
  static Future<bool> deleteNotification(int notificationId) async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.deleteNotification(notificationId)}',
    );

    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 204 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete notification: ${response.statusCode}');
    }
  }

  /// Xóa tất cả notifications đã đọc
  static Future<int> deleteReadNotifications() async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.notificationsDeleteRead}',
    );

    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['deleted_count'] as int;
    } else {
      throw Exception('Failed to delete read notifications: ${response.statusCode}');
    }
  }

  /// Lấy chi tiết một notification (nếu cần)
  static Future<NotificationModel?> fetchNotificationDetail(int id) async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.notificationDetail(id)}',
    );

    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return NotificationModel.fromJson(data);
    } else {
      print("Error: ${response.statusCode}");
      return null;
    }
  }

  /// Xử lý khi click vào notification
  /// Đánh dấu đã đọc và trả về URL redirect
  static Future<String?> handleNotificationClick(NotificationModel notification) async {
    if (!notification.isRead) {
      try {
        await markAsRead(notification.id);
      } catch (e) {
        print('Error marking notification as read: $e');
      }
    }
    return notification.redirectUrl;
  }
}
