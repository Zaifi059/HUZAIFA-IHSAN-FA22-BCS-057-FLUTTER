import 'package:flutter/material.dart';

import 'screens/patient_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF1976D2), // Blue 700
      onPrimary: Colors.white,
      secondary: Color(0xFF2196F3), // Blue 500
      onSecondary: Colors.white,
      error: Color(0xFFEF5350),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      primaryContainer: Color(0xFFE3F2FD), // Blue 50
      onPrimaryContainer: Color(0xFF1976D2),
      secondaryContainer: Color(0xFFF5F5F5), // Grey 100
      onSecondaryContainer: Colors.black,
      surfaceContainerHighest: Color(0xFFF5F5F5),
      surfaceContainerHigh: Color(0xFFFAFAFA),
      surfaceContainer: Colors.white,
      surfaceContainerLow: Color(0xFFFEFEFE),
      surfaceContainerLowest: Colors.white,
      outline: Color(0xFFE0E0E0), // Grey 300
      outlineVariant: Color(0xFFF5F5F5), // Grey 100
      scrim: Colors.black54,
      shadow: Colors.black26,
      tertiary: Color(0xFF1976D2),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFE3F2FD),
      onTertiaryContainer: Color(0xFF1976D2),
    );
    return MaterialApp(
      title: 'Doctor App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.background,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        cardColor: colorScheme.surface,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
        ),
        listTileTheme: const ListTileThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        }),
      ),
      home: const PatientListScreen(),
    );
  }
}
