import 'package:flutter/material.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoScreen(),
    );
  }
}

// Todo model
class Todo {
  final int id;
  final String text;
  final bool done;

  Todo({required this.id, required this.text, required this.done});

  Todo copyWith({bool? done}) {
    return Todo(
      id: this.id,
      text: this.text,
      done: done ?? this.done,
    );
  }
}

// Todo store (equivalent to Zustand)
class TodoStore extends ChangeNotifier {
  List<Todo> _todos = [
    Todo(id: 1, text: "Learn Flutter", done: true),
    Todo(id: 2, text: "Build a Todo List", done: false),
    Todo(id: 3, text: "Style with Flutter", done: false),
    Todo(id: 4, text: "Add fuzzy search", done: false),
  ];

  List<Todo> get todos => _todos;

  void toggle(int id) {
    _todos = _todos.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(done: !todo.done);
      }
      return todo;
    }).toList();
    notifyListeners();
  }
}

// Simple fuzzy match function
bool fuzzyMatch(String text, String query) {
  if (query.isEmpty) return true;

  query = query.toLowerCase();
  text = text.toLowerCase();

  int textIndex = 0;
  for (int queryIndex = 0; queryIndex < query.length; queryIndex++) {
    textIndex = text.indexOf(query[queryIndex], textIndex);
    if (textIndex == -1) return false;
    textIndex++;
  }
  return true;
}

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TodoStore store = TodoStore();
  String query = "";

  @override
  void initState() {
    super.initState();
    store.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  List<Todo> get filteredTodos {
    return store.todos.where((todo) => fuzzyMatch(todo.text, query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 360),
          margin: EdgeInsets.all(32),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search box
              Container(
                margin: EdgeInsets.only(bottom: 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "🔍 Search...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      query = value;
                    });
                  },
                ),
              ),

              // Todo items
              ...filteredTodos.map((todo) => TodoItem(
                todo: todo,
                onToggle: () => store.toggle(todo.id),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;

  TodoItem({required this.todo, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                todo.text,
                style: TextStyle(
                  decoration: todo.done ? TextDecoration.lineThrough : null,
                  color: todo.done ? Color(0xFF999999) : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            Checkbox(
              value: todo.done,
              onChanged: (_) => onToggle(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
