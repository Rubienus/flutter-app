import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
  static const String notificationUrl =
      "$baseUrl/api/posts/crud/create_notification.php";
  static const String fetchNotificationUrl =
      "$baseUrl/api/posts/crud/read_notification.php";
  static const String claimCouponUrl =
      "$baseUrl/api/posts/crud/claim_coupon.php";

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

//update about me
  static Future<bool> updateAboutMe({
    required String userId,
    required String aboutMe,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/microuser/crud/update_aboutme.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'about_me': aboutMe,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Update About Me Error: $e');
      return false;
    }
  }

  // Create post with optional points
  static Future<Map<String, dynamic>?> createPost(
    String text,
    int category,
    File? image, {
    int? points,
  }) async {
    try {
      print("Starting post creation...");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      print("User ID: $userId");

      if (userId == null) {
        print("Error: No user ID found.");
        return {"error": "User not logged in"};
      }

      var request = http.MultipartRequest('POST', Uri.parse(postUrl));
      request.fields['user_id'] = userId;
      request.fields['text'] = text;
      request.fields['category_id'] = category.toString();
      request.fields['points'] = (points ?? 0).toString();

      if (image != null) {
        print("Adding image to request: ${image.path}");
        // Ensure proper content type for image
        var fileExtension = image.path.split('.').last.toLowerCase();
        var contentType = 'image/jpeg'; // Default

        if (fileExtension == 'png') {
          contentType = 'image/png';
        } else if (fileExtension == 'gif') {
          contentType = 'image/gif';
        }

        final fileName =
            'post_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
            filename: fileName,
            contentType: MediaType.parse(contentType),
          ),
        );

        // Add filename to fields as well for reference
        request.fields['image_filename'] = fileName;
      }

      print("Sending request to server...");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Server Response Code: ${response.statusCode}");
      print("Server Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final earnedPoints = data['points_earned'] ?? data['points'] ?? 0;

        // Create notification with actual points
        await createNotification(
          userId: userId,
          message: 'You earned $earnedPoints EcoPoints for your post!',
        );

        return data;
      } else {
        return {
          "error": "Failed to create post. Status: ${response.statusCode}"
        };
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
        List<Map<String, dynamic>> posts = [];

        // Check if response is a list (multiple posts) or a single post (map)
        if (data is List) {
          posts = data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic>) {
          posts = [data]; // Wrap single post in a list
        } else {
          print('Unexpected response format');
          return null;
        }

        // Process each post to ensure image_url is properly formatted
        for (var post in posts) {
          if (post.containsKey('image_url') && post['image_url'] != null) {
            // Make sure image_url doesn't already contain the full path
            if (!post['image_url'].toString().startsWith('http')) {
              // Keep the original image_url for reference
              post['original_image_url'] = post['image_url'];
              // Add the full URL path
              post['image_url'] =
                  '$baseUrl/api/posts/uploads/${post['image_url']}';
            }
          }
        }

        return posts;
      } else {
        print('Fetch Posts Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Fetch Posts Exception: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updatePost(
    int postId,
    String text,
    int category,
    File? image,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      if (userId == null) {
        return {"error": "User not logged in"};
      }

      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/api/posts/crud/edit.php'));
      request.fields['post_id'] = postId.toString();
      request.fields['user_id'] = userId;
      request.fields['text'] = text;
      request.fields['category_id'] = category.toString();

      if (image != null) {
        var fileExtension = image.path.split('.').last.toLowerCase();
        var contentType = 'image/jpeg';
        if (fileExtension == 'png')
          contentType = 'image/png';
        else if (fileExtension == 'gif') contentType = 'image/gif';

        final fileName =
            'post_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
            filename: fileName,
            contentType: MediaType.parse(contentType),
          ),
        );
        request.fields['image_filename'] = fileName;
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "error": "Failed to update post. Status: ${response.statusCode}"
        };
      }
    } catch (e) {
      print("Update Post Exception: $e");
      return {"error": "Exception occurred: $e"};
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

  // Method to get user's total points
  static Future<int?> fetchUserTotalPoints(String userId) async {
    try {
      final data = await fetchUserPostsWithPoints(userId);
      if (data != null && data.containsKey('total_points')) {
        return data['total_points'] as int?;
      }
      return 0;
    } catch (e) {
      print('Fetch User Points Exception: $e');
      return null;
    }
  }

  // Delete post
  static Future<bool> deletePost(int postId) async {
    try {
      final response = await postRequest(deletePostUrl, {'post_id': postId});
      return response != null;
    } catch (e) {
      print('Delete Post Exception: $e');
      return false;
    }
  }

  // Create notification
  static Future<bool> createNotification({
    required String userId,
    required String message,
  }) async {
    try {
      final response = await postRequest(notificationUrl, {
        'user_id': userId,
        'message': message,
      });
      return response != null;
    } catch (e) {
      print('Create Notification Error: $e');
      return false;
    }
  }

  // Fetch user notifications
  static Future<Map<String, dynamic>?> fetchUserNotifications(
      String userId) async {
    try {
      final response = await http
          .get(
            Uri.parse(
                '$baseUrl/api/posts/crud/read_notification.php?user_id=$userId'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Ensure proper type conversion
          final notifications = (data['notifications'] as List).map((n) {
            return {
              'notification_id': n['notification_id'] is int
                  ? n['notification_id']
                  : int.tryParse(n['notification_id'].toString()) ?? 0,
              'user_id': n['user_id'] is int
                  ? n['user_id']
                  : int.tryParse(n['user_id'].toString()) ?? 0,
              'post_id': n['post_id'] != null
                  ? (n['post_id'] is int
                      ? n['post_id']
                      : int.tryParse(n['post_id'].toString()))
                  : null,
              'message': n['message'].toString(),
              'points': n['points'] is int
                  ? n['points']
                  : int.tryParse(n['points'].toString()) ?? 0,
              'is_read': (n['is_read'] is bool)
                  ? n['is_read']
                  : (int.tryParse(n['is_read'].toString()) ?? 0) == 1,
              'created_at': n['created_at'].toString(),
            };
          }).toList();

          return {
            'status': 'success',
            'notifications': notifications,
          };
        }
        return data;
      }
      return {
        'status': 'error',
        'message':
            'Failed to load notifications. Status: ${response.statusCode}'
      };
    } catch (e) {
      return {'status': 'error', 'message': 'Exception: ${e.toString()}'};
    }
  }

  static Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/api/posts/crud/read_notification.php?notification_id=$notificationId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Claim coupon
  static Future<bool> claimCoupon({
    required String userId,
    required int couponId,
    required int points,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(claimCouponUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'coupon_id': couponId,
          'points': points,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == 1 || data['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Claim Coupon Error: $e');
      return false;
    }
  }
}
