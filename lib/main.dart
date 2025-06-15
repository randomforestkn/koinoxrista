import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/calculator/presentation/calculator_page.dart';
import 'core/theme.dart';


void main() {
  runApp(const ProviderScope(child: KoinoxristaApp()));
}

class KoinoxristaApp extends StatelessWidget {
  const KoinoxristaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Κοινόχρηστα',
      debugShowCheckedModeBanner: false,
      theme:  appTheme(ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0))),
	  darkTheme: appTheme(ColorScheme.fromSeed(
  		seedColor: const Color(0xFF1565C0),
  		brightness: Brightness.dark,
		)),
      home: const CalculatorPage(),
    );
  }
}
