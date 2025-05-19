import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String userEmail;

  ProfilePage({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $userEmail', style: TextStyle(fontSize: 18)),
            SizedBox(height: 24),
            Text('Add Study Task (Placeholder)', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Study Goal Setting (Placeholder)', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Push Notification Reminder (Placeholder)', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}