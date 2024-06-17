import 'package:flutter/material.dart';
import 'package:halisicrm/components/customerpage/addcustomer.dart';
import 'package:halisicrm/components/customerpage/customerdetails.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database/customer.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
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

  void _openAddCustomerScreen({Customer? customerToEdit}) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: AddCustomerScreen(customerToEdit: customerToEdit),
          ),
        );
      },
    );

    if (result != null) {
      String message = customerToEdit == null
          ? 'Customer added successfully'
          : 'Customer edited successfully';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      _loadCustomers(); // Reload customers after adding/editing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Customer List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[500],
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
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _openAddCustomerScreen(customerToEdit: customer);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openAddCustomerScreen();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[500],
      ),
    );
  }
}
