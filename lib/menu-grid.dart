import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MenuScreen(),
    );
  }
}

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? activeItem;

  final List<String> menuItems = [
    'Dashboard',
    'Settings',
    'Profile',
    'Notifications',
    'Messages',
    'Analytics',
    'Users',
    'Help',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Menu Grid
          Padding(
            padding: EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 2; // default for mobile
                double maxWidth = 200; // max width for grid items

                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 6;
                  maxWidth = 160;
                } else if (constraints.maxWidth > 900) {
                  crossAxisCount = 4;
                  maxWidth = 180;
                } else if (constraints.maxWidth > 600) {
                  crossAxisCount = 3;
                  maxWidth = 180;
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: maxWidth,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return MenuItem(
                      title: item,
                      onTap: () {
                        setState(() {
                          activeItem = item;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Full Screen Panel
          if (activeItem != null)
            DetailPanel(
              title: activeItem!,
              onClose: () {
                setState(() {
                  activeItem = null;
                });
              },
            ),
        ],
      ),
    );
  }
}

class MenuItem extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  MenuItem({required this.title, required this.onTap});

  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isHovered ? Colors.blue[700] : Colors.blue[600],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: isHovered ? 8 : 4,
                offset: Offset(0, isHovered ? 4 : 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class DetailPanel extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  DetailPanel({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            color: Colors.blue[800],
            padding: EdgeInsets.all(16),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Back'),
                  ),
                  SizedBox(width: 16),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to $title',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'This is the content area for $title. You can add any widgets here like forms, lists, charts, or other content.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sample Content',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('• Feature 1: Basic functionality'),
                        Text('• Feature 2: Advanced options'),
                        Text('• Feature 3: User management'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
