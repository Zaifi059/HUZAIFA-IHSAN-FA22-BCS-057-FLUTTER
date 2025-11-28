// Conditional export for platform-specific database implementation
// Web uses shared_preferences, Mobile uses sqflite
export 'database_helper_stub.dart'
    if (dart.library.html) 'database_helper_web.dart'
    if (dart.library.io) 'database_helper_mobile.dart';
