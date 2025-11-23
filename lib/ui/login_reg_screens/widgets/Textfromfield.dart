import 'package:flutter/material.dart';

class textfromfield extends StatelessWidget {
  const textfromfield({ required this.controller, this.text, this.icon});

  final icon;
  final text;
  final controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: text,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
