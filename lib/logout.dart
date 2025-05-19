import 'package:flutter/material.dart';
import 'login_page.dart';

class LogoutPage extends StatelessWidget {
  final String userEmail;

  const LogoutPage({Key? key, required this.userEmail}) : super(key: key);

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // close dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Logged out successfully')),
              );
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _confirmLogout(context),
          child: Text('Logout'),
        ),
      ),
    );
  }
}