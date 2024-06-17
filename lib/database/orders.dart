import 'package:hive/hive.dart';
import 'customer.dart'; // Adjust the import path as needed
import 'product.dart'; // Adjust the import path as needed

part 'orders.g.dart';

@HiveType(typeId: 2)
class Order extends HiveObject {
  @HiveField(0)
  String orderNumber;

  @HiveField(1)
  Customer customer;

  @HiveField(2)
  List<OrderItem> items;

  @HiveField(3)
  double totalPrice;

  @HiveField(4)
  double amountPaid;

  @HiveField(5)
  int status; // New status field

  Order({
    required this.orderNumber,
    required this.customer,
    required this.items,
    required this.totalPrice,
    required this.amountPaid,
    this.status = 0, // Initialize status to 0
  });

  double get balance => totalPrice - amountPaid;

  // Method to update status based on balance
  void updateStatus() {
    if (balance == 0) {
      status = 1; // Set status to 1 if balance is zero
    }
    // You can add more conditions or logic here based on your requirements
  }
}

@HiveType(typeId: 3)
class OrderItem extends HiveObject {
  @HiveField(0)
  Product product;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double meters;

  OrderItem({
    required this.product,
    required this.quantity,
    required this.meters,
  });

  double get totalItemPrice => product.priceInKsh * quantity * meters;
}
