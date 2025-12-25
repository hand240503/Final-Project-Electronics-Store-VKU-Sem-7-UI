import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/config/endpoints.dart';

/// Model cho response từ chatbot
class ChatResponse {
  final bool success;
  final String message;
  final String? timestamp;
  final Map<String, dynamic>? metadata;

  ChatResponse({
    required this.success,
    required this.message,
    this.timestamp,
    this.metadata,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      success: json['success'] ?? false,
      message: json['response'] ?? json['message'] ?? '',
      timestamp: json['timestamp'],
      metadata: json['metadata'] as Map<String, dynamic>?, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'timestamp': timestamp,
      'metadata': metadata,
    };
  }
}

/// Model cho lịch sử chat
class ChatHistoryItem {
  final int id;
  final String message;
  final String response;
  final DateTime timestamp;
  final bool isUser;

  ChatHistoryItem({
    required this.id,
    required this.message,
    required this.response,
    required this.timestamp,
    required this.isUser,
  });

  factory ChatHistoryItem.fromJson(Map<String, dynamic> json) {
    return ChatHistoryItem(
      id: json['id'],
      message: json['message'] ?? '',
      response: json['response'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      isUser: json['is_user'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'response': response,
      'timestamp': timestamp.toIso8601String(),
      'is_user': isUser,
    };
  }
}

/// Custom exception cho chatbot
class ChatbotException implements Exception {
  final String message;
  final String code;

  ChatbotException(this.message, this.code);

  @override
  String toString() => message;

  /// Lấy user-friendly error message
  String getUserFriendlyMessage() {
    switch (code) {
      case 'TIMEOUT':
        return 'Yêu cầu quá hạn. Vui lòng thử lại.';
      case 'NETWORK_ERROR':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối của bạn.';
      case 'SERVER_ERROR':
        return 'Lỗi máy chủ. Vui lòng thử lại sau.';
      case 'API_ERROR':
        return 'Có lỗi xảy ra. Vui lòng thử lại.';
      default:
        return message;
    }
  }
}

class ChatbotService {
  /// Gửi tin nhắn tới chatbot AI
  static Future<ChatResponse> sendMessage(String message) async {
    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.chatWithAI}');

      debugPrint('🌐 Sending to: $url');
      debugPrint('🌐 Message: $message');

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'message': message,
        }),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ChatbotException('Request timeout', 'TIMEOUT');
        },
      );

      debugPrint('🌐 Response status: ${response.statusCode}');
      debugPrint('🌐 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        debugPrint('🌐 Parsed data: $data');
        debugPrint('🌐 Success: ${data['success']}');
        debugPrint('🌐 Has metadata: ${data['metadata'] != null}');
        debugPrint('🌐 Metadata: ${data['metadata']}');

        if (data['success'] == true) {
          return ChatResponse(
            success: true,
            message: data['response'],
            timestamp: data['timestamp'],
            metadata: data['metadata'], // ✅ Pass metadata
          );
        } else {
          throw ChatbotException(
            data['error'] ?? 'Unknown error',
            'API_ERROR',
          );
        }
      } else if (response.statusCode == 408) {
        throw ChatbotException('Request timeout', 'TIMEOUT');
      } else if (response.statusCode >= 500) {
        throw ChatbotException(
          'Server error. Please try again later.',
          'SERVER_ERROR',
        );
      } else {
        throw ChatbotException(
          'HTTP ${response.statusCode}: ${response.body}',
          'HTTP_ERROR',
        );
      }
    } catch (e) {
      debugPrint('❌ ChatbotService error: $e');
      if (e is ChatbotException) {
        rethrow;
      }
      throw ChatbotException(
        'Connection error: ${e.toString()}',
        'NETWORK_ERROR',
      );
    }
  }

  /// Health check cho chatbot service
  static Future<bool> healthCheck() async {
    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.chatHealthCheck}');

      final response = await http.get(url).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Lấy lịch sử chat (nếu backend có implement)
  static Future<List<ChatHistoryItem>> getChatHistory() async {
    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.chatHistory}');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Thêm auth token nếu cần
          // 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> historyData = data['history'] ?? [];

        return historyData.map((item) => ChatHistoryItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      throw ChatbotException(
        'Failed to load chat history: ${e.toString()}',
        'HISTORY_ERROR',
      );
    }
  }

  /// Xóa lịch sử chat
  static Future<bool> clearChatHistory() async {
    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.chatClearHistory}');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Thêm auth token nếu cần
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Lưu conversation
  static Future<bool> saveConversation(List<Map<String, dynamic>> messages) async {
    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.chatSaveConversation}');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              // Thêm auth token nếu cần
            },
            body: jsonEncode({
              'messages': messages,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
