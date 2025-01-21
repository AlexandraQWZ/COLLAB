// ignore_for_file: avoid_print, depend_on_referenced_packages, use_build_context_synchronously
import 'dart:io';
import 'dart:typed_data';
import '../database/event_model.dart';
import '../database/fbhelper.dart';
import '../database/provider.dart';
import '../notification/notification_controller.dart';
import '../widgets/dashboard_mitra.dart';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:localization/localization.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  // late EventModel hasil;
  FirebaseHelper firebase = FirebaseHelper();
  TextEditingController searchController = TextEditingController();
  TextEditingController orderController = TextEditingController();
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> order = [];
  List<String> filteredCategories = [];
  final Map<String, List<TextEditingController>> _controllers = {};
  late EventModel hasil;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProviderHelper>(context, listen: false);
    Future.microtask(() {
      getData(provider.uid[0]);
    });
    _loadBudget();
    filteredCategories = categories;
    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications().then(
            (value) => Navigator.pop(context),
          );
        }
      },
    );
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (receivedAction) =>
          NotificationController.onActionReceivedMethod(
              context, receivedAction),
    );
  }

  Future<void> createBasicNotification(String nilai) async {
    await AwesomeNotifications().createNotification(
        // actionButtons: [
        //   NotificationActionButton(key: "open_notify", label: "open")
        // ],
        content: NotificationContent(
            id: 0,
            channelKey: "anggaran",
            title: "Pencapaian pendapatan!!",
            body: "Selamat pendapatan anda mencapai Rp. $nilai"));
  }

  List<String> tanggal = [];
  String total = '';
  int? _currentBudget;
  Future<void> _loadBudget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentBudget = prefs.getInt('budget') ?? 0;
    });
  }

  void susun(List<Map<String, dynamic>> orders) {
    int dapat = 0;
    setState(() {
      for (var item in order) {
        if (!tanggal.contains(item['date'])) {
          tanggal.add(item['date']);
        }
        int price = int.parse(item['price'].split('.')[0]);
        dapat += price * int.parse(item['unit']);
      }
      total = dapat.toString();
      if (int.parse(total) > _currentBudget!) {
        createBasicNotification(total);
      }
    });
  }

  String formatPrice(double price) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2);
    return formatter.format(price);
  }

  List<String> categories = [
    // 'buah-buahan'
  ];
  Map<String, List<Map<String, dynamic>>> groupedProducts = {};
  void _proses(List<String> category, Map<String, List> groupedProduct) async {
    final provider = Provider.of<ProviderHelper>(context, listen: false);
    String uid = provider.uid[0];
    String jsonCategory = jsonEncode(category); //List<String>
    String jsonGroupedProducts = jsonEncode(groupedProduct);
    String orderItem = jsonEncode(order); //Map<String, List>
    List list = await firebase.getData();
    List list2 = list.where((e) => e.uid == uid).toList();
    print(list2);
    if (list2.isEmpty) {
      firebase.addData(EventModel(
          uid: uid,
          category: jsonCategory,
          terjual: orderItem,
          groupedProducts: jsonGroupedProducts));
      print('berhasil ditambahkan');
    } else {
      await firebase.updateData(
          uid,
          EventModel(
              uid: uid,
              category: jsonCategory,
              terjual: orderItem,
              groupedProducts: jsonGroupedProducts));
      print('berhasil ubah');
    }
  }

  void _filterProducts(String query) {
    List<String> tempCategory = List.from(categories);
    List<Map<String, dynamic>> matchedProducts = [];
    for (var item in categories) {
      List temp = groupedProducts[item]!
          .where((product) => product['isActive'] == false)
          .toList();
      if (groupedProducts[item]!.length == temp.length) {
        tempCategory.remove(item);
      }
    }
    if (query.isEmpty) {
      setState(() {
        filteredCategories = tempCategory;
        filteredProducts = [];
      });
    } else {
      for (var element in tempCategory) {
        matchedProducts = groupedProducts[element]!.where((product) {
          return product['name']
                  .toLowerCase()
                  .startsWith(query.toLowerCase()) &&
              product['isActive'] == true;
        }).toList();
      }
      List<String> matchedCategories = tempCategory.where((category) {
        return category.toLowerCase().startsWith(query.toLowerCase(), 0);
      }).toList();

      if (matchedCategories.isEmpty == false) {
        setState(() {
          filteredCategories = matchedCategories;
        });
      } else {
        for (String element in categories) {
          List<Map<String, dynamic>> matched =
              groupedProducts[element]!.where((category) {
            return category['name']
                .toLowerCase()
                .startsWith(query.toLowerCase());
          }).toList();
          if (matched.isEmpty) {
            tempCategory.remove(element);
          }
        }
        setState(() {
          filteredCategories = tempCategory;
          filteredProducts = matchedProducts;
        });
      }
    }
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
        categories = List<String>.from(jsonDecode(hasil.category));
        if(hasil.terjual.isNotEmpty) {
          order = List<Map<String, dynamic>>.from(jsonDecode(hasil.terjual));
        }
        groupedProducts =
            (jsonDecode(hasil.groupedProducts) as Map<String, dynamic>)
                .map((key, value) => MapEntry(
                      key,
                      (value as List)
                          .map((item) => Map<String, dynamic>.from(item))
                          .toList(),
                    ));
        List<String> tempCategory = List.from(categories);
        for (String element in categories) {
          if(groupedProducts[element] == null) {
            tempCategory.remove(element);
            continue;
          }
          List<Map<String, dynamic>> matched =
              groupedProducts[element]!.where((category) {
            return category['isActive'] == true;
          }).toList();
          if (matched.isEmpty) {
            tempCategory.remove(element);
          }
        }
        filteredCategories = tempCategory;
        simpanOrder();
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void simpanOrder() {
    int counter1 = 0;
    for (String category in filteredCategories) {
      if (groupedProducts.containsKey(category) && groupedProducts[category] != null) {
        for (int i = 0; i < groupedProducts[category]!.length; i++) {
          // masalah di key
          String key = '${counter1}_$i';
          String quantity = groupedProducts[category]![i]['unit'];
          setState(() {
            _controllers[key] = [
              TextEditingController(text: quantity),
              TextEditingController(text: '0')
            ];
            print(_controllers);
          });
        }
        counter1 += 1;
      } else {
        continue;
      }
    }
  }

  void orderToRiwayat() {
    for (var entry in _controllers.entries) {
      String category = filteredCategories[int.parse(entry.key.split('_')[0])];
      int product = int.parse(entry.key.split('_')[1]);
      int quantity = int.parse(_controllers[entry.key]![1].text);
      int available = int.parse(_controllers[entry.key]![0].text);
      print(available);
      available -= quantity;

      groupedProducts[category]![product]['unit'] = available.toString();
      Map<String, dynamic> item = groupedProducts[category]![product];
      DateTime today = DateTime.now();

      // Format ke "2 Jan 2024"
      String formattedDate = DateFormat('d MMM yyyy').format(today);

      // print('Tanggal: $formattedDate');
      if (quantity > 0) {
        Map<String, dynamic> products = {
          'name': item['name'],
          'unit': quantity.toString(),
          'price': item['price'].toString(),
          'imagePath': item['imagePath'],
          'date': formattedDate
        };
        setState(() {
          order.add(products);
        });
      }

      setState(() {
        _controllers[entry.key]![0].text = available.toString();
        _controllers[entry.key]![1].text = '0';
      });
    }
    _proses(categories, groupedProducts);
  }

  void _decrement(String key) {
    // int counter = int.parse(orderController.text);
    int counter1 = int.parse(_controllers[key]![1].text);
    // int counter2 = int.parse(_controllers[key]![0].text);
    if (counter1 > 0) {
      counter1 -= 1;
      counter -= 1;
    }
    setState(() {
      _controllers[key]![1].text =
          counter1.toString(); // Perbarui teks tanpa membuat objek baru
    });
  }

  void _increment(String key) {
    // int counter = int.parse(orderController.text);
    int counter1 = int.parse(_controllers[key]![1].text);
    int counter2 = int.parse(_controllers[key]![0].text);
    if (counter1 < counter2) {
      counter1 += 1;
      counter += 1;
    }
    setState(() {
      _controllers[key]![1].text =
          counter1.toString(); // Perbarui teks tanpa membuat objek baru
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('pesanan'.i18n()),
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DashboardMitra()));
            }),
      ),
      body: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          TextField(
            controller: searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '${'cari'.i18n()}...',
              border: InputBorder.none,
            ),
            onChanged: _filterProducts,
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                String category = filteredCategories[index];
                return ExpansionTile(
                  title: Text(
                    category,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  children: groupedProducts[category]?.where((product) {
                        return product['isActive'] == true;
                      }).map((product) {
                        int productIndex =
                            groupedProducts[category]!.indexOf(product);
                        String key = '${index}_$productIndex';
                        String temp = _controllers[key]![1].text;
                        String temp2 = _controllers[key]![0].text;
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: product['imagePath'] != null &&
                                          product['imagePath'].isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.file(File(product['imagePath']!),
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
                                        formatPrice(product['price']),
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700]),
                                      ),
                                      if (!product['isActive'])
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        _decrement(key);
                                      },
                                    ),
                                    SizedBox(
                                      width: 40,
                                      child: TextField(
                                        controller: _controllers[key]![1],
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {
                                            int hitung1 = int.parse(temp);
                                            int hitung2 = int.parse(value);
                                            if (hitung2 <= int.parse(temp2)) {
                                              if (hitung2 > hitung1) {
                                                counter += (hitung2 - hitung1);
                                              } else {
                                                counter -= (hitung1 - hitung2);
                                              }
                                              print(counter);
                                              _controllers[key]![1].text =
                                                  value.toString();
                                            } else {
                                              _controllers[key]![1].text = '0';
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        _increment(key);
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList() ??
                      [],
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: counter > 0
                  ? () {
                      print(_controllers);
                      orderToRiwayat();
                      susun(order);
                      print('Tombol Pesan Ditekan');
                    }
                  : null,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) {
                    if (counter == 0) {
                      // WidgetState.disabled;
                      return Colors.grey; // Warna ketika counter == 0
                    }
                    return Colors.green; // Warna default
                  },
                ),
              ),
              child: Text('pesanan'.i18n()),
            ),
          ),
        ]),
      ),
    );
  }
}
