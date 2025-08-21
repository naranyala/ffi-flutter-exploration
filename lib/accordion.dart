import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Accordion Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: AccordionScreen(),
    );
  }
}

class AccordionScreen extends StatelessWidget {
  // Sample data structure
  final List<AccordionItem> accordionData = [
    AccordionItem(
      title: 'What is Flutter?',
      content: 'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.',
    ),
    AccordionItem(
      title: 'Key Features',
      content: 'Fast development, expressive UIs, native performance, and hot reload for quick iteration.',
    ),
    AccordionItem(
      title: 'Programming Language',
      content: 'Flutter uses Dart, a client-optimized language for fast apps on any platform.',
    ),
    AccordionItem(
      title: 'Popular Apps Built with Flutter',
      content: 'Google Ads, Alibaba, BMW, Toyota, and many other major companies use Flutter for their mobile applications.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minimal Accordion'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Tap any section to expand/collapse',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            // Simple approach using ExpansionTile
            ...accordionData.map((item) => Card(
              margin: EdgeInsets.only(bottom: 8.0),
              child: ExpansionTile(
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      item.content,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}

// Custom accordion using ExpansionPanelList for more control
class CustomAccordionScreen extends StatefulWidget {
  @override
  _CustomAccordionScreenState createState() => _CustomAccordionScreenState();
}

class _CustomAccordionScreenState extends State<CustomAccordionScreen> {
  List<AccordionItem> accordionData = [
    AccordionItem(title: 'Section 1', content: 'Content for section 1', isExpanded: false),
    AccordionItem(title: 'Section 2', content: 'Content for section 2', isExpanded: false),
    AccordionItem(title: 'Section 3', content: 'Content for section 3', isExpanded: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Accordion'),
      ),
      body: SingleChildScrollView(
        child: ExpansionPanelList(
          elevation: 1,
          expandedHeaderPadding: EdgeInsets.all(0),
          children: accordionData.asMap().entries.map<ExpansionPanel>((entry) {
            int index = entry.key;
            AccordionItem item = entry.value;
            
            return ExpansionPanel(
              headerBuilder: (context, isExpanded) {
                return ListTile(
                  title: Text(
                    item.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
              body: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(item.content),
              ),
              isExpanded: item.isExpanded,
            );
          }).toList(),
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              accordionData[index].isExpanded = !isExpanded;
            });
          },
        ),
      ),
    );
  }
}

// Data model for accordion items
class AccordionItem {
  final String title;
  final String content;
  bool isExpanded;

  AccordionItem({
    required this.title,
    required this.content,
    this.isExpanded = false,
  });
}
