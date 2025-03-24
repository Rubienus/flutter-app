import 'package:flutter/material.dart';
import '../api_service.dart';

class ProfilePage extends StatefulWidget {
  final String? username; // Username is now optional

  const ProfilePage({super.key, this.username}); // No longer required

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
      final data = await ApiService.fetchUser(widget.username!);
      if (mounted) {
        setState(() {
          if (data != null && data.containsKey('username')) {
            username = data['username'];
            email = data['user_email'] ?? "No email available";
          } else {
            username = "User not found";
            email = "No email available";
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        username = "Network error";
        email = "Please try again later";
        isLoading = false;
      });
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
                    const SizedBox(height: 16),
                    const Text(
                      'About Me',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You are a guest user. Register or login to access more features.',
                      style: TextStyle(fontSize: 16),
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
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text('Blog Post Title $index'),
                            subtitle: Text('Subtitle for blog post $index'),
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
