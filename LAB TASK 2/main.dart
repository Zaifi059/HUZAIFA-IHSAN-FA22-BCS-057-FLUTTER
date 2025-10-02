import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        fontFamily: 'Roboto',
      ),
      home: const Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> with TickerProviderStateMixin {
  String _display = '0';
  String _previousOperand = '';
  String _operator = '';
  bool _waitingForOperand = false;
  bool _hasDecimal = false;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _inputNumber(String number) {
    setState(() {
      if (_waitingForOperand) {
        _display = number;
        _waitingForOperand = false;
        _hasDecimal = false;
      } else {
        _display = _display == '0' ? number : _display + number;
      }
    });
  }

  void _inputDecimal() {
    setState(() {
      if (_waitingForOperand) {
        _display = '0.';
        _waitingForOperand = false;
        _hasDecimal = true;
      } else if (!_hasDecimal) {
        _display += '.';
        _hasDecimal = true;
      }
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _previousOperand = '';
      _operator = '';
      _waitingForOperand = false;
      _hasDecimal = false;
    });
  }

  void _inputOperator(String nextOperator) {
    try {
      double inputValue = double.parse(_display);

      if (_previousOperand.isEmpty) {
        _previousOperand = _display;
      } else if (!_waitingForOperand) {
        double previousValue = double.parse(_previousOperand);
        double result = _calculate(previousValue, inputValue, _operator);
        
        setState(() {
          _display = _formatNumber(result);
          _previousOperand = _display;
        });
      }

      setState(() {
        _waitingForOperand = true;
        _operator = nextOperator;
        _hasDecimal = false;
      });
    } catch (e) {
      setState(() {
        _display = 'Error';
        _previousOperand = '';
        _operator = '';
        _waitingForOperand = true;
        _hasDecimal = false;
      });
    }
  }

  void _performCalculation() {
    if (_previousOperand.isNotEmpty && !_waitingForOperand) {
      try {
        double previousValue = double.parse(_previousOperand);
        double inputValue = double.parse(_display);
        double result = _calculate(previousValue, inputValue, _operator);
        
        setState(() {
          _display = _formatNumber(result);
          _previousOperand = '';
          _operator = '';
          _waitingForOperand = true;
          _hasDecimal = _display.contains('.');
        });
      } catch (e) {
        setState(() {
          _display = 'Error';
          _previousOperand = '';
          _operator = '';
          _waitingForOperand = true;
          _hasDecimal = false;
        });
      }
    }
  }

  void _toggleSign() {
    setState(() {
      if (_display != '0' && _display != 'Error') {
        if (_display.startsWith('-')) {
          _display = _display.substring(1);
        } else {
          _display = '-$_display';
        }
      }
    });
  }

  double _calculate(double firstOperand, double secondOperand, String operator) {
    switch (operator) {
      case '+':
        return firstOperand + secondOperand;
      case '-':
        return firstOperand - secondOperand;
      case '×':
        return firstOperand * secondOperand;
      case '÷':
        if (secondOperand == 0) {
          throw Exception('Cannot divide by zero');
        }
        return firstOperand / secondOperand;
      case '%':
        return firstOperand % secondOperand;
      default:
        return secondOperand;
    }
  }

  String _formatNumber(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    } else {
      return number.toString();
    }
  }

  void _onButtonPressed() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Display Area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2D2D2D), Color(0xFF1E1E1E)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_previousOperand.isNotEmpty && _operator.isNotEmpty)
            Text(
                        '$_previousOperand $_operator',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _display,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Button Grid
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Row 1: Clear, ±, %, ÷
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('C', _clear, isSpecial: true),
                          _buildButton('±', _toggleSign, isSpecial: true),
                          _buildButton('%', () => _inputOperator('%'), isSpecial: true),
                          _buildButton('÷', () => _inputOperator('÷'), isOperator: true),
                        ],
                      ),
                    ),
                    // Row 2: 7, 8, 9, ×
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('7', () => _inputNumber('7')),
                          _buildButton('8', () => _inputNumber('8')),
                          _buildButton('9', () => _inputNumber('9')),
                          _buildButton('×', () => _inputOperator('×'), isOperator: true),
                        ],
                      ),
                    ),
                    // Row 3: 4, 5, 6, -
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('4', () => _inputNumber('4')),
                          _buildButton('5', () => _inputNumber('5')),
                          _buildButton('6', () => _inputNumber('6')),
                          _buildButton('-', () => _inputOperator('-'), isOperator: true),
                        ],
                      ),
                    ),
                    // Row 4: 1, 2, 3, +
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('1', () => _inputNumber('1')),
                          _buildButton('2', () => _inputNumber('2')),
                          _buildButton('3', () => _inputNumber('3')),
                          _buildButton('+', () => _inputOperator('+'), isOperator: true),
                        ],
                      ),
                    ),
                    // Row 5: 0, ., =
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('0', () => _inputNumber('0'), isWide: true),
                          _buildButton('.', _inputDecimal),
                          _buildButton('=', _performCalculation, isOperator: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    String text,
    VoidCallback onPressed, {
    bool isOperator = false,
    bool isSpecial = false,
    bool isWide = false,
  }) {
    Color backgroundColor;
    Color textColor;
    
    if (isOperator) {
      backgroundColor = const Color(0xFFFF9500);
      textColor = Colors.white;
    } else if (isSpecial) {
      backgroundColor = const Color(0xFFA6A6A6);
      textColor = Colors.black;
    } else {
      backgroundColor = const Color(0xFF333333);
      textColor = Colors.white;
    }

    return Expanded(
      flex: isWide ? 2 : 1,
      child: Container(
        margin: const EdgeInsets.all(4),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Material(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(isWide ? 40 : 80),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.3),
                child: InkWell(
                  borderRadius: BorderRadius.circular(isWide ? 40 : 80),
                  onTap: () {
                    _onButtonPressed();
                    onPressed();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isWide ? 40 : 80),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          backgroundColor.withOpacity(0.8),
                          backgroundColor,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
