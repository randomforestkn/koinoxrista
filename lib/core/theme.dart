import 'package:flutter/material.dart';

ThemeData appTheme(ColorScheme scheme) => ThemeData(
  colorScheme: scheme,
  useMaterial3: true,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(letterSpacing: 0.1),
  ),
);
