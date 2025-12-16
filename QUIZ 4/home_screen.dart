// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService().getCurrentUser();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SupabaseService().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/', 
                  (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: Center(
        child: user == null
            ? const Text('No user logged in')
            : Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Welcome!', 
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Email: ${user.email}', 
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'User ID: ${user.id}', 
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Created At: ${user.createdAt}', 
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}