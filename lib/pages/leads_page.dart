import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database/customer.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({Key? key}) : super(key: key);

  @override
  _LeadsPageState createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
  late Box<Customer> _customersBox;
  late List<Customer> _customers;

  @override
  void initState() {
    super.initState();
    _customersBox = Hive.box<Customer>('customers');
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _customers = _customersBox.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer List'),
      ),
      body: _customers.isEmpty
          ? Center(child: Text('No customers found'))
          : ListView.builder(
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final customer = _customers[index];
                return ListTile(
                  title: Text(customer.name),
                  subtitle: Text(customer.phoneNumber),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerDetailsScreen(
                          customer: customer,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCustomerScreen()),
          ).then((_) => _loadCustomers());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({Key? key}) : super(key: key);

  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final placeOfDeliveryController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Customer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: placeOfDeliveryController,
              decoration: InputDecoration(labelText: 'Place of Delivery'),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No date selected!'
                        : 'Date of Purchase: ${_selectedDate!.toLocal()}'
                            .split(' ')[0],
                  ),
                ),
                SizedBox(width: 20.0),
                ElevatedButton(
                  onPressed: () => _pickDate(context),
                  child: Text('Select date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_selectedDate != null) {
                  final customer = Customer(
                    name: nameController.text,
                    phoneNumber: phoneNumberController.text,
                    placeOfDelivery: placeOfDeliveryController.text,
                    dateOfPurchase: _selectedDate!,
                    key: null,
                  );

                  // Access the Hive box
                  final box = Hive.box<Customer>('customers');
                  await box.add(customer);

                  Navigator.pop(context);
                } else {
                  // Show an error message if the date is not selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a date')),
                  );
                }
              },
              child: Text('Add Customer'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerDetailsScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailsScreen({Key? key, required this.customer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Name: ${customer.name}'),
            Text('Phone Number: ${customer.phoneNumber}'),
            Text('Place of Delivery: ${customer.placeOfDelivery}'),
            Text('Date of Purchase: ${customer.dateOfPurchase.toString()}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle action for floating action button
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
