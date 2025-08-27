import 'package:flutter/material.dart';
import 'dart:math';

class BudgetItem {
  final String category;
  double amount;
  final bool isExpense; // true if expense, false if income
  
  BudgetItem({
    required this.category,
    required this.amount,
    required this.isExpense,
  });
}

final List<BudgetItem> initialBudgetData = [
  BudgetItem(category: 'Salary', amount: 5000, isExpense: false),
  BudgetItem(category: 'Freelance', amount: 1200, isExpense: false),
  BudgetItem(category: 'Rent', amount: 1500, isExpense: true),
  BudgetItem(category: 'Groceries', amount: 400, isExpense: true),
  BudgetItem(category: 'Utilities', amount: 200, isExpense: true),
  BudgetItem(category: 'Entertainment', amount: 150, isExpense: true),
];

class BudgetTable extends StatelessWidget {
  final List<BudgetItem> items;
  final VoidCallback onDataChanged;
  
  const BudgetTable({
    super.key, 
    required this.items,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    double totalIncome = items
        .where((item) => !item.isExpense)
        .fold(0, (sum, item) => sum + item.amount);
    
    double totalExpense = items
        .where((item) => item.isExpense)
        .fold(0, (sum, item) => sum + item.amount);
    
    double balance = totalIncome - totalExpense;

    final incomeItems = items.where((item) => !item.isExpense).toList();
    final expenseItems = items.where((item) => item.isExpense).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          Text(
            'Total Income: \$${totalIncome.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          Text(
            'Total Expenses: \$${totalExpense.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          Text(
            'Balance: \$${balance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: balance >= 0 ? Colors.green : Colors.red,
            ),
          ),

          const SizedBox(height: 24),

          // Income Section
          if (incomeItems.isNotEmpty) ...[
            const Text('Income Sources', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _BudgetDataTable(
              items: incomeItems, 
              isExpense: false,
              onDataChanged: onDataChanged,
            ),
            const SizedBox(height: 24),
          ],

          // Expenses Section
          if (expenseItems.isNotEmpty) ...[
            const Text('Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _BudgetDataTable(
              items: expenseItems, 
              isExpense: true,
              onDataChanged: onDataChanged,
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetDataTable extends StatelessWidget {
  final List<BudgetItem> items;
  final bool isExpense;
  final VoidCallback onDataChanged;

  const _BudgetDataTable({
    required this.items,
    required this.isExpense,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = isExpense ? Colors.red : Colors.green;
    final totalAmount = items.fold(0.0, (sum, i) => sum + i.amount);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(color.withOpacity(0.1)),
        columnSpacing: 20,
        columns: [
          DataColumn(
            label: Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
          DataColumn(
            label: Text(
              'Amount',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
          DataColumn(
            label: Text(
              'Percentage',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
          DataColumn(
            label: Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
        rows: items.map((item) {
          final percentage = totalAmount > 0 ? (item.amount / totalAmount * 100) : 0.0;
          
          return DataRow(
            cells: [
              DataCell(
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(item.category),
                  ],
                ),
              ),
              DataCell(
                Text(
                  '\$${item.amount.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.w500, color: color),
                ),
              ),
              DataCell(
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(fontWeight: FontWeight.w500, color: color),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      color: color,
                      onPressed: () {
                        item.amount = max(0, item.amount - 50);
                        onDataChanged();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      color: color,
                      onPressed: () {
                        item.amount += 50;
                        onDataChanged();
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class BudgetCalculatorPage extends StatefulWidget {
  const BudgetCalculatorPage({super.key});

  @override
  State<BudgetCalculatorPage> createState() => _BudgetCalculatorPageState();
}

class _BudgetCalculatorPageState extends State<BudgetCalculatorPage> {
  late List<BudgetItem> _budgetData;

  @override
  void initState() {
    super.initState();
    _budgetData = initialBudgetData.map((item) => BudgetItem(
      category: item.category,
      amount: item.amount,
      isExpense: item.isExpense,
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BudgetTable(
          items: _budgetData,
          onDataChanged: () => setState(() {}),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      title: 'Budget Calculator',
      home: const BudgetCalculatorPage(),
    ),
  );
}
