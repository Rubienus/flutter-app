import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> getUserDetails(String username) async {
  final response = await http.get(
    Uri.parse('https://just1ncantiler0.heliohost.us/Ecotracker_api/script/api.php?username=$username'),
  );

  final data = jsonDecode(response.body);
  print(data);
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
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
                  'John Doe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Flutter Developer',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'About Me',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                'Vestibulum in neque et nisl. Nulla facilisi. '
                'Curabitur ac felis arcu. Sed vehicula, urna eget aliquam '
                'feugiat, nisi libero ultricies nisi, vel tincidunt elit '
                'nunc vel nisi.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Recent Posts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Blog Post Title $index'),
                      subtitle: Text('Subtitle for blog post $index'),
                      trailing: Icon(Icons.arrow_forward),
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