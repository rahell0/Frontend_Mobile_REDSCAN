import 'package:flutter/material.dart';
import '../widgets/shared.dart';

class CashOrderConfirmationScreen extends StatelessWidget {
  final String kodePesanan;
  final int total;
  final int uangDiterima;
  final int kembalian;
  final String Function(int) rupiah;

  const CashOrderConfirmationScreen({
    super.key,
    required this.kodePesanan,
    required this.total,
    required this.uangDiterima,
    required this.kembalian,
    required this.rupiah,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: brown,
        elevation: 0,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('REDScan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          Text('Konfirmasi Pesanan', style: TextStyle(fontSize: 10, color: Colors.black54)),
        ]),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 12, offset: const Offset(0, 5))]),
              child: Column(children: [
                Container(width: 76, height: 76, decoration: const BoxDecoration(color: Color(0xFFE2F8EF), shape: BoxShape.circle), child: const Icon(Icons.check_circle, color: Color(0xFF20C98B), size: 68)),
                const SizedBox(height: 15),
                const Text('PESANAN ANDA BERHASIL!', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF292929))),
                const SizedBox(height: 7),
                const Text('Pesanan berhasil dibuat. Silakan lakukan pembayaran tunai kepada petugas.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.5)),
                const SizedBox(height: 16),
                Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 13), decoration: BoxDecoration(color: const Color(0xFFE8EFF0), border: Border.all(color: const Color(0xFFD0DFE0)), borderRadius: BorderRadius.circular(11)), child: Column(children: [const Text('ID PESANAN ANDA:', style: TextStyle(fontSize: 10, color: darkTeal)), const SizedBox(height: 4), Text('#$kodePesanan', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, letterSpacing: 1, color: brown))])),
                const SizedBox(height: 16),
                Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFFCFBF9), border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(12)), child: Column(children: [
                  _cashDetailRow('Metode Pembayaran', 'Tunai (CASH)', highlight: true),
                  const SizedBox(height: 12),
                  _cashDetailRow('Total Tagihan', rupiah(total)),
                  const SizedBox(height: 12),
                  _cashDetailRow('Uang Diterima', rupiah(uangDiterima)),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  _cashDetailRow('Kembalian (simulasi)', rupiah(kembalian), green: true),
                ])),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 46, child: FilledButton.icon(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), icon: const Icon(Icons.arrow_forward, size: 17), label: const Text('SELESAI'), style: FilledButton.styleFrom(backgroundColor: darkTeal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))))),
                const SizedBox(height: 9),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () => showDialog<void>(context: context, builder: (_) => ReceiptDialog(kodePesanan: kodePesanan, metode: 'Tunai (Cash)', total: total, rupiah: rupiah)), icon: const Icon(Icons.print_outlined, size: 16), label: const Text('Cetak Struk', style: TextStyle(fontSize: 11)))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur berbagi bukti belum terhubung.'))), icon: const Icon(Icons.share_outlined, size: 16), label: const Text('Bagikan Bukti', style: TextStyle(fontSize: 11)))),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.shield_outlined, color: darkTeal, size: 13), SizedBox(width: 5), Text('Simpan kode pesanan untuk proses pembayaran', style: TextStyle(fontSize: 10, color: Colors.black54))]),
          ],
        ),
      ),
    );
  }

  Widget _cashDetailRow(String label, String value, {bool highlight = false, bool green = false}) {
    return Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54))),
      if (highlight) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE0F8EB), borderRadius: BorderRadius.circular(7)), child: Row(children: [const Icon(Icons.circle, size: 6, color: Color(0xFF16B878)), const SizedBox(width: 5), Text(value, style: const TextStyle(fontSize: 10, color: Color(0xFF13895B), fontWeight: FontWeight.bold))]))
      else Text(value, style: TextStyle(fontSize: 11, color: green ? const Color(0xFF13895B) : brown, fontWeight: FontWeight.bold)),
    ]);
  }
}

// ============================================================
// HALAMAN 2: PILIH PRODUK
// ============================================================


class ReceiptDialog extends StatelessWidget {
  final String kodePesanan; final String metode; final int total; final String Function(int) rupiah;
  const ReceiptDialog({super.key, required this.kodePesanan, required this.metode, required this.total, required this.rupiah});
  @override Widget build(BuildContext context) => AlertDialog(
    title: const Row(children: [Icon(Icons.receipt_long, color: darkTeal), SizedBox(width: 8), Text('Struk REDScan')]),
    content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Center(child: Text('REDScan • Bukti Pesanan', style: TextStyle(fontWeight: FontWeight.bold))),
      const Divider(height: 24), Text('Kode: #$kodePesanan'), const SizedBox(height: 8), Text('Metode: $metode'), const SizedBox(height: 8),
      Row(children: [const Expanded(child: Text('Total')), Text(rupiah(total), style: const TextStyle(fontWeight: FontWeight.bold))]),
      const SizedBox(height: 12), const Text('Ini adalah pratinjau struk. Pencetakan fisik belum terhubung.', style: TextStyle(fontSize: 11, color: Colors.black54)),
    ]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')), FilledButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pratinjau struk siap. Hubungkan printer untuk mencetak fisik.'))); }, child: const Text('Selesai'))]);
}
