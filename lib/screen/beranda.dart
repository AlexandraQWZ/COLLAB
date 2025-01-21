import '../notification/setting_anggaran.dart';
import '../database/event_model.dart';
import '../database/fbhelper.dart';
import '../database/provider.dart';
import '../pages/inspirasi.dart';
import '../pages/team.dart';
import '../pages/tips.dart';
import '../menu/pesanan.dart';
import '../menu/katalog.dart';
import 'package:localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  FirebaseHelper firebase = FirebaseHelper();
  List<Map<String, dynamic>> order = [];
  List<String> tanggal = [];
  String total = '0';
  List<Map<String, dynamic>> salesData = [];
  late EventModel hasil;

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
      int dapat = 0;
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
          // print(order);
          for (var item in order) {
            if (!tanggal.contains(item['date'])) {
              tanggal.add(item['date']);
            }
            int price = int.parse(item['price'].split('.')[0]);
            dapat += price * int.parse(item['unit']);
          }
          total = dapat.toString();
          // print(total);
          susun(order);
        }
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void susun(List<Map<String, dynamic>> orders) {
    List order2 = List.from(orders);
    for (var i = 0; i < tanggal.length; i++) {
      String date = tanggal[i];
      salesData.add({"date": date, "income": 0.0});
      for (var item in order2) {
        if (item['date'] == date) {
          salesData[i]['income'] += double.parse(item['price'].split('.')[0]) *
              int.parse(item['unit']);
        }
      }
    }
    int selisihIndex = salesData.length - 5;
    List<int> index = [];
    for (var i = 0; i < selisihIndex; i++) {
      index.add(i);
    }
    for (var i = 0; i < index.length; i++) {
      salesData.removeAt(i);
      tanggal.removeAt(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'JayaMart',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              // margin: const EdgeInsets.only(top: 20),
              color: Colors.greenAccent,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingAnggaranPage(),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'penghasilan_total'.i18n(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp $total,-',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconButton(context, Icons.shopping_bag, 'pesanan', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PesananPage()),
                    );
                  }),
                  _buildIconButton(context, Icons.list_alt, 'katalog', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const KatalogPage()),
                    );
                  }),
                ],
              ),
            ),
            // const SizedBox(height: 60),
            // masukkan chart disini
            // tanggal.isEmpty ? Container() :
            // Expanded(
            //   child: SizedBox(
            //     width: 400,
            //     height: 300,
            //     child: LineChart(
            //       LineChartData(
            //         minY: 0,
            //         maxX: 4,
            //         maxY: 4,
            //         gridData: FlGridData(
            //           show: true,
            //           getDrawingHorizontalLine: (value) {
            //             return const FlLine(
            //               color: Colors.black26,
            //               strokeWidth: 0.5,
            //             );
            //           },
            //           getDrawingVerticalLine: (value) {
            //             return const FlLine(
            //               color: Colors.black26,
            //               strokeWidth: 0.5,
            //             );
            //           },
            //         ), // Menyembunyikan grid
            //         titlesData: FlTitlesData(
            //           bottomTitles: AxisTitles(
            //             sideTitles: SideTitles(
            //               interval: 1,
            //               showTitles: true,
            //               getTitlesWidget: (value, meta) {
            //                 final index = value.toInt() % tanggal.length;
            //                 final label = tanggal[index];
            //                 return SideTitleWidget(
            //                     space: 3.0,
            //                     axisSide: AxisSide.bottom,
            //                     child: Text(label,
            //                         style: const TextStyle(fontSize: 10)));
            //               },
            //             ),
            //           ),
            //           leftTitles: AxisTitles(
            //               sideTitles: SideTitles(
            //             showTitles: true,
            //             interval: 1,
            //             reservedSize: 50,
            //             getTitlesWidget: (value, meta) {
            //               // print(value);
            //               final data = ['0', '400', '800', '1200', '1600'];
            //               final index = value.toInt() % 5;
            //               final label = data[index];
            //               return SideTitleWidget(
            //                 space: 3.0,
            //                 axisSide: AxisSide.bottom,
            //                 child:
            //                     Text(label, style: const TextStyle(fontSize: 10)),
            //               );
            //             },
            //           )),
            //           rightTitles: const AxisTitles(
            //               sideTitles: SideTitles(showTitles: false)),
            //           topTitles: const AxisTitles(
            //               sideTitles: SideTitles(showTitles: false)),
            //         ),
            //         // Menyembunyikan title
            //         borderData: FlBorderData(show: true), // Menyembunyikan border
            //         lineBarsData: [
            //           LineChartBarData(
            //             spots: List<FlSpot>.generate(
            //               salesData.length,
            //               (index) => FlSpot(index.toDouble(),
            //                   salesData[index]['income'] / 400000),
            //             ),
            //             isCurved: true, // Membuat garis melengkung
            //             color: Colors.blue, // Warna garis
            //             dotData:
            //                 const FlDotData(show: true), // Menyembunyikan titik
            //             belowBarData: BarAreaData(
            //                 show: true), // Menyembunyikan area bawah garis
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            // ===================
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Info',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(3, (index) {
                        String title = '';
                        switch (index) {
                          case 0:
                            title = 'kelompok';
                            break;
                          case 1:
                            title = 'tips';
                            break;
                          case 2:
                            title = 'inspirasi';
                            break;
                        }
                        return GestureDetector(
                          onTap: () {
                            switch (index) {
                              case 0:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TeamPage()),
                                );
                                break;
                              case 1:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TipsPage()),
                                );
                                break;
                              case 2:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => InspirasiPage()),
                                );
                                break;
                            }
                          },
                          child: Container(
                            width: 200,
                            height: 70,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(title.i18n()),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, String label,
      VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 50),
          onPressed: onPressed,
        ),
        const SizedBox(height: 5),
        Text(
          '    ${label.i18n()}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
