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
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFBF8),
          foregroundColor: Color(0xFF3B241A),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFF0E5DE)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE8DCD5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE8DCD5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF9A4A1B), width: 2),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 74,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFFFE0CC),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
      home: const AppShell(),
    );
  }
}
