import 'package:flutter/material.dart';
import 'logout.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  final String userEmail;

  HomePage({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('StudyBuddy Home'),
        leading: IconButton(
          icon: Icon(Icons.account_circle),
          tooltip: 'Profile',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(userEmail: userEmail),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LogoutPage(userEmail: userEmail),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome to StudyBuddy!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}