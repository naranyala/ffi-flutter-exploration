import 'package:flutter/material.dart';

void main() => runApp(const FuzzySearchApp());

class FuzzySearchApp extends StatelessWidget {
  const FuzzySearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fuzzy Search List',
      theme: ThemeData.dark(),
      home: const SearchPage(),
    );
  }
}

class SearchItem {
  final String title;
  const SearchItem(this.title);
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List<SearchItem> allItems = const [
    SearchItem('Fedora Workstation'),
    SearchItem('Ultramarine Linux'),
    SearchItem('Cinnamon Desktop'),
    SearchItem('Rust Audio Toolkit'),
    SearchItem('Svelte UI Components'),
    SearchItem('Zustand State Manager'),
    SearchItem('Flutter DSP Module'),
  ];

  List<SearchItem> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = allItems;
  }

  void updateSearch(String query) {
    if (query.isEmpty) {
      setState(() => filteredItems = allItems);
      return;
    }

    final scored = allItems.map((item) {
      final score = fuzzyScore(item.title.toLowerCase(), query.toLowerCase());
      return MapEntry(item, score);
    }).where((entry) => entry.value > 0).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    setState(() => filteredItems = scored.map((e) => e.key).toList());
  }

  int fuzzyScore(String text, String query) {
    int score = 0;
    int lastMatchIndex = -1;

    for (var char in query.characters) {
      final index = text.indexOf(char, lastMatchIndex + 1);
      if (index != -1) {
        score += 10 - (index - lastMatchIndex); // reward proximity
        lastMatchIndex = index;
      } else {
        score -= 5; // penalty for missing char
      }
    }

    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fuzzy Search List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
              ),
              onChanged: updateSearch,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (_, index) {
                final item = filteredItems[index];
                return ListTile(
                  title: Text(item.title),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

