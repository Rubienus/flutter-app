import 'package:flutter/material.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  static const int itemCount = 5;
  List<bool> liked = List<bool>.generate(itemCount, (index) => false);

  @override
  void initState() {
    super.initState();
    liked = List<bool>.generate(itemCount, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/profile_picture.png'),
                    ),
                    const SizedBox(width: 10),
                    Text('User Name'),
                  ],
                ),
                const SizedBox(height: 10),
                Text('These are events'),
                const SizedBox(height: 10),
                Image.asset('assets/sample_image.png'),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.thumb_up,
                            color: liked[index] ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              liked[index] = !liked[index];
                            });
                          },
                        ),
                        const SizedBox(width: 5),
                        Text('Like'),
                      ],
                    ),
                    Row(
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
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var events = snapshot.data!.docs;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              var event = events[index];
              return Container(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/profile_picture.png'),
                          ),
                          const SizedBox(width: 10),
                          Text(event['userName']),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(event['description']),
                      const SizedBox(height: 10),
                      Image.network(event['imageUrl']),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(
                                  Icons.thumb_up,
                                  color: event['liked'] ? Colors.blue : Colors.grey,
                                ),
                                onPressed: () {
                                  // Handle like functionality
                                },
                              ),
                              const SizedBox(width: 5),
                              Text('Like'),
                            ],
                          ),
                          Row(
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
          );
        },
      ),
    );
  }
}*/