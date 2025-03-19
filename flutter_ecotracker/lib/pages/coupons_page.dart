import 'package:flutter/material.dart';

class CouponsPage extends StatelessWidget {
  const CouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> coupons = [
      {"title": "Coupons1", "subtitle": "10pcs Yumburger"},
      {"title": "Coupons2", "subtitle": "5pcs Chickenjoy"},
      {"title": "Coupons3", "subtitle": "Buy 1 Take 1 Fries"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupons'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: coupons.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                leading: Icon(Icons.local_offer, color: Theme.of(context).colorScheme.primary),
                title: Text(
                  coupons[index]["title"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(coupons[index]["subtitle"]!),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Future action, like navigating to coupon details
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${coupons[index]["title"]} tapped!")),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
