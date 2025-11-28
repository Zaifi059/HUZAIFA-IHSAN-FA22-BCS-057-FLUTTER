import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static SharedPreferences? _prefs;
  static const String _key = 'game_results';

  DatabaseHelper._init();

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<int> insertGameResult({
    required int guessedNumber,
    required int targetNumber,
    required String status,
    required String timestamp,
  }) async {
    await _initPrefs();
    final results = await getAllGameResults();
    
    final newResult = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'guessed_number': guessedNumber,
      'target_number': targetNumber,
      'status': status,
      'timestamp': timestamp,
    };
    
    results.add(newResult);
    await _prefs!.setString(_key, jsonEncode(results));
    return newResult['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getAllGameResults() async {
    await _initPrefs();
    final jsonString = _prefs!.getString(_key);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList()
      ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
  }

  Future<int> deleteAllGameResults() async {
    await _initPrefs();
    await _prefs!.remove(_key);
    return 1;
  }

  Future<void> close() async {
    // No-op for web
  }
}

