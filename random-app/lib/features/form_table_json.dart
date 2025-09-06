import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Form + Table + JSON',
    home: Scaffold(
      appBar: AppBar(title: const Text('Entry Manager')),
      body: const EntryFormTable(),
    ),
  );
}

class EntryModel {
  final String name;
  final int age;
  final String email;

  EntryModel({required this.name, required this.age, required this.email});

  factory EntryModel.fromJson(Map<String, dynamic> json) => EntryModel(
    name: json['name'],
    age: json['age'],
    email: json['email'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'email': email,
  };
}

class EntryFormTable extends StatefulWidget {
  const EntryFormTable({super.key});
  @override
  State<EntryFormTable> createState() => _EntryFormTableState();
}

class _EntryFormTableState extends State<EntryFormTable> {
  final List<EntryModel> _entries = [];
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  void _addEntry() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _entries.add(EntryModel(
          name: _nameCtrl.text,
          age: int.parse(_ageCtrl.text),
          email: _emailCtrl.text,
        ));
        _nameCtrl.clear();
        _ageCtrl.clear();
        _emailCtrl.clear();
      });
    }
  }

  Future<void> _importJson() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        setState(() {
          _entries.addAll(jsonList.map((e) => EntryModel.fromJson(e)).toList());
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imported ${jsonList.length} entries')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _exportJson() async {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No entries to export')),
      );
      return;
    }

    // Let user choose directory
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      // User canceled the directory picker
      return;
    }

    // Show dialog to get filename
    String? fileName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController fileNameCtrl = TextEditingController(text: 'entries_export');
        return AlertDialog(
          title: const Text('Export File'),
          content: TextField(
            controller: fileNameCtrl,
            decoration: const InputDecoration(
              labelText: 'File Name',
              hintText: 'Enter file name without extension',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, fileNameCtrl.text),
              child: const Text('Export'),
            ),
          ],
        );
      },
    );

    if (fileName == null || fileName.isEmpty) {
      // User canceled or entered empty filename
      return;
    }

    // Ensure filename has .json extension
    if (!fileName.endsWith('.json')) {
      fileName = '$fileName.json';
    }

    try {
      final file = File('$selectedDirectory/$fileName');
      final jsonStr = jsonEncode(_entries.map((e) => e.toJson()).toList());
      await file.writeAsString(jsonStr);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _ageCtrl,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid age' : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null,
              ),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _addEntry, child: const Text('Add Entry')),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _entries.isEmpty
          ? const Text('No entries yet.')
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Age')),
                  DataColumn(label: Text('Email')),
                ],
                rows: _entries.map((e) => DataRow(cells: [
                  DataCell(Text(e.name)),
                  DataCell(Text(e.age.toString())),
                  DataCell(Text(e.email)),
                ])).toList(),
              ),
            ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _importJson, 
              child: const Text('Import JSON')
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _exportJson, 
              child: const Text('Export JSON')
            ),
          ],
        ),
      ],
    ),
  );
}
