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
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];

      // 🔐 TOKEN
      await storage.write(key: 'access', value: data['access']);
      await storage.write(key: 'refresh', value: data['refresh']);

      // 👤 USER INFO
      await storage.write(key: 'user_id', value: user['id'].toString());
      await storage.write(key: 'username', value: user['username']);
      await storage.write(key: 'email', value: user['email']);
      await storage.write(key: 'first_name', value: user['first_name']);
      await storage.write(key: 'is_active', value: user['is_active'].toString());

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

  Future<bool> register(String email, String password) async {
    final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.register);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      // Lưu token ngay khi đăng ký thành công
      final data = jsonDecode(response.body);
      await storage.write(key: 'access', value: data['access']);
      await storage.write(key: 'refresh', value: data['refresh']);
      return true;
    } else {
      return false;
    }
  }

  /// =================== OTP ===================

  /// Gửi OTP để xác thực
  Future<bool> verifyRegistrationOtp(String email, String otp) async {
    final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.verifyOtp);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Lưu token sau khi xác thực thành công
      await storage.write(key: 'access', value: data['access']);
      await storage.write(key: 'refresh', value: data['refresh']);

      return true;
    }
    return false;
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
