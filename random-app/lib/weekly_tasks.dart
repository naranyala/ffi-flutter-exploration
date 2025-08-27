import 'package:flutter/material.dart';

class Task {
  final String title;
  final String description;
  DateTime dueDate;
  bool isDone;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    this.isDone = false,
  });
}

class TaskManager {
  final List<Task> _tasks = [];

  void addTask(Task task) => _tasks.add(task);

  List<Task> getTasksForDay(DateTime day) {
    return _tasks.where((t) => _isSameDay(t.dueDate, day)).toList();
  }

  void carryOverUndoneTasks(DateTime currentDay) {
    for (var task in _tasks) {
      if (!task.isDone && task.dueDate.isBefore(currentDay)) {
        // Move to current day if still not done
        task.dueDate = DateTime(
          currentDay.year,
          currentDay.month,
          currentDay.day,
        ); // Avoid time-of-day issues
      }
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Getter to access tasks for weekly view (needed since _tasks is private)
  List<Task> get tasks => List.unmodifiable(_tasks);
}

class DailyTaskScreen extends StatefulWidget {
  final TaskManager taskManager;

  const DailyTaskScreen({Key? key, required this.taskManager}) : super(key: key);

  @override
  State<DailyTaskScreen> createState() => _DailyTaskScreenState();
}

class _DailyTaskScreenState extends State<DailyTaskScreen> {
  late DateTime selectedDate;
  late List<DateTime> weekDays;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _updateWeekDays();
    widget.taskManager.carryOverUndoneTasks(selectedDate);
  }

  void _updateWeekDays() {
    final firstDayOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    weekDays = List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));
  }

  String _formatDayOfWeek(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _formatDateNumber(DateTime date) {
    return date.day.toString();
  }

  String _formatMonthYear(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isSelected(DateTime date) {
    return selectedDate.year == date.year && 
           selectedDate.month == date.month && 
           selectedDate.day == date.day;
  }

  void _navigateToPreviousWeek() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 7));
      _updateWeekDays();
    });
  }

  void _navigateToNextWeek() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 7));
      _updateWeekDays();
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.taskManager.getTasksForDay(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasks for ${_formatMonthYear(selectedDate)}',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateToPreviousWeek,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _navigateToNextWeek,
          ),
        ],
      ),
      body: Column(
        children: [
          // Week days header
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: weekDays.map((date) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(date),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _isSelected(date)
                            ? Theme.of(context).primaryColor
                            : _isToday(date)
                                ? Theme.of(context).primaryColor.withOpacity(0.2)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: _isToday(date) && !_isSelected(date)
                            ? Border.all(color: Theme.of(context).primaryColor)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatDayOfWeek(date),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _isSelected(date) ? Colors.white : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateNumber(date),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _isSelected(date) ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Tasks list
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Text(
                      'No tasks for ${_formatDayOfWeek(selectedDate)}, ${_formatDateNumber(selectedDate)}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return CheckboxListTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isDone ? TextDecoration.lineThrough : null,
                            color: task.isDone ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          task.description,
                          style: TextStyle(
                            decoration: task.isDone ? TextDecoration.lineThrough : null,
                            color: task.isDone ? Colors.grey : Colors.black54,
                          ),
                        ),
                        value: task.isDone,
                        onChanged: (val) {
                          setState(() {
                            task.isDone = val ?? false;
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TaskManager taskManager = TaskManager();

    // Add some sample tasks
    final now = DateTime.now();
    
    // Tasks for today
    taskManager.addTask(Task(
      title: "Finish Flutter App",
      description: "Fix the task manager app",
      dueDate: DateTime(now.year, now.month, now.day),
    ));

    taskManager.addTask(Task(
      title: "Buy Groceries",
      description: "Milk and eggs",
      dueDate: DateTime(now.year, now.month, now.day),
    ));

    // Tasks for tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    taskManager.addTask(Task(
      title: "Meeting with team",
      description: "Project discussion",
      dueDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
    ));

    // Tasks for yesterday (should be carried over)
    final yesterday = now.subtract(const Duration(days: 1));
    taskManager.addTask(Task(
      title: "Clean room",
      description: "Vacuum and dust",
      dueDate: DateTime(yesterday.year, yesterday.month, yesterday.day),
    ));

    return MaterialApp(
      title: "Daily Task Manager",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DailyTaskScreen(taskManager: taskManager),
      debugShowCheckedModeBanner: false,
    );
  }
}
