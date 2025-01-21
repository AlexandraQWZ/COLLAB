// ignore_for_file: avoid_print

import 'dart:typed_data';
import '../database/event_model.dart';
import '../database/fbhelper.dart';
import '../database/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localization/localization.dart';

class Riwayat extends StatefulWidget {
  const Riwayat({super.key});

  @override
  State<Riwayat> createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  FirebaseHelper firebase = FirebaseHelper();
  List<Map<String, dynamic>> order = [];
  List<String> tanggal = [];
  List<List> itemOrder = [];
  late EventModel hasil;
  late Uint8List imageBytes;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProviderHelper>(context, listen: false);
    Future.microtask(() {
      getData(provider.uid[0]);
    });
  }

  void getData(String uid) async {
    try {
      List list = await firebase.getData();
      setState(() {
        for (int i = 0; i < list.length; i++) {
          if (list[i].uid == uid) {
            hasil = list[i];
            break;
          }
        }
        if (hasil.terjual.isNotEmpty) {
          order = List<Map<String, dynamic>>.from(jsonDecode(hasil.terjual));
          for (var item in order) {
            if (!tanggal.contains(item['date'])) {
              setState(() {
                tanggal.add(item['date']);
              });
            }
          }
          susun(order);
        }
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  List<Map<String, dynamic>> simpan = [];
  void susun(List<Map<String, dynamic>> orders) {
    List itemTemp = [];
    List order2 = List.from(orders);
    for (String date in tanggal) {
      for (var item in order2) {
        if (item['date'] == date) {
          itemTemp.add(item);
        }
      }
      itemOrder.add(itemTemp);
      Map<String, Map<String, dynamic>> groupedItems = {};
      for (var item in itemTemp) {
        String name = item['name'];
        int unit = int.parse(item['unit']);
        int price = int.parse(item['price'].split('.')[0]);
        if (groupedItems.containsKey(name)) {
          // Jika item dengan nama yang sama sudah ada, tambahkan unit
          groupedItems[name]!['unit'] += unit;
        } else {
          // Jika belum ada, tambahkan sebagai elemen baru
          groupedItems[name] = {
            'name': item['name'],
            'unit': unit,
            'price': price,
            'date': item['date']
          };
        }
      }

      // Ubah Map menjadi List
      for (var item in groupedItems.entries) {
        simpan.add(item.value);
      }
      itemTemp = [];
    }
    print(simpan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'riwayat'.i18n(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          automaticallyImplyLeading: false,
        ),
        body: tanggal.isEmpty
            ? const Text('')
            : Container(
              decoration: BoxDecoration(
                color: Colors.grey[200]
              ),
              child: ListView.builder(
                  itemCount: tanggal.length,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                  child: Text(
                                tanggal[index],
                                // 'baa',
                                style: const TextStyle(fontSize: 24),
                              )),
                              ...itemOrder[index].map((product) {
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: product['imagePath'] != null &&
                                                  product['imagePath']!.isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
                                                  child: Image.file(
                                                    File(product['imagePath']),
                                                    fit: BoxFit.cover,
                                                    height: 100,
                                                    width: double.infinity,
                                                  ),
                                                )
                                              : Container(
                                                  color: Colors.grey[200],
                                                  height: 100,
                                                  child: const Center(
                                                      child: Text('Image')),
                                                ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${product['name']}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                product['unit'],
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700]),
                                              ),
                                              Text(
                                                product['price'],
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700]),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                            ]));
                  }),
            ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            exportToExcel(simpan, 'Riwayat Penjuala');
            // print(itemOrder);
          },
          child: const Icon(Icons.download),
        ));
  }

  void exportToExcel(List<Map<String, dynamic>> salesData, String name) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['SalesData'];

    sheetObject.appendRow([
      TextCellValue('Date'),
      TextCellValue('product'),
      TextCellValue('quantity'),
      TextCellValue('price'),
      TextCellValue('total'),
    ]);

    for (var i = 0; i < salesData.length; i++) {
      int total = salesData[i]['price'] * salesData[i]['unit'];
      print(total);
      // sheetObject.appendRow([
      //   TextCellValue(salesData[i]['date']),
      //   TextCellValue(salesData[i]['product']),
      //   TextCellValue(salesData[i]['unit'].toString()),
      //   TextCellValue(salesData[i]['price'].toString()),
      //   TextCellValue(total.toString()),
      // ]);
      sheetObject.appendRow([
        TextCellValue(salesData[i]['date']),
        TextCellValue(salesData[i]['name']),
        TextCellValue(salesData[i]['unit'].toString()),
        TextCellValue(salesData[i]['price'].toString()),
        TextCellValue(total.toString()),
      ]);
    }

    writeCounter(excel, name);

    print("File berhasil di simpan");
    // const path = '/storage/emulated/0/Download';
    // final file = File('$path/$name.xlsx');
    // file.writeAsBytes(excel.encode()!);
  }

  Future<File> writeCounter(Excel excel, String name) async {
    // final path = await _localPath;
    const path = '/storage/emulated/0/Download';
    final file = File('$path/$name.xlsx');
    return file.writeAsBytes(excel.encode()!);
  }
}

// [{name: apel minuman keras, price: 10000.0, unit: 2, date: 7 Dec 2024}, {name: Buku 30 lbr, price: 5000.0, unit: 33, date: 17 Dec 2024}, {name: apel minuman, price: 10000.0, unit: 22, date: 20 Dec 2024}, {name: apel minuman, price: 10000.0, unit: 22, date: 20 Dec 2024}]
// File berhasil di simpan
// [
// [
//   {name: apel minuman keras, unit: 2, price: 10000.0, imagePath: null, date: 7 Dec 2024}, simpan = 1
//   {name: apel minuman keras, unit: 1, price: 10000.0, imagePath: null, date: 7 Dec 2024}, 
//   {name: apel minuman keras, unit: 1, price: 10000.0, imagePath: null, date: 7 Dec 2024}, 
//   {name: apel minuman keras, unit: 1, price: 10000.0, imagePath: null, date: 7 Dec 2024}, 
//   {name: Buku 30 lbr, unit: 3, price: 5000.0, imagePath: null, date: 7 Dec 2024}, 
//   {name: apel minuman, unit: 1, price: 10000.0, imagePath: null, date: 7 Dec 2024}, 
//   {name: Buku 30 lbr, unit: 2, price: 5000.0, imagePath: null, date: 7 Dec 2024}], 
//  [
//   {name: Buku 30 lbr, unit: 3, price: 5000.0, imagePath: null, date: 17 Dec 2024}], 
//  [
//   {name: apel minuman, unit: 2, price: 10000.0, imagePath: null, date: 20 Dec 2024}
// ]]