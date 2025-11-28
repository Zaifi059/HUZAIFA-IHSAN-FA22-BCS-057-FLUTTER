import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class ResultScreen extends StatefulWidget {
  final int guessedNumber;
  final int targetNumber;

  const ResultScreen({
    super.key,
    required this.guessedNumber,
    required this.targetNumber,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _status = '';
  Color _statusColor = Colors.blue;
  IconData _statusIcon = Icons.info;

  @override
  void initState() {
    super.initState();
    _determineStatus();
    _saveGameResult();
  }

  void _determineStatus() {
    if (widget.guessedNumber == widget.targetNumber) {
      _status = 'Correct!';
      _statusColor = Colors.green;
      _statusIcon = Icons.check_circle;
    } else if (widget.guessedNumber > widget.targetNumber) {
      _status = 'Too High!';
      _statusColor = Colors.orange;
      _statusIcon = Icons.arrow_upward;
    } else {
      _status = 'Too Low!';
      _statusColor = Colors.red;
      _statusIcon = Icons.arrow_downward;
    }
  }

  Future<void> _saveGameResult() async {
    final db = DatabaseHelper.instance;
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    
    await db.insertGameResult(
      guessedNumber: widget.guessedNumber,
      targetNumber: widget.targetNumber,
      status: _status,
      timestamp: timestamp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Result'),
        centerTitle: true,
        backgroundColor: _statusColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _statusIcon,
              size: 100,
              color: _statusColor,
            ),
            const SizedBox(height: 30),
            Text(
              _status,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: _statusColor,
              ),
            ),
            const SizedBox(height: 40),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Guess:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${widget.guessedNumber}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Target Number:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${widget.targetNumber}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/history',
                    (route) => route.isFirst,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'View History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

