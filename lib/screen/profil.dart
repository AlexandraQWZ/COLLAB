// ignore_for_file: avoid_print, unused_field, unused_element

import 'package:collab_mitra/screen/login_page.dart';

import '../database/fbhelper.dart';
import '../database/provider.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  // final String _password = '';
  // uid, username, katalog
  FirebaseHelper firebase = FirebaseHelper();
  bool _isLoading = false;
  bool _isImage = false;
  bool isConfirmed = false;

  // untuk edit akun
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> _showMyDialog(String teks) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(teks),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text("Untuk hapus ketik KONFIRMASI di bawah ini:"),
                TextField(
                  controller: email,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                email.text = "";
                Navigator.of(context).pop();
              },
              child: const Text('cancel'),
            ),
            TextButton(
              onPressed: () {
                print(email.text);
                if (email.text == "KONFIRMASI") {
                  firebase.deleteAccount();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
              child: const Text('Approve'),
            )
          ],
        );
      },
    );
  }

  // untuk mengambil gambar
  Uint8List? _imageBytes;
  final StreamController<double> _progressStreamController =
      StreamController<double>();
  final ImagePicker image = ImagePicker();
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await image.pickImage(source: ImageSource.gallery);
    _progressStreamController.add(0.0);
    _isLoading = true;
    setState(() {});

    if (pickedFile != null) {
      for (double progress = 0.1; progress <= 1.0; progress += 0.1) {
        await Future.delayed(const Duration(milliseconds: 100));
        _progressStreamController.add(progress);
      }

      _progressStreamController.add(1.0);
      final Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _isImage = true;
        _isLoading = false;
      });
    } else {
      _isLoading = false;
      setState(() {});
    }
  }

  // untuk mendapatkan username
  String _email = 'Kosong';
  void getData() {
    try {
      setState(() {
        _email = Provider.of<ProviderHelper>(context).uid[1];
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    email.addListener(() {
      setState(() {
        isConfirmed = email.text == "KONFIRMASI";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderHelper>(context, listen: true);
    getData();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'profil'.i18n(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // GestureDetector(
                  //   onTap: _pickImage,
                  //   child: CircleAvatar(
                  //       radius: 50,
                  //       backgroundImage: _isImage
                  //           ? MemoryImage(_imageBytes!)
                  //           : null),
                  // ),
                  const SizedBox(
                    width: 20,
                    height: 50,
                  ),
                  Text(
                    _email,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: () async {
              //       _showMyDialog('edit'.i18n());
              //     },
              //     child: Align(
              //         alignment: Alignment.centerLeft,
              //         child: Text('edit'.i18n(),
              //             style: const TextStyle(fontSize: 20))),
              //   ),
              // ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showMyDialog('edit'.i18n());
                  },
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('hapus'.i18n(),
                          style: const TextStyle(fontSize: 20))),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    provider.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (Route<dynamic> route) => false);
                  },
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('keluar'.i18n(),
                          style: const TextStyle(fontSize: 20))),
                ),
              ),
              StreamBuilder<double>(
                  stream: _progressStreamController.stream,
                  builder: (context, snapshot) {
                    if (_isLoading) {
                      return Stack(
                        children: [
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                            child:
                                Container(color: Colors.black // Faded overlay
                                    ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: LinearProgressIndicator(
                              value: snapshot.data,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Memuat Gambar... ${(snapshot.data! * 100).toInt()}%",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox();
                  })
            ],
          ),
        ),
      ),
    );
  }
}
