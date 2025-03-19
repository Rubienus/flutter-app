import 'package:flutter/material.dart';
import 'package:flutter_ecotracker/pages/home_page.dart';
import '../api_service.dart'; // Import ApiService
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> login() async {
    final response = await ApiService.loginUser(
      _usernameController.text,
      _passwordController.text,
    );

print("API Response: $response"); // Debugging

if (response != null && response.containsKey("message") && response["message"].toLowerCase().contains("login successful")) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      setState(() {
        _errorMessage = response?["error"] ?? "Login failed. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: Text("Login"),
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
            if (_errorMessage != null) 
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
