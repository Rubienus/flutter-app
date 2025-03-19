import 'package:flutter/material.dart';
import '../api_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _register() async {
 if (_emailController.text.isEmpty || _usernameController.text.isEmpty || _passwordController.text.isEmpty) {
    setState(() {
      _errorMessage = "All fields are required.";
    });
    return;
  }
      final response = await ApiService.registerUser(
      _emailController.text,
      _usernameController.text,
      _passwordController.text,
    );

  print("API Response: $response"); // Debugging

if (response != null && response.containsKey("message") && response["message"].toLowerCase().contains("registered successfully")) {
      Navigator.pop(context); // Go back to login page
    } else {
      setState(() {
        _errorMessage = response?["error"] ?? "Registration failed. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
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
              onPressed: _register,
              child: Text("Register"),
            ),
            if (_errorMessage != null) 
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
