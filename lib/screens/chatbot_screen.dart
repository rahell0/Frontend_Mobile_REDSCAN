import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool fromUser;
  final bool isTip;

  const ChatMessage({
    required this.text,
    required this.fromUser,
    this.isTip = false,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<ChatMessage> messages = [
    const ChatMessage(
      text: 'Halo! 👋 Aku RED Assistant, asisten menu REDScan. Lagi ingin pesan apa hari ini? Aku bisa bantu rekomendasikan minuman dan makanan sesuai cuaca atau selera kamu.',
      fromUser: false,
    ),
    const ChatMessage(
      text: 'Kalau cuacanya sejuk, menu apa yang cocok?',
      fromUser: true,
    ),
    const ChatMessage(
      text: 'Saat cuaca sejuk, menu hangat bisa jadi pilihan yang nyaman ☁️',
      fromUser: false,
    ),
    const ChatMessage(
      text: '☕ Rekomendasi saat cuaca sejuk\n'
          '• Caffe Latte — kopi susu hangat yang lembut.\n'
          '• Cappuccino — kopi dengan foam susu yang creamy.\n'
          '• Chocolate — pilihan cokelat hangat tanpa kopi.\n'
          '• Butter Croissant — camilan yang cocok menemani minuman hangat.\n\n'
          'Kalau ingin rasa kopi yang lebih kuat, kamu bisa memilih Americano.',
      fromUser: false,
      isTip: true,
    ),
  ];

  final List<String> quickQuestions = const [
    'Cuaca sejuk ☁️',
    'Cuaca panas ☀️',
    'Rekomendasi non-kopi',
    'Menu camilan',
  ];

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void sendMessage([String? suggestedText]) {
    final textToSend = (suggestedText ?? messageController.text).trim();
    if (textToSend.isEmpty) return;

    setState(() {
      messages.add(ChatMessage(text: textToSend, fromUser: true));
      messageController.clear();
    });

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final lower = textToSend.toLowerCase();
      String answer;

      if (lower.contains('sejuk') || lower.contains('dingin') || lower.contains('hujan')) {
        answer = '☁️ Kalau cuaca sedang sejuk atau hujan, coba menu yang hangat:\n\n'
            '• Caffe Latte — kopi susu hangat dengan rasa lembut.\n'
            '• Cappuccino — kopi dan foam susu yang creamy.\n'
            '• Chocolate — cokelat hangat untuk pilihan non-kopi.\n'
            '• Americano — cocok kalau kamu suka rasa kopi yang lebih kuat.\n'
            '• Butter Croissant — camilan pendamping minuman hangat.\n\n'
            'Kamu lebih suka kopi atau minuman non-kopi?';
      } else if (lower.contains('panas') || lower.contains('terik') || lower.contains('gerah')) {
        answer = '☀️ Saat cuaca panas, minuman dingin dan menyegarkan bisa jadi pilihan!\n\n'
            '• Peach Tea — rasa teh buah yang segar.\n'
            '• Matcha Latte dingin — creamy dengan rasa matcha.\n'
            '• Americano dingin — kopi yang ringan dan menyegarkan.\n'
            '• Brown Sugar Latte dingin — kopi susu dengan rasa gula aren.\n'
            '• Chocolate dingin — pilihan manis tanpa kopi.\n\n'
            'Ketersediaan versi panas/dingin bergantung pada pilihan yang tersedia di outlet.';
      } else if (lower.contains('non-kopi') || lower.contains('tanpa kopi')) {
        answer = 'Kalau ingin minuman tanpa kopi, kamu bisa mencoba Chocolate atau Matcha Latte. Untuk rasa yang lebih segar saat cuaca panas, pilih Peach Tea. Saat cuaca sejuk, Chocolate hangat bisa jadi pilihan. ☕';
      } else if (lower.contains('camilan') || lower.contains('snack') || lower.contains('makanan')) {
        answer = 'Untuk camilan, kamu bisa mencoba Butter Croissant atau Cinnamon Roll. Saat cuaca sejuk, camilan pastry cocok dipasangkan dengan Caffe Latte atau Chocolate hangat. Saat cuaca panas, coba padukan dengan Peach Tea. 🥐';
      } else if (lower.contains('menu') || lower.contains('rekomendasi') || lower.contains('sarankan')) {
        answer = 'Aku bisa bantu memilih menu berdasarkan cuaca! ☁️ Cuaca sejuk: Caffe Latte, Cappuccino, Chocolate hangat, atau Butter Croissant. ☀️ Cuaca panas: Peach Tea, Americano dingin, Matcha Latte dingin, atau Brown Sugar Latte dingin. Mau rekomendasi untuk cuaca sejuk atau panas?';
      } else {
        answer = 'Aku bisa membantu merekomendasikan menu berdasarkan cuaca dan selera kamu. ☁️ Coba tanyakan “menu saat cuaca sejuk” atau ☀️ “menu saat cuaca panas”. Kamu juga bisa meminta rekomendasi minuman non-kopi atau camilan.\n\nCatatan: rekomendasi ini berdasarkan menu contoh di aplikasi; chatbot belum terhubung ke cuaca aktual atau stok outlet.';
      }

      setState(() {
        messages.add(ChatMessage(text: answer, fromUser: false));
      });
      scrollToBottom();
    });
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Kembali ke Pesanan',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF496F72)),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF527D7F),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text(
                'R',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 9),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RED Assistant AI',
                    style: TextStyle(
                      color: Color(0xFF27333A),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Asisten Rekomendasi Menu',
                        style: TextStyle(
                          color: Color(0xFF687781),
                          fontSize: 9,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.circle, size: 6, color: Color(0xFF20A875)),
                      SizedBox(width: 3),
                      Text(
                        'Online',
                        style: TextStyle(
                          color: Color(0xFF16845B),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFEAF0F1),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              child: const Row(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 14, color: Color(0xFF527D7F)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Bantu pilih menu sesuai cuaca dan selera',
                      style: TextStyle(fontSize: 10, color: Color(0xFF40545A)),
                    ),
                  ),
                  Text(
                    'Menu AI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF456F74),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _messageBubble(message);
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(9, 8, 9, 10),
              child: Column(
                children: [
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: quickQuestions.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 6),
                      itemBuilder: (context, index) {
                        return ActionChip(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          label: Text(
                            quickQuestions[index],
                            style: const TextStyle(fontSize: 9),
                          ),
                          onPressed: () => sendMessage(quickQuestions[index]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lampiran belum tersedia di demo.'),
                            ),
                          );
                        },
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        color: const Color(0xFF70858A),
                      ),
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          minLines: 1,
                          maxLines: 3,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => sendMessage(),
                          decoration: InputDecoration(
                            hintText: 'Tanyakan menu yang cocok untukmu...',
                            hintStyle: const TextStyle(fontSize: 10),
                            filled: true,
                            fillColor: const Color(0xFFF4F6F7),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton.filled(
                        tooltip: 'Kirim pesan',
                        onPressed: () => sendMessage(),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF527D7F),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.send_rounded, size: 17),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageBubble(ChatMessage message) {
    if (message.fromUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          margin: const EdgeInsets.only(left: 42, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF527D7F),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(13),
              bottomRight: Radius.circular(13),
            ),
          ),
          child: Text(
            message.text,
            style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.45),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 7, top: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF527D7F),
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: const Text(
              'R',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(13),
                  bottomLeft: Radius.circular(13),
                  bottomRight: Radius.circular(13),
                ),
                border: Border.all(color: const Color(0xFFE0E7E9)),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Color(0xFF34454B),
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HALAMAN KONFIRMASI PESANAN TUNAI
// ============================================================

