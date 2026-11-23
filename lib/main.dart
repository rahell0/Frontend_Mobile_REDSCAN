import 'package:flutter/material.dart';
import 'screens/pesanan_screen.dart';

void main() {
  runApp(const REDScanApp());
}

class REDScanApp extends StatelessWidget {
  const REDScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'REDScan',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF7F6F2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF402719),
        ),
        useMaterial3: true,
      ),
      home: const PesananScreen(),
    );
  }
}
