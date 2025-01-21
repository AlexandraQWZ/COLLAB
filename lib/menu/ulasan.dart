import 'package:flutter/material.dart';

// ignore: use_key_in_widget_constructors
class UlasanPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _UlasanPageState createState() => _UlasanPageState();
}

class _UlasanPageState extends State<UlasanPage> {
  final List<String> reviews = [
    "Review 1: Sangat memuaskan!",
    "Review 2: Layanan yang baik.",
    "Review 3: Produk sesuai dengan deskripsi.",
  ];

  void _addReview(String review) {
    setState(() {
      reviews.add(review);
    });
  }

  void _showAddReviewDialog() {
    String newReview = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Ulasan'),
          content: TextField(
            onChanged: (value) {
              newReview = value;
            },
            decoration: const InputDecoration(hintText: "Masukkan ulasan"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newReview.isNotEmpty) {
                  _addReview(newReview);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Simpan'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulasan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddReviewDialog,
          ),
        ],
      ),
      body: reviews.isEmpty
          ? const Center(
              child: Text(
                'Belum Ada Ulasan',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(reviews[index]),
                );
              },
            ),
    );
  }
}
