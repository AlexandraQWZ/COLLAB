import 'package:flutter/material.dart';

class TextFormField1 extends StatelessWidget {
  const TextFormField1({super.key, required this.controller, required this.label, required this.obscure, required this.validator});
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // Garis tepi merah
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.black, width: 2.0), // Garis tepi putih saat aktif
          ),
        ),
        obscureText: obscure,
        validator: validator
      );
  }
}
