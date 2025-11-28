// Stub file for conditional imports
// This file should not be used directly
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  Future<int> insertGameResult({
    required int guessedNumber,
    required int targetNumber,
    required String status,
    required String timestamp,
  }) async =>
      throw UnimplementedError();

  Future<List<Map<String, dynamic>>> getAllGameResults() async =>
      throw UnimplementedError();
  Future<int> deleteAllGameResults() async => throw UnimplementedError();
  Future<void> close() async => throw UnimplementedError();
}
