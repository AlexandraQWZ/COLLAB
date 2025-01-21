// ignore_for_file: depend_on_referenced_packages

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'data_model.dart';

class DataService {
  final String tipsUrl = 'https://dummyjson.com/products';
  final String inspirationUrl = 'https://dummyjson.com/posts';

  Future<List<Tip>> fetchTips() async {
    final response = await http.get(Uri.parse(tipsUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body)['products'];
      return jsonData.map((json) => Tip.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tips');
    }
  }

  Future<List<Inspiration>> fetchInspirations() async {
    final response = await http.get(Uri.parse(inspirationUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body)['posts'];
      return jsonData.map((json) => Inspiration.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load inspirations');
    }
  }
}
