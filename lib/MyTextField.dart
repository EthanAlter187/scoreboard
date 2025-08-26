import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({
    super.key,
    required this.controller,
    required this.isNumeric,
    required this.label,
  });

  final TextEditingController controller;
  final bool isNumeric;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: 40,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: const Color.fromARGB(255, 215, 214, 214),
      ),
      inputFormatters: [
        if (isNumeric) FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}
