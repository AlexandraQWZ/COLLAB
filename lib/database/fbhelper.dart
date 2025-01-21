

// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab_mitra/database/event_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseHelper {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore store = FirebaseFirestore.instance;

  Future<void> testEventLog(value) async {
    await analytics.logEvent(name: '$value', parameters: {'value': value});
  }

  //=================================================================
  Future<String> signUp(String email, String password) async {
    try {
      UserCredential authResult = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = authResult.user;
      return user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email sudah digunakan. Silakan gunakan email lain.';
      }
      return '';
    }
  }

  Future<String> logIn(String email, String password) async {
    try {
      UserCredential authResult = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = authResult.user;
      return user!.uid;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> deleteAccount() async {
  try {
    // Mendapatkan instance pengguna yang sedang login
    User? user = auth.currentUser;
    if (user != null) {
      // Menghapus akun
      await user.delete();
      print('Akun berhasil dihapus.');
    } else {
      print('Tidak ada pengguna yang sedang login.');
    }
  } catch (e) {
    // Menangani error (misalnya, token kedaluwarsa)
    print('Gagal menghapus akun: $e');

    // Error paling umum: token kedaluwarsa
    if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
      print('Anda perlu login ulang sebelum menghapus akun.');
    }
  }
}

  Future<User?> getUser() async {
    User? user = auth.currentUser;
    return user;
  }

  //=================================================================
  Future<List> getData() async {
    try {
      var data = await store.collection('app').get();
      List list =
          data.docs.map((doc) => EventModel.fromDocSnapshot(doc)).toList();
      return list;
    } catch (e) {
      print("errror karena $e");
      return [];
    }
  }

  Future updateData(String uid, EventModel item) async {
    QuerySnapshot snapshot =
        await store.collection('app').where('uid', isEqualTo: uid).get();
    if (item.terjual == '') {
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        // Update dokumen berdasarkan ID
        await doc.reference.update({
          'category': item.category,
          'groupedProducts': item.groupedProducts,
        });
        return;
      }
    }
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      // Update dokumen berdasarkan ID
      await doc.reference.update(item.toMap());
    }
    // await store.collection('app').doc(id).update(item.toMap());
  }

  Future addData(EventModel item) async {
    await store.collection('app').add(item.toMap());
  }
}
