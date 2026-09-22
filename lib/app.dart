import 'package:flutter/material.dart';

import 'presentation/app_shell.dart';

class BalaBaianaApp extends StatelessWidget {
  const BalaBaianaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF9A4A1B);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bala Baiana',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFBF8),
      ),
      home: const AppShell(),
    );
  }
}
