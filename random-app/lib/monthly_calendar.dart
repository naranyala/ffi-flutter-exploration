import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Calendar',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CalendarPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MonthlyDatePicker(
          selectedDate: _selectedDate,
          onChanged: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
        ),
      ),
    );
  }
}

class MonthlyDatePicker extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  const MonthlyDatePicker({
    Key? key,
    required this.selectedDate,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<MonthlyDatePicker> createState() => _MonthlyDatePickerState();
}

class _MonthlyDatePickerState extends State<MonthlyDatePicker> {
  late DateTime _currentMonth; // First day of current displayed month

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
  }

  @override
  void didUpdateWidget(covariant MonthlyDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-navigate to selected date's month if changed
    if (widget.selectedDate.month != oldWidget.selectedDate.month ||
        widget.selectedDate.year != oldWidget.selectedDate.year) {
      _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = _currentMonth.month == 1
          ? DateTime(_currentMonth.year - 1, 12)
          : DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = _currentMonth.month == 12
          ? DateTime(_currentMonth.year + 1, 1)
          : DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  // Get list of all days to show in the grid (including padding from prev/next month)
  List<DateTime> _buildDays() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0); // last day

    // Weekday: 1=Mon → 7=Sun
    final firstWeekday = firstDay.weekday; // Mon=1, Sun=7
    final daysInMonth = lastDay.day;

    // Calculate days from previous month to show (align to Monday)
    final prevDays = firstWeekday == 7 ? 6 : firstWeekday - 1;

    // Total days to display (must be multiple of 7: 5 or 6 rows)
    final totalDays = prevDays + daysInMonth + (6 - ((prevDays + daysInMonth - 1) % 7));

    final days = <DateTime>[];

    // Previous month
    for (int i = prevDays; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }

    // Current month
    for (int day = 1; day <= daysInMonth; day++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, day));
    }

    // Next month
    while (days.length < totalDays) {
      days.add(days.last.add(const Duration(days: 1)));
    }

    return days;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isSelected(DateTime date) {
    final selected = widget.selectedDate;
    return date.year == selected.year &&
           date.month == selected.month &&
           date.day == selected.day;
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildDays();
    final monthName = DateFormat('MMMM yyyy').format(_currentMonth); // Requires 'intl' or manual

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          // Header: Month & Navigation
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: _previousMonth,
                ),
                Text(
                  '${_currentMonth.month == DateTime.january ? 'January' : _currentMonth.month == DateTime.february ? 'February' : [
                      'January', 'February', 'March', 'April', 'May', 'June',
                      'July', 'August', 'September', 'October', 'November', 'December'
                    ][_currentMonth.month - 1]} ${_currentMonth.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          // Weekday Labels
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.5,
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              return Center(
                child: Text(
                  weekday[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.5,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              final isCurrentMonth = date.month == _currentMonth.month;
              final isToday = _isToday(date);
              final isSelected = _isSelected(date);

              return GestureDetector(
                onTap: () => widget.onChanged(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue
                        : isToday
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isCurrentMonth
                                ? Colors.black
                                : Colors.grey[400],
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
