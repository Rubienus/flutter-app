import 'package:flutter/material.dart';

class NearyouPage extends StatefulWidget {
  const NearyouPage({super.key});

  @override
  _NearyouPageState createState() => _NearyouPageState();
}

class _NearyouPageState extends State<NearyouPage> {
  List<bool> liked = List<bool>.filled(5, false);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: AssetImage('images/profile_sample.jpg'),
                    ),
                    SizedBox(width: 10),
                    Text('User Name'),
                  ],
                ),
                SizedBox(height: 10),
                Text('This is a sample blog post content. It can be a few lines long.'),
                SizedBox(height: 10),
                Image.asset(
                  'images/sample.jpg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 10),
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
                            color: liked[index] ? Colors.blue : Colors.grey,
                          ),
                          SizedBox(width: 5),
                          Text('Like'),
                        ],
                      ),
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
