import 'package:flutter/material.dart';

void main() => runApp(LyricsViewerApp());

class LyricsViewerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LyricsViewer());
  }
}

class LyricsViewer extends StatefulWidget {
  @override
  _LyricsViewerState createState() => _LyricsViewerState();
}

class _LyricsViewerState extends State<LyricsViewer> {
  final List<String> lyrics = [
    "Line 1: Just a placeholder",
    "Line 2: Another fake lyric",
    "Line 3: This one's in the center",
    "Line 4: Scroll me away",
    "Line 5: End of the demo"
  ];

  final FixedExtentScrollController _controller = FixedExtentScrollController();

  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ListWheelScrollView.useDelegate(
          controller: _controller,
          itemExtent: 50,
          physics: FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) {
              if (index < 0 || index >= lyrics.length) return null;
              final isSelected = index == _selectedIndex;
              return Center(
                child: Text(
                  lyrics[index],
                  style: TextStyle(
                    color: isSelected ? Colors.amber : Colors.grey,
                    fontSize: isSelected ? 22 : 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
            childCount: lyrics.length,
          ),
        ),
      ),
    );
  }
}

