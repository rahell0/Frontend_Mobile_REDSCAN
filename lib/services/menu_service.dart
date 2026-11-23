
import 'dart:convert';
import 'package:http/http.dart' as http;

class MenuService {
  static const String baseUrl = 'http://localhost:5000/api';

  // ALAMAT SERVER BACKEND TANPA /api
  static String get serverUrl {
    return Uri.parse(baseUrl).origin;
  }

  // MENGUBAH PATH GAMBAR MENJADI URL LENGKAP
  static String? getImageUrl(dynamic gambar) {
    if (gambar == null) {
      return null;
    }

    final String path = gambar.toString().trim();

    if (path.isEmpty) {
      return null;
    }

    // Jika sudah berupa URL lengkap
    if (path.startsWith('http://') ||
        path.startsWith('https://')) {
      return path;
    }

    // Jika berupa path dari backend, misalnya:
    // /uploads/menu-123.jpg
    if (path.startsWith('/')) {
      return '$serverUrl$path';
    }

    return '$serverUrl/$path';
  }

  // MENGAMBIL MENU DARI BACKEND
  static Future<List<Map<String, dynamic>>> getMenu() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/menu'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Server error: ${response.statusCode}',
        );
      }

      final result = jsonDecode(response.body);

      if (result['success'] != true) {
        throw Exception(
          result['message'] ?? 'Gagal mengambil menu',
        );
      }

      final List data = result['data'];

      return data.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();
    } catch (e) {
      throw Exception(
        'Gagal mengambil data menu: $e',
      );
    }
  }
}
