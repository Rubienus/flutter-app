import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../api_service.dart';
import 'createpost_page.dart'; // For post editing

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
  String aboutMe = "Tell us about yourself...";
  bool isLoading = true;
  bool isEditingAboutMe = false;
  TextEditingController aboutMeController = TextEditingController();

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
      final userData = await ApiService.fetchUser(widget.username!);
      if (userData == null) throw Exception("User data not found");

      final userId = userData['user_id']?.toString();
      if (userId == null) throw Exception("User ID not found");

      final postsResponse = await ApiService.fetchUserPostsWithPoints(userId);

      if (mounted) {
        setState(() {
          username = userData['username'] ?? "Unknown";
          email = userData['user_email'] ?? "No email available";
          aboutMe = userData['about_me'] ?? "Tell us about yourself...";
          aboutMeController.text = aboutMe;
          if (postsResponse != null && postsResponse['status'] == 'success') {
            totalPoints = postsResponse['total_points'] ?? 0;
            userPosts = (postsResponse['posts'] as List?)
                    ?.cast<Map<String, dynamic>>() ??
                [];
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

  Future<void> _deletePost(int postId) async {
    try {
      final success = await ApiService.deletePost(postId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
        fetchUser(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete post')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _editPost(Map<String, dynamic> post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostPage(
          initialText: post['title'],
          initialCategory: post['category_id']?.toString(),
          postId: post['post_id'],
        ),
      ),
    );

    if (result == true) {
      fetchUser(); // Refresh after editing
    }
  }

  Future<void> _updateAboutMe() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final success = await ApiService.updateAboutMe(
        userId: userId,
        aboutMe: aboutMeController.text,
      );

      if (success) {
        setState(() {
          aboutMe = aboutMeController.text;
          isEditingAboutMe = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('About me updated successfully')),
        );
      } else {
        throw Exception('Failed to update about me');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating about me: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (widget.username != null) // Only show for logged in users
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditingAboutMe = true;
                });
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile picture and basic info remains the same
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
                    isEditingAboutMe
                        ? Column(
                            children: [
                              TextField(
                                controller: aboutMeController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Tell us about yourself...',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        isEditingAboutMe = false;
                                      });
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: _updateAboutMe,
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Text(
                            aboutMe,
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
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editPost(post);
                                } else if (value == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Post'),
                                      content: const Text(
                                          'Are you sure you want to delete this post?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deletePost(post['post_id']);
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
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
