import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:localization/localization.dart';

class TambahBarangPage extends StatefulWidget {
  final List<String> categories;
  final Function(String, String, double, String?, String) onAddProduct;

  const TambahBarangPage({
    super.key,
    required this.categories,
    required this.onAddProduct,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TambahBarangPageState createState() => _TambahBarangPageState();
}

class _TambahBarangPageState extends State<TambahBarangPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedCategory;
  String? _imagePath;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final StreamController<double> _progressStreamController =
      StreamController<double>();

  Future<void> _pickImage() async {
    _progressStreamController.add(0.0);
    _isLoading = true;
    setState(() {});

    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      for (double progress = 0.1; progress <= 1.0; progress += 0.1) {
        await Future.delayed(const Duration(milliseconds: 100));
        _progressStreamController.add(progress);
      }

      _progressStreamController.add(1.0);
      setState(() {
        _imagePath = pickedFile.path;
        _isLoading = false;
      });
    } else {
      _isLoading = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _progressStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('tambah_barang'.i18n()),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text('nama_barang'.i18n()),
            TextField(
              controller: _nameController,
              decoration:
                  InputDecoration(hintText: 'masukkan_nama_barang'.i18n()),
            ),
            const SizedBox(height: 10),
            Text('unit'.i18n()),
            TextField(
              controller: _unitController,
              decoration: InputDecoration(hintText: 'masukkan_unit'.i18n()),
            ),
            const SizedBox(height: 10),
            Text('harga'.i18n()),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'masukkan_harga'.i18n()),
            ),
            const SizedBox(height: 10),
            Text('unggah_gambar'.i18n()),
            StreamBuilder<double>(
              stream: _progressStreamController.stream,
              builder: (context, snapshot) {
                if (_isLoading) {
                  return Column(
                    children: [
                      LinearProgressIndicator(value: snapshot.data),
                      const SizedBox(height: 10),
                      Text(
                        "${'muat_gambar'.i18n()}... ${(snapshot.data! * 100).toInt()}%",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  );
                } else if (_imagePath != null) {
                  return GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Image.file(
                              File(_imagePath!),
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            )),
                        const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 50,
                        ), //membuat ikon kamera didepan gambar
                      ],
                    ),
                  );
                } else {
                  return TextButton(
                    onPressed: _pickImage,
                    child: Text('pilih_gambar'.i18n()),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              hint: Text('pilih_kategori'.i18n()),
              items: widget.categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              icon: const Icon(Icons.arrow_drop_down),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            String name = _nameController.text;
            String unit = _unitController.text;
            double price;

            if (name.isEmpty || unit.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${'kalimat_unit'.i18n()}!')),
              );
              return;
            }

            if (_selectedCategory == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${'kalimat_kategori'.i18n()}!')),
              );
              return;
            }

            try {
              price = double.parse(_priceController.text);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${'kalimat_harga'.i18n()}!')),
              );
              return;
            }
            widget.onAddProduct(
                name, unit, price, _selectedCategory, _imagePath!);
            Navigator.of(context).pop();
          },
          child: Text('tambah'.i18n()),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('batal'.i18n()),
        ),
      ],
    );
  }
}
