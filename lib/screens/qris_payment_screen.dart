import 'package:flutter/material.dart';
import '../widgets/shared.dart';
import 'qris_berhasil_screen.dart';

class QrisPaymentScreen extends StatelessWidget {
  final String kodePesanan;
  final int total;
  final String Function(int) rupiah;

  const QrisPaymentScreen({
    super.key,
    required this.kodePesanan,
    required this.total,
    required this.rupiah,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: brown,
        title: const Text(
          'Pembayaran QRIS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_2,
                    size: 48,
                    color: darkTeal,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SCAN UNTUK MEMBAYAR',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: brown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pindai kode QR menggunakan aplikasi pembayaran yang mendukung QRIS.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2,
                          size: 150,
                          color: Colors.black87,
                        ),
                        Text(
                          'SIMULASI QRIS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'TOTAL PEMBAYARAN',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rupiah(total),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: darkTeal,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Kode Pesanan',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          kodePesanan,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4DD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Ini adalah simulasi QRIS. Kode ini belum dapat digunakan untuk pembayaran sungguhan.',
                      style: TextStyle(fontSize: 11, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QrisBerhasilScreen(
                              kodePesanan: kodePesanan,
                              total: total,
                              rupiah: rupiah,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Saya Sudah Bayar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: darkTeal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kembali ke Pesanan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}