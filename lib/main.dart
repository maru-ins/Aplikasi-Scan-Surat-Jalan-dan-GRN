import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const LaporanSJApp());
}

class LaporanSJApp extends StatelessWidget {
  const LaporanSJApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Laporan SJ Logistik',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),

        useMaterial3: true,
      ),

      home: const HomeScreen(),
    );
  }
}