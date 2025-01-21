import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class TambahKategoriPage extends StatelessWidget {
  const TambahKategoriPage({super.key, required this.onAddCategory});
  final Function(String) onAddCategory;

  @override
  Widget build(BuildContext context) {
    String newCategory = "";

    return AlertDialog(
      title: Text("tambah_kategori".i18n()),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newCategory = value;
                },
                decoration: InputDecoration(hintText: "nama_kategori".i18n()),
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (newCategory.isNotEmpty) {
              onAddCategory(newCategory);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("kategori_kosong".i18n()),
                ),
              );
            }
          },
          child: Text("tambah".i18n()),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("batal".i18n()),
        ),
      ],
    );
  }
}
