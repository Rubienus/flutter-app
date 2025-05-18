import 'package:flutter/material.dart';
import '../api_service.dart';

class ProfilePage extends StatefulWidget {
  final String? username;

  const ProfilePage({super.key, this.username});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, dynamic>> userPosts = [];
  int totalPoints = 0;
  String username = "Loading...";
  String email = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    if (widget.username == null || widget.username!.isEmpty) {
      if (!mounted) return;
      setState(() {
        username = "Guest";
        email = "No email available";
        isLoading = false;
      });
      return;
    }

    try {
    // Get user data
    final userData = await ApiService.fetchUser(widget.username!);
    if (userData == null) throw Exception("User data not found");
    
    // Get user ID for points and posts
    final userId = userData['user_id']?.toString();
    if (userId == null) throw Exception("User ID not found");

    // Single API call to get both posts and points
    final postsResponse = await ApiService.fetchUserPostsWithPoints(userId);
    
    if (mounted) {
      setState(() {
        username = userData['username'] ?? "Unknown";
        email = userData['user_email'] ?? "No email available";
        if (postsResponse != null && postsResponse['status'] == 'success') {
          totalPoints = postsResponse['total_points'] ?? 0;
          userPosts = (postsResponse['posts'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        }
        isLoading = false;
      });
    }
  } catch (e) {
    if (!mounted) return;
    setState(() {
      username = "Error loading data";
      email = "Please try again later";
      isLoading = false;
    });
    print("Error fetching user data: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('images/sample.png'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Total Ecopoints: $totalPoints',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'About Me',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.username == null
                          ? 'You are a guest user. Register or login to access more features.'
                          : 'Welcome to your profile!',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Recent Posts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: userPosts.length,
                      itemBuilder: (context, index) {
                        final post = userPosts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(post['title'] ?? 'No title'),
                            subtitle: Text('${post['points'] ?? 0} Ecopoints'),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () {
                              // Handle post tap
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
