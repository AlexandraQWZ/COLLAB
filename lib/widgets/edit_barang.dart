
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class EditBarangPage extends StatefulWidget {
  final String initialProductName;
  final String initialUnit;
  final double initialPrice;
  final Function(String, String, double) onUpdateProduct;
  final Function() onDeleteProduct;

  const EditBarangPage({
    super.key,
    required this.initialProductName,
    required this.initialUnit,
    required this.initialPrice,
    required this.onUpdateProduct,
    required this.onDeleteProduct,
  });

  @override
  State<EditBarangPage> createState() => _EditKategoriPageState();
}

class _EditKategoriPageState extends State<EditBarangPage> {
  late TextEditingController _productNameController;
  late TextEditingController _unitController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _productNameController =
        TextEditingController(text: widget.initialProductName);
    _unitController = TextEditingController(text: widget.initialUnit);
    _priceController =
        TextEditingController(text: widget.initialPrice.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('edit_barang'.i18n()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'nama_barang'.i18n(),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _productNameController,
              decoration:
                  InputDecoration(hintText: 'masukkan_nama_barang'.i18n()),
            ),
            const SizedBox(height: 20),
            Text(
              'unit'.i18n(),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _unitController,
              decoration: InputDecoration(hintText: 'masukkan_unit'.i18n()),
            ),
            const SizedBox(height: 20),
            Text(
              'harga'.i18n(),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'masukkan_harga'.i18n()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onUpdateProduct(
                    _productNameController.text,
                    _unitController.text,
                    double.tryParse(_priceController.text) ?? 0);
                Navigator.of(context).pop();
              },
              child: Text('simpan'.i18n()),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                widget.onDeleteProduct();
                Navigator.of(context).pop();
              },
              child: Text('hapus_barang'.i18n()),
            ),
          ],
        ),
      ),
    );
  }
}
