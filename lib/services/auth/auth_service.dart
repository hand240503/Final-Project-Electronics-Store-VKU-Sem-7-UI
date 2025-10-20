import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop/config/endpoints.dart';

class AuthService {
  final FlutterSecureStorage storage;

  AuthService({required this.storage});

  /// =================== LOGIN / LOGOUT ===================
  Future<bool> login(String username, String password) async {
    final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.login);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access', value: data['access']);
      await storage.write(key: 'refresh', value: data['refresh']);
      return true;
    } else {
      return false;
    }
  }

  Future<void> refreshToken() async {
    final refreshToken = await storage.read(key: 'refresh');
    final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.refreshToken);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access', value: data['access']);
    } else {
      await logout();
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'access');
    await storage.delete(key: 'refresh');
  }

  Future<String?> getAccessToken() async => await storage.read(key: 'access');

  /// =================== OTP ===================

  /// Gửi OTP để xác thực
  Future<bool> verifyRegistrationOtp(String otp) async {
    final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.verifyOtp);

    // Nếu backend yêu cầu token tạm, dùng storage hoặc bỏ qua nếu chưa có
    final accessToken = await storage.read(key: 'access');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'otp': otp}),
    );

    return response.statusCode == 200;
  }

  /// Gửi yêu cầu resend OTP trong quá trình đăng ký
  Future<bool> resendRegistrationOtp() async {
    final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.resendOtp);
    final accessToken = await storage.read(key: 'access');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
    );

    return response.statusCode == 200;
  }
}
