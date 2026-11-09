import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
 
void main() {
  runApp(const MyApp());
}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
 
class HomePage extends StatefulWidget {
  const HomePage({super.key});
 
  @override
  State<HomePage> createState() => _HomePageState();
}
 
class _HomePageState extends State<HomePage> {
  String hasil = 'Belum terhubung ke server';
 
  Future<void> ambilData() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000'),
      );
 
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          hasil = data['message'];
        });
      } else {
        setState(() {
          hasil = 'Server mengalami kesalahan';
        });
      }
    } catch (e) {
      setState(() {
        hasil = 'Koneksi gagal: $e';
      });
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi REDScan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(hasil),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: ambilData,
              child: const Text('Hubungkan ke Backend'),
            ),
          ],
        ),
      ),
    );
  }
}