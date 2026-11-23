
import 'package:flutter/material.dart';

import '../widgets/shared.dart';
import '../services/menu_service.dart';

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
  final TextEditingController searchController =
      TextEditingController();

  String kategoriAktif = 'Semua';

  late List<Produk> pilihan;

  List<Produk> katalog = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    pilihan = widget.produkAwal
        .map((produk) => produk.salin())
        .toList();

    ambilMenu();
  }

  // ============================================================
  // MENGAMBIL DATA MENU DARI BACKEND
  // ============================================================

  Future<void> ambilMenu() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final dataMenu = await MenuService.getMenu();

      final List<Produk> dataProduk = dataMenu.map((item) {
        final int id = int.tryParse(
              item['id']?.toString() ?? '',
            ) ??
            0;

        final String nama =
            item['nama_menu']?.toString() ?? '';

        final String kategori =
            item['kategori']?.toString() ?? 'Lainnya';

        // MEMBACA HARGA DARI DATABASE
        final dynamic hargaData = item['harga'];

        int harga = 0;

        if (hargaData is num) {
          harga = hargaData.round();
        } else if (hargaData != null) {
          final String hargaString = hargaData
              .toString()
              .trim()
              .replaceAll('Rp', '')
              .replaceAll(' ', '');

          // Membaca format DECIMAL MySQL
          final double? hargaParsed =
              double.tryParse(hargaString);

          if (hargaParsed != null) {
            harga = hargaParsed.round();
          }
        }

        // MEMBACA GAMBAR DARI DATABASE
        final String? gambar =
            MenuService.getImageUrl(item['gambar']);

        return Produk(
          id: id,
          nama: nama,
          kategori: kategori,
          harga: harga,
          gambar: gambar,
          ikon: ikonProduk(kategori),
        );
      }).where((produk) {
        return (produk.id ?? 0) > 0 &&
            produk.nama.isNotEmpty;
      }).toList();

      if (!mounted) return;

      setState(() {
        katalog = dataProduk;
        isLoading = false;

        if (!['Semua', ...daftarKategori]
            .contains(kategoriAktif)) {
          kategoriAktif = 'Semua';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // IKON BERDASARKAN KATEGORI
  // ============================================================

  IconData ikonProduk(String kategori) {
    final namaKategori = kategori.toLowerCase();

    if (namaKategori.contains('kopi')) {
      return Icons.local_cafe_outlined;
    }

    if (namaKategori.contains('teh')) {
      return Icons.emoji_food_beverage_outlined;
    }

    if (namaKategori.contains('pastry') ||
        namaKategori.contains('camilan') ||
        namaKategori.contains('roti')) {
      return Icons.cake_outlined;
    }

    if (namaKategori.contains('makanan') ||
        namaKategori.contains('mie') ||
        namaKategori.contains('nasi') ||
        namaKategori.contains('burger')) {
      return Icons.restaurant_outlined;
    }

    if (namaKategori.contains('non kopi') ||
        namaKategori.contains('non-kopi')) {
      return Icons.local_drink_outlined;
    }

    return Icons.fastfood_outlined;
  }

  // ============================================================
  // KATEGORI DINAMIS DARI DATABASE
  // ============================================================

  List<String> get daftarKategori {
    final kategori = katalog
        .map((produk) => produk.kategori)
        .toSet()
        .toList();

    kategori.sort();

    return kategori;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // FORMAT RUPIAH
  // ============================================================

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

  // ============================================================
  // MENAMPILKAN GAMBAR MENU
  // ============================================================

  Widget tampilkanGambar(Produk produk) {
    if (produk.gambar == null ||
        produk.gambar!.isEmpty) {
      return Center(
        child: Icon(
          produk.ikon,
          color: brown,
          size: 38,
        ),
      );
    }

    return Image.network(
      produk.gambar!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            produk.ikon,
            color: brown,
            size: 38,
          ),
        );
      },
    );
  }

  // ============================================================
  // JUMLAH PRODUK
  // ============================================================

  int jumlahProduk(Produk produk) {
    final index = pilihan.indexWhere(
      (item) => item.id == produk.id,
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

  // ============================================================
  // MENAMBAHKAN ATAU MENGURANGI PRODUK
  // ============================================================

  void ubahPilihan(Produk produk, int perubahan) {
    setState(() {
      final index = pilihan.indexWhere(
        (item) => item.id == produk.id,
      );

      if (index == -1 && perubahan > 0) {
        pilihan.add(
          produk.salin(jumlahBaru: perubahan),
        );
      } else if (index != -1) {
        pilihan[index].jumlah += perubahan;

        if (pilihan[index].jumlah <= 0) {
          pilihan.removeAt(index);
        }
      }
    });
  }

  // ============================================================
  // TAMPILAN HALAMAN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final lebarLayar = MediaQuery.of(context).size.width;

    // RESPONSIVE GRID
    final int jumlahKolom = lebarLayar >= 1100
        ? 4
        : lebarLayar >= 700
            ? 3
            : 2;

    final hasilCari = katalog.where((produk) {
      final cocokNama = produk.nama.toLowerCase().contains(
            searchController.text.toLowerCase(),
          );

      final cocokKategori = kategoriAktif == 'Semua' ||
          produk.kategori == kategoriAktif;

      return cocokNama && cocokKategori;
    }).toList();

    // KELOMPOKKAN PRODUK BERDASARKAN KATEGORI
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
            // ==================================================
            // HEADER, PENCARIAN, DAN KATEGORI
            // ==================================================

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
                        icon: const Icon(
                          Icons.close,
                          size: 19,
                        ),
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

                  if (!isLoading && errorMessage == null)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'Semua',
                          ...daftarKategori,
                        ].map((kategori) {
                          final aktif =
                              kategoriAktif == kategori;

                          return Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: ChoiceChip(
                              label: Text(
                                kategori,
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
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
                                color: aktif
                                    ? Colors.white
                                    : brown,
                              ),
                              visualDensity:
                                  VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),

            // ==================================================
            // GRID PRODUK
            // ==================================================

            Expanded(
              child: Builder(
                builder: (context) {
                  // LOADING
                  if (isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Mengambil data menu...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // ERROR
                  if (errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.wifi_off,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Gagal mengambil data menu.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: ambilMenu,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // KATALOG KOSONG
                  if (katalog.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada produk di database.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  // PRODUK TIDAK DITEMUKAN
                  if (hasilCari.isEmpty) {
                    return const Center(
                      child: Text(
                        'Produk tidak ditemukan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      8,
                      8,
                      8,
                      12,
                    ),
                    children: [
                      ...kelompok.entries.map((kelompokProduk) {
                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                2,
                                8,
                                2,
                                9,
                              ),
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
                                      kelompokProduk.key
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFFFFE8C4),
                                        fontSize: 10,
                                        fontWeight:
                                            FontWeight.bold,
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

                            // GRID KARTU PRODUK
                            GridView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount:
                                  kelompokProduk.value.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: jumlahKolom,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                mainAxisExtent: 255,
                              ),
                              itemBuilder: (context, index) {
                                final produk =
                                    kelompokProduk.value[index];

                                final jumlah =
                                    jumlahProduk(produk);

                                return Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: brown,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF6B4936,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // FOTO PRODUK
                                      SizedBox(
                                        width: double.infinity,
                                        height: 165,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(9),
                                          child: Container(
                                            color: brown,
                                            child: tampilkanGambar(
                                              produk,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      // NAMA PRODUK
                                      Text(
                                        produk.nama,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 3),

                                      // HARGA PRODUK
                                      Text(
                                        rupiah(produk.harga),
                                        style: const TextStyle(
                                          color: Color(0xFFFFD783),
                                          fontSize: 10,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      // TOMBOL PILIH
                                      SizedBox(
                                        width: double.infinity,
                                        height: 29,
                                        child: FilledButton(
                                          onPressed: () {
                                            ubahPilihan(
                                              produk,
                                              1,
                                            );
                                          },
                                          style:
                                              FilledButton.styleFrom(
                                            backgroundColor: cream,
                                            foregroundColor: brown,
                                            padding: EdgeInsets.zero,
                                            shape:
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(9),
                                            ),
                                          ),
                                          child: Text(
                                            jumlah > 0
                                                ? '+ Pilih ($jumlah)'
                                                : '+ Pilih',
                                            style:
                                                const TextStyle(
                                              fontSize: 10,
                                              fontWeight:
                                                  FontWeight.bold,
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
                  );
                },
              ),
            ),

            // ==================================================
            // BAR RINGKASAN PRODUK
            // ==================================================

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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
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
                    icon: const Icon(
                      Icons.check,
                      size: 16,
                    ),
                    label: const Text('Selesai'),
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
