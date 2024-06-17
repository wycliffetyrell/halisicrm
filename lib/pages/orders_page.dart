import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';
import '../database/customer.dart';
import '../database/product.dart';
import '../database/orders.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Order>('orders').listenable(),
        builder: (context, Box<Order> box, _) {
          final orders =
              box.values.where((order) => order.status == 0).toList();

          if (orders.isEmpty) {
            return Center(child: Text('No orders available'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              Order order = orders[index];

              return ListTile(
                title: Text(order.orderNumber),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer: ${order.customer.name}'),
                    Text('Balance: Ksh ${order.balance}'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrdersPage(orderToEdit: order),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/orders');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class OrdersPage extends StatefulWidget {
  final Order? orderToEdit;

  const OrdersPage({Key? key, this.orderToEdit}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  TextEditingController clientController = TextEditingController();
  TextEditingController amountPaidController = TextEditingController();
  List<OrderItem> items = [
    OrderItem(
      product: Product(id: 0, name: 'Select', description: '', priceInKsh: 0),
      quantity: 0,
      meters: 0,
    ),
  ];
  Customer? selectedCustomer;
  List<Customer> customers = [];
  List<Product> products = [];
  double totalPrice = 0;
  double amountPaid = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.orderToEdit != null) {
      selectedCustomer = widget.orderToEdit!.customer;
      clientController.text = selectedCustomer!.name;
      items = List.from(widget.orderToEdit!.items);
      totalPrice = widget.orderToEdit!.totalPrice;
      amountPaid = widget.orderToEdit!.amountPaid;
      amountPaidController.text = amountPaid.toString();
    }
  }

  Future<void> _loadData() async {
    final customerBox = Hive.box<Customer>('customers');
    final productBox = Hive.box<Product>('products');
    setState(() {
      customers = customerBox.values.toList();
      products = productBox.values.toList();
    });
  }

  String _generateOrderNumber() {
    final random = Random();
    return 'ORD-${random.nextInt(1000000).toString().padLeft(6, '0')}';
  }

  void _addOrder() async {
    if (selectedCustomer == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select a customer')));
      return;
    }

    String orderNumber =
        widget.orderToEdit?.orderNumber ?? _generateOrderNumber();

    double totalPrice = items.fold(0, (sum, item) => sum + item.totalItemPrice);
    double amountPaid = double.tryParse(amountPaidController.text) ?? 0;

    Order order = Order(
      orderNumber: orderNumber,
      customer: selectedCustomer!,
      items: items,
      totalPrice: totalPrice,
      amountPaid: amountPaid,
    );

    order.updateStatus();

    final box = Hive.box<Order>('orders');
    if (widget.orderToEdit != null) {
      await box.put(widget.orderToEdit!.key, order);
    } else {
      await box.add(order);
    }

    setState(() {
      selectedCustomer = null;
      clientController.clear();
      items = [
        OrderItem(
          product:
              Product(id: 0, name: 'Select', description: '', priceInKsh: 0),
          quantity: 0,
          meters: 0,
        ),
      ];
      totalPrice = 0;
      amountPaidController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.orderToEdit == null
            ? 'Order added successfully'
            : 'Order updated successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    if (order.status == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sales completed successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }

    Navigator.pop(context);
  }

  void _updateTotalPrice() {
    setState(() {
      totalPrice = items.fold(0, (sum, item) => sum + item.totalItemPrice);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderToEdit == null ? 'Create Order' : 'Edit Order',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        backgroundColor: Colors.blue[500],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    controller: clientController,
                    decoration: InputDecoration(
                      labelText: 'Search Client',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[500]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedCustomer = customers.firstWhere(
                          (customer) => customer.name
                              .toLowerCase()
                              .contains(value.toLowerCase()),
                          orElse: () => Customer(
                            id: 0,
                            name: '',
                            phoneNumber: '',
                            placeOfDelivery: '',
                            dateOfPurchase: DateTime.now(),
                            key: null,
                          ),
                        );
                      });
                    },
                  ),
                ),
                SizedBox(height: 16),
                if (selectedCustomer != null &&
                    selectedCustomer!.name.isNotEmpty)
                  Text('Selected Client: ${selectedCustomer!.name}'),
                SizedBox(height: 16),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          DropdownButtonFormField<Product>(
                            value: items[index].product.id != 0
                                ? items[index].product
                                : null,
                            items: products.map((Product product) {
                              return DropdownMenuItem<Product>(
                                value: product,
                                child: Text(product.name),
                              );
                            }).toList(),
                            onChanged: (Product? newValue) {
                              setState(() {
                                items[index].product = newValue!;
                                _updateTotalPrice();
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Select Product',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue[500]!),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue[500]!),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                items[index].quantity =
                                    int.tryParse(value) ?? 0;
                                _updateTotalPrice();
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Meters',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue[500]!),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) {
                              setState(() {
                                items[index].meters =
                                    double.tryParse(value) ?? 0;
                                _updateTotalPrice();
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          if (index == items.length - 1)
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  items.add(OrderItem(
                                    product: Product(
                                      id: 0,
                                      name: 'Select',
                                      description: '',
                                      priceInKsh: 0,
                                    ),
                                    quantity: 0,
                                    meters: 0,
                                  ));
                                });
                              },
                              child: Text('Add Another Product'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue[500],
                                disabledForegroundColor:
                                    Colors.blue[300]?.withOpacity(0.38),
                                disabledBackgroundColor:
                                    Colors.blue[300]?.withOpacity(0.12),
                              ),
                            ),
                          Divider(),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    controller: amountPaidController,
                    decoration: InputDecoration(
                      labelText: 'Amount Paid',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[500]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(height: 16),
                Text('Total Price: Ksh $totalPrice'),
                Text(
                    'Balance: Ksh ${totalPrice - (double.tryParse(amountPaidController.text) ?? 0)}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addOrder,
                  child: Text(widget.orderToEdit == null
                      ? 'Submit Order'
                      : 'Update Order'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue[500],
                    disabledForegroundColor:
                        Colors.blue[300]?.withOpacity(0.38),
                    disabledBackgroundColor:
                        Colors.blue[300]?.withOpacity(0.12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
