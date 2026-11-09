import 'package:flutter/material.dart';
import '../widgets/shared.dart';
import 'pembayaran_berhasil_screen.dart';

class QrisBerhasilScreen extends StatelessWidget {
  final String kodePesanan; final int total; final String Function(int) rupiah;
  const QrisBerhasilScreen({super.key, required this.kodePesanan, required this.total, required this.rupiah});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: pageColor,
    appBar: AppBar(backgroundColor: Colors.white, foregroundColor: brown, title: const Text('REDScan', style: TextStyle(fontWeight: FontWeight.bold))),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(children: [
        const Icon(Icons.check_circle, size: 76, color: Color(0xFF20C98B)), const SizedBox(height: 12),
        const Text('PEMBAYARAN QRIS BERHASIL!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        const SizedBox(height: 8), const Text('Ini adalah tampilan simulasi. Pembayaran belum diverifikasi oleh penyedia QRIS.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 11)),
        const SizedBox(height: 18), Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFE8EFF0), borderRadius: BorderRadius.circular(12)), child: Column(children: [const Text('ID PESANAN ANDA', style: TextStyle(fontSize: 10, color: darkTeal)), const SizedBox(height: 4), Text('#$kodePesanan', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: brown))])),
        const SizedBox(height: 16), _row('Metode Pembayaran', 'QRIS'), const SizedBox(height: 10), _row('Total Tagihan', rupiah(total)), const SizedBox(height: 18),
        SizedBox(width: double.infinity, height: 46, child: FilledButton.icon(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), icon: const Icon(Icons.arrow_forward), label: const Text('SELESAI'), style: FilledButton.styleFrom(backgroundColor: darkTeal, foregroundColor: Colors.white))),
        const SizedBox(height: 8), SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => showDialog<void>(context: context, builder: (_) => ReceiptDialog(kodePesanan: kodePesanan, metode: 'QRIS (simulasi)', total: total, rupiah: rupiah)), icon: const Icon(Icons.print_outlined), label: const Text('Lihat / Cetak Struk'))),
      ])), const SizedBox(height: 12), const Center(child: Text('Status transaksi perlu diverifikasi sistem pembayaran.', style: TextStyle(fontSize: 10, color: Colors.black54)))
    ])));
  Widget _row(String a, String b) => Row(children: [Expanded(child: Text(a, style: const TextStyle(fontSize: 12, color: Colors.black54))), Text(b, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: brown))]);
}
