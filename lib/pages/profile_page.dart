import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../database/user.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _passwordController = TextEditingController();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    // Assuming current user email is stored in shared preferences or passed via arguments
    // For this example, we'll just fetch the first user
    final box = Hive.box<User>('users');
    setState(() {
      currentUser = box.values.first;
    });
  }

  void _updatePassword() {
    if (_passwordController.text.isNotEmpty) {
      final box = Hive.box<User>('users');
      currentUser = currentUser?.copyWith(password: _passwordController.text);
      if (currentUser != null) {
        box.put(currentUser!.email, currentUser!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text('First Name'),
              subtitle: Text(currentUser!.firstName),
            ),
            ListTile(
              title: Text('Last Name'),
              subtitle: Text(currentUser!.lastName),
            ),
            ListTile(
              title: Text('Email'),
              subtitle: Text(currentUser!.email),
            ),
            ListTile(
              title: Text('Phone Number'),
              subtitle: Text(currentUser!.phoneNumber),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updatePassword,
              child: Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }
}
