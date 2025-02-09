import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.account_circle),
        onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        },
      ),
      title: const Text('Ecotracker'),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'notifications',
          ),
        ],
      ),
      body: NavigatorWidget(),

      
    );
  }
}

class NavigatorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        Widget page;
        switch (settings.name) {
          case '/':
            page = Page1();
            break;
          case '/page2':
            page = Page2();
            break;
          default:
            page = Page1();
        }
        return MaterialPageRoute(builder: (_) => page);
      },
    );
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              
              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).pushNamed('/page2');
                },
                child: Text("For you"),
              ),
              
              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).pushNamed('/page2');
                },
                child: Text("Events"),
              ),
              
            ],
          ),
        ),
       
        Text('Page 1 Content'),
        Text('Page 1 Content'),
        Text('Page 1 Content'),
        Text('Page 1 Content'),
      ],
    );
    }
  }


class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("Back to Page 1"),
      ),
    );
  }
}
class SingleChildLayoutPage extends StatelessWidget {
  const SingleChildLayoutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Single-Child Layout'),
      ),
      body: Center(
        child: Text('Single-Child Layout Content'),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Text('Profile Content'),
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Center(
        child: Text('Notifications Content'),
      ),
    );
  }
}