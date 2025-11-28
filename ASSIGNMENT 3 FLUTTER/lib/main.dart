import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'database/database_helper.dart';

void main() {
  // Optional: Configure custom database path
  // Uncomment and set your custom path if needed
  // DatabaseHelper.customDatabasePath = r'C:\Users\Ur Soft\Downloads\sqlite-src-3510000';
  
  // By default, Flutter uses the app's default database directory
  // The sqflite package automatically handles SQLite integration
  // No additional SQLite source configuration is needed
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Guessing Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}

