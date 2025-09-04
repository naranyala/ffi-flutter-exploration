import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const RandomQuoteApp());
}

class RandomQuoteApp extends StatelessWidget {
  const RandomQuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Quote Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
      ),
      home: const QuoteGeneratorScreen(),
    );
  }
}

class QuoteGeneratorScreen extends StatefulWidget {
  const QuoteGeneratorScreen({super.key});

  @override
  _QuoteGeneratorScreenState createState() => _QuoteGeneratorScreenState();
}

class _QuoteGeneratorScreenState extends State<QuoteGeneratorScreen> {
  final List<Map<String, String>> _quotes = const [
    {
      'quote': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs'
    },
    {
      'quote': 'Believe you can and you\'re halfway there.',
      'author': 'Theodore Roosevelt'
    },
    {
      'quote': 'The future belongs to those who believe in the beauty of their dreams.',
      'author': 'Eleanor Roosevelt'
    },
    {
      'quote': 'What you get by achieving your goals is not as important as what you become by achieving your goals.',
      'author': 'Zig Ziglar'
    },
    {
      'quote': 'Strive not to be a success, but rather to be of value.',
      'author': 'Albert Einstein'
    },
  ];

  final Random _random = Random();
  Map<String, String> _currentQuote = {};
  Color _currentBackgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _generateRandomQuote();
  }

  void _generateRandomQuote() {
    setState(() {
      // Get a random index from the quotes list.
      final int quoteIndex = _random.nextInt(_quotes.length);
      _currentQuote = _quotes[quoteIndex];

      // Generate a new random background color.
      _currentBackgroundColor = Color.fromRGBO(
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
        1.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentBackgroundColor,
      appBar: AppBar(
        title: const Text('Random Quote Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Display the quote
              Text(
                '“${_currentQuote['quote']}”',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              // Display the author
              Text(
                '- ${_currentQuote['author']}',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _generateRandomQuote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Get New Quote',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
