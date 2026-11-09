import 'package:flutter/material.dart';

import '../widgets/shared.dart';
import 'chatbot_screen.dart';
import 'pilih_produk_screen.dart';
import 'qris_payment_screen.dart';
import 'pembayaran_berhasil_screen.dart';

class PesananScreen extends StatefulWidget {
  const PesananScreen({super.key});

  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  final namaController = TextEditingController();
  final kontakController = TextEditingController();

  String metodeBayar = 'Tunai (Cash)';
  String statusPesanan = 'Belum Dibayar';

  int uangDiterima = 60500;

  List<Produk> keranjang = [
    Produk(
      nama: 'Chocolate Cake',
      kategori: 'Pastry & Camilan',
      harga: 25000,
      ikon: Icons.cake_outlined,
      jumlah: 1,
    ),
    Produk(
      nama: 'Brown Sugar Latte',
      kategori: 'Kopi Base',
      harga: 15000,
      ikon: Icons.local_cafe_outlined,
      jumlah: 2,
    ),
  ];

  int get subtotal {
    return keranjang.fold(
      0,
      (total, produk) => total + produk.harga * produk.jumlah,
    );
  }

  // Pajak contoh 10%. Sesuaikan dengan aturan outlet.
  int get pajak => (subtotal * 0.10).round();

  int get total => subtotal + pajak;

  int get jumlahJenis => keranjang.length;

  int get jumlahSemua {
    return keranjang.fold(
      0,
      (total, produk) => total + produk.jumlah,
    );
  }

  int get kembalian {
    if (metodeBayar != 'Tunai (Cash)') return 0;
    if (uangDiterima < total) return 0;
    return uangDiterima - total;
  }

  String rupiah(int nilai) {
    final angka = nilai.toString();
    final hasil = StringBuffer();

    for (int i = 0; i < angka.length; i++) {
      hasil.write(angka[i]);

      final sisa = angka.length - i - 1;

      if (sisa > 0 && sisa % 3 == 0) {
        hasil.write('.');
      }
    }

    return 'Rp $hasil';
  }

