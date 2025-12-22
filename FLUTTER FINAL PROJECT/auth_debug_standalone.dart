import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/data/providers/auth_provider.dart';
import 'features/auth/data/services/role_storage_service.dart';
import 'features/auth/data/models/user_role.dart';

class AuthDebugPage extends ConsumerStatefulWidget {
  const AuthDebugPage({super.key});

  @override
  ConsumerState<AuthDebugPage> createState() => _AuthDebugPageState();
}

class _AuthDebugPageState extends ConsumerState<AuthDebugPage> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'test123456');
  bool _isLoading = false;
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
    print('DEBUG: $message');
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      _addLog('Starting login test for: $email');

      // Check initial state
      final initialSession = ref.read(authStateProvider);
      final initialRole = ref.read(roleProvider);
      final initialImmediate = RoleStorageService.getImmediateRole();

      _addLog('Initial session: ${initialSession?.user.email ?? 'null'}');
      _addLog('Initial role provider: ${initialRole?.value ?? 'null'}');
      _addLog('Initial immediate role: ${initialImmediate?.value ?? 'null'}');

      // Attempt sign in
      _addLog('Calling auth state notifier sign in...');

      await ref.read(authStateProvider.notifier).signIn(
            email: email,
            password: password,
          );

      _addLog('Sign in call completed');

      // Check state after sign in
      await Future.delayed(const Duration(milliseconds: 500));

      final afterSession = ref.read(authStateProvider);
      final afterRole = ref.read(roleProvider);
      final afterImmediate = RoleStorageService.getImmediateRole();

      _addLog('After session: ${afterSession?.user.email ?? 'null'}');
      _addLog('After role provider: ${afterRole?.value ?? 'null'}');
      _addLog('After immediate role: ${afterImmediate?.value ?? 'null'}');

      // Check if user exists in Supabase auth
      final currentUser = Supabase.instance.client.auth.currentUser;
      _addLog('Supabase current user: ${currentUser?.email ?? 'null'}');

      if (currentUser != null) {
        // Check if user exists in public.users table
        try {
          final userRecord = await Supabase.instance.client
              .from('users')
              .select('*')
              .eq('id', currentUser.id)
              .maybeSingle();

          if (userRecord != null) {
            _addLog('User found in public.users table');
            _addLog('DB Role: ${userRecord['role'] ?? 'null'}');
            _addLog('DB Full Name: ${userRecord['full_name'] ?? 'null'}');
          } else {
            _addLog('User NOT found in public.users table');
          }
        } catch (e) {
          _addLog('Error checking public.users: $e');
        }
      }

      // Determine what should happen next
      final roleToUse = afterRole ?? afterImmediate;
      if (roleToUse != null) {
        _addLog('✅ Role found: ${roleToUse.value}');
        _addLog('Should navigate to: ${roleToUse.dashboardRoute}');
      } else {
        _addLog('⚠️  No role found - should go to role selection');
      }
    } catch (e) {
      _addLog('❌ Login failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignup() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      _addLog('Starting signup test for: $email');

      // Clear any existing role data
      await RoleStorageService.clearAll();
      ref.read(roleProvider.notifier).state = null;
      _addLog('Cleared role caches');

      // Mark signup in progress
      ref.read(authStateProvider.notifier).markSignupInProgress();
      _addLog('Marked signup in progress');

      // Attempt signup
      await ref.read(authControllerProvider.notifier).signUp(
            email: email,
            password: password,
            fullName: 'Test User',
            phoneNumber: '+1-555-0000',
          );

      _addLog('Signup completed');

      // Check state after signup
      await Future.delayed(const Duration(milliseconds: 500));

      final afterSession = ref.read(authStateProvider);
      final afterRole = ref.read(roleProvider);

      _addLog('After signup session: ${afterSession?.user.email ?? 'null'}');
      _addLog('After signup role: ${afterRole?.value ?? 'null'}');

      _addLog('✅ Should now navigate to role selection page');
    } catch (e) {
      _addLog('❌ Signup failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Debug'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Test credentials
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // Test buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testLogin,
                    child: const Text('Test Login'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testSignup,
                    child: const Text('Test Signup'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Loading indicator
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _logs.clear();
                  });
                },
                child: const Text('Clear Logs'),
              ),

            const SizedBox(height: 16),

            // Logs
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _logs
                        .map((log) => Text(
                              log,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
