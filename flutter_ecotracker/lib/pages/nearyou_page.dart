import 'package:flutter/material.dart';

class NearyouPage extends StatelessWidget {
  const NearyouPage({super.key});

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
                      backgroundImage: AssetImage('assets/profile_picture.png'),
                    ),
                    SizedBox(width: 10),
                    Text('User Name'),
                  ],
                ),
                SizedBox(height: 10),
                Text('This is a sample blog post content. It can be a few lines long.'),
                SizedBox(height: 10),
                Image.asset('assets/sample_image.png'),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.thumb_up),
                        SizedBox(width: 5),
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
