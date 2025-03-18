import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://just1ncantiler0.heliohost.us/Ecotracker_api/script/api.php";

  // Fetch user data (GET)
  static Future<Map<String, dynamic>?> fetchUser(String username, String apiKey) async {
    final url = Uri.parse('$baseUrl?username=$username');
    final response = await http.get(url, headers: {
      'Authorization': apiKey,
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error: ${response.body}');
      return null;
    }
  }

  // Send data (POST)
  static Future<Map<String, dynamic>?> postRequest(String action, Map<String, String> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'action': action, ...data}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error: ${response.body}');
      return null;
    }
  }

  // Register user
  static Future<Map<String, dynamic>?> registerUser(String email, String username, String password) async {
    return await postRequest('register', {
      'email': email,
      'username': username,
      'password': password,
    });
  }

  // Login user
  static Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    return await postRequest('login', {
      'username': username,
      'password': password,
    });
  }
}
