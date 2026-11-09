import 'package:flutter/material.dart';
import '../widgets/shared.dart';

class ProductPickerScreen extends StatefulWidget {
  final List<Produk> produkAwal;

  const ProductPickerScreen({
    super.key,
    required this.produkAwal,
  });

  @override
  State<ProductPickerScreen> createState() =>
      _ProductPickerScreenState();
}

class _ProductPickerScreenState extends State<ProductPickerScreen> {
  final TextEditingController searchController = TextEditingController();

  String kategoriAktif = 'Semua';

  late List<Produk> pilihan;

  final List<Produk> katalog = [
    Produk(
      nama: 'Espresso',
      kategori: 'Kopi Base',
      harga: 18000,
      ikon: Icons.coffee_outlined,
    ),
    Produk(
      nama: 'Americano',
      kategori: 'Kopi Base',
      harga: 20000,
      ikon: Icons.local_cafe_outlined,
    ),
    Produk(
      nama: 'Caffe Latte',
      kategori: 'Kopi Base',
      harga: 24000,
      ikon: Icons.local_cafe_outlined,
    ),
    Produk(
      nama: 'Cappuccino',
      kategori: 'Kopi Base',
      harga: 24000,
      ikon: Icons.coffee_outlined,
    ),
    Produk(
      nama: 'Kopi Susu Gula Aren',
      kategori: 'Kopi Base',
      harga: 22000,
      ikon: Icons.local_cafe_outlined,
    ),
    Produk(
      nama: 'V60 / Pour Over',
      kategori: 'Kopi Base',
      harga: 25000,
      ikon: Icons.coffee_maker_outlined,
    ),
    Produk(
      nama: 'Matcha Latte',
      kategori: 'Non-Kopi',
      harga: 25000,
      ikon: Icons.local_drink_outlined,
    ),
    Produk(
      nama: 'Chocolate',
      kategori: 'Non-Kopi',
      harga: 22000,
      ikon: Icons.local_cafe_outlined,
    ),
    Produk(
      nama: 'Peach Tea',
      kategori: 'Non-Kopi',
      harga: 20000,
      ikon: Icons.emoji_food_beverage_outlined,
    ),
    Produk(
      nama: 'Butter Croissant',
      kategori: 'Pastry & Camilan',
      harga: 20000,
      ikon: Icons.cake_outlined,
    ),
    Produk(
      nama: 'Cinnamon Roll',
      kategori: 'Pastry & Camilan',
      harga: 22000,
      ikon: Icons.bakery_dining_outlined,
    ),
    Produk(
      nama: 'Truffle Fries',
      kategori: 'Pastry & Camilan',
      harga: 24000,
      ikon: Icons.fastfood_outlined,
    ),
    Produk(
      nama: 'Chicken Wings',
      kategori: 'Pastry & Camilan',
      harga: 28000,
      ikon: Icons.restaurant_outlined,
    ),
    Produk(
      nama: 'Club Sandwich',
      kategori: 'Makanan Utama & Toast',
      harga: 28000,
      ikon: Icons.lunch_dining_outlined,
    ),
    Produk(
      nama: 'Nasi Goreng Spesial',
      kategori: 'Makanan Utama & Toast',
      harga: 32000,
      ikon: Icons.rice_bowl_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();

    pilihan = widget.produkAwal
        .map((produk) => produk.salin())
        .toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

  int jumlahProduk(String nama) {
    final index = pilihan.indexWhere(
      (produk) => produk.nama == nama,
    );

    return index < 0 ? 0 : pilihan[index].jumlah;
  }

  int get jumlahJenis => pilihan.length;

  int get jumlahSemua {
    return pilihan.fold(
      0,
      (total, produk) => total + produk.jumlah,
    );
  }

  void ubahPilihan(Produk produk, int perubahan) {
    setState(() {
      final index = pilihan.indexWhere(
        (item) => item.nama == produk.nama,
      );

      if (index == -1 && perubahan > 0) {
        pilihan.add(produk.salin(jumlahBaru: perubahan));
      } else if (index != -1) {
        pilihan[index].jumlah += perubahan;

        if (pilihan[index].jumlah <= 0) {
          pilihan.removeAt(index);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasilCari = katalog.where((produk) {
      final cocokNama = produk.nama.toLowerCase().contains(
            searchController.text.toLowerCase(),
          );

      final cocokKategori = kategoriAktif == 'Semua' ||
          produk.kategori == kategoriAktif;

      return cocokNama && cocokKategori;
    }).toList();

    final Map<String, List<Produk>> kelompok = {};

    for (final produk in hasilCari) {
      kelompok.putIfAbsent(produk.kategori, () => []);
      kelompok[produk.kategori]!.add(produk);
    }

    return Scaffold(
      backgroundColor: brown,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER, PENCARIAN, DAN KATEGORI
            Container(
              color: const Color(0xFFFAF8F2),
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 7,
                        color: teal,
                      ),
                      const SizedBox(width: 5),
                      const Expanded(
                        child: Text(
                          'Pilih Produk',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: brown,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Tutup',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 19),
                      ),
                    ],
                  ),
                  TextField(
                    controller: searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari nama produk...',
                      hintStyle: const TextStyle(fontSize: 11),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'Semua',
                        'Kopi Base',
                        'Non-Kopi',
                        'Pastry & Camilan',
                        'Makanan Utama & Toast',
                      ].map((kategori) {
                        final aktif = kategoriAktif == kategori;

                        return Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: ChoiceChip(
                            label: Text(
                              kategori,
                              style: const TextStyle(fontSize: 10),
                            ),
                            selected: aktif,
                            onSelected: (_) {
                              setState(() {
                                kategoriAktif = kategori;
                              });
                            },
                            selectedColor: teal,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: aktif ? Colors.white : brown,
                            ),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // GRID PRODUK
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                children: [
                  if (hasilCari.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Text(
                        'Produk tidak ditemukan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                  ...kelompok.entries.map((kelompokProduk) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(2, 8, 2, 9),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_cafe,
                                color: Color(0xFFE9C878),
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  kelompokProduk.key.toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFFFFE8C4),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '${kelompokProduk.value.length} Menu',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: kelompokProduk.value.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 7,
                            mainAxisSpacing: 7,
                            mainAxisExtent: 178,
                          ),
                          itemBuilder: (context, index) {
                            final produk = kelompokProduk.value[index];
                            final jumlah = jumlahProduk(produk.nama);

                            return Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: brown,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF6B4936),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Icon(
                                        produk.ikon,
                                        color: brown,
                                        size: 29,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    produk.nama,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    rupiah(produk.harga),
                                    style: const TextStyle(
                                      color: Color(0xFFFFD783),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 29,
                                    child: FilledButton(
                                      onPressed: () {
                                        ubahPilihan(produk, 1);
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: cream,
                                        foregroundColor: brown,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(9),
                                        ),
                                      ),
                                      child: Text(
                                        jumlah > 0
                                            ? '+ Pilih ($jumlah)'
                                            : '+ Pilih',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }),
                ],
              ),
            ),

            // BAR RINGKASAN PRODUK
            Container(
              color: const Color(0xFFFAF8F2),
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
              child: Row(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    color: brown,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$jumlahJenis Jenis Produk',
                          style: const TextStyle(
                            color: brown,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '$jumlahSemua produk ditambahkan',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        pilihan
                            .map((produk) => produk.salin())
                            .toList(),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: teal,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Selesai'),
                  ),
                ],
              ),
            ),

            // NAVIGASI BAWAH SESUAI FIGMA
            Container(
              color: const Color(0xFFFAF8F2),
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BottomItem(
                    icon: Icons.receipt_long,
                    label: 'Pesanan',
                    aktif: true,
                  ),
                  BottomItem(
                    icon: Icons.history,
                    label: 'Riwayat',
                  ),
                  BottomItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Stok Bahan',
                  ),
                  BottomItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
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

// ============================================================
// KOMPONEN NAVIGASI BAWAH
// ============================================================

