import 'package:flutter/material.dart';

class NearyouPage extends StatefulWidget {
  const NearyouPage({super.key});

  @override
  _NearyouPageState createState() => _NearyouPageState();
}

class _NearyouPageState extends State<NearyouPage> {
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
                Text('This is a sample blog post content. It can be a few lines long.'),
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
