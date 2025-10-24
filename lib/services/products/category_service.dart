import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop/config/endpoints.dart';

class CategoryService {
  final FlutterSecureStorage storage;

  CategoryService({required this.storage});

  /// Lấy danh sách category parent từ API (kèm subCategories đầy đủ)
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}/api/products/categories-parents/');
      final accessToken = await storage.read(key: 'access');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((parent) {
          return {
            'id': parent['id'],
            'title': parent['name'],
            'slug': parent['slug'],
            'svgSrc': parent['svgSrc'],
            'subCategories': (parent['subCategories'] as List<dynamic>).map((sub) {
              return {
                'id': sub['id'],
                'title': sub['name'],
                'slug': sub['slug'],
                'svgSrc': sub['svgSrc'],
              };
            }).toList(),
          };
        }).toList();
      } else {
        print('Lỗi khi lấy category parents: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Lỗi khi tải category: $e');
      return [];
    }
  }
}
