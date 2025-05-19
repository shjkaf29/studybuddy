import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login() async {
    final enteredEmail = emailController.text;
    final enteredPassword = passwordController.text;

    if (enteredEmail.isEmpty || enteredPassword.isEmpty) {
      _showMessage("Please enter both email and password");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('registered_email');
    final savedPassword = prefs.getString('registered_password');

    if (enteredEmail == savedEmail && enteredPassword == savedPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userEmail: enteredEmail), // Navigate to HomePage
        ),
      );
    } else {
      _showMessage("Incorrect email or password");
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
      appBar: AppBar(title: Text("StudyBuddy Login")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to StudyBuddy",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text("Don't have an account? Register here"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                );
              },
              child: Text("Forgot Password?"),
            ),
          ],
        ),
      ),
    );
  }
}