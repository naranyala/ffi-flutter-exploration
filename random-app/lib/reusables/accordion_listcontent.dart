import 'package:flutter/material.dart';

/// DATA_MODEL: Represents a single section in the accordion list.
/// Each section has a title and a list of content items (strings).
class AccordionSection {
  final String title;
  final List<String> contentItems;

  AccordionSection({
    required this.title,
    required this.contentItems,
  });
}

/// The main application widget.
class AccordionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Accordion UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AccordionHomePage(),
    );
  }
}

/// The home page of the accordion application, a StatefulWidget to manage its state.
class AccordionHomePage extends StatefulWidget {
  @override
  State<AccordionHomePage> createState() => _AccordionHomePageState();
}

/// The state for the AccordionHomePage.
class _AccordionHomePageState extends State<AccordionHomePage> {
  /// Initial data for the accordion sections.
  /// This list drives the creation of the accordion UI.
  final List<AccordionSection> _accordionSections = <AccordionSection>[
    AccordionSection(
      title: 'Section 1: Getting Started',
      contentItems: <String>[
        'Welcome to our app!',
        'This section introduces the basic features.',
        'Explore the different functionalities available.',
      ],
    ),
    AccordionSection(
      title: 'Section 2: User Settings',
      contentItems: <String>[
        'Manage your profile information.',
        'Adjust notification preferences.',
        'Change your password securely.',
        'Configure privacy settings.',
      ],
    ),
    AccordionSection(
      title: 'Section 3: Frequently Asked Questions',
      contentItems: <String>[
        'How do I reset my password?',
        'Where can I find my order history?',
        'Is there a dark mode option?',
        'How can I contact support?',
        'What are the system requirements?',
      ],
    ),
    AccordionSection(
      title: 'Section 4: About This Application',
      contentItems: <String>[
        'Version: 1.0.0',
        'Developed by Custom UI Solutions.',
        'Copyright © 2023. All rights reserved.',
        'Terms of Service and Privacy Policy.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accordion List Content'),
      ),
      body: ListView.builder(
        itemCount: _accordionSections.length,
        itemBuilder: (BuildContext context, int index) {
          final AccordionSection section = _accordionSections[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ExpansionTile(
              key: PageStorageKey<String>(section.title), // Unique key for state preservation
              initiallyExpanded: true, // Make every item expanded by default
              title: Text(
                section.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
              // Use a Column for the children to display the list items vertically.
              // Each content item is wrapped in a Padding and Row for consistent styling.
              children: section.contentItems.map<Widget>((String item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.fiber_manual_record,
                        size: 10.0,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(AccordionApp());
}
