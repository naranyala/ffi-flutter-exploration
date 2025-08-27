import 'package:flutter/material.dart';

// Model classes remain the same
class DashboardItem {
  final String title;
  final String detailContent;
  DashboardItem({
    required this.title,
    required this.detailContent,
  });
}

class AccordionSection {
  final String title;
  final List<DashboardItem> contentItems;
  AccordionSection({
    required this.title,
    required this.contentItems,
  });
}

// External data source (composed from outside the UI components)
const List<Map<String, dynamic>> _rawAccordionData = [
  {
    'title': 'Section 1: Getting Started',
    'items': [
      {
        'title': 'Welcome to our app!',
        'content': 'This is the welcome message for new users. It provides an overview of the application and its main features.',
      },
      {
        'title': 'Introduction to Features',
        'content': 'Discover all the powerful features designed to enhance your experience. Learn how to navigate and utilize each tool effectively.',
      },
      {
        'title': 'Exploring Functionalities',
        'content': 'Dive deeper into specific functionalities. This section guides you through advanced usage and tips for maximizing productivity.',
      },
    ],
  },
  {
    'title': 'Section 2: User Settings',
    'items': [
      {
        'title': 'Manage Profile',
        'content': 'Update your personal information, profile picture, and contact details here.',
      },
      {
        'title': 'Notification Preferences',
        'content': 'Customize how and when you receive notifications from the app. Control email, push, and in-app alerts.',
      },
      {
        'title': 'Change Password',
        'content': 'Securely update your account password to maintain your privacy and security.',
      },
      {
        'title': 'Privacy Settings',
        'content': 'Control your data sharing and privacy options. Review and adjust what information is visible to others.',
      },
    ],
  },
  {
    'title': 'Section 3: Frequently Asked Questions',
    'items': [
      {
        'title': 'How to Reset Password?',
        'content': 'If you forgot your password, follow these steps to reset it quickly and securely.',
      },
      {
        'title': 'Where is Order History?',
        'content': 'Your complete order history, including past purchases and statuses, can be found in this section.',
      },
      {
        'title': 'Dark Mode Option',
        'content': 'Learn how to enable or disable dark mode for a more comfortable viewing experience.',
      },
      {
        'title': 'Contact Support',
        'content': 'Find various ways to contact our support team for assistance with any issues or questions.',
      },
      {
        'title': 'System Requirements',
        'content': 'Check the minimum system requirements needed to run this application smoothly on your device.',
      },
    ],
  },
  {
    'title': 'Section 4: About This Application',
    'items': [
      {
        'title': 'Version Information',
        'content': 'Current application version: 1.0.0. Stay updated with the latest features and bug fixes.',
      },
      {
        'title': 'Developed By',
        'content': 'This application was proudly developed by Custom UI Solutions, dedicated to creating bespoke user experiences.',
      },
      {
        'title': 'Copyright Notice',
        'content': 'Copyright © 2023. All rights reserved. Unauthorized reproduction or distribution is prohibited.',
      },
      {
        'title': 'Terms of Service & Privacy Policy',
        'content': 'Review our comprehensive terms of service and privacy policy to understand your rights and obligations.',
      },
    ],
  },
];

// Data parser that transforms raw data into model objects
class AccordionDataParser {
  static List<AccordionSection> parseData() {
    return _rawAccordionData.map((sectionData) {
      final items = (sectionData['items'] as List).map((itemData) {
        return DashboardItem(
          title: itemData['title'],
          detailContent: itemData['content'],
        );
      }).toList();

      return AccordionSection(
        title: sectionData['title'],
        contentItems: items,
      );
    }).toList();
  }
}

// Main app widget
class AccordionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Accordion UI Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
      ),
      home: AccordionDashboard(),
    );
  }
}

// Dashboard widget
class AccordionDashboard extends StatefulWidget {
  @override
  State<AccordionDashboard> createState() => _AccordionDashboardState();
}

class _AccordionDashboardState extends State<AccordionDashboard> {
  late List<AccordionSection> _accordionSections;

  @override
  void initState() {
    super.initState();
    // Parse data from external source
    _accordionSections = AccordionDataParser.parseData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accordion Dashboard'),
      ),
      body: ListView.builder(
        itemCount: _accordionSections.length,
        itemBuilder: (BuildContext context, int sectionIndex) {
          final AccordionSection section = _accordionSections[sectionIndex];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ExpansionTile(
              key: PageStorageKey<String>(section.title),
              initiallyExpanded: sectionIndex == 0, // Only expand first section by default
              title: Text(
                section.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
              children: section.contentItems.map<Widget>((DashboardItem item) {
                return ListTile(
                  leading: const Icon(
                    Icons.arrow_right,
                    color: Colors.blueAccent,
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => DetailPage(item: item),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

// Detail page remains the same
class DetailPage extends StatelessWidget {
  final DashboardItem item;
  const DetailPage({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              item.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(
              item.detailContent,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'For more information, please refer to the documentation.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(AccordionApp());
}
