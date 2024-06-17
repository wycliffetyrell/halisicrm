import 'package:flutter/material.dart';
import '../../database/customer.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailsScreen({Key? key, required this.customer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Customer Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[500],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Name: ${customer.name}'),
            Text('Phone Number: ${customer.phoneNumber}'),
            Text('Place of Delivery: ${customer.placeOfDelivery}'),
            Text('Date of Purchase: ${customer.dateOfPurchase.toLocal()}'
                .split(' ')[0]),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.check),
        backgroundColor: Colors.blue[500],
      ),
    );
  }
}
