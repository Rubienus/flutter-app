import 'package:flutter/material.dart';
import '../api_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false; // Added loading state
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Future<void> _register() async {
    print("Register button clicked"); // Debugging

    if (_emailController.text.isEmpty || _usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "All fields are required.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.registerUser(
        _emailController.text,
        _usernameController.text,
        _passwordController.text,
      );

      print("API Response: $response"); // Debugging

      if (response != null &&
          response.containsKey("message") &&
          response["message"].toLowerCase().contains("registered successfully")) {
        print("Registration successful, navigating back.");
        Navigator.pop(context); // Go back to login page
      } else {
        setState(() {
          _errorMessage = response?["message"] ?? "Registration failed. Try again.";
        });
      }
    } catch (e, stackTrace) {
      print("Error during registration: $e"); // Debugging
      print("Stack trace: $stackTrace");

      setState(() {
        _errorMessage = "Something went wrong: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
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
            _isLoading
                ? CircularProgressIndicator() // Show loading indicator
                : ElevatedButton(
                    onPressed: _register,
                    child: Text("Register"),
                  ),
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