  Future<void> bukaPilihProduk() async {
    final hasil = await Navigator.push<List<Produk>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductPickerScreen(
          produkAwal: keranjang,
        ),
      ),
    );

    if (hasil == null || !mounted) return;

    setState(() {
      keranjang = hasil.map((produk) => produk.salin()).toList();

      if (uangDiterima < total) {
        uangDiterima = total;
      }
    });
  }

  void ubahJumlah(Produk produk, int perubahan) {
    setState(() {
      produk.jumlah += perubahan;

      if (produk.jumlah <= 0) {
        keranjang.remove(produk);
      }

      if (uangDiterima < total) {
        uangDiterima = total;
      }
    });
  }

  void konfirmasiPesanan() {
    if (keranjang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan tambahkan produk terlebih dahulu.')),
      );
      return;
    }

    final kodePesanan = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    if (metodeBayar == 'QRIS Dinamis') {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => QrisPaymentScreen(
        kodePesanan: kodePesanan,
        total: total,
        rupiah: rupiah,
      ),
    ),
  );
  return;
}

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: const Color(0xFFF6F0E5), borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.check_rounded, color: darkTeal, size: 28),
              ),
              const SizedBox(height: 12),
              const Text('Pesanan Berhasil Dibuat', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: brown)),
              const SizedBox(height: 3),
              const Text('(Pembayaran Tunai / Cash)', style: TextStyle(fontSize: 11, color: darkTeal, fontWeight: FontWeight.w600)),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFCFBF9), border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(12)),
                child: const Text('Tunjukkan kode pesanan ini kepada petugas saat melakukan pembayaran tunai.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.5)),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                decoration: BoxDecoration(color: const Color(0xFFFCFBF9), border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  const Text('KODE PESANAN', style: TextStyle(fontSize: 9, color: Colors.black45, letterSpacing: .5)),
                  const SizedBox(height: 4),
                  Text('#$kodePesanan', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: brown)),
                ]),
              ),
              const SizedBox(height: 12),
              Row(children: [const Expanded(child: Text('Total Tagihan', style: TextStyle(fontSize: 11, color: Colors.black54))), Text(rupiah(total), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: brown))]),
              const SizedBox(height: 14),
              SizedBox(width: double.infinity, height: 44, child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: darkTeal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CashOrderConfirmationScreen(
                    kodePesanan: kodePesanan,
                    total: total,
                    uangDiterima: uangDiterima,
                    kembalian: kembalian,
                    rupiah: rupiah,
                  )));
                },
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
              )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    kontakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: teal.withValues(alpha:0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: darkTeal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PESANAN',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Terminal Kasir · Lantai 1',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F7EC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 7,
                          color: Colors.green,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Kasir Aktif',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF16845B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ISI PESANAN
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // DATA PELANGGAN
                  SectionCard(
                    title: 'Data Pelanggan',
                    icon: Icons.person_outline,
                    trailing: 'Regular / Member',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('Nama Pelanggan'),
                        const SizedBox(height: 5),
                        TextField(
                          controller: namaController,
                          decoration: inputDecoration(
                            'Contoh: Budi Santoso / Meja 04',
                          ),
                        ),
                        const SizedBox(height: 12),
                        const FieldLabel('Loyalty ID / No. HP'),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: kontakController,
                                keyboardType: TextInputType.phone,
                                decoration: inputDecoration(
                                  '081234567890',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 42,
                              width: 42,
                              child: FilledButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Pencarian pelanggan belum terhubung.',
                                      ),
                                    ),
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: teal,
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Icon(Icons.add),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // INPUT PRODUK
                  SectionCard(
                    title: 'Input Produk',
                    icon: Icons.shopping_bag_outlined,
                    trailing: 'Scan Cepat Aktif',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cari dan pilih menu untuk pesanan kamu.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: bukaPilihProduk,
                            style: FilledButton.styleFrom(
                              backgroundColor: darkTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Produk'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$jumlahJenis jenis produk · $jumlahSemua item dipilih',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // DETAIL ITEM
                  SectionCard(
                    title: 'Detail Item Terpilih',
                    icon: Icons.shopping_cart_outlined,
                    trailing: '$jumlahJenis Jenis Item',
                    child: Column(
                      children: [
                        if (keranjang.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Belum ada produk dipilih.'),
                          ),
                        ...keranjang.map(
                          (produk) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        produk.nama,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${rupiah(produk.harga)} / item',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        rupiah(
                                          produk.harga * produk.jumlah,
                                        ),
                                        style: const TextStyle(
                                          color: darkTeal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    quantityButton(
                                      icon: Icons.remove,
                                      onTap: () => ubahJumlah(produk, -1),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Text('${produk.jumlah}'),
                                    ),
                                    quantityButton(
                                      icon: Icons.add,
                                      onTap: () => ubahJumlah(produk, 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        priceRow('Subtotal Item', rupiah(subtotal)),
                        const SizedBox(height: 8),
                        priceRow('Pajak Restoran (10%)', rupiah(pajak)),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: darkTeal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'RINGKASAN BIAYA',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Total Akhir Pesanan',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  rupiah(total),
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // PEMBAYARAN
                  SectionCard(
                    title: 'Pembayaran & Faktur',
                    icon: Icons.receipt_long_outlined,
                    trailing: statusPesanan,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No. Order: RS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F4EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFF9B7938),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Pastikan pesanan sudah benar sebelum menyelesaikan pembayaran.',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const FieldLabel('Metode Pembayaran'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: paymentOption(
                                title: 'Tunai (Cash)',
                                icon: Icons.payments_outlined,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: paymentOption(
                                title: 'QRIS Dinamis',
                                icon: Icons.qr_code_2,
                              ),
                            ),
                          ],
                        ),
                        if (metodeBayar == 'Tunai (Cash)') ...[
                          const SizedBox(height: 16),
                          const FieldLabel('Uang Diterima'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: {total, 70000, 100000}.map(
                              (nominal) {
                                return ChoiceChip(
                                  label: Text(
                                    rupiah(nominal),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  selected: uangDiterima == nominal,
                                  onSelected: (_) {
                                    setState(() {
                                      uangDiterima = nominal;
                                    });
                                  },
                                  selectedColor: teal.withValues(alpha:0.2),
                                );
                              },
                            ).toList(),
                          ),
                          const SizedBox(height: 12),
                          priceRow('Total Belanja', rupiah(total)),
                          const SizedBox(height: 7),
                          priceRow('Uang Diterima', rupiah(uangDiterima)),
                          const SizedBox(height: 7),
                          priceRow('Uang Kembalian', rupiah(kembalian)),
                        ] else ...[
                          const SizedBox(height: 12),
                          const Text(
                            'QRIS akan tersedia setelah integrasi penyedia pembayaran.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: konfirmasiPesanan,
                            style: FilledButton.styleFrom(
                              backgroundColor: darkTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(
                              'Konfirmasi Pembayaran (${rupiah(total)})',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Tombol AI chatbot mengambang di kanan bawah halaman Pesanan.
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatbotScreen()),
              ),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: Color(0xFF20C997)),
                    SizedBox(width: 6),
                    Text(
                      'Tanya AI Kasir',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatbotScreen()),
              ),
              borderRadius: BorderRadius.circular(17),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: darkTeal,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: darkTeal.withValues(alpha:0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.white,
                  size: 29,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentOption({
    required String title,
    required IconData icon,
  }) {
    final aktif = metodeBayar == title;

    return InkWell(
      onTap: () {
        setState(() {
          metodeBayar = title;

          if (metodeBayar == 'Tunai (Cash)' && uangDiterima < total) {
            uangDiterima = total;
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: aktif ? teal.withValues(alpha:0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: aktif ? teal : borderColor,
            width: aktif ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: darkTeal),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// HALAMAN 3: RED ASSISTANT AI / CHATBOT
// ============================================================

