import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  Future<void> _verifyEmail() async {
    final enteredEmail = emailController.text;
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('registered_email');

    if (enteredEmail == savedEmail) {
      _showMessage("Make a new password for yourself with the code we have provided for you in your email.");
    } else {
      _showMessage("Email does not exist");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter your registered email", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _verifyEmail,
              child: Text("Submit"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}