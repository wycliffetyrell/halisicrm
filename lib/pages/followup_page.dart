import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../database/customer.dart';
import '../database/follow_up.dart';

class FollowUpPage extends StatefulWidget {
  const FollowUpPage({super.key});

  @override
  _FollowUpPageState createState() => _FollowUpPageState();
}

class _FollowUpPageState extends State<FollowUpPage> {
  List<FollowUp> followUps = [];
  List<Customer> customers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final followUpBox = Hive.box<FollowUp>('followUps');
    final customerBox = Hive.box<Customer>('customers');
    setState(() {
      followUps = followUpBox.values.toList();
      customers = customerBox.values.toList();
    });
  }

  void _addFollowUp(FollowUp followUp) async {
    final followUpBox = Hive.box<FollowUp>('followUps');
    await followUpBox.add(followUp);
    _loadData();
    _showSuccessMessage('Follow-up added successfully');
  }

  void _updateFollowUp(int index, FollowUp followUp) async {
    final followUpBox = Hive.box<FollowUp>('followUps');
    await followUpBox.putAt(index, followUp);
    _loadData();
    _showSuccessMessage('Follow-up rescheduled successfully');
  }

  void _deleteFollowUp(int index) async {
    final followUpBox = Hive.box<FollowUp>('followUps');
    await followUpBox.deleteAt(index);
    _loadData();
    _showSuccessMessage('Follow-up deleted successfully');
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

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAddFollowUpDialog({int? index, FollowUp? followUp}) {
    Customer? selectedCustomer = followUp?.customer;
    DateTime selectedDate = followUp?.followUpDate ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(index == null ? 'Add Follow-Up' : 'Reschedule Follow-Up'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Customer>(
                decoration: InputDecoration(
                  labelText: 'Select Customer',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[500]!),
                  ),
                ),
                value: selectedCustomer,
                items: customers.map((Customer customer) {
                  return DropdownMenuItem<Customer>(
                    value: customer,
                    child: Text(customer.name),
                  );
                }).toList(),
                onChanged: (Customer? newValue) {
                  setState(() {
                    selectedCustomer = newValue!;
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text(
                  'Select Date',
                  style: TextStyle(color: Colors.white),
                ),
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
                    _showSuccessMessage(
                        'Date selected: ${DateFormat.yMd().format(picked)}');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[500],
                ),
              ),
              SizedBox(height: 8), // Add space between date and time buttons
              ElevatedButton(
                child: Text(
                  'Select Time',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null && picked != selectedTime) {
                    setState(() {
                      selectedTime = picked;
                    });
                    _showSuccessMessage(
                        'Time selected: ${picked.format(context)}');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[500],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              child: Text(index == null ? 'Add' : 'Reschedule'),
              onPressed: () {
                if (selectedCustomer != null) {
                  // Check if the customer already has a follow-up
                  bool customerExists = followUps
                      .any((followUp) => followUp.customer == selectedCustomer);
                  if (index == null && customerExists) {
                    _showErrorMessage(
                        'This customer already has a follow-up scheduled.');
                  } else {
                    DateTime followUpDate = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                    FollowUp newFollowUp = FollowUp(
                      customer: selectedCustomer!,
                      followUpDate: followUpDate,
                    );
                    if (index == null) {
                      _addFollowUp(newFollowUp);
                    } else {
                      _updateFollowUp(index, newFollowUp);
                    }
                    Navigator.of(context).pop();
                  }
                } else {
                  _showErrorMessage('Please select a customer');
                }
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

  String _timeLeft(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return '$days days left';
    } else if (hours > 0) {
      return '$hours hours left';
    } else {
      return '$minutes minutes left';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Customer Follow-Up',
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
            'Follow-Up List',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: followUps.length,
              itemBuilder: (context, index) {
                FollowUp followUp = followUps[index];
                return ListTile(
                  title: Text(followUp.customer.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phone: ${followUp.customer.phoneNumber}'),
                      Text(_timeLeft(followUp.followUpDate)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showAddFollowUpDialog(
                              index: index, followUp: followUp);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteFollowUp(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFollowUpDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[500],
      ),
    );
  }
}
