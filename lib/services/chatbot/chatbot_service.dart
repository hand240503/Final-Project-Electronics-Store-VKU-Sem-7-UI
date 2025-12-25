import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop/config/endpoints.dart';
import 'package:shop/models/chabot_model.dart';

class ChatbotService {
  /// Gửi tin nhắn tới chatbot AI
  static Future<ChatResponse> sendMessage(String message) async {
    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.chatWithAI}');

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

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data['success'] == true) {
          return ChatResponse(
            success: true,
            message: data['response'],
            timestamp: data['timestamp'],
            metadata: data['metadata'],
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
