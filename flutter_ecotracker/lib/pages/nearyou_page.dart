import 'dart:math';
import 'package:flutter/material.dart';

class NearyouPage extends StatefulWidget {
  const NearyouPage({super.key});

  @override
  _NearyouPageState createState() => _NearyouPageState();
}

class _NearyouPageState extends State<NearyouPage> {
  List<List<String>> images = List<List<String>>.generate(5, (index) => List<String>.generate(Random().nextInt(5) + 1, (i) => 'images/sample.jpg'));
  List<int> points = List<int>.generate(5, (index) => Random().nextInt(100) + 15);
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
                Text('${points[index]} Ecopoints'),
                SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images[index].length,
                    itemBuilder: (context, imgIndex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Image.asset(
                          images[index][imgIndex],
                        ),
                      );
                    },
                  ),
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
