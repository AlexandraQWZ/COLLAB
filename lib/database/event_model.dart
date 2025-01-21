import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String? id;
  final String uid;
  final String category;
  final String groupedProducts;
  final String terjual;

  EventModel({
    this.id,
    required this.uid,
    required this.category,
    required this.groupedProducts,
    required this.terjual,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "category": category,
      "groupedProducts": groupedProducts,
      "terjual": terjual
    };
  }

  EventModel.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        uid = doc.data()?['uid'] ?? true,
        category = doc.data()?['category'] ?? '',
        groupedProducts = doc.data()?['groupedProducts'] ?? '',
        terjual = doc.data()?['terjual'] ?? '';
}
