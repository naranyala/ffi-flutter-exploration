import 'package:flutter/material.dart';
import 'dart:math';

class RandomQuoteWidget extends StatefulWidget {
  const RandomQuoteWidget({super.key});

  @override
  State<RandomQuoteWidget> createState() => _RandomQuoteWidgetState();
}

class _RandomQuoteWidgetState extends State<RandomQuoteWidget> {
  final List<String> quotes = [
    "The only way to do great work is to love what you do.",
    "Don't watch the clock; do what it does. Keep going.",
    "Believe you can and you're halfway there.",
    "Everything you've ever wanted is on the other side of fear.",
    "Success is not final, failure is not fatal: it is the courage to continue that counts.",
  ];

  String currentQuote = "";

  @override
  void initState() {
    super.initState();
    _generateRandomQuote();
  }

  void _generateRandomQuote() {
    final random = Random();
    setState(() {
      currentQuote = quotes[random.nextInt(quotes.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5)),
            ],
          ),
          child: Text(
            currentQuote,
            style: const TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _generateRandomQuote,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('New Quote'),
        ),
      ],
    );
  }
}
