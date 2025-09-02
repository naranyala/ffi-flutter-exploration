import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Dropdown',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String? selectedValue;

  final List<String> items = ['Option 1', 'Option 2', 'Option 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dropdown Example')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: DropdownButton<String>(
          value: selectedValue,
          hint: const Text('Select an option'),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue;
            });
          },
        ),
      ),
    );
  }
}
