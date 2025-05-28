import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  Future<List<Map<String, dynamic>>> _parseNotifications(
      dynamic responseData) async {
    try {
      final List<dynamic> rawList = responseData['notifications'] ?? [];
      return rawList
          .map((item) => {
                'notification_id': item['notification_id'] as int,
                'user_id': item['user_id'] as int,
                'post_id': item['post_id'] as int? ?? 0,
                'message': item['message'] as String? ?? '',
                'points': item['points'] as int? ?? 0,
                'is_read': (item['is_read'] as int? ?? 0) == 1,
                'created_at': item['created_at'] as String? ?? '',
              })
          .toList();
    } catch (e) {
      print('Error parsing notifications: $e');
      return [];
    }
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    print('All preferences: ${prefs.getKeys()}');
    if (!mounted) return;

    setState(() => isLoading = true);
    print('Loading notifications...'); // Debug log

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      print('Current user ID: $userId'); // Debug log

      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      final response = await ApiService.fetchUserNotifications(userId);
      print('API response: $response'); // Debug log

      if (response == null) {
        throw Exception('No response from server');
      }

      if (response['status'] == 'success') {
        final List<dynamic> rawNotifications = response['notifications'] ?? [];
        print('Received ${rawNotifications.length} notifications'); // Debug log

        if (mounted) {
          setState(() {
            notifications = List<Map<String, dynamic>>.from(rawNotifications);
            isLoading = false;
          });
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to load notifications');
      }
    } catch (e) {
      print('Error in _loadNotifications: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      final success = await ApiService.deleteNotification(notificationId);
      if (success) {
        setState(() {
          notifications
              .removeWhere((n) => n['notification_id'] == notificationId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete notification: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text('No notifications yet'))
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Dismissible(
                        key: Key(notification['notification_id'].toString()),
                        background: Container(color: Colors.red),
                        onDismissed: (direction) => _deleteNotification(
                            int.parse(
                                notification['notification_id'].toString())),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.notifications),
                            title:
                                Text(notification['message'] ?? 'Notification'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatTimestamp(notification['created_at']),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                if (notification['points'] > 0)
                                  Text(
                                    '+${notification['points']} EcoPoints',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteNotification(int.parse(
                                  notification['notification_id'].toString())),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}
