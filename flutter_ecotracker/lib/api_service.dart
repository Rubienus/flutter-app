import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://just1ncantiler0.heliohost.us/Ecotracker_api/script/api.php";
  static const String logoutUrl = "https://just1ncantiler0.heliohost.us/Ecotracker_api/logout.php";
  static const String postUrl = "https://just1ncantiler0.heliohost.us/Ecotracker_api/api/method.php/api/posts/crud/create";

  // Fetch user data (GET)
  static Future<Map<String, dynamic>?> fetchUser(String username, String apiKey) async {
    try {
      final url = Uri.parse('$baseUrl?username=$username');
      final response = await http.get(url, headers: {
        'Authorization': apiKey,
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Fetch User Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Fetch User Exception: $e');
      return null;
    }
  }

  // Send data (POST)
  static Future<Map<String, dynamic>?> postRequest(String action, Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': action, ...data}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Post Request Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Post Request Exception: $e');
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

  // Logout user
  static Future<bool> logoutUser(String apiKey) async {
    try {
      final response = await http.post(Uri.parse(logoutUrl), headers: {'Authorization': apiKey});

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Logout Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Logout Error: $e");
      return false;
    }
  }

  // Create post with optional image upload
  static Future<Map<String, dynamic>?> createPost(String text, String category, File? image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(postUrl));

      request.fields['text'] = text;
      request.fields['category'] = category;

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Create Post Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Create Post Exception: $e");
      return null;
    }
  }
}
