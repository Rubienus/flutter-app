import 'package:flutter/material.dart';

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