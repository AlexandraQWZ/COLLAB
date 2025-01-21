// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:localization/localization.dart';

class SettingAnggaranPage extends StatefulWidget {
  const SettingAnggaranPage({super.key});

  @override
  State<SettingAnggaranPage> createState() => _SettingAnggaranPageState();
}

class _SettingAnggaranPageState extends State<SettingAnggaranPage> {
  final TextEditingController _budgetController = TextEditingController();
  int? _currentBudget;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  // Load the current budget from SharedPreferences
  Future<void> _loadBudget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentBudget = prefs.getInt('budget') ?? 0;
    });
  }

  // Save the budget to SharedPreferences
  Future<void> _saveBudget(int budget) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('budget', budget);
    setState(() {
      _currentBudget = budget;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${'anggaran'.i18n()} $budget')),
    );
  }

  // Reset the budget to 0 and clear from SharedPreferences
  Future<void> _resetBudget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('budget'); // Remove the saved budget
    setState(() {
      _currentBudget = 0;
      _budgetController.clear(); // Clear the input field
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('notif_reset'.i18n())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('atur_anggaran'.i18n()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'tetap_anggaran'.i18n(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'masukkan_anggaran'.i18n(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                int budget = _budgetController.text.isEmpty ? 0 : int.parse(_budgetController.text);
                if (budget > 0) {
                  _saveBudget(budget);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('masukkan_nominal'.i18n())),
                  );
                }
              },
              child: Text('simpan_anggaran'.i18n()),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _resetBudget, // Call reset function
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('reset_anggaran'.i18n()),
            ),
            const SizedBox(height: 10),
            if (_currentBudget != null)
              Text(
                '${'anggaran_saat_ini'.i18n()} $_currentBudget',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
