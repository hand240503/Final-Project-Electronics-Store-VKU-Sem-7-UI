import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop/config/endpoints.dart';

class ProfileService {
  final FlutterSecureStorage storage;

  ProfileService({required this.storage});

  /// =================== GET PROFILE ===================
  /// GET /api/accounts/profile/
  Future<Map<String, dynamic>?> getProfile() async {
    final accessToken = await storage.read(key: 'access');
    if (accessToken == null) return null;

    final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.profileDetail);

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final profile = jsonDecode(response.body);

      /// Cache lại profile
      await storage.write(
        key: 'profile',
        value: jsonEncode(profile),
      );

      return profile;
    }

    return null;
  }

  /// =================== UPDATE PROFILE ===================
  /// PUT /api/accounts/profile/update/
  Future<bool> updateProfile({
    String? name,
    String? bio,
    String? gender,
    DateTime? birthday,
    String? personalInfo,
    String? phone,
    String? email,
    String? avatar,
  }) async {
    final accessToken = await storage.read(key: 'access');
    if (accessToken == null) return false;

    final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.profileUpdate);

    final Map<String, dynamic> body = {};

    if (name != null) body['name'] = name;
    if (bio != null) body['bio'] = bio;
    if (gender != null) body['gender'] = gender;
    if (birthday != null) {
      body['birthday'] = birthday.toIso8601String().split('T')[0];
    }
    if (personalInfo != null) body['personal_info'] = personalInfo;
    if (phone != null) body['phone'] = phone;
    if (email != null) body['email'] = email;
    if (avatar != null) body['avatar'] = avatar;

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      /// Update cache profile
      if (data['profile'] != null) {
        await storage.write(
          key: 'profile',
          value: jsonEncode(data['profile']),
        );
      }

      return true;
    }

    return false;
  }

  /// =================== GET CACHED PROFILE ===================
  Future<Map<String, dynamic>?> getCachedProfile() async {
    final profileString = await storage.read(key: 'profile');
    if (profileString == null) return null;
    return jsonDecode(profileString);
  }

  /// =================== CLEAR PROFILE ===================
  Future<void> clearProfile() async {
    await storage.delete(key: 'profile');
  }
}
