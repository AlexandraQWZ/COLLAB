// ignore_for_file: avoid_print

import 'dart:io';

import '../database/event_model.dart';
import '../database/fbhelper.dart';
import '../database/provider.dart';
import '../widgets/card_katalog.dart';
import '../widgets/edit_barang.dart';
import '../widgets/tambah_barang.dart';
import '../widgets/edit_kategori.dart';
import '../widgets/tambah_kategori.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:localization/localization.dart';

class KatalogPage extends StatefulWidget {
  const KatalogPage({super.key});

  @override
  State<KatalogPage> createState() => _KatalogPageState();
}

class _KatalogPageState extends State<KatalogPage> {
  FirebaseHelper firebase = FirebaseHelper();
  late EventModel hasil;
  late Uint8List imageBytes;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<String> categories = [
    // 'buah-buahan'
  ];
  List<String> filteredCategories = [];
  Map<String, List<Map<String, dynamic>>> groupedProducts = {};
  Map<int, bool> expandedDetails = {};
  TextEditingController searchController = TextEditingController();
  String? selectedCategory;
  String? selectedStatus = 'Semuanya';
  String searchQuery = '';
  bool showAvailableOnly = false;
  bool isSearching = false;
  bool hasCategoryAdded = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProviderHelper>(context, listen: false);
    Future.microtask(() {
      getData(provider.uid[0]);
    });
  }

  void _filterProducts(String query) {
    List<String> tempCategory = List.from(categories);
    List<Map<String, dynamic>> matchedProducts = [];

    if (query.isEmpty) {
      setState(() {
        filteredCategories = tempCategory;
        filteredProducts = [];
      });
    } else {
      for (var element in tempCategory) {
        matchedProducts = groupedProducts[element]!.where((product) {
          return product['name'].toLowerCase().startsWith(query.toLowerCase());
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
      // list = [1,2,3]
      setState(() {
        for (int i = 0; i < list.length; i++) {
          if (list[i].uid == uid) {
            hasil = list[i];
            break;
          }
        }
        categories = List<String>.from(jsonDecode(hasil.category));
        groupedProducts =
            (jsonDecode(hasil.groupedProducts) as Map<String, dynamic>)
                .map((key, value) => MapEntry(
                      key,
                      (value as List)
                          .map((item) => Map<String, dynamic>.from(item))
                          .toList(),
                    ));

        print(categories);
        filteredCategories = categories;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _openStatusDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('status'.i18n()),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Radio<String>(
                      value: 'Semuanya',
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value;
                          showAvailableOnly = false;
                          filteredProducts = products;
                        });
                      },
                    ),
                    title: Text('semua'.i18n()),
                  ),
                  ListTile(
                    leading: Radio<String>(
                      value: 'Tidak Tersedia',
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value;
                          showAvailableOnly = true;
                          filteredProducts = products
                              .where((product) => !product['isActive'])
                              .toList();
                        });
                      },
                    ),
                    title: Text('tidak'.i18n()),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop();
              },
              child: const Text('Terapkan'),
            ),
          ],
        );
      },
    );
  }

  void _proses(List<String> category, Map<String, List> groupedProduct) async {
    final provider = Provider.of<ProviderHelper>(context, listen: false);
    String uid = provider.uid[0];
    String jsonCategory = jsonEncode(category); //List<String>
    String jsonGroupedProducts = jsonEncode(groupedProduct); //Map<String, List>
    List list = await firebase.getData();
    List list2 = list.where((e) => e.uid == uid).toList();
    if (list2.isEmpty) {
      firebase.addData(EventModel(
          uid: uid,
          category: jsonCategory,
          terjual: '[]',
          groupedProducts: jsonGroupedProducts));
      print('berhasil ditambahkan');
    } else {
      await firebase.updateData(
          uid,
          EventModel(
              uid: uid,
              category: jsonCategory,
              terjual: '',
              groupedProducts: jsonGroupedProducts));
      print('berhasil ubah');
    }
  }

  void _addCategory(String category) async {
    setState(() {
      categories.add(category);
      groupedProducts[category] = [];
      hasCategoryAdded = true;
    });
    _proses(categories, groupedProducts);
  }

  void _updateCategory(int index, String newCategoryName) {
    setState(() {
      List<Map<String, dynamic>>? productsList =
          groupedProducts[categories[index]];
      groupedProducts.remove(categories[index]);
      categories[index] = newCategoryName;
      groupedProducts[newCategoryName] = productsList!;
    });
    _proses(categories, groupedProducts);
  }

  void _deleteCategory(int index) {
    setState(() {
      groupedProducts.remove(categories[index]);
      categories.removeAt(index);
      hasCategoryAdded = false;
    });
    _proses(categories, groupedProducts);
  }

  void _addProduct(String newProduct, String unit, double price,
      String? selectedCategory, String imagePath) {
    try {
      Map<String, dynamic> product = {
        'name': newProduct,
        'unit': unit,
        'price': price,
        'isActive': true,
        'imagePath': imagePath,
      };

      setState(() {
        if (selectedCategory != null && selectedCategory.isNotEmpty) {
          // Cek apakah kategori sudah ada dalam groupedProducts, jika tidak inisialisasi daftar kosong
          if (!groupedProducts.containsKey(selectedCategory)) {
            groupedProducts[selectedCategory] = [];
          }
          groupedProducts[selectedCategory]!.add(product);
        } else {
          products.add(product);
          filteredProducts = products;
        }
      });
      _proses(categories, groupedProducts);
    } catch (error) {
      print("Error adding product: $error");
    }
  }

  void _updateProduct(int index, int productIndex, String newName,
      String newUnit, double newPrice) {
    setState(() {
      print('masuk');
      groupedProducts[categories[index]]![productIndex]['name'] = newName;
      groupedProducts[categories[index]]![productIndex]['unit'] = newUnit;
      groupedProducts[categories[index]]![productIndex]['price'] = newPrice;
    });
    _proses(categories, groupedProducts);
  }

  Future<void> _deleteProduct(int index) async {
    try {
      setState(() {
        products.removeAt(index);
      });
      _proses(categories, groupedProducts);
    } catch (error) {
      print('Error deleting product: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '${'cari'.i18n()}...',
                  border: InputBorder.none,
                ),
                onChanged: _filterProducts,
              )
            : Text('katalog'.i18n()),
        leading: isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    isSearching = false;
                    searchController.clear();
                    filteredProducts = products;
                    filteredCategories = categories;
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
      ),
      body: isSearching
          ? ListView.builder(
              shrinkWrap: true,
              itemCount:
                  // ,
                  filteredCategories.length,
              itemBuilder: (context, index) {
                String category = filteredCategories[index];
                List<Map<String, dynamic>> listGrouped =
                    groupedProducts[category]!;
                print(index);
                return ExpansionTile(
                  title: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditKategoriPage(
                            initialCategoryName: category,
                            onUpdateCategoryName: (newName) {
                              _updateCategory(index, newName);
                            },
                            onDeleteCategory: () {
                              _deleteCategory(index);
                            },
                          ),
                        ),
                      );
                    },
                    child: Text(
                      category,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  children: groupedProducts[category]?.where((product) {
                        if (showAvailableOnly) {
                          return !product['isActive'];
                        }
                        return true;
                      }).map((product) {
                        int productIndex =
                            groupedProducts[category]!.indexOf(product);
                        print('');
                        print(productIndex);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditBarangPage(
                                  initialProductName: product['name'],
                                  initialUnit: product['unit'],
                                  initialPrice: product['price'],
                                  onUpdateProduct:
                                      (newName, newUnit, newPrice) {
                                    _updateProduct(index, productIndex, newName,
                                        newUnit, newPrice);
                                  },
                                  onDeleteProduct: () {
                                    setState(() {
                                      groupedProducts[category]!
                                          .removeAt(productIndex);
                                      print(1);
                                      _proses(categories, groupedProducts);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          child: CardKatalog(
                              product: product,
                              categories: categories,
                              productIndex: productIndex,
                              listGrouped: listGrouped,
                              mapList: groupedProducts,
                              process: _proses),
                        );
                      }).toList() ??
                      [],
                );
              },
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  color: Colors.grey[300],
                  child: const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Material(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isSearching = true;
                              filteredProducts = products;
                            });
                          },
                          borderRadius: BorderRadius.circular(8.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.black),
                                const SizedBox(width: 8),
                                Text(
                                  'cari'.i18n(),
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                        child: GestureDetector(
                          onTap: _openStatusDialog,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Row(
                              children: [
                                Text(
                                  'status'.i18n(),
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_drop_down,
                                    color: Colors.black),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return ExpansionTile(
                        title: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditKategoriPage(
                                  initialCategoryName: categories[index],
                                  onUpdateCategoryName: (newName) {
                                    _updateCategory(index, newName);
                                  },
                                  onDeleteCategory: () {
                                    _deleteCategory(index);
                                  },
                                ),
                              ),
                            );
                          },
                          child: Text(
                            categories[index],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        children: groupedProducts[categories[index]]
                                ?.where((product) {
                              if (showAvailableOnly) {
                                return !product['isActive'];
                              }
                              return true;
                            }).map((product) {
                              int productIndex =
                                  groupedProducts[categories[index]]!
                                      .indexOf(product);
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditBarangPage(
                                        initialProductName: product['name'],
                                        initialUnit: product['unit'],
                                        initialPrice: product['price'],
                                        onUpdateProduct:
                                            (newName, newUnit, newPrice) {
                                          _updateProduct(index, productIndex,
                                              newName, newUnit, newPrice);
                                        },
                                        onDeleteProduct: () {
                                          setState(() {
                                            groupedProducts[categories[index]]!
                                                .removeAt(productIndex);
                                            _proses(categories, groupedProducts);
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: CardKatalog(
                                    product: product,
                                    categories: categories,
                                    productIndex: productIndex,
                                    listGrouped:
                                        groupedProducts[categories[index]]!,
                                    mapList: groupedProducts,
                                    process: _proses),
                              );
                            }).toList() ??
                            [],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: categories.isEmpty && !hasCategoryAdded
                      ? Center(
                          child: Text('belum_ada'.i18n()),
                        )
                      : ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> product = products[index];
                            if (showAvailableOnly &&
                                products[index]['isActive']) {
                              return const SizedBox.shrink();
                            }
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
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
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditBarangPage(
                                                initialProductName:
                                                    products[index]['name'],
                                                initialUnit: products[index]
                                                    ['unit'],
                                                initialPrice: products[index]
                                                    ['price'],
                                                onUpdateProduct: (newName,
                                                    newUnit, newPrice) {
                                                  String namas = '';
                                                  for (var entry
                                                      in groupedProducts
                                                          .entries) {
                                                    List<dynamic> valueList =
                                                        entry.value;
                                                    for (var item
                                                        in valueList) {
                                                      if (item['name'] ==
                                                          products[index]
                                                              ['name']) {
                                                        namas = entry.key;
                                                      }
                                                    }
                                                  }
                                                  int indeks = 0;
                                                  for (int i = 0;
                                                      i < categories.length;
                                                      i++) {
                                                    if (categories[i] ==
                                                        namas) {
                                                      indeks = i;
                                                      break;
                                                    }
                                                  }
                                                  _updateProduct(
                                                      indeks,
                                                      index,
                                                      newName,
                                                      newUnit,
                                                      newPrice);
                                                },
                                                onDeleteProduct: () {
                                                  _deleteProduct(index);
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              products[index]['name'],
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.left,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              products[index]['unit'],
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700]),
                                            ),
                                            Text(
                                              Provider.of<ProviderHelper>(
                                                      context)
                                                  .formatPrice(
                                                      products[index]['price']),
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700]),
                                            ),
                                            if (!products[index]['isActive'])
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
                                    ),
                                    Switch(
                                      value: products[index]['isActive'],
                                      onChanged: (value) {
                                        setState(() {
                                          products[index]['isActive'] = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: isSearching
          ? null
          : SpeedDial(
              animatedIcon: AnimatedIcons.add_event,
              backgroundColor: Colors.blue,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.add),
                  label: 'tambah_kategori'.i18n(),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return TambahKategoriPage(onAddCategory: _addCategory);
                      },
                    );
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.add),
                  label: 'tambah_barang'.i18n(),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return TambahBarangPage(
                          categories: categories,
                          onAddProduct: _addProduct,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
    );
  }
}
