import 'package:flutter/material.dart';

void main() => runApp(const FabPanelApp());

class FabPanelApp extends StatelessWidget {
  const FabPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAB Slide-Up Panel',
      theme: ThemeData.dark(),
      home: const FabPanelPage(),
    );
  }
}

class FabPanelPage extends StatefulWidget {
  const FabPanelPage({super.key});

  @override
  State<FabPanelPage> createState() => _FabPanelPageState();
}

enum MainView {
  pageOne,
  pageTwo,
  pageThree,
}

// ✅ Define the MenuItem class
class MenuItem {
  final IconData icon;
  final String label;
  final MainView view;

  const MenuItem({
    required this.icon,
    required this.label,
    required this.view,
  });
}

class _FabPanelPageState extends State<FabPanelPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool isPanelVisible = false;
  MainView currentView = MainView.audioPlayer;

  final List<MenuItem> menuItems = const [
    MenuItem(icon: Icons.code, label: 'Page 1, view:
MainView.pageOne),
    MenuItem(icon: Icons.code, label: 'Page 2', view:
MainView.pageTwo),
    MenuItem(icon: Icons.code, label: 'Page 3', view:
MainView.pageThree),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose(); // ✅ Always dispose the animation controller
    super.dispose();
  }

  void togglePanel() {
    setState(() {
      isPanelVisible = !isPanelVisible;
    });
    if (isPanelVisible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void selectView(MainView view) {
    setState(() {
      currentView = view;
      isPanelVisible = false; // Close panel
    });
    _controller.reverse(); // Animate panel closed
  }

  Widget buildGridMenu() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      mainAxisSpacing: 32,
      crossAxisSpacing: 32,
      children: menuItems.map((item) {
        return GestureDetector(
          onTap: () => selectView(item.view),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.greenAccent.withOpacity(0.7),
                child: Icon(item.icon, size: 32, color: Colors.black),
              ),
              const SizedBox(height: 16),
              Text(item.label, style: const TextStyle(fontSize: 16)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildMainView() {
    switch (currentView) {
      case MainView.pageOne:
        return const Center(child: Text('Page One'));  
      case MainView.pageTwo:
        return const Center(child: Text('Page Two'));
      case MainView.pageThree:
        return const Center(child: Text('Page Three'));
    }
  }

  final Set<MainView> hoveredViews = {};

  void setHover(MainView view, bool isHovering) {
    setState(() {
      if (isHovering) {
        hoveredViews.add(view);
      } else {
        hoveredViews.remove(view);
      }
    });
  }

  Widget buildListMenu() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      children: menuItems.map((item) {
        final isHovered = hoveredViews.contains(item.view);
        return MouseRegion(
          onEnter: (_) => setHover(item.view, true),
          onExit: (_) => setHover(item.view, false),
          child: GestureDetector(
            onTap: () => selectView(item.view),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: isHovered
                    ? Colors.greenAccent.withOpacity(0.2)
                    : Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(item.icon, size: 28, color: Colors.greenAccent),
                  const SizedBox(width: 16),
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAB Slide-Up Panel')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          buildMainView(),
          // Only show panel when animation is running or should be visible
          if (_controller.status != AnimationStatus.dismissed || isPanelVisible)
            SlideTransition(
              position: _offsetAnimation,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 12),
                    ],
                  ),
                  child: buildListMenu(),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: togglePanel,
        child: Icon(isPanelVisible ? Icons.close : Icons.menu),
      ),
    );
  }
}

