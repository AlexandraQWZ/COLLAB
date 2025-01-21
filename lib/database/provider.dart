// ignore_for_file: avoid_print

import 'package:collab_mitra/database/event_model.dart';
import 'package:collab_mitra/database/fbhelper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProviderHelper with ChangeNotifier {
  FirebaseHelper firebase = FirebaseHelper();
  final List<String> _uid = [];
  EventModel? hasil;

  List<String> get uid => _uid;

  Future<String> login(String email, String password) async {
    String uid = await firebase.logIn(email, password);
    if (uid == 'invalid-credential') {
      return 'GAGAL';
    }
    _uid.add(uid);
    _uid.add(email.split('@')[0]);
    getData();
    return '';
  }

  Future<void> signOut() async {
    await firebase.signOut();
    _uid.clear();
    hasil = null;
    notifyListeners();
  }

  Future<void> getData() async {
    try {
      List list = await firebase.getData();
      // list = [1,2,3]
      for (int i = 0; i < list.length; i++) {
        if (list[i].uid == _uid[0]) {
          hasil = list[i];
          break;
        }
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  String formatPrice(double price) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2);
    return formatter.format(price);
  }
}
