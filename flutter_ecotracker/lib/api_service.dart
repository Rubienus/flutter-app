import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://just1ncantiler0.heliohost.us/Ecotracker_api";
  static const String registerUrl = "$baseUrl/api/microuser/register.php";
  static const String loginUrl = "$baseUrl/api/microuser/login.php";
  static const String fetchUserUrl = "$baseUrl/api/microuser/crud/read.php";
  static const String logoutUrl = "$baseUrl/api/microuser/logout.php";
  static const String postUrl = "$baseUrl/api/posts/crud/create.php";

   // Fetch user data (GET)
  static Future<Map<String, dynamic>?> fetchUser(String username) async {
  try {
    final url = Uri.parse("$fetchUserUrl?username=$username");
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
    });

    print("API Request Sent to: $url");

    if (response.statusCode == 200) {
      Map<String, dynamic> userData = jsonDecode(response.body);
      print("User Data Retrieved: ${userData}");
      return userData;
    } else {
      print("Fetch User Failed: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Fetch User Exception: $e");
  }
  return null;
}


  // Register user
  static Future<Map<String, dynamic>?> registerUser(
      String email, String username, String password,
      {String roles = 'user', String userStatus = 'active'}) async {
    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
          'roles': roles, // Role assignment
          'user_status': userStatus, // User status assignment
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('api_key')) {
          print("User Registered! API Key: ${responseData['api_key']}");
          return responseData;
        } else {
          print("Error: ${responseData['message']}");
        }
      } else {
        print("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in registerUser: $e");
    }
    return null;
  }

  // Login user
  static Future<Map<String, dynamic>?> loginUser(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData.containsKey('api_id') && responseData.containsKey('username')) {
        return responseData;
      }
    } else {
      print("Login Error: ${response.body}");
    }
  } catch (e) {
    print("Login Exception: $e");
  }
  return null;
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
