import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // Add this import for input formatters
import '../database/expense.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final expenseBox = Hive.box<Expense>('expenses');
    setState(() {
      expenses = expenseBox.values.toList();
    });
  }

  void _addExpense(Expense expense) async {
    final expenseBox = Hive.box<Expense>('expenses');
    await expenseBox.add(expense);
    _loadData();
    _showSuccessMessage('Expense added successfully');
  }

  void _editExpense(int index, Expense expense) async {
    final expenseBox = Hive.box<Expense>('expenses');
    await expenseBox.putAt(index, expense);
    _loadData();
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showEditDialog({Expense? expense, int? index}) {
    final TextEditingController typeController = TextEditingController(
      text: expense?.type ?? '',
    );
    final TextEditingController amountController = TextEditingController(
      text: expense?.amount.toString() ?? '',
    );
    DateTime selectedDate = expense?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(expense == null ? 'Add Expense' : 'Edit Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeController,
                decoration: InputDecoration(
                  labelText: 'Expense Type',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[500]!),
                  ),
                ),
              ),
              SizedBox(height: 16), // Added padding between fields
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[500]!),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ], // Input formatter for numbers only
              ),
              SizedBox(height: 16),
              Text('Date: ${DateFormat.yMd().format(selectedDate)}'),
              ElevatedButton(
                child: Text('Select Date'),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[500], // Set button color to blue
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              child: Text(expense == null ? 'Add' : 'Save'),
              onPressed: () {
                String type = typeController.text;
                double amount = double.parse(amountController.text);

                if (expense == null) {
                  _addExpense(
                      Expense(type: type, amount: amount, date: selectedDate));
                } else {
                  _editExpense(index!,
                      Expense(type: type, amount: amount, date: selectedDate));
                }

                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[500],
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    if (expenses.isEmpty) {
      return [
        PieChartSectionData(
          title: 'No Data',
          value: 1,
          color: Colors.grey,
        ),
      ];
    }
    return expenses.map((expense) {
      return PieChartSectionData(
        title: expense.type,
        value: expense.amount,
        color: Colors
            .primaries[expenses.indexOf(expense) % Colors.primaries.length],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expenses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[500],
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          Text(
            'A pie chart of expense',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'List of Expense',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                Expense expense = expenses[index];
                return ListTile(
                  title: Text(expense.type),
                  subtitle: Text(
                      'Ksh ${expense.amount} - ${DateFormat.yMd().format(expense.date)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog(expense: expense, index: index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEditDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[500],
      ),
    );
  }
}
