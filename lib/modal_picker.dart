import 'package:flutter/material.dart';

class ListPickerModalDemo extends StatefulWidget {
  @override
  _ListPickerModalDemoState createState() => _ListPickerModalDemoState();
}

class _ListPickerModalDemoState extends State<ListPickerModalDemo> {
  String? _selectedItem;

  final List<String> _items = [
    'Option A',
    'Option B',
    'Option C',
    'Option D',
  ];

  void _showListPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return ListView.separated(
          shrinkWrap: true,
          itemCount: _items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = _items[index];
            return ListTile(
              title: Text(item),
              onTap: () => Navigator.pop(context, item),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedItem = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List Picker Modal')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selectedItem ?? 'No item selected'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _showListPicker,
              child: const Text('Pick an Item'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ListPickerModalDemo()));
}

