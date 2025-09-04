// flutter_sortable_list_with_stack.dart
// Single-file Flutter app demonstrating a sortable list with drag-and-drop handler
// and a perfectly centered reactive stacked view on top
import 'package:flutter/material.dart';

void main() {
  runApp(const SortableListWithStackApp());
}

class SortableListWithStackApp extends StatelessWidget {
  const SortableListWithStackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sortable List with Stacked View',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SortableListWithStackPage(),
    );
  }
}

class SortableListWithStackPage extends StatefulWidget {
  const SortableListWithStackPage({super.key});

  @override
  State<SortableListWithStackPage> createState() => _SortableListWithStackPageState();
}

class _SortableListWithStackPageState extends State<SortableListWithStackPage> {
  List<String> items = [
    'Item A',
    'Item B',
    'Item C',
    'Item D',
    'Item E',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sortable List with Stacked View'),
      ),
      body: Column(
        children: [
          // Perfectly centered stacked viewer
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: SizedBox(
                width: 300, // Fixed width for the stacking area
                height: 150, // Fixed height for the stacking area
                child: Stack(
                  children: [
                    // Create centered stacked items
                    for (int i = 0; i < items.length; i++)
                      Positioned(
                        left: 150 + (i * 15) - (items.length * 7.5), // Center horizontally in the 300px width
                        top: 75 + (i * 8) - (items.length * 4), // Center vertically in the 150px height
                        child: Transform.translate(
                          offset: const Offset(-50, -10), // Adjust for text width/height
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(i * 1.0, i * 1.0),
                                ),
                              ],
                            ),
                            child: Opacity(
                              opacity: 1.0 - (i * 0.12).clamp(0, 0.8),
                              child: Text(
                                items[i],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(thickness: 2),
          // List info
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Items: ${items.length} | Drag to reorder, tap delete to remove',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          // Sortable list
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = items.removeAt(oldIndex);
                  items.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                return Card(
                  key: ValueKey(items[index]),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(
                      items[index],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    leading: Icon(
                      Icons.drag_handle,
                      color: Colors.grey.shade600,
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade400,
                      ),
                      onPressed: () {
                        setState(() {
                          items.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

    );
  }
}
