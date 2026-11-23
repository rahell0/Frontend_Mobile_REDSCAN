
import 'package:flutter/material.dart';
import '../services/pemesanan_service.dart';
import '../widgets/shared.dart';

class RiwayatPemesananScreen extends StatefulWidget {
  final String nomorHp;

  const RiwayatPemesananScreen({
    super.key,
    required this.nomorHp,
  });

  @override
  State<RiwayatPemesananScreen> createState() =>
      _RiwayatPemesananScreenState();
}

class _RiwayatPemesananScreenState
    extends State<RiwayatPemesananScreen> {
  late Future<List<dynamic>> riwayatFuture;

  @override
  void initState() {
    super.initState();
    riwayatFuture = ambilRiwayat();
  }

  Future<List<dynamic>> ambilRiwayat() {
    return PemesananService.ambilRiwayatPemesanan(
      nomorHp: widget.nomorHp,
    );
  }

  Future<void> muatUlang() async {
    setState(() {
      riwayatFuture = ambilRiwayat();
    });

    await riwayatFuture;
  }

  String rupiah(dynamic nilai) {
    final angka = num.tryParse('$nilai')?.round() ?? 0;
    final teks = angka.toString();
    final hasil = StringBuffer();

    for (int i = 0; i < teks.length; i++) {
      hasil.write(teks[i]);

      final sisa = teks.length - i - 1;
      if (sisa > 0 && sisa % 3 == 0) {
        hasil.write('.');
      }
    }

    return 'Rp $hasil';
  }

  String formatTanggal(dynamic tanggal) {
    if (tanggal == null) return '-';

    final date = DateTime.tryParse('$tanggal')?.toLocal();
    if (date == null) return '$tanggal';

    final hari = date.day.toString().padLeft(2, '0');
    final bulan = date.month.toString().padLeft(2, '0');
    final tahun = date.year;

    final jam = date.hour.toString().padLeft(2, '0');
    final menit = date.minute.toString().padLeft(2, '0');

    return '$hari/$bulan/$tahun · $jam:$menit';
  }

  Color warnaStatus(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green;

      case 'diproses':
        return Colors.blue;

      case 'antre':
        return Colors.orange;

      case 'menunggu':
      case 'pending':
        return Colors.deepOrange;

      default:
        return Colors.grey;
    }
  }

  String labelStatus(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return 'Selesai';
      case 'diproses':
        return 'Sedang Diproses';
      case 'antre':
        return 'Antre';
      case 'menunggu':
      case 'pending':
        return 'Menunggu Pembayaran';
      default:
        return status;
    }
  }

  Widget kartuPesanan(Map<String, dynamic> pesanan) {
    final detail = pesanan['detail'] is List
        ? List<dynamic>.from(pesanan['detail'])
        : <dynamic>[];

    final status = '${pesanan['status'] ?? '-'}';
    final warna = warnaStatus(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: darkTeal,
                size: 21,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Detail Pesanan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: brown,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: warna.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  labelStatus(status),
                  style: TextStyle(
                    color: warna,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            'Kode Transaksi',
            style: TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            '#${pesanan['kode_transaksi'] ?? '-'}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: brown,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            formatTanggal(pesanan['created_at']),
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),

          const Divider(height: 24),

          const Text(
            'Produk Dipesan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: brown,
            ),
          ),

          const SizedBox(height: 10),

          if (detail.isEmpty)
            const Text(
              'Detail produk tidak tersedia.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),

          ...detail.map((item) {
            final produk = Map<String, dynamic>.from(item);

            final nama = produk['nama_menu'] ?? 'Produk';
            final jumlah = produk['jumlah'] ?? 0;
            final subtotal = produk['subtotal'] ?? 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$nama',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Text(
                    'x$jumlah',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    rupiah(subtotal),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 20),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  '${pesanan['metode_pembayaran'] ?? '-'}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total Pesanan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: brown,
                    ),
                  ),
                ),
                Text(
                  rupiah(pesanan['total_harga']),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: darkTeal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: brown,
        elevation: 0,
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: riwayatFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: darkTeal,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 45,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gagal Memuat Riwayat',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(height: 15),
                    FilledButton.icon(
                      onPressed: muatUlang,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      style: FilledButton.styleFrom(
                        backgroundColor: darkTeal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 55,
                      color: Colors.black26,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Belum Ada Riwayat Pesanan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: brown,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pesanan dengan nomor HP ini belum ditemukan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 15),
                    OutlinedButton.icon(
                      onPressed: muatUlang,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Muat Ulang'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: muatUlang,
            color: darkTeal,
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: darkTeal,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.phone_android,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nomor HP Pelanggan',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.nomorHp,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${data.length} Pesanan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                ...data.map(
                  (item) => kartuPesanan(
                    Map<String, dynamic>.from(item),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
