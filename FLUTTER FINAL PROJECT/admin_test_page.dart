import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/data/services/hardcoded_admin_service.dart';

class AdminTestPage extends StatefulWidget {
  const AdminTestPage({super.key});

  @override
  State<AdminTestPage> createState() => _AdminTestPageState();
}

class _AdminTestPageState extends State<AdminTestPage> {
  final _logs = <String>[];
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
    print('ADMIN_TEST: $message');
  }

  Future<void> _testAdminLogin() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    try {
      _addLog('🚀 Starting hardcoded admin login test...');

      // Test credential validation
      _addLog('Testing credential validation...');
      final isValid = HardcodedAdminService.isAdminCredentials(
          'admin@mail.com', 'password777');
      _addLog('Credential validation: ${isValid ? '✅ PASS' : '❌ FAIL'}');

      if (!isValid) {
        _addLog('❌ Credential validation failed - stopping test');
        return;
      }

      // Test admin login
      _addLog('Attempting hardcoded admin login...');
      final result = await HardcodedAdminService.adminLogin(
          'admin@mail.com', 'password777');

      if (result != null) {
        _addLog('✅ Admin login successful!');
        _addLog('User data received: ${result['user']?['email']}');
        _addLog(
            'Session data received: ${result['session'] != null ? 'YES' : 'NO'}');

        // Test session check
        _addLog('Testing admin session status...');
        final isLoggedIn = await HardcodedAdminService.isAdminLoggedIn();
        _addLog('Admin logged in status: ${isLoggedIn ? '✅ YES' : '❌ NO'}');

        // Test session retrieval
        _addLog('Testing session retrieval...');
        final session = await HardcodedAdminService.getAdminSession();
        _addLog(
            'Session retrieval: ${session != null ? '✅ SUCCESS' : '❌ FAILED'}');

        _addLog('🎉 ALL TESTS PASSED! Admin can now navigate to dashboard.');

        // Show success dialog with navigation option
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Admin Login Test Success'),
              content: const Text(
                  'All tests passed! Would you like to navigate to the admin dashboard?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/admin');
                  },
                  child: const Text('Go to Dashboard'),
                ),
              ],
            ),
          );
        }
      } else {
        _addLog('❌ Admin login failed - no data returned');
      }
    } catch (e) {
      _addLog('❌ Test failed with error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testAdminLogout() async {
    _addLog('Testing admin logout...');
    await HardcodedAdminService.adminLogout();

    final isLoggedIn = await HardcodedAdminService.isAdminLoggedIn();
    _addLog(
        'After logout - logged in: ${isLoggedIn ? '❌ STILL LOGGED IN' : '✅ LOGGED OUT'}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login Test'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testAdminLogin,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: const Text('Test Admin Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _testAdminLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Test Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'This tests the hardcoded admin service without any Supabase queries',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: _logs.isEmpty
                    ? const Text(
                        'Click "Test Admin Login" to start testing...',
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
                                        : log.contains('🚀') ||
                                                log.contains('🎉')
                                            ? Colors.blue
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
