import 'package:flutter/material.dart';

void main() => runApp(const ChipSelectorApp());

class ChipSelectorApp extends StatelessWidget {
  const ChipSelectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Chip Selector',
      theme: ThemeData.dark(),
      home: const ChipSelectorPage(),
    );
  }
}

class ChipSelectorPage extends StatefulWidget {
  const ChipSelectorPage({super.key});

  @override
  State<ChipSelectorPage> createState() => _ChipSelectorPageState();
}

class _ChipSelectorPageState extends State<ChipSelectorPage> {
  final List<String> chipLabels = [
    'Fedora',
    'Ultramarine',
    'Cinnamon',
    'Rust',
    'Flutter',
    'Svelte',
    'Zustand',
  ];

  final Set<String> selectedChips = {};

  void toggleChip(String label) {
    setState(() {
      if (selectedChips.contains(label)) {
        selectedChips.remove(label);
      } else {
        selectedChips.add(label);
      }
    });
  }

  Widget buildChip(String label) {
    final isSelected = selectedChips.contains(label);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => toggleChip(label),
        selectedColor: Colors.greenAccent.withOpacity(0.6),
        backgroundColor: Colors.grey[800],
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toggleable Chip Selector')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chipLabels.map(buildChip).toList(),
        ),
      ),
    );
  }
}

