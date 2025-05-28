import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';

class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  final List<Map<String, dynamic>> coupons = [
    {
      "title": "10% Off Eco Products",
      "subtitle": "Get 10% discount on eco-friendly products",
      "points": 50,
      "code": "ECO10",
      "coupon_id": 1 // Matches the coupon_id in your database
    },
    {
      "title": "Free Reusable Bag",
      "subtitle": "Claim your free reusable shopping bag",
      "points": 100,
      "code": "BAGFREE",
      "coupon_id": 2 // Matches the coupon_id in your database
    },
    {
      "title": "Buy 1 Take 1 Coffee",
      "subtitle": "Buy one coffee, get one free at EcoCafe",
      "points": 75,
      "code": "B1T1COFFEE",
      "coupon_id": 3 // Matches the coupon_id in your database
    },
  ];

  int userPoints = 0;
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
    });

    if (userId != null) {
      final pointsResponse = await ApiService.fetchUserTotalPoints(userId!);
      setState(() {
        userPoints = pointsResponse ?? 0;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _claimCoupon(int couponIndex) async {
  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please login to claim coupons'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final coupon = coupons[couponIndex];
  final requiredPoints = coupon['points'] as int;

  if (userPoints < requiredPoints) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You need ${requiredPoints - userPoints} more points to claim this coupon'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Claim'),
      content: Text(
        'Are you sure you want to claim "${coupon['title']}" for $requiredPoints points?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Claim'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    setState(() => isLoading = true);
    
    final success = await ApiService.claimCoupon(
      userId: userId!,
      couponId: coupon['coupon_id'],
      points: requiredPoints,
    );

    if (success && mounted) {
      // Update local points
      setState(() {
        userPoints -= requiredPoints;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Coupon claimed successfully!'),
              const SizedBox(height: 4),
              Text('Code: ${coupon['code']}', 
                style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to claim coupon. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupons'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your EcoPoints:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userPoints.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: coupons.length,
                    itemBuilder: (context, index) {
                      final coupon = coupons[index];
                      final canClaim = userPoints >= coupon['points'];

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          leading: Icon(
                            Icons.local_offer,
                            color: canClaim
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          ),
                          title: Text(
                            coupon["title"]!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(coupon["subtitle"]!),
                              const SizedBox(height: 4),
                              Text(
                                '${coupon["points"]} Ecopoints',
                                style: TextStyle(
                                  color: canClaim
                                      ? Theme.of(context).primaryColor
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _claimCoupon(index),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
