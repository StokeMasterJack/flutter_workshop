import 'package:flutter/material.dart';

ThemeData buildSimpleTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(), filled: true),
  );
}
