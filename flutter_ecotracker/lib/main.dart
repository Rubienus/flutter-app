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
      ),
      
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Ecotracker'),
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
              title: Text('coupons'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CouponsPage()),
                );
              },
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'notifications',
          ),
        ],
      ),
      body: NavigatorWidget(),

      
    );
  }
}

class NavigatorWidget extends StatelessWidget {
  const NavigatorWidget({super.key});

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
  const Page1({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              
              SizedBox(
              width: 215,
              height: 50,
              child: FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).pushNamed('/page1');
                },
                style: ButtonStyle(
                  textStyle: WidgetStateProperty.all(
                    TextStyle(fontSize: 18.0, decoration: TextDecoration.underline),
                  ),
                ),

                child: Text("For you"),

              ),
              ),
              SizedBox(
              width: 215,
              height: 50,
              child: FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).pushNamed('/page2');
                },
                child: Text("Events"),
              ),
              ),
            ],
          ),
        ),
       
        Text('Page 1 Content'),
        Divider(
          color: Colors.black,
          height: 10,
          thickness: .5,
          indent: 25,
          endIndent: 25,
        ),
        Text('Page 1 Content'),
        Text('Page 1 Content'),
        Text('Page 1 Content'),
      ],
    );
    }
}
class Page2 extends StatelessWidget {
  const Page2({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              
              SizedBox(
              width: 215,
              height: 50,
              child: FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).pushNamed('/page1');
                },
                child: Text("For you"),
              ),
              ),

              SizedBox(
              width: 215,
              height: 50,
              child: FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).pushNamed('/page2');
                },
                style: ButtonStyle(
                  textStyle: WidgetStateProperty.all(
                    TextStyle(fontSize: 18.0, decoration: TextDecoration.underline),
                  ),
                ),

                child: Text("Events"),

              ),
              ),
              
            ],
          ),
        ),
       
        Text('Page 2 Content'),
        Text('Page 2 Content'),
        Text('Page 2 Content'),
        Text('Page 2 Content'),
        Text('Page 2 Content'),
        Text('Page 2 Content'),
        Text('Page 2 Content'),
        Text('Page 2 Content'),
      ],
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

class CouponsPage extends StatelessWidget {
  const CouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupons'),
      ),
body: Center(
  child: ListView(
    children: ListTile.divideTiles(
      context: context,
      tiles: [
        ListTile(
          leading: Icon(Icons.food_bank),
          title: Text('Coupons1'),
          subtitle: Text('10pcs yumburger'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          leading: Icon(Icons.food_bank),
          title: Text('Coupons2'),
          subtitle: Text('10pcs yumburger'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          leading: Icon(Icons.food_bank),
          title: Text('Coupons3'),
          subtitle: Text('10pcs yumburger'),
          trailing: Icon(Icons.arrow_forward_ios),
           ),
          ],
       ).toList(),
     ),
   ),
  );
  }
}
