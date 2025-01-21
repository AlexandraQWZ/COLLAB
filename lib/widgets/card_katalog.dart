// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CardKatalog extends StatefulWidget {
  const CardKatalog(
      {super.key,
      required this.product,
      required this.categories,
      required this.productIndex,
      required this.listGrouped,
      required this.mapList,
      required this.process});
  final Map<String, dynamic> product;
  final List<String> categories;
  final int productIndex;
  final List<Map<String, dynamic>> listGrouped;
  final Function process;
  final Map<String, List<Map<String, dynamic>>> mapList;

  @override
  State<CardKatalog> createState() => _CardKatalogState();
}

class _CardKatalogState extends State<CardKatalog> {
  String formatPrice(double price) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2);
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: widget.product['imagePath'] != null &&
                      widget.product['imagePath']!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                         File(widget.product['imagePath']),
                        fit: BoxFit.cover,
                        height: 100,
                        width: double.infinity,
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      height: 100,
                      child: const Center(child: Text('Image')),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.product['name']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product['unit'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  Text(
                    formatPrice(widget.product['price']),
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  if (!widget.product['isActive'])
                    const Text(
                      "Tidak Tersedia",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
            Switch(
              value: widget.product['isActive'],
              onChanged: (value) {
                setState(() {
                  widget.listGrouped[widget.productIndex]['isActive'] = value;
                });
                print(widget.categories);
                Map<String, dynamic> mapSimpan = widget.listGrouped[widget.productIndex];
                for (var entry in widget.mapList.entries) {
                  List<Map<String, dynamic>> valueList = entry.value;
                  for (int i = 0; i < valueList.length; i++) {
                    var item = valueList[i];
                    if (item['nama'] == mapSimpan['name'] && item['unit'] == mapSimpan['unit']) {
                      widget.mapList[entry.key] = valueList;
                    }
                  }
                }
                widget.process(
                    widget.categories, widget.mapList);
              },
            ),
          ],
        ),
      ),
    );
  }
}
