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

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId != null) {
        // Fetch notifications from API
        final response = await ApiService.fetchUserNotifications(userId);
        
        if (response != null && response['status'] == 'success') {
          setState(() {
            notifications = List<Map<String, dynamic>>.from(response['notifications'] ?? []);
            isLoading = false;
          });
          return;
        }
      }
      
      // Fallback to local notifications if API fails
      final localNotifs = prefs.getStringList('local_notifications') ?? [];
      setState(() {
        notifications = localNotifs.map((n) => {'message': n, 'timestamp': DateTime.now().toString()}).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      isLoading = true;
    });
    await _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNotifications,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(
                  child: Text('You have no notifications as of now.'),
                )
              : RefreshIndicator(
                  onRefresh: _refreshNotifications,
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.eco, color: Colors.green),
                          title: Text(notification['message'] ?? 'New notification'),
                          subtitle: Text(
                            notification['timestamp'] != null
                                ? _formatTimestamp(notification['timestamp'])
                                : 'Just now',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _dismissNotification(index),
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
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} - ${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return timestamp;
    }
  }

  Future<void> _dismissNotification(int index) async {
    setState(() {
      notifications.removeAt(index);
    });
    
    // Update local storage if using local notifications
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'local_notifications',
      notifications.map((n) => n['message']).toList().cast<String>(),
    );
  }
}