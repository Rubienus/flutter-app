import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ApiService {
  static const String baseUrl = "https://just1ncantiler0.heliohost.us/Ecotracker_api";
  static const String fetchUserUrl = "$baseUrl/api/microuser/crud/read.php";
  static const String registerUrl = "$baseUrl/api/microuser/register.php";
  static const String loginUrl = "$baseUrl/api/microuser/login.php";
  static const String postUrl = "$baseUrl/api/posts/crud/create.php";

  // Fetch user data (GET)
  static Future<Map<String, dynamic>?> fetchUser(String username) async {
  try {
    final url = Uri.parse('$fetchUserUrl?username=$username');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      
      if (data.containsKey("user_id")) {
        // Store user ID in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', data['user_id'].toString());
      }

      return data;
    } else {
      print('Fetch User Error: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Fetch User Exception: $e');
    return null;
  }
}


  // Generic POST request handler
  static Future<Map<String, dynamic>?> postRequest(String url, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
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
  static Future<Map<String, dynamic>?> registerUser(
      String email, String username, String password,
      {String roles = 'user', String userStatus = 'active'}) async {
    return await postRequest(registerUrl, {
      'email': email,
      'username': username,
      'password': password,
      'roles': roles,
      'user_status': userStatus,
    });
  }

  // Login user
  static Future<Map<String, dynamic>?> loginUser(String username, String password) async {
  final response = await postRequest(loginUrl, {
    'username': username,
    'password': password,
  });

  if (response != null && response.containsKey('user_id')) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', response['user_id'].toString());
    await prefs.setString('username', response['username']);
    await prefs.setString('email', response['user_email']); // Store email
  }

  return response;
}


  // Logout user
  static Future<bool> logoutUser() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear stored user data
    print("User logged out locally.");
    return true;
  } catch (e) {
    print("Logout Error: $e");
    return false;
  }
}


  static Future<Map<String, dynamic>?> createPost(String text, int category, File? image) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      print("Error: No user ID found.");
      return {"error": "User not logged in"};
    }

    var request = http.MultipartRequest('POST', Uri.parse(postUrl));
    request.fields['user_id'] = userId;
    request.fields['text'] = text;
    request.fields['category_id'] = category.toString(); // Convert int to String

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    // Debugging output before sending the request
    print("Sending request with fields:");
    print("User ID: $userId");
    print("Text: $text");
    print("Category: ${category.toString()}");

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    print("Server Response Code: ${response.statusCode}");
    print("Server Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"error": "Failed to create post"};
    }
  } catch (e) {
    print("Create Post Exception: $e");
    return {"error": "Exception occurred: $e"};
  }
}


}