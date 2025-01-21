import 'package:flutter/material.dart';
import 'package:collab_mitra/pages/data/data_model.dart';
import 'package:collab_mitra/pages/data/data_service.dart';
import 'package:collab_mitra/widgets/detail_page.dart';
import 'package:localization/localization.dart';

class InspirasiPage extends StatelessWidget {
  InspirasiPage({super.key});
  final DataService dataService = DataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'inspirasi'.i18n(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<List<Inspiration>>(
        future: dataService.fetchInspirations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found'));
          } else {
            final inspirations = snapshot.data!;
            return ListView.builder(
              itemCount: inspirations.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 2,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            title: inspirations[index].title,
                            content: inspirations[index].story,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(
                        inspirations[index].title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Tap to view story'), 
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
