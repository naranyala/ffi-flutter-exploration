import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Sheet Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: BottomSheetDemo(),
    );
  }
}

class BottomSheetDemo extends StatefulWidget {
  @override
  _BottomSheetDemoState createState() => _BottomSheetDemoState();
}

class _BottomSheetDemoState extends State<BottomSheetDemo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Bottom Sheet Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose a Bottom Sheet Type:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // Modal Bottom Sheet
            ElevatedButton.icon(
              onPressed: _showModalBottomSheet,
              icon: Icon(Icons.launch),
              label: Text('Modal Bottom Sheet'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
              ),
            ),
            SizedBox(height: 12),
            
            // Persistent Bottom Sheet
            ElevatedButton.icon(
              onPressed: _showPersistentBottomSheet,
              icon: Icon(Icons.vertical_align_bottom),
              label: Text('Persistent Bottom Sheet'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
              ),
            ),
            SizedBox(height: 12),
            
            // Draggable Scrollable Sheet
            ElevatedButton.icon(
              onPressed: _showDraggableScrollableSheet,
              icon: Icon(Icons.drag_handle),
              label: Text('Draggable Scrollable Sheet'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
              ),
            ),
            SizedBox(height: 12),
            
            // Custom Bottom Sheet
            ElevatedButton.icon(
              onPressed: _showCustomBottomSheet,
              icon: Icon(Icons.tune),
              label: Text('Custom Styled Sheet'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
              ),
            ),
            
            SizedBox(height: 40),
            Text(
              'Tips:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• Modal sheets overlay content and dismiss on tap outside\n'
              '• Persistent sheets stay visible and push content up\n'
              '• Draggable sheets can be resized by dragging\n'
              '• Custom sheets allow full styling control',
              style: TextStyle(color: Colors.grey[600], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Modal Bottom Sheet - Most common, overlays content
  void _showModalBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows custom height
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle indicator
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      Text(
                        'Modal Bottom Sheet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      ...List.generate(10, (index) => 
                        ListTile(
                          leading: Icon(Icons.star, color: Colors.amber),
                          title: Text('Item ${index + 1}'),
                          subtitle: Text('This is item number ${index + 1}'),
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tapped item ${index + 1}')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 2. Persistent Bottom Sheet - Stays visible, pushes content
  void _showPersistentBottomSheet() {
    _scaffoldKey.currentState?.showBottomSheet(
      (context) => Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Persistent Bottom Sheet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'This sheet pushes content up and stays visible until explicitly closed.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Action performed!')),
                          );
                        },
                        child: Text('Action'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Draggable Scrollable Sheet - Full-screen capable
  void _showDraggableScrollableSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  width: 50,
                  height: 5,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Draggable Sheet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                
                // Scrollable content
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: 50,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: Text('Scrollable Item ${index + 1}'),
                          subtitle: Text('Drag the handle to resize this sheet'),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 4. Custom Bottom Sheet with advanced styling
  void _showCustomBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CustomBottomSheet(),
    );
  }
}

// Custom Bottom Sheet Widget with advanced features
class CustomBottomSheet extends StatefulWidget {
  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.purple[100]!, Colors.white],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Custom handle with animation
              Container(
                width: 60 * _animation.value,
                height: 6,
                margin: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.purple[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              
              // Title with slide animation
              Transform.translate(
                offset: Offset(0, 20 * (1 - _animation.value)),
                child: Opacity(
                  opacity: _animation.value,
                  child: Text(
                    'Custom Bottom Sheet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Content with staggered animation
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      ...List.generate(3, (index) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            30 * (1 - _animation.value) * (index + 1),
                          ),
                          child: Opacity(
                            opacity: _animation.value,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 15),
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.stars,
                                    color: Colors.purple,
                                    size: 30,
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Feature ${index + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'This is a custom styled feature item',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      
                      Spacer(),
                      
                      // Action buttons
                      Transform.translate(
                        offset: Offset(0, 20 * (1 - _animation.value)),
                        child: Opacity(
                          opacity: _animation.value,
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    side: BorderSide(color: Colors.purple),
                                  ),
                                  child: Text('Cancel'),
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Custom action completed!'),
                                        backgroundColor: Colors.purple,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                  ),
                                  child: Text('Confirm'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
