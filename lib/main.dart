import 'package:flutter/material.dart';
import 'package:halisicrm/pages/followup_page.dart';
import 'package:halisicrm/pages/home_page.dart';
import 'package:halisicrm/pages/orders_page.dart';
import 'package:halisicrm/pages/profile_page.dart';
import 'package:halisicrm/pages/sales_page.dart';
import 'package:halisicrm/pages/customer_page.dart';
import 'package:halisicrm/pages/expense_page.dart';
import 'package:halisicrm/pages/product_page.dart';
import 'package:halisicrm/pages/login_page.dart';
import 'package:halisicrm/pages/signup_page.dart';
import 'package:halisicrm/pages/splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'database/product.dart';
import 'database/customer.dart';
import 'database/orders.dart';
import 'database/expense.dart';
import 'database/user.dart';
import 'database/follow_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(OrderAdapter());
  Hive.registerAdapter(OrderItemAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(FollowUpAdapter());

  await Hive.openBox<Product>('products');
  await Hive.openBox<Customer>('customers');
  await Hive.openBox<Order>('orders');
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<User>('users');
  await Hive.openBox<FollowUp>('followUps');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Start with SplashScreen
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/profile': (context) => ProfileScreen(),
        '/follow-up': (context) => const FollowUpPage(),
        '/home': (context) => const HomePage(),
        '/orders': (context) => const OrdersPage(),
        '/orderspage': (context) => OrdersScreen(),
        '/sales': (context) => SalesPage(),
        '/products': (context) => const ProductPage(),
        '/customers': (context) => const CustomerPage(),
        '/expense': (context) => const ExpensePage(),
      },
    );
  }
}
