import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _register() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please enter both email and password");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registered_email', email);
    await prefs.setString('registered_password', password);

    _showMessage("Registered successfully!");
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("StudyBuddy Register")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Create your StudyBuddy account", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 32),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}