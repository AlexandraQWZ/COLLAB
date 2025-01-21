import 'package:flutter/material.dart';

// ignore: use_key_in_widget_constructors
class Keuangan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keuangan'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Halaman Keuangan',
                style: TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    title: Text('Transaksi 1'),
                    subtitle: Text('Detail transaksi 1'),
                    trailing: Text('Rp 100.000'),
                  ),
                  ListTile(
                    title: Text('Transaksi 2'),
                    subtitle: Text('Detail transaksi 2'),
                    trailing: Text('Rp 200.000'),
                  ),
                  ListTile(
                    title: Text('Transaksi 3'),
                    subtitle: Text('Detail transaksi 3'),
                    trailing: Text('Rp 300.000'),
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
