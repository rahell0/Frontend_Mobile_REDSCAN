
import 'package:flutter/material.dart';

// ============================================================
// WARNA UTAMA REDSCAN
// ============================================================

const Color brown = Color(0xFF402719);
const Color darkBrown = Color(0xFF2F1D13);
const Color cream = Color(0xFFE9E1CF);
const Color teal = Color(0xFF648F94);
const Color darkTeal = Color(0xFF456F74);
const Color pageColor = Color(0xFFF7F6F2);
const Color borderColor = Color(0xFFE6E1DA);

// ============================================================
// MODEL PRODUK
// ============================================================

class Produk {
  final int? id;
  final String nama;
  final String kategori;
  final int harga;
  final IconData ikon;

  // ALAMAT GAMBAR DARI BACKEND
  final String? gambar;

  // JUMLAH PRODUK
  int jumlah;

  Produk({
    this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    this.ikon = Icons.local_cafe_outlined,
    this.gambar,
    this.jumlah = 1,
  });

  // ==========================================================
  // MENYALIN DATA PRODUK
  // ==========================================================

  Produk salin({
    int? jumlahBaru,
  }) {
    return Produk(
      id: id,
      nama: nama,
      kategori: kategori,
      harga: harga,
      ikon: ikon,

      // GAMBAR TETAP IKUT DISALIN
      gambar: gambar,

      jumlah: jumlahBaru ?? jumlah,
    );
  }
}

// ============================================================
// BOTTOM NAVIGATION ITEM
// ============================================================

class BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool aktif;

  const BottomItem({
    super.key,
    required this.icon,
    required this.label,
    this.aktif = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color warna =
        aktif ? darkTeal : const Color(0xFF806E5F);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 19,
          color: warna,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: warna,
            fontWeight:
                aktif ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// KOMPONEN KARTU
// ============================================================

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? trailing;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: darkTeal,
                size: 18,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (trailing != null)
                Flexible(
                  child: Text(
                    trailing!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.black54,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ============================================================
// LABEL FORM
// ============================================================

class FieldLabel extends StatelessWidget {
  final String text;

  const FieldLabel(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ============================================================
// KOMPONEN INPUT
// ============================================================

InputDecoration inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      fontSize: 11,
      color: Colors.black38,
    ),
    filled: true,
    fillColor: const Color(0xFFFCFCFC),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 12,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: borderColor,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: borderColor,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: teal,
        width: 1.5,
      ),
    ),
  );
}

// ============================================================
// TOMBOL JUMLAH PRODUK
// ============================================================

Widget quantityButton({
  required IconData icon,
  required VoidCallback onTap,
}) {
  return SizedBox(
    width: 30,
    height: 30,
    child: IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: darkTeal,
        side: const BorderSide(
          color: borderColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(
        icon,
        size: 16,
      ),
    ),
  );
}

// ============================================================
// BARIS HARGA
// ============================================================

Widget priceRow(
  String label,
  String value,
) {
  return Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
          ),
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    ],
  );
}
