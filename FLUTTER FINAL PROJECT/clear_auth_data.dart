import 'package:shared_preferences/shared_preferences.dart';

/// Clear all authentication and role data from SharedPreferences
/// Use this to reset the app's local storage for debugging
Future<void> clearAllAuthData() async {
  print('🧹 CLEARING ALL AUTH DATA FROM SHARED PREFERENCES');
  print('=' * 60);

  final prefs = await SharedPreferences.getInstance();

  // List all keys before clearing
  print('📋 Current SharedPreferences keys:');
  final allKeys = prefs.getKeys();
  for (final key in allKeys) {
    print('   $key');
  }

  // Clear all auth-related keys
  final authKeys = [
    // Role storage
    'user_role',
    'has_selected_role',
    'session_role_selected',

    // Session manager
    'user_email',
    'is_first_launch',

    // Mobile auth service
    'access_token',
    'refresh_token',
    'user_id',
    'expires_at',

    // Hardcoded admin service
    'admin_logged_in',
    'admin_email',
    'admin_role',
    'backup_admin_email',
    'backup_admin_password',

    // Any other auth keys
    'session_token',
    'auth_session',
    'current_user',
  ];

  print('\n🧹 Clearing auth-related keys...');
  for (final key in authKeys) {
    if (prefs.containsKey(key)) {
      await prefs.remove(key);
      print('   ✅ Removed: $key');
    } else {
      print('   ➖ Not found: $key');
    }
  }

  print('\n📋 Remaining SharedPreferences keys:');
  final remainingKeys = prefs.getKeys();
  for (final key in remainingKeys) {
    print('   $key');
  }

  print('\n' + '=' * 60);
  print('✅ Auth data cleared successfully');
  print('   App should now behave as if it\'s a fresh install');
  print('   All users will need to login again');
}
