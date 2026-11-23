import 'package:flutter/material.dart';

import '../services/menu_service.dart';
import '../services/ai_service.dart';
import '../widgets/shared.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  List<Produk> katalog = [];
  List<Produk> produkDipilih = [];

  bool isLoading = true;
  bool isSending = false;

  String? errorMessage;
  String pilihanAktif = '';

  final TextEditingController chatController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  // Riwayat percakapan untuk Gemini
  final List<Map<String, String>> riwayatChat = [];

  final List<Map<String, dynamic>> pilihanRekomendasi = [
    {
      'judul': 'Cuaca Sejuk',
      'deskripsi': 'Menu yang cocok dinikmati saat suasana sejuk',
      'ikon': Icons.cloud_outlined,
      'warna': Color(0xFF648F94),
      'kataKunci': [
        'kopi',
        'latte',
        'cappuccino',
        'cokelat',
        'mocha',
        'americano',
        'signature',
        'pastry',
        'roti',
        'cake',
        'croissant',
      ],
      'prompt':
          'Aku sedang ingin menikmati menu saat cuaca sejuk. '
          'Tolong rekomendasikan makanan dan minuman REDScan '
          'yang cocok beserta harganya.',
    },
    {
      'judul': 'Cuaca Panas',
      'deskripsi': 'Pilihan minuman yang terasa menyegarkan',
      'ikon': Icons.wb_sunny_outlined,
      'warna': Color(0xFFE5A34B),
      'kataKunci': [
        'refresh',
        'teh',
        'tea',
        'lemon',
        'peach',
        'jeruk',
        'soda',
        'es',
        'ice',
        'non kopi',
        'non-kopi',
      ],
      'prompt':
          'Cuaca sedang panas. Tolong rekomendasikan minuman '
          'REDScan yang dingin dan menyegarkan beserta harganya.',
    },
    {
      'judul': 'Ingin Minuman',
      'deskripsi': 'Lihat pilihan kopi dan minuman lainnya',
      'ikon': Icons.local_cafe_outlined,
      'warna': Color(0xFF648F94),
      'kataKunci': [
        'kopi',
        'teh',
        'tea',
        'minuman',
        'drink',
        'refresh',
        'latte',
        'americano',
        'cappuccino',
        'non kopi',
        'non-kopi',
      ],
      'prompt':
          'Aku sedang ingin membeli minuman. Tolong '
          'rekomendasikan beberapa pilihan minuman REDScan '
          'beserta harga dan penjelasannya.',
    },
    {
      'judul': 'Ingin Makanan',
      'deskripsi': 'Cari menu makanan untuk mengisi perut',
      'ikon': Icons.restaurant_outlined,
      'warna': Color(0xFF9B7958),
      'kataKunci': [
        'makanan',
        'mie',
        'nasi',
        'ayam',
        'burger',
        'toast',
        'rice',
        'food',
      ],
      'prompt':
          'Aku sedang lapar dan ingin membeli makanan. '
          'Tolong rekomendasikan menu makanan REDScan '
          'beserta harganya.',
    },
    {
      'judul': 'Ingin Camilan',
      'deskripsi': 'Temukan pastry dan camilan pendamping',
      'ikon': Icons.bakery_dining_outlined,
      'warna': Color(0xFFB98762),
      'kataKunci': [
        'pastry',
        'camilan',
        'roti',
        'cake',
        'croissant',
        'cookie',
        'donat',
        'snack',
        'cinnamon',
      ],
      'prompt':
          'Aku sedang ingin camilan. Tolong rekomendasikan '
          'pastry atau camilan yang tersedia di REDScan '
          'beserta harganya.',
    },
  ];

  @override
  void initState() {
    super.initState();
    ambilMenu();
  }

  @override
  void dispose() {
    chatController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ==========================================
  // MENGAMBIL MENU DARI BACKEND
  // ==========================================

  Future<void> ambilMenu() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final dataMenu = await MenuService.getMenu();

      final List<Produk> hasil = dataMenu.map((item) {
        final int id =
            int.tryParse(item['id']?.toString() ?? '') ?? 0;

        final String nama =
            item['nama_menu']?.toString() ?? '';

        final String kategori =
            item['kategori']?.toString() ?? 'Lainnya';

        final dynamic hargaData = item['harga'];

        int harga = 0;

        if (hargaData is num) {
          harga = hargaData.round();
        } else if (hargaData != null) {
          String hargaString = hargaData
              .toString()
              .trim()
              .replaceAll('Rp', '')
              .replaceAll(' ', '');

          // Menangani format Indonesia, misalnya 15.000,00
          if (hargaString.contains(',') &&
              hargaString.contains('.')) {
            if (hargaString.lastIndexOf(',') >
                hargaString.lastIndexOf('.')) {
              hargaString = hargaString
                  .replaceAll('.', '')
                  .replaceAll(',', '.');
            } else {
              hargaString = hargaString.replaceAll(',', '');
            }
          } else if (hargaString.contains(',')) {
            hargaString = hargaString.replaceAll(',', '.');
          } else if ('.'.allMatches(hargaString).length > 1) {
            hargaString = hargaString.replaceAll('.', '');
          }

          final double? hargaParsed =
              double.tryParse(hargaString);

          if (hargaParsed != null) {
            harga = hargaParsed.round();
          }
        }

        return Produk(
          id: id,
          nama: nama,
          kategori: kategori,
          harga: harga,
          gambar: MenuService.getImageUrl(item['gambar']),
          ikon: ikonProduk(kategori),
        );
      }).where((produk) {
        return (produk.id ?? 0) > 0 &&
            produk.nama.isNotEmpty;
      }).toList();

      if (!mounted) return;

      setState(() {
        katalog = hasil;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  IconData ikonProduk(String kategori) {
    final nama = kategori.toLowerCase();

    if (nama.contains('kopi')) {
      return Icons.local_cafe_outlined;
    }

    if (nama.contains('teh')) {
      return Icons.emoji_food_beverage_outlined;
    }

    if (nama.contains('pastry') ||
        nama.contains('camilan') ||
        nama.contains('roti')) {
      return Icons.cake_outlined;
    }

    if (nama.contains('makanan') ||
        nama.contains('mie') ||
        nama.contains('nasi') ||
        nama.contains('burger')) {
      return Icons.restaurant_outlined;
    }

    if (nama.contains('non kopi') ||
        nama.contains('non-kopi')) {
      return Icons.local_drink_outlined;
    }

    return Icons.fastfood_outlined;
  }

  // ==========================================
  // FORMAT RUPIAH
  // ==========================================

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

  // ==========================================
  // MENGATUR SCROLL CHAT
  // ==========================================

  void scrollKeBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ==========================================
  // MENGIRIM PESAN KE GEMINI (STREAMING)
  // ==========================================

  Future<void> kirimPesan({String? teks}) async {
    final pesan = (teks ?? chatController.text).trim();

    if (pesan.isEmpty || isSending) return;

    chatController.clear();

    setState(() {
      riwayatChat.add({
        'role': 'user',
        'content': pesan,
      });

      isSending = true;
    });

    scrollKeBawah();

    // Posisi gelembung jawaban AI.
    final int indexJawaban = riwayatChat.length;

    // Buat gelembung jawaban kosong terlebih dahulu.
    setState(() {
      riwayatChat.add({
        'role': 'assistant',
        'content': '',
      });
    });

    scrollKeBawah();

    try {
      // Kirim riwayat percakapan sebelum gelembung jawaban kosong.
      final messagesUntukAi = riwayatChat
          .take(indexJawaban)
          .map((message) => Map<String, String>.from(message))
          .toList();

      // Terima jawaban Gemini sedikit demi sedikit.
      await for (final potongan in AiService.kirimPesan(
        messages: messagesUntukAi,
      )) {
        if (!mounted) return;

        setState(() {
          riwayatChat[indexJawaban]['content'] =
              (riwayatChat[indexJawaban]['content'] ?? '') +
                  potongan;
        });

        scrollKeBawah();
      }

      if (!mounted) return;

      setState(() {
        isSending = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        riwayatChat[indexJawaban]['content'] =
            'Maaf, aku belum berhasil terhubung ke AI REDScan. '
            'Silakan coba kirim pesan kembali.';

        isSending = false;
      });

      debugPrint('Error Chatbot REDScan: $e');
    }

    scrollKeBawah();
  }

  // ==========================================
  // MEMILIH REKOMENDASI
  // ==========================================

  void pilihRekomendasi(Map<String, dynamic> pilihan) {
    setState(() {
      pilihanAktif = pilihan['judul'];
    });

    kirimPesan(
      teks: pilihan['prompt'].toString(),
    );
  }

  List<Produk> get hasilRekomendasi {
    if (pilihanAktif.isEmpty) return [];

    final pilihan = pilihanRekomendasi.firstWhere(
      (item) => item['judul'] == pilihanAktif,
    );

    final List<String> kataKunci =
        List<String>.from(pilihan['kataKunci']);

    final hasil = katalog.where((produk) {
      final nama = produk.nama.toLowerCase();
      final kategori = produk.kategori.toLowerCase();

      return kataKunci.any((kata) {
        final kataLower = kata.toLowerCase();

        return nama.contains(kataLower) ||
            kategori.contains(kataLower);
      });
    }).toList();

    if (hasil.isEmpty) {
      return katalog;
    }

    return hasil;
  }

  // ==========================================
  // MENAMBAHKAN MENU KE PILIHAN KERANJANG
  // ==========================================

  void tambahProduk(Produk produk) {
    setState(() {
      final index = produkDipilih.indexWhere(
        (item) => item.id == produk.id,
      );

      if (index == -1) {
        produkDipilih.add(
          produk.salin(jumlahBaru: 1),
        );
      } else {
        produkDipilih[index].jumlah++;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${produk.nama} ditambahkan ke pilihan.'),
        duration: const Duration(seconds: 1),
        backgroundColor: darkTeal,
      ),
    );
  }

  int jumlahProdukDipilih(Produk produk) {
    final index = produkDipilih.indexWhere(
      (item) => item.id == produk.id,
    );

    if (index == -1) return 0;

    return produkDipilih[index].jumlah;
  }

  int get jumlahSemua {
    return produkDipilih.fold(
      0,
      (total, produk) => total + produk.jumlah,
    );
  }

  // ==========================================
  // MENGEMBALIKAN PRODUK KE HALAMAN PESANAN
  // ==========================================

  void kirimKePesanan() {
    Navigator.pop(
      context,
      produkDipilih.map((produk) => produk.salin()).toList(),
    );
  }

  // ==========================================
  // GELEMBUNG CHAT
  // ==========================================

  Widget gelembungChat(Map<String, String> pesan) {
    final bool dariUser = pesan['role'] == 'user';

    return Align(
      alignment: dariUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: dariUser ? darkTeal : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(dariUser ? 14 : 3),
            bottomRight: Radius.circular(dariUser ? 3 : 14),
          ),
          border: dariUser
              ? null
              : Border.all(color: borderColor),
        ),
        child: Text(
          pesan['content'] ?? '',
          style: TextStyle(
            color: dariUser ? Colors.white : brown,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // INDIKATOR AI SEDANG MENJAWAB
  // ==========================================

  Widget indikatorMengetik() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: borderColor),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: darkTeal,
              ),
            ),
            SizedBox(width: 9),
            Text(
              'AI sedang mengetik...',
              style: TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAMPILAN KARTU PRODUK
  // ==========================================

  Widget kartuProduk(Produk produk) {
    final jumlah = jumlahProdukDipilih(produk);

    return Container(
      width: 175,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              height: 115,
              color: const Color(0xFFF3EFE8),
              child: produk.gambar == null ||
                      produk.gambar!.isEmpty
                  ? Icon(
                      produk.ikon,
                      color: brown,
                      size: 40,
                    )
                  : Image.network(
                      produk.gambar!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return Icon(
                          produk.ikon,
                          color: brown,
                          size: 40,
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            produk.nama,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: brown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            produk.kategori,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            rupiah(produk.harga),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: darkTeal,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: FilledButton.icon(
              onPressed: () => tambahProduk(produk),
              style: FilledButton.styleFrom(
                backgroundColor: darkTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              icon: const Icon(Icons.add, size: 15),
              label: Text(
                jumlah > 0 ? 'Tambah ($jumlah)' : 'Tambah',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // INPUT CHAT
  // ==========================================

  Widget inputChat() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: chatController,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => kirimPesan(),
              decoration: InputDecoration(
                hintText: 'Tanyakan sesuatu kepada REDScan AI...',
                hintStyle: const TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                ),
                filled: true,
                fillColor: pageColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 43,
            height: 43,
            child: FilledButton(
              onPressed: isSending ? null : () => kirimPesan(),
              style: FilledButton.styleFrom(
                backgroundColor: darkTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
              ),
              child: isSending
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      size: 19,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAMPILAN UTAMA
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,

      appBar: AppBar(
        backgroundColor: brown,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.smart_toy_outlined, size: 22),
            SizedBox(width: 9),
            Text(
              'REDScan AI Assistant',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang menu',
            onPressed: ambilMenu,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(14),
              children: [
                // SAPAAN CHATBOT
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: borderColor),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xFFE9E1CF),
                        child: Icon(
                          Icons.smart_toy_outlined,
                          color: brown,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo! Ada yang bisa aku bantu?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: brown,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Aku adalah AI Assistant REDScan. '
                              'Aku bisa membantu memilih menu berdasarkan '
                              'suasana, keinginan, dan anggaranmu. '
                              'Yuk, ngobrol denganku!',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.5,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Kamu sedang ingin apa?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: brown,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Pilih salah satu untuk meminta rekomendasi dari AI.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 12),

                // PILIHAN KONDISI
                ...pilihanRekomendasi.map((pilihan) {
                  final aktif =
                      pilihanAktif == pilihan['judul'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: InkWell(
                      onTap: isSending
                          ? null
                          : () => pilihRekomendasi(pilihan),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: aktif
                              ? teal.withValues(alpha: 0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: aktif ? teal : borderColor,
                            width: aktif ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 39,
                              height: 39,
                              decoration: BoxDecoration(
                                color: (pilihan['warna'] as Color)
                                    .withValues(alpha: 0.13),
                                borderRadius:
                                    BorderRadius.circular(11),
                              ),
                              child: Icon(
                                pilihan['ikon'] as IconData,
                                color: pilihan['warna'] as Color,
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pilihan['judul'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: brown,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    pilihan['deskripsi'],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              aktif
                                  ? Icons.check_circle
                                  : Icons.arrow_forward_ios,
                              color: aktif ? teal : Colors.black38,
                              size: 17,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 12),

                // REKOMENDASI MENU DARI DATABASE
                if (pilihanAktif.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 8),

                  Text(
                    'Menu: $pilihanAktif',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: brown,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Menu yang tersedia di database REDScan.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25),
                        child: CircularProgressIndicator(
                          color: darkTeal,
                        ),
                      ),
                    )
                  else if (errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            color: Colors.redAccent,
                            size: 30,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Menu belum berhasil dimuat.',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            onPressed: ambilMenu,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                  else if (katalog.isEmpty)
                    const Center(
                      child: Text(
                        'Belum ada menu di database.',
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  else
                    SizedBox(
                      height: 245,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: hasilRekomendasi.length,
                        itemBuilder: (context, index) {
                          return kartuProduk(
                            hasilRekomendasi[index],
                          );
                        },
                      ),
                    ),
                ],

                // AREA PERCAKAPAN
                if (riwayatChat.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  const Text(
                    'Percakapan dengan REDScan AI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: brown,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...riwayatChat.map(gelembungChat),

                  if (isSending) indikatorMengetik(),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),

          // INPUT CHAT
          inputChat(),

          // BAR KERANJANG
          if (produkDipilih.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: borderColor),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    color: darkTeal,
                    size: 23,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$jumlahSemua item dipilih',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: brown,
                          ),
                        ),
                        const Text(
                          'Siap ditambahkan ke pesanan',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: kirimKePesanan,
                    style: FilledButton.styleFrom(
                      backgroundColor: darkTeal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Masukkan ke Pesanan',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}