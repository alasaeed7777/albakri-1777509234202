```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ø­Ø§Ø³Ø¨Ù',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blueGrey,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double? _firstOperand;
  String? _operator;
  bool _waitingForSecondOperand = false;

  void _inputDigit(String digit) {
    if (_waitingForSecondOperand) {
      setState(() {
        _display = digit;
        _waitingForSecondOperand = false;
      });
    } else {
      setState(() {
        if (_display == '0') {
          _display = digit;
        } else {
          _display += digit;
        }
      });
    }
  }

  void _inputDecimal() {
    if (_waitingForSecondOperand) {
      setState(() {
        _display = '0.';
        _waitingForSecondOperand = false;
      });
      return;
    }
    if (!_display.contains('.')) {
      setState(() {
        _display += '.';
      });
    }
  }

  void _performOperation(String op) {
    final double current = double.parse(_display);
    if (_firstOperand != null && !_waitingForSecondOperand) {
      _calculate();
    }
    setState(() {
      _firstOperand = double.parse(_display);
      _operator = op;
      _waitingForSecondOperand = true;
      _expression = '${_formatNumber(_firstOperand!)} $op';
    });
  }

  void _calculate() {
    if (_firstOperand == null || _operator == null) return;
    final double secondOperand = double.parse(_display);
    double result;
    switch (_operator) {
      case '+':
        result = _firstOperand! + secondOperand;
        break;
      case '-':
        result = _firstOperand! - secondOperand;
        break;
      case 'Ã':
        result = _firstOperand! * secondOperand;
        break;
      case 'Ã·':
        result = secondOperand != 0 ? _firstOperand! / secondOperand : double.nan;
        break;
      default:
        return;
    }
    setState(() {
      _display = result.isNaN ? 'Ø®Ø·Ø£' : _formatNumber(result);
      _expression = '${_formatNumber(_firstOperand!)} $_operator ${_formatNumber(secondOperand)} =';
      _firstOperand = result.isNaN ? null : result;
      _operator = null;
      _waitingForSecondOperand = true;
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _expression = '';
      _firstOperand = null;
      _operator = null;
      _waitingForSecondOperand = false;
    });
  }

  void _deleteLast() {
    if (_waitingForSecondOperand) return;
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  void _toggleSign() {
    if (_display == '0') return;
    setState(() {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
    });
  }

  void _percentage() {
    final double value = double.parse(_display) / 100;
    setState(() {
      _display = _formatNumber(value);
    });
  }

  String _formatNumber(double number) {
    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }
    // Remove trailing zeros
    String text = number.toStringAsFixed(10);
    text = text.replaceAll(RegExp(r'0+$'), '');
    text = text.replaceAll(RegExp(r'\.$'), '');
    return text;
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: 70,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ø­Ø§Ø³Ø¨Ù'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Display area
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _expression,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _display,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
          // Button grid
          Expanded(
            flex: 4,
            child: Column(
              children: [
                // Row 1: AC, Â±, %, Ã·
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('AC', Colors.grey.shade700, _clear),
                      _buildButton('Â±', Colors.grey.shade700, _toggleSign),
                      _buildButton('%', Colors.grey.shade700, _percentage),
                      _buildButton('Ã·', Colors.orange.shade700, () => _performOperation('Ã·')),
                    ],
                  ),
                ),
                // Row 2: 7, 8, 9, Ã
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('7', Colors.grey.shade800, () => _inputDigit('7')),
                      _buildButton('8', Colors.grey.shade800, () => _inputDigit('8')),
                      _buildButton('9', Colors.grey.shade800, () => _inputDigit('9')),
                      _buildButton('Ã', Colors.orange.shade700, () => _performOperation('Ã')),
                    ],
                  ),
                ),
                // Row 3: 4, 5, 6, -
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('4', Colors.grey.shade800, () => _inputDigit('4')),
                      _buildButton('5', Colors.grey.shade800, () => _inputDigit('5')),
                      _buildButton('6', Colors.grey.shade800, () => _inputDigit('6')),
                      _buildButton('-', Colors.orange.shade700, () => _performOperation('-')),
                    ],
                  ),
                ),
                // Row 4: 1, 2, 3, +
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('1', Colors.grey.shade800, () => _inputDigit('1')),
                      _buildButton('2', Colors.grey.shade800, () => _inputDigit('2')),
                      _buildButton('3', Colors.grey.shade800, () => _inputDigit('3')),
                      _buildButton('+', Colors.orange.shade700, () => _performOperation('+')),
                    ],
                  ),
                ),
                // Row 5: 0, ., â«, =
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('0', Colors.grey.shade800, () => _inputDigit('0')),
                      _buildButton('.', Colors.grey.shade800, _inputDecimal),
                      _buildButton('â«', Colors.grey.shade700, _deleteLast),
                      _buildButton('=', Colors.orange.shade700, _calculate),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```