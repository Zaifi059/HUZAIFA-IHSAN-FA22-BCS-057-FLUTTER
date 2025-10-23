import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const DiceGuessingGame());
}

class DiceGuessingGame extends StatelessWidget {
  const DiceGuessingGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dice Guessing Game',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const DiceGameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DiceGameScreen extends StatefulWidget {
  const DiceGameScreen({Key? key}) : super(key: key);

  @override
  State<DiceGameScreen> createState() => _DiceGameScreenState();
}

class _DiceGameScreenState extends State<DiceGameScreen>
    with SingleTickerProviderStateMixin {
  int? userGuess;
  int? diceResult;
  bool isRolling = false;
  String resultMessage = '';
  int wins = 0;
  int losses = 0;
  late AnimationController _animController;
  late Animation<double> _rotationAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 4 * pi).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void selectGuess(int number) {
    setState(() {
      userGuess = number;
      diceResult = null;
      resultMessage = '';
    });
    _playClickSound();
  }

  void _playClickSound() {
    // Play a simple beep sound using frequency
    _audioPlayer.play(AssetSource('sounds/click.mp3')).catchError((e) {
      // If sound file not found, just continue without sound
      debugPrint('Sound not available');
    });
  }

  void _playRollSound() {
    // Play dice rolling sound
    _audioPlayer.play(AssetSource('sounds/dice_roll.mp3')).catchError((e) {
      debugPrint('Sound not available');
    });
  }

  void _playWinSound() {
    _audioPlayer.play(AssetSource('sounds/win.mp3')).catchError((e) {
      debugPrint('Sound not available');
    });
  }

  void _playLoseSound() {
    _audioPlayer.play(AssetSource('sounds/lose.mp3')).catchError((e) {
      debugPrint('Sound not available');
    });
  }

  void rollDice() async {
    if (userGuess == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select your guess first!'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      isRolling = true;
      resultMessage = '';
    });

    _playRollSound();
    _animController.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 800));

    final random = Random();
    final result = random.nextInt(6) + 1;

    setState(() {
      diceResult = result;
      isRolling = false;

      if (userGuess == result) {
        resultMessage = '🎉 You Won! 🎉';
        wins++;
        _playWinSound();
      } else {
        resultMessage = '😔 You Lost!';
        losses++;
        _playLoseSound();
      }
    });
  }

  void resetGame() {
    setState(() {
      userGuess = null;
      diceResult = null;
      resultMessage = '';
      wins = 0;
      losses = 0;
    });
    _playClickSound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.casino, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Text(
              'Dice Master',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.shade700,
                Colors.deepPurple.shade900,
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: resetGame,
              tooltip: 'Reset Game',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade100,
              Colors.pink.shade100,
              Colors.orange.shade100,
            ],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://www.transparenttextures.com/patterns/cubes.png',
              ),
              repeat: ImageRepeat.repeat,
              opacity: 0.1,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Score Section
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.shade200,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.emoji_events,
                                    color: Colors.green.shade700, size: 24),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Wins',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$wins',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 60,
                            width: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade400,
                                  Colors.grey.shade300,
                                ],
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.sentiment_dissatisfied,
                                    color: Colors.red.shade700, size: 24),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Losses',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$losses',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Guess Selection Section
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '🎲 Select Your Guess 🎲',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: List.generate(6, (index) {
                          final number = index + 1;
                          final isSelected = userGuess == number;
                          return GestureDetector(
                            onTap: () => selectGuess(number),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isSelected
                                      ? [
                                          Colors.purple.shade400,
                                          Colors.deepPurple.shade600,
                                        ]
                                      : [Colors.white, Colors.grey.shade100],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.purple.shade700
                                      : Colors.purple.shade300,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? Colors.purple.shade300
                                        : Colors.black.withOpacity(0.1),
                                    blurRadius: isSelected ? 8 : 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '$number',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.purple.shade700,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  // Dice Display Section
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: isRolling ? _rotationAnimation.value : 0,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Colors.grey.shade100,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.purple.shade300, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.shade200,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: diceResult != null
                              ? DiceFace(number: diceResult!)
                              : Center(
                                  child: Icon(
                                    Icons.casino_outlined,
                                    size: 50,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),

                  // Result Message
                  SizedBox(
                    height: 50,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: resultMessage.isNotEmpty ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: resultMessage.contains('Won')
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: resultMessage.contains('Won')
                                  ? Colors.green
                                  : Colors.red,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            resultMessage,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: resultMessage.contains('Won')
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Roll Button
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isRolling
                            ? [Colors.grey.shade400, Colors.grey.shade500]
                            : [
                                Colors.purple.shade400,
                                Colors.deepPurple.shade600,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.shade300,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isRolling ? null : rollDice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isRolling ? Icons.hourglass_empty : Icons.casino,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isRolling ? 'Rolling...' : 'Roll Dice',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget to display dice face with dots
class DiceFace extends StatelessWidget {
  final int number;

  const DiceFace({Key? key, required this.number}) : super(key: key);

  Widget buildDot() {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.red.shade600,
            Colors.red.shade800,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade300,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _buildDicePattern(),
    );
  }

  Widget _buildDicePattern() {
    switch (number) {
      case 1:
        return Center(child: buildDot());
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [buildDot()],
            ),
          ],
        );
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [buildDot()],
            ),
          ],
        );
      case 4:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [buildDot(), buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [buildDot(), buildDot()],
            ),
          ],
        );
      case 5:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [buildDot(), buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [buildDot(), buildDot()],
            ),
          ],
        );
      case 6:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [buildDot(), buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [buildDot(), buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [buildDot(), buildDot()],
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }
}
