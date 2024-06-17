import 'package:flutter/material.dart';
import 'package:halisicrm/pages/followup_page.dart';
import 'package:halisicrm/pages/orders_page.dart';
import 'package:hive/hive.dart';
import 'package:halisicrm/components/appbar.dart';
import '../database/orders.dart'; // Adjust import path
import '../database/expense.dart'; // Adjust import path
import '../database/follow_up.dart'; // Adjust import path
import 'dart:async'; // Import dart:async for Timer

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Hive boxes for orders and expenses
  late Box<Order> _ordersBox;
  late Box<Expense> _expensesBox;
  late Box<FollowUp> _followUpsBox;

  Timer? _refreshTimer; // Timer for refreshing data

  @override
  void initState() {
    super.initState();
    _openBoxes();
    _initializeData();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(Duration(seconds: 20), (timer) {
      _initializeData(); // Call async initialization method periodically
    });
  }

  Future<void> _openBoxes() async {
    // Access already initialized Hive boxes from main.dart
    _ordersBox = Hive.box<Order>('orders');
    _expensesBox = Hive.box<Expense>('expenses');
    _followUpsBox = Hive.box<FollowUp>('followUps');
  }

  Future<void> _initializeData() async {
    // Update state once data is initialized
    setState(() {});
  }

  @override
  void dispose() {
    // Close Hive boxes and cancel the timer when no longer needed
    // _ordersBox.close();
    // _expensesBox.close();
    // _followUpsBox.close();
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Function to calculate number of orders with status 0
  Future<int> calculateOrdersWithStatus0() async {
    //  await _openBoxes(); // Ensure boxes are opened before accessing data
    return _ordersBox.values.where((order) => order.status == 0).length;
  }

  // Function to calculate total sales amount (orders with status 1)
  Future<double> calculateTotalSalesAmount() async {
    //   await _openBoxes(); // Ensure boxes are opened before accessing data
    var orders =
    await _ordersBox.values.toList(); // Convert to list to await the values

    // Calculate total sales amount asynchronously
    double totalSales = orders
        .where((order) => order.status == 1)
        .fold(0, (double sum, order) => sum + order.totalPrice);

    return totalSales;
  }

  // Function to calculate number of customer leads
  Future<int> calculateCustomerLeads() async {
    //await _openBoxes(); // Ensure boxes are opened before accessing data
    return _followUpsBox.length;
  }

  // Function to calculate total expense amount
  Future<double> calculateTotalExpense() async {
    //  await _openBoxes(); // Ensure boxes are opened before accessing data
    var expenses = await _expensesBox.values
        .toList(); // Convert to list to await the values

    // Calculate total expense amount asynchronously
    double totalExpense =
    expenses.fold(0, (double sum, expense) => sum + expense.amount);

    return totalExpense;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: MyAppBar(), // Assuming MyAppBar is defined elsewhere
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: _currentIndex == 0 ? _buildHomeContent() : _buildOrdersContent(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return FutureBuilder(
      future: _initializeData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        shrinkWrap: true,
                        children: [
                          _buildCard(
                            context,
                            title: 'Orders',
                            futureValue: calculateOrdersWithStatus0(),
                            color: Colors.red,
                            routeName: '/orderspage',
                          ),
                          _buildCard(
                            context,
                            title: 'Sales Total',
                            futureValue: calculateTotalSalesAmount(),
                            color: Colors.green,
                            routeName: '/sales',
                          ),
                          _buildCard(
                            context,
                            title: 'Follow',
                            futureValue: calculateCustomerLeads(),
                            color: Colors.orange,
                            routeName: '/follow-up',
                          ),
                          _buildCard(
                            context,
                            title: 'Expense',
                            futureValue: calculateTotalExpense(),
                            color: Colors.blue,
                            routeName: '/expense',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildFollowUpDrawerItem(),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildOrdersContent() {
    return Center(
      child: OrdersScreen(),
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required String title,
        required Future<dynamic> futureValue,
        required Color color,
        required String routeName,
      }) {
    return FutureBuilder(
      future: futureValue,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // Handle the case where snapshot.data is Future<double>
          if (snapshot.data is Future<double>) {
            return FutureBuilder<double>(
              future: snapshot.data as Future<double>,
              builder: (context, AsyncSnapshot<double> doubleSnapshot) {
                if (doubleSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (doubleSnapshot.hasError) {
                  return Center(child: Text('Error: ${doubleSnapshot.error}'));
                } else {
                  return Card(
                    color: color,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            doubleSnapshot.data!.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: color,
                              backgroundColor: Colors.white, // Text color
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, routeName);
                            },
                            child: const Text('View Details'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          } else {
            // Handle the case where snapshot.data is already resolved to double
            return Card(
              color: color,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      snapshot.data.toString(),
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: color,
                        backgroundColor: Colors.white, // Text color
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, routeName);
                      },
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Navigation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: const Text('Sales'),
            onTap: () {
              Navigator.pushNamed(context, '/sales');
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: const Text('Customers'),
            onTap: () {
              Navigator.pushNamed(context, '/customers');
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: const Text('Products'),
            onTap: () {
              Navigator.pushNamed(context, '/products');
            },
          ),
          ListTile(
            leading: Icon(Icons.money),
            title: const Text('Expense'),
            onTap: () {
              Navigator.pushNamed(context, '/expense');
            },
          ),
          _buildFollowUpDrawerItem(), // Add the Follow-Up drawer item
          ListTile(
            leading: Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          const Spacer(),
          ListTile(
            leading: Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpDrawerItem() {
    return ListTile(
      leading: Icon(Icons.phone_callback),
      title: const Text('Customer Follow-Up'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FollowUpPage()),
        );
      },
    );
  }
}

