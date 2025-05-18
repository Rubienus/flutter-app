import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ApiService {
  static const String baseUrl =
      "https://just1ncantiler0.heliohost.us/Ecotracker_api";

  // User endpoints
  static const String registerUrl = "$baseUrl/api/microuser/register.php";
  static const String loginUrl = "$baseUrl/api/microuser/login.php";
  static const String fetchUserUrl = "$baseUrl/api/microuser/crud/read.php";

  // Post endpoints
  static const String postUrl = "$baseUrl/api/posts/crud/create.php";
  static const String fetchPostUrl = "$baseUrl/api/posts/crud/read.php";
  static const String deletePostUrl = "$baseUrl/api/posts/crud/delete.php";
  static const String userPostsUrl = "$baseUrl/api/posts/crud/user_posts.php";

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
  static Future<Map<String, dynamic>?> postRequest(
      String url, Map<String, dynamic> data) async {
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
  static Future<Map<String, dynamic>?> loginUser(
      String username, String password) async {
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

  static Future<Map<String, dynamic>?> createPost(
    String text,
    int category,
    File? image, {
    int? points, // Add this optional parameter
  }) async {
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
      request.fields['category_id'] = category.toString();

      // Add points if provided
      if (points != null) {
        request.fields['points'] = points.toString();
      }

      if (image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));
      }

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

// Fetch Posts (GET)
  static Future<List<Map<String, dynamic>>?> fetchPosts(
      {String? postId}) async {
    try {
      Uri url = postId != null
          ? Uri.parse('$fetchPostUrl?post_id=$postId')
          : Uri.parse(fetchPostUrl);

      final response = await http.get(url);

      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);

        // Check if response is a list (multiple posts) or a single post (map)
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic>) {
          return [data]; // Wrap single post in a list
        } else {
          print('Unexpected response format');
          return null;
        }
      } else {
        print('Fetch Posts Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Fetch Posts Exception: $e');
      return null;
    }
  }

// Method to create post with points
  static Future<Map<String, dynamic>?> createPostWithPoints(
    String text,
    int category,
    File? image,
    int points,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) return {"error": "User not logged in"};

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(postUrl))
        ..fields['user_id'] = userId
        ..fields['text'] = text
        ..fields['category_id'] = category.toString()
        ..fields['points'] = points.toString();

      if (image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseData);
      }
      return {"error": "Failed to create post"};
    } catch (e) {
      print("Create Post Exception: $e");
      return {"error": "Exception occurred: $e"};
    }
  }

// Method to get user's total points
  static Future<int?> fetchUserTotalPoints(String userId) async {
    try {
      final url = Uri.parse('$fetchPostUrl?user_id=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return data['total_points'] as int?;
        } else if (data is int) {
          return data;
        }
      }
      return null;
    } catch (e) {
      print('Fetch User Points Exception: $e');
      return null;
    }
  }

// Method to get user's posts with points
  static Future<Map<String, dynamic>?> fetchUserPostsWithPoints(
      String userId) async {
    try {
      final url = Uri.parse('$fetchPostUrl?user_id=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        return {'posts': [], 'total_points': 0};
      }
      return null;
    } catch (e) {
      print('Fetch User Posts Exception: $e');
      return null;
    }
  }

  static Future<bool> deletePost(int postId) async {
    try {
      final url = Uri.parse('$baseUrl/api/posts/crud/delete.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'post_id': postId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Delete Post Exception: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> fetchUserNotifications(
      String userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/notifications?user_id=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Fetch Notifications Error: $e');
      return null;
    }
  }
}
