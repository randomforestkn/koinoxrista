import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'features/calculator/presentation/calculator_page.dart';
import 'models/apartment.dart';
import 'models/expense.dart';
import 'models/result_row.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);

  Hive.registerAdapter(ApartmentAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(ResultRowAdapter());

  await Hive.openBox('koinoxrista');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Εφαρμογή Κοινοχρήστων',
      themeMode: ThemeMode.system,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: const StadiumBorder(),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 1,
          margin: EdgeInsets.all(4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: const StadiumBorder(),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 1,
          margin: EdgeInsets.all(4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        textTheme: Typography.whiteMountainView.apply(
          bodyColor: Colors.white70,
        ),
      ),

      home: const CalculatorPage(),
    );
  }
}
