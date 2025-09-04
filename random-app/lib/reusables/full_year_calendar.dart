import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MonthGoalsPage(),
    );
  }
}

class MonthGoalsPage extends StatelessWidget {
  final List<String> months = [
    "January", "February", "March", "April",
    "May", "June", "July", "August",
    "September", "October", "November", "December"
  ];

  // Sample goals for each month
  final Map<String, List<String>> monthGoals = {
    "January": ["Goal 1", "Goal 2", "Goal 3", "Goal 4", "Goal 5"],
    "February": ["Goal 1", "Goal 2", "Goal 3", "Goal 4", "Goal 5"],
    // Add goals for other months similarly...
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Monthly Goals")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: months.length,
          itemBuilder: (context, index) {
            String month = months[index];
            return GestureDetector(
              onTap: () => _showGoals(context, month),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    month,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showGoals(BuildContext context, String month) {
    final goals = monthGoals[month] ?? ["Goal 1", "Goal 2", "Goal 3", "Goal 4", "Goal 5"];
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$month Goals", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ...goals.map((goal) => ListTile(
                leading: Icon(Icons.check_circle_outline),
                title: Text(goal),
              )),
            ],
          ),
        );
      },
    );
  }
}

