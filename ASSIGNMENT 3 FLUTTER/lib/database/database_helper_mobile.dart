import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  // Configure custom database path if needed
  // Set to null to use default Flutter database path
  static String? customDatabasePath;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('game_results.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String dbPath;
    
    // Use custom path if configured, otherwise use default Flutter path
    if (customDatabasePath != null && customDatabasePath!.isNotEmpty) {
      // Ensure the custom directory exists
      final customDir = Directory(customDatabasePath!);
      if (!await customDir.exists()) {
        await customDir.create(recursive: true);
      }
      dbPath = customDatabasePath!;
    } else {
      // Use default Flutter database path
      dbPath = await getDatabasesPath();
    }
    
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const integerType = 'INTEGER NOT NULL';
    const textType = 'TEXT NOT NULL';
    const timestampType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE game_results (
        id $idType,
        guessed_number $integerType,
        target_number $integerType,
        status $textType,
        timestamp $timestampType
      )
    ''');
  }

  Future<int> insertGameResult({
    required int guessedNumber,
    required int targetNumber,
    required String status,
    required String timestamp,
  }) async {
    final db = await database;
    return await db.insert(
      'game_results',
      {
        'guessed_number': guessedNumber,
        'target_number': targetNumber,
        'status': status,
        'timestamp': timestamp,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAllGameResults() async {
    final db = await database;
    return await db.query(
      'game_results',
      orderBy: 'timestamp DESC',
    );
  }

  Future<int> deleteAllGameResults() async {
    final db = await database;
    return await db.delete('game_results');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

