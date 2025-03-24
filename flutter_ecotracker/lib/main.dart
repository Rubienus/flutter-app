import 'package:flutter/material.dart';
import 'pages/home_page.dart';


const primaryColor = Color(0xFF91A287);
const secondaryColor = Color(0xFFcbb89d);
const tertiaryColor = Color(0xFFA1A79E);

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
        colorScheme: ColorScheme.fromSwatch().copyWith(primary: primaryColor),
      ),
      home: HomePage(), 
    );
  }
}
  