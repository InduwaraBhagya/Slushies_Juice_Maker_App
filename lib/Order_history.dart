import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<Map<String, dynamic>> userOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      debugPrint('No user logged in.');
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .get();
    final snapshot2 = await FirebaseFirestore.instance
        .collection('orders')
        .where('user_id', isEqualTo: user.uid)
        .get();

    userOrders = [
      ...snapshot.docs.map((doc) => doc.data()),
      ...snapshot2.docs.map((doc) => doc.data()),
    ];
    debugPrint('Fetched orders: $userOrders');
    setState(() {
      isLoading = false;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem(BuildContext context, int index) {
    final Animation<double> animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (index / (userOrders.length == 0 ? 1 : userOrders.length)),
        1.0,
        curve: Curves.easeOut,
      ),
    );

    final order = userOrders[index];
    final flavor = order['flavor'] ?? order['juice_type'] ?? '';
    final addons = (order['addons'] is List)
        ? (order['addons'] as List).join(', ')
        : (order['ingredient_list'] is List)
            ? (order['ingredient_list'] as List).join(', ')
            : '';
    final date = order['date'] ?? (order['timestamp'] is Timestamp
        ? (order['timestamp'] as Timestamp).toDate().toString()
        : order['timestamp']?.toString() ?? '');
    final location = order['location'] ?? '';

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(animation),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: Colors.deepOrange.withOpacity(0.4),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: const Icon(Icons.wine_bar, color: Colors.deepOrangeAccent, size: 30),
            title: Text(
              flavor,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add-ons: $addons'),
                Text('Location: $location'),
              ],
            ),
            trailing: Text(
              date,
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        elevation: 4,
        //shape: const RoundedRectangleBorder(
          //borderRadius: BorderRadius.vertical(
            //bottom: Radius.circular(20),
         // ),
        //),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE0B2), Color(0xFFFFCCBC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : userOrders.isEmpty
                ? const Center(
                    child: Text(
                      'No orders found.',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: userOrders.length,
                    itemBuilder: _buildAnimatedItem,
                  ),
      ),
    );
  }
}
