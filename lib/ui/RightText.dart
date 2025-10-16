// ignore_for_file: file_names

import 'package:flutter/material.dart';

class RightText extends StatelessWidget{
  final String text;
  const RightText(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Text(text, textAlign: TextAlign.right,);
  }
  
}