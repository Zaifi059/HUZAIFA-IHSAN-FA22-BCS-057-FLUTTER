import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router_new.dart';
import 'core/services/mobile_auth_service.dart';
import 'features/auth/data/services/role_storage_service.dart';
import 'features/game_management/data/repositories/cached_game_repository.dart';
import 'features/real_time/data/services/unified_sync_service.dart';
import 'features/notifications/data/services/supabase_notification_service.dart';
import 'services/automated_game_reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with PKCE for mobile platforms
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
    storageOptions: const StorageClientOptions(
      retryAttempts: 10,
    ),
  );

  // ✅ CRITICAL FIX: Initialize role cache early to prevent role selection flash
  await RoleStorageService.initializeCache();
  print('Main: Role cache initialized');

  // ✅ Initialize game cache for instant dashboard loading
  await CachedGameRepository().initializeCache();
  print('Main: Game cache initialized');

  // ✅ Initialize unified sync service for real-time dashboard consistency
  await UnifiedSyncService().initialize();
  print('Main: Unified sync service initialized');

  // Initialize mobile auth service for session persistence
  await MobileAuthService.initialize();

  // Initialize Supabase-based notification service (replaces Firebase)
  await SupabaseNotificationService().initialize();
  print('Main: Supabase notification service initialized');

  // Start automated game reminder service for 30-minute notifications
  AutomatedGameReminderService()
      .startService(interval: const Duration(minutes: 2));
  print(
      'Main: Automated game reminder service started - checking every 2 minutes');

  // ✅ DISABLED: Automated payout service for manual scheduler approval workflow
  // AutomatedPayoutService().startService(interval: const Duration(seconds: 15));
  print(
      'Main: Manual payout approval workflow enabled - scheduler must approve requests');

  runApp(
    ProviderScope(
      child: const NetworkOfOneApp(),
    ),
  );
}

class NetworkOfOneApp extends ConsumerWidget {
  const NetworkOfOneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // NOTE: Automated payout service is available but not auto-started
    // This allows schedulers to manually approve payouts before processing
    // To enable auto-processing, use the admin dashboard control panel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🎯 Payout system ready - scheduler approval workflow enabled');
      print('ℹ️ Auto-processing can be enabled via admin dashboard');
    });

    return MaterialApp.router(
      title: 'NetworkOfOne - I AM Basketball',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
