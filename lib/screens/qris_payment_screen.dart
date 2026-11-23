
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/pemesanan_service.dart';
import '../widgets/shared.dart';
import 'qris_berhasil_screen.dart';

class QrisPaymentScreen extends StatefulWidget {
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
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen>
    with WidgetsBindingObserver {
  Timer? _timer;

  bool _sedangMembuatPembayaran = true;
  bool _sedangMengecek = false;
  bool _sedangMembukaMidtrans = false;
  bool _pembayaranBerhasil = false;

  String? _redirectUrl;
  String? _pesanError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _buatPembayaran();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // Periksa status ketika pengguna kembali dari halaman Midtrans.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cekStatusPembayaran();
    }
  }

  Future<void> _buatPembayaran() async {
    if (!mounted) return;

    setState(() {
      _sedangMembuatPembayaran = true;
      _pesanError = null;
    });

    try {
      final hasil = await PemesananService.buatPembayaranMidtrans(
        kodePesanan: widget.kodePesanan,
      );

      final status = (hasil['status_pembayaran'] ?? '')
          .toString()
          .toLowerCase();

      if (status == 'berhasil') {
        if (!mounted) return;
        _bukaHalamanBerhasil();
        return;
      }

      final redirectUrl = hasil['redirect_url']?.toString();

      if (redirectUrl == null || redirectUrl.isEmpty) {
        throw Exception('URL pembayaran Midtrans tidak ditemukan.');
      }

      if (!mounted) return;

      setState(() {
        _redirectUrl = redirectUrl;
        _sedangMembuatPembayaran = false;
      });

      _mulaiPengecekanOtomatis();
      await _bukaHalamanMidtrans();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _sedangMembuatPembayaran = false;
        _pesanError = e.toString();
      });
    }
  }

  Future<void> _bukaHalamanMidtrans() async {
    if (_redirectUrl == null || _sedangMembukaMidtrans) return;

    setState(() {
      _sedangMembukaMidtrans = true;
      _pesanError = null;
    });

    try {
      final uri = Uri.parse(_redirectUrl!);

      final berhasilDibuka = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!berhasilDibuka) {
        throw Exception('Halaman pembayaran Midtrans gagal dibuka.');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _pesanError = 'Tidak dapat membuka Midtrans: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _sedangMembukaMidtrans = false;
        });
      }
    }
  }

  void _mulaiPengecekanOtomatis() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _cekStatusPembayaran(),
    );
  }

  Future<void> _cekStatusPembayaran() async {
    if (_sedangMengecek || _pembayaranBerhasil || !mounted) {
      return;
    }

    setState(() {
      _sedangMengecek = true;
    });

    try {
      final status = await PemesananService.cekStatusPembayaran(
        kodePesanan: widget.kodePesanan,
      );

      if (!mounted) return;

      if (status == 'berhasil') {
        _bukaHalamanBerhasil();
        return;
      }

      if (status == 'gagal' || status == 'kedaluwarsa') {
        _timer?.cancel();

        setState(() {
          _pesanError = status == 'gagal'
              ? 'Pembayaran gagal. Silakan coba kembali.'
              : 'Waktu pembayaran sudah berakhir.';
        });
      } else if (status == 'pending') {
        setState(() {
          _pesanError = null;
        });
      }
    } catch (_) {
      // Pengecekan berikutnya akan mencoba kembali.
    } finally {
      if (mounted && !_pembayaranBerhasil) {
        setState(() {
          _sedangMengecek = false;
        });
      }
    }
  }

  void _bukaHalamanBerhasil() {
    if (!mounted || _pembayaranBerhasil) return;

    _timer?.cancel();

    setState(() {
      _pembayaranBerhasil = true;
      _sedangMengecek = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QrisBerhasilScreen(
          kodePesanan: widget.kodePesanan,
          total: widget.total,
          rupiah: widget.rupiah,
        ),
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
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.payment,
                    size: 48,
                    color: darkTeal,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'PEMBAYARAN QRIS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: brown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selesaikan pembayaran melalui halaman resmi Midtrans Sandbox.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),

                  if (_sedangMembuatPembayaran) ...[
                    const CircularProgressIndicator(
                      color: darkTeal,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Sedang menyiapkan pembayaran...',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ] else if (_redirectUrl == null) ...[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _pesanError ?? 'Pembayaran belum berhasil dibuat.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _buatPembayaran,
                        style: FilledButton.styleFrom(
                          backgroundColor: darkTeal,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4F2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.open_in_browser,
                            color: darkTeal,
                            size: 42,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Halaman Midtrans siap',
                            style: TextStyle(
                              color: darkTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Tekan tombol di bawah untuk membuka halaman pembayaran dan menyelesaikan simulasi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _sedangMembukaMidtrans
                            ? null
                            : _bukaHalamanMidtrans,
                        icon: const Icon(Icons.open_in_new),
                        label: Text(
                          _sedangMembukaMidtrans
                              ? 'Membuka Midtrans...'
                              : 'Buka Pembayaran Midtrans',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: darkTeal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_pesanError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _pesanError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: darkTeal,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _sedangMengecek
                          ? 'Sedang memeriksa pembayaran...'
                          : 'Menunggu konfirmasi pembayaran dari Midtrans.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _cekStatusPembayaran,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Periksa Status Pembayaran'),
                    ),
                  ],

                  const Divider(height: 30),

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
                          widget.kodePesanan,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total Pembayaran',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Text(
                        widget.rupiah(widget.total),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
