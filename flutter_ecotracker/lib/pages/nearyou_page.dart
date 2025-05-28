import 'package:flutter/material.dart';
import '../api_service.dart';

class NearyouPage extends StatefulWidget {
  const NearyouPage({super.key});

  @override
  _NearyouPageState createState() => _NearyouPageState();
}

class _NearyouPageState extends State<NearyouPage> {
  List<Map<String, dynamic>> posts = [];
  List<bool> liked = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final fetchedPosts = await ApiService.fetchPosts();
      if (fetchedPosts != null) {
        setState(() {
          posts = fetchedPosts;
          liked = List<bool>.filled(fetchedPosts.length, false);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load posts';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {
      isLoading = true;
    });
    await _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshPosts,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundImage: post['image_url'] != null &&
                                          post['image_url'].isNotEmpty
                                      ? NetworkImage(
                                          'https://just1ncantiler0.heliohost.us/Ecotracker_api/api/posts/uploads/${post['image_url']}')
                                      : const AssetImage(
                                              'images/profile_sample.jpg')
                                          as ImageProvider,
                                ),
                                const SizedBox(width: 10),
                                Text(post['username'] ?? 'Unknown User'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(post['title'] ?? 'No content'),
                            if (post['category_name'] != null)
                              Text(
                                '${post['category_name']}',
                                style: TextStyle(
                                  color: Colors.blueGrey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            Text(
                              '${post['points'] ?? 0} Ecopoints',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (post['image_url'] != null &&
                                post['image_url'].toString().isNotEmpty)
                              Column(
                                children: [
                                  SizedBox(
                                    height: 200,
                                    child: Image.network(
                                      'https://just1ncantiler0.heliohost.us/Ecotracker_api/api/posts/uploads/${post['image_url']}',
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                            child: CircularProgressIndicator());
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        print(
                                            'Failed to load image: ${post['image_url']} - Error: $error');
                                        return Container(); // Return empty container instead of broken image icon
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      liked[index] = !liked[index];
                                    });
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.thumb_up,
                                        color: liked[index]
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 5),
                                      const Text('Like'),
                                    ],
                                  ),
                                ),
                                const Row(
                                  children: <Widget>[
                                    Icon(Icons.comment),
                                    SizedBox(width: 5),
                                    Text('Comment'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
