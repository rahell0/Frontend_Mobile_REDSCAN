import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'menu_service.dart';

class AiService {
  // Mengirim pesan ke backend dan menerima jawaban secara streaming.
  static Stream<String> kirimPesan({
    required List<Map<String, String>> messages,
  }) async* {
    final url = Uri.parse(
      '${MenuService.baseUrl}/ai/chat',
    );

    final client = http.Client();

    debugPrint('========== REDSCAN AI ==========');
    debugPrint('Mengirim pesan ke: $url');
    debugPrint('Jumlah pesan: ${messages.length}');

    try {
      final request = http.Request('POST', url);

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/x-ndjson',
      });

      request.body = jsonEncode({
        'messages': messages,
      });

      // Mengirim request ke backend.
      final response = await client
          .send(request)
          .timeout(const Duration(seconds: 120));

      debugPrint('Status HTTP: ${response.statusCode}');
      debugPrint('Content-Type: ${response.headers['content-type']}');

      // Memeriksa status respons backend.
      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();

        debugPrint('Respons error backend: $errorBody');

        String pesanError = 'Backend gagal memproses pesan.';

        try {
          final hasil = jsonDecode(errorBody);

          if (hasil is Map) {
            pesanError = hasil['message']?.toString() ??
                hasil['error']?.toString() ??
                pesanError;
          }
        } catch (_) {
          if (errorBody.isNotEmpty) {
            pesanError = errorBody;
          }
        }

        throw Exception(
          'HTTP ${response.statusCode}: $pesanError',
        );
      }

      bool menerimaJawaban = false;

      // Membaca respons NDJSON baris demi baris.
      await for (final baris in response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .timeout(const Duration(seconds: 120))) {
        if (baris.trim().isEmpty) {
          continue;
        }

        debugPrint('[AI STREAM] $baris');

        dynamic hasil;

        try {
          hasil = jsonDecode(baris);
        } catch (e) {
          throw Exception(
            'Format streaming backend tidak valid: $baris',
          );
        }

        if (hasil is! Map) {
          throw Exception(
            'Format data streaming AI tidak sesuai.',
          );
        }

        // Jika backend mengirim pesan error.
        if (hasil['error'] != null) {
          throw Exception(
            hasil['error'].toString(),
          );
        }

        // Mengambil potongan teks jawaban Gemini.
        if (hasil['chunk'] != null) {
          final String potongan = hasil['chunk'].toString();

          if (potongan.isNotEmpty) {
            menerimaJawaban = true;

            // Mengirim potongan teks ke chatbot_screen.dart.
            yield potongan;
          }
        }

        // Jika backend sudah selesai menghasilkan jawaban.
        if (hasil['done'] == true) {
          debugPrint('[AI STREAM] Jawaban selesai.');
          break;
        }
      }

      if (!menerimaJawaban) {
        throw Exception(
          'Backend berhasil dihubungi, tetapi jawaban AI kosong.',
        );
      }

      debugPrint('AI berhasil memberikan jawaban.');
      debugPrint('================================');
    } catch (e) {
      debugPrint('ERROR AI SERVICE: $e');
      debugPrint('================================');

      rethrow;
    } finally {
      client.close();
    }
  }
}
