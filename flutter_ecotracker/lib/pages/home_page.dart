import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'nearyou_page.dart';
import 'events_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'coupons_page.dart';
import 'login_page.dart';
import 'createpost_page.dart';
import '../api_service.dart';

const primaryColor = Color(0xFF91A287);
const secondaryColor = Color(0xFFcbb89d);
const tertiaryColor = Color(0xFFA1A79E);

class HomePage extends StatefulWidget {
  final String? username;

  HomePage({this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;

  String username = "Loading...";
  String email = "Loading...";
  bool isLoading = true;

  static List<Widget> _pages = <Widget>[
    NearyouPage(),
    EventsPage(),
    NotificationsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchUser();
  }

  Future<void> fetchUser() async {
    final url = Uri.parse(
        'https://just1ncantiler0.heliohost.us/Ecotracker_api/api/microuser/crud/read.php?username=${widget.username}');

    try {
      final response = await http.get(url);

      print("Fetching user with username: ${widget.username}");
      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data.containsKey("message")) {
            username = "User not found";
            email = "No email available";
          } else {
            username = data['username'];
            email = data['email'];
          }
          isLoading = false;
        });
      } else {
        setState(() {
          username = "Error fetching data";
          email = "Check API response";
          isLoading = false;
        });
      }
    } catch (e) {
      print("Network error: $e");
      setState(() {
        username = "Network error";
        email = "Please try again";
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreatePostPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _logout() async {
    bool success = await ApiService.logoutUser();
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed, try again!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text('Ecotracker'),
        bottom: _selectedIndex == 0
            ? TabBar(
                controller: _tabController,
                dividerHeight: 1.5,
                labelColor: Colors.white,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Near You'),
                  Tab(text: 'Events'),
                ],
              )
            : null,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _selectedIndex == 0
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    NearyouPage(),
                    EventsPage(),
                  ],
                )
              : _pages.elementAt(_selectedIndex),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: tertiaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Eco Tracker',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Welcome, $username', style: TextStyle(fontSize: 16)),
                  Text('Email: $email', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              title: Text('Login'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              title: Text('Coupons'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CouponsPage()),
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: primaryColor,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
