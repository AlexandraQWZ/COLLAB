import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'kelompok'.i18n(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'nama_tim'.i18n(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16), 
            Text(
              'topik'.i18n(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24), 
            Text(
              'anggota'.i18n(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. ALEXANDRA - 221110391',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '2. CHRISTOPHER LUHUR - 221111366',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '3. CALVIN CHRISTOFEL SIBUEA - 221113372',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
