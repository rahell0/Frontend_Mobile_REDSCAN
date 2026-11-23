
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class PemesananService {
  static String get baseUrl => ApiService.baseUrl;

  // Menyimpan pesanan baru
  static Future<Map<String, dynamic>> simpanPemesanan({
    required String namaPelanggan,
    required String nomorHp,
    required String metodePembayaran,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/pemesanan'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'nama_pelanggan': namaPelanggan,
              'nomor_hp': nomorHp,
              'metode_pembayaran': metodePembayaran,
              'items': items,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final hasil = jsonDecode(response.body);

      if (response.statusCode == 201 && hasil['success'] == true) {
        return Map<String, dynamic>.from(hasil['data']);
      }

      throw Exception(
        hasil['message'] ?? 'Gagal menyimpan pesanan.',
      );
    } catch (e) {
      throw Exception('Gagal mengirim pesanan: $e');
    }
  }

  // Membuat transaksi Midtrans Snap Checkout
  static Future<Map<String, dynamic>> buatPembayaranMidtrans({
    required String kodePesanan,
  }) async {
    try {
      final kode = Uri.encodeComponent(kodePesanan);

      final response = await http
          .post(
            Uri.parse('$baseUrl/pembayaran/$kode/midtrans'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      final hasil = jsonDecode(response.body);

      if (response.statusCode == 200 && hasil['success'] == true) {
        final data = hasil['data'] is Map
            ? Map<String, dynamic>.from(hasil['data'])
            : Map<String, dynamic>.from(hasil);

        return data;
      }

      throw Exception(
        hasil['message'] ?? 'Gagal membuat pembayaran Midtrans.',
      );
    } catch (e) {
      throw Exception('Gagal membuat pembayaran: $e');
    }
  }

  // Memeriksa status pembayaran
  static Future<String> cekStatusPembayaran({
    required String kodePesanan,
  }) async {
    try {
      final kode = Uri.encodeComponent(kodePesanan);

      final response = await http
          .get(
            Uri.parse('$baseUrl/pembayaran/$kode/status'),
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 20));

      final hasil = jsonDecode(response.body);

      if (response.statusCode == 200 && hasil['success'] == true) {
        final data = hasil['data'] is Map
            ? Map<String, dynamic>.from(hasil['data'])
            : Map<String, dynamic>.from(hasil);

        return (data['status_pembayaran'] ?? 'belum_bayar')
            .toString()
            .toLowerCase();
      }

      throw Exception(
        hasil['message'] ?? 'Gagal memeriksa status pembayaran.',
      );
    } catch (e) {
      throw Exception('Gagal memeriksa pembayaran: $e');
    }
  }

  // Mengambil riwayat pesanan berdasarkan nomor HP
  static Future<List<dynamic>> ambilRiwayatPemesanan({
    required String nomorHp,
  }) async {
    try {
      final nomorBersih = nomorHp.replaceAll(RegExp(r'[^0-9]'), '');

      final response = await http
          .get(
            Uri.parse('$baseUrl/pemesanan/riwayat/$nomorBersih'),
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 20));

      final hasil = jsonDecode(response.body);

      if (response.statusCode == 200 && hasil['success'] == true) {
        return List<dynamic>.from(hasil['data']);
      }

      throw Exception(
        hasil['message'] ?? 'Gagal mengambil riwayat pesanan.',
      );
    } catch (e) {
      throw Exception('Gagal mengambil riwayat: $e');
    }
  }
}
