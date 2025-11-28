import 'package:flutter/material.dart';
import 'dart:math';
import '../screens/result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _guessController = TextEditingController();
  int? _targetNumber;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateNewNumber();
  }

  void _generateNewNumber() {
    _targetNumber = _random.nextInt(100) + 1; // Random number between 1 and 100
  }

  void _handleGuess() {
    final guessText = _guessController.text.trim();

    if (guessText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final guess = int.tryParse(guessText);
    if (guess == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (guess < 1 || guess > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a number between 1 and 100'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_targetNumber == null) {
      _generateNewNumber();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          guessedNumber: guess,
          targetNumber: _targetNumber!,
        ),
      ),
    ).then((_) {
      _guessController.clear();
      _generateNewNumber();
    });
  }

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Guessing Game'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.casino,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 30),
            const Text(
              'Guess the Number',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter a number between 1 and 100',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _guessController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Your Guess',
                hintText: 'Enter a number (1-100)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleGuess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Submit Guess',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },
              child: const Text(
                'View Game History',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

