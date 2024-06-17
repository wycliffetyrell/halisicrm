import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database/orders.dart';

class SalesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Order>('orders').listenable(),
        builder: (context, Box<Order> box, _) {
          final orders = box.values.where((order) => order.status == 1).toList();

          if (orders.isEmpty) {
            return Center(child: Text('No sales available'));
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
                    Text('Total Price: Ksh ${order.totalPrice}'),
                    Text('Amount Paid: Ksh ${order.amountPaid}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
