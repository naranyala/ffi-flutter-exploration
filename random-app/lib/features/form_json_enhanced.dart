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

  EntryModel copyWith({String? name, int? age, String? email}) {
    return EntryModel(
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntryModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          age == other.age &&
          email == other.email;

  @override
  int get hashCode => name.hashCode ^ age.hashCode ^ email.hashCode;
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

  int? _editingIndex; // Track which entry is being edited (null for new entries)

  void _showFormModal({int? index}) {
    // If editing, populate the form with existing data
    if (index != null) {
      final entry = _entries[index];
      _nameCtrl.text = entry.name;
      _ageCtrl.text = entry.age.toString();
      _emailCtrl.text = entry.email;
      _editingIndex = index;
    } else {
      // If adding new, clear the form
      _nameCtrl.clear();
      _ageCtrl.clear();
      _emailCtrl.clear();
      _editingIndex = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _editingIndex == null ? 'Add New Entry' : 'Edit Entry',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _saveEntry,
                      child: Text(_editingIndex == null ? 'Add' : 'Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      // Clear form when modal is dismissed
      _nameCtrl.clear();
      _ageCtrl.clear();
      _emailCtrl.clear();
      _editingIndex = null;
    });
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final newEntry = EntryModel(
        name: _nameCtrl.text,
        age: int.parse(_ageCtrl.text),
        email: _emailCtrl.text,
      );

      setState(() {
        if (_editingIndex != null) {
          // Update existing entry
          _entries[_editingIndex!] = newEntry;
        } else {
          // Add new entry
          _entries.add(newEntry);
        }
      });

      Navigator.pop(context); // Close the modal
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingIndex == null ? 'Entry added' : 'Entry updated')),
      );
    }
  }

  void _deleteEntry(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${_entries[index].name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _entries.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Entry deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return;

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

    if (fileName == null || fileName.isEmpty) return;
    if (!fileName.endsWith('.json')) fileName = '$fileName.json';

    try {
      final file = File('$selectedDirectory/$fileName');
      final jsonStr = jsonEncode(_entries.map((e) => e.toJson()).toList());
      await file.writeAsString(jsonStr);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: ${e.toString()}')),
      );
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Add Entry Button (replaces the form)
        ElevatedButton(
          onPressed: () => _showFormModal(),
          child: const Text('Add New Entry'),
        ),
        const SizedBox(height: 20),
        
        // Entries Table
        Expanded(
          child: _entries.isEmpty
            ? const Center(child: Text('No entries yet. Click "Add New Entry" to start.'))
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Age')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _entries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      return DataRow(cells: [
                        DataCell(Text(data.name)),
                        DataCell(Text(data.age.toString())),
                        DataCell(Text(data.email)),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _showFormModal(index: index),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _deleteEntry(index),
                              tooltip: 'Delete',
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
        ),
        
        const SizedBox(height: 20),
        
        // Import/Export Buttons
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
