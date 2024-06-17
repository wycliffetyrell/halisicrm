import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../database/customer.dart';

class AddCustomerScreen extends StatefulWidget {
  final Customer? customerToEdit;

  const AddCustomerScreen({Key? key, this.customerToEdit}) : super(key: key);

  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController phoneNumberController;
  late TextEditingController placeOfDeliveryController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.customerToEdit?.name);
    phoneNumberController =
        TextEditingController(text: widget.customerToEdit?.phoneNumber);
    placeOfDeliveryController =
        TextEditingController(text: widget.customerToEdit?.placeOfDelivery);
    if (widget.customerToEdit != null) {
      _selectedDate = widget.customerToEdit!.dateOfPurchase;
    }
  }

  Future<void> _saveCustomer() async {
    final box = Hive.box<Customer>('customers');
    if (widget.customerToEdit != null) {
      final editedCustomer = Customer(
        key: widget.customerToEdit!.key,
        name: nameController.text,
        phoneNumber: phoneNumberController.text,
        placeOfDelivery: placeOfDeliveryController.text,
        dateOfPurchase: _selectedDate,
      );
      await box.put(widget.customerToEdit!.key, editedCustomer);
    } else {
      final newCustomer = Customer(
        name: nameController.text,
        phoneNumber: phoneNumberController.text,
        placeOfDelivery: placeOfDeliveryController.text,
        dateOfPurchase: _selectedDate,
        key: null,
      );
      await box.add(newCustomer);
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.customerToEdit == null
                      ? 'Add Customer'
                      : 'Edit Customer Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[500]!),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the customer name';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[500]!),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the phone number';
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: placeOfDeliveryController,
              decoration: InputDecoration(
                labelText: 'Place of Delivery',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[500]!),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Date of Purchase: ${_selectedDate.toLocal()}'.split(' ')[0],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveCustomer();
                }
              },
              child: Text(widget.customerToEdit == null
                  ? 'Add Customer'
                  : 'Save Changes'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue[500],
              ).copyWith(
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) {
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.white;
                    }
                    return null;
                  },
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) {
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.blue[300];
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
