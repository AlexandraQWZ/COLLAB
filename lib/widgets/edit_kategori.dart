import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class EditKategoriPage extends StatelessWidget {
  final String initialCategoryName;
  final ValueChanged<String> onUpdateCategoryName;
  final VoidCallback onDeleteCategory; 

  // ignore: use_key_in_widget_constructors
  const EditKategoriPage({
    required this.initialCategoryName,
    required this.onUpdateCategoryName,
    required this.onDeleteCategory, 
  });

  @override
  Widget build(BuildContext context) {
    String updatedCategoryName = initialCategoryName;
    return Scaffold(
      appBar: AppBar(
        title: Text('edit_kategori'.i18n()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'nama_kategori'.i18n(), 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), 
            ),
            TextField(
              onChanged: (value) {
                updatedCategoryName = value;
              },
              decoration: InputDecoration(hintText: "masuk_kategori".i18n()),
              controller: TextEditingController(text: initialCategoryName),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start, 
              children: [
                ElevatedButton(
                  onPressed: () {
                    onUpdateCategoryName(updatedCategoryName);
                    Navigator.of(context).pop();
                  },
                  child: Text("simpan".i18n()),
                ),
              ],
            ),
            const SizedBox(height: 10), 
            Row(
              mainAxisAlignment: MainAxisAlignment.start, 
              children: [
                ElevatedButton(
                  onPressed: () {
                    onDeleteCategory(); 
                    Navigator.of(context).pop();
                  },
                  // ignore: sort_child_properties_last
                  child: Text("hapus_kategori".i18n()),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red), 
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
