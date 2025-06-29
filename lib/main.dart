import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const CryptoTycoonApp());
}

class CryptoTycoonApp extends StatelessWidget {
  const CryptoTycoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Tycoon',
      debugShowCheckedModeBanner: false, // Убираем DEBUG banner
      theme: ThemeData(
        // Binance-style dark theme
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0E11),
        cardColor: const Color(0xFF1E2329),
        primaryColor: const Color(0xFFF0B90B), // Binance yellow
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF0B90B), // Binance yellow
          secondary: Color(0xFF02C076), // Binance green
          surface: Color(0xFF1E2329),
          error: Color(0xFFF6465D), // Binance red
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E2329),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E2329),
          selectedItemColor: Color(0xFFF0B90B),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF0B90B),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E2329),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.grey),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          fillColor: Color(0xFF1E2329),
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFF0B90B)),
          ),
          labelStyle: TextStyle(color: Colors.grey),
          hintStyle: TextStyle(color: Colors.grey),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xFF1E2329),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF1E2329),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFFF0B90B),
        ),
        dividerTheme: const DividerThemeData(
          color: Colors.grey,
          thickness: 0.5,
        ),
      ),
      home: const GameScreen(),
    );
  }
}