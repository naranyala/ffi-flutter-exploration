import 'package:flutter/material.dart';

void main() {
  runApp(const SWOTApp());
}

class SWOTApp extends StatelessWidget {
  const SWOTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SWOT Analysis',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        cardTheme: const CardTheme(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
      home: const SWOTPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SWOTPage extends StatelessWidget {
  const SWOTPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<SWOTItem> swotData = [
      SWOTItem("Strengths", [
        "Fast performance",
        "User-friendly UI",
        "Good documentation"
      ], Colors.green.shade300),
      SWOTItem("Weaknesses", [
        "Limited offline features",
        "Small developer team"
      ], Colors.red.shade300),
      SWOTItem("Opportunities", [
        "Growing market",
        "Partnership options"
      ], Colors.blue.shade300),
      SWOTItem("Threats", [
        "Competition from big players",
        "Changing regulations"
      ], Colors.orange.shade300),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("SWOT Analysis")),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: swotData.length,
          itemBuilder: (context, index) {
            return SWOTCard(item: swotData[index]);
          },
        ),
      ),
    );
  }
}

class SWOTItem {
  final String title;
  final List<String> points;
  final Color color;

  SWOTItem(this.title, this.points, this.color);
}

class SWOTCard extends StatelessWidget {
  final SWOTItem item;
  const SWOTCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: item.color,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: item.points.map((point) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("• ",
                              style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              point,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

