import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminLoginDebugScreen extends StatefulWidget {
  const AdminLoginDebugScreen({super.key});

  @override
  State<AdminLoginDebugScreen> createState() => _AdminLoginDebugScreenState();
}

class _AdminLoginDebugScreenState extends State<AdminLoginDebugScreen> {
  final _logs = <String>[];
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
    print('DEBUG: $message');
  }

  Future<void> _testAdminLogin() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    try {
      _addLog('Starting admin login test...');

      // Step 1: Sign in
      _addLog('Attempting sign in with admin@mail.com');
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: 'admin@mail.com',
        password: 'password777',
      );

      if (response.user != null) {
        _addLog('✅ Sign in successful!');
        _addLog('User ID: ${response.user!.id}');
        _addLog('Email: ${response.user!.email}');

        // Step 2: Test role query by ID
        _addLog('Testing role query by user ID...');
        try {
          final roleResponse = await Supabase.instance.client
              .from('users')
              .select('role, id, email, full_name')
              .eq('id', response.user!.id)
              .single();

          _addLog('✅ Role query by ID successful');
          _addLog('Role: ${roleResponse['role']}');
          _addLog('Full Name: ${roleResponse['full_name']}');
        } catch (e) {
          _addLog('❌ Role query by ID failed: $e');

          // Fallback: try by email
          _addLog('Trying fallback query by email...');
          try {
            final emailResponse = await Supabase.instance.client
                .from('users')
                .select('role, id, email, full_name')
                .eq('email', 'admin@mail.com')
                .single();

            _addLog('✅ Role query by email successful');
            _addLog('Role: ${emailResponse['role']}');
            _addLog('DB User ID: ${emailResponse['id']}');
            _addLog('Auth User ID: ${response.user!.id}');

            if (emailResponse['id'] == response.user!.id) {
              _addLog('✅ User IDs match');
            } else {
              _addLog('❌ USER ID MISMATCH!');
            }
          } catch (e2) {
            _addLog('❌ Email query also failed: $e2');
          }
        }

        // Step 3: Test metadata
        _addLog('Checking user metadata...');
        final metadata = response.user!.userMetadata;
        if (metadata != null && metadata.isNotEmpty) {
          _addLog('Metadata: ${metadata.toString()}');
        } else {
          _addLog('No user metadata found');
        }

        // Sign out
        await Supabase.instance.client.auth.signOut();
        _addLog('✅ Signed out successfully');
      } else {
        _addLog('❌ Sign in failed - no user returned');
      }
    } catch (e) {
      _addLog('❌ Login test failed: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login Debug'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testAdminLogin,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test Admin Login'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? const Text(
                        'Click "Test Admin Login" to start debugging...',
                        style: TextStyle(color: Colors.grey),
                      )
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              log,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: log.contains('✅')
                                    ? Colors.green
                                    : log.contains('❌')
                                        ? Colors.red
                                        : Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
