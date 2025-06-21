import 'package:flutter/material.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> dummyOrders = const [
    {
      'flavor': 'Mango',
      'addons': ['Add Ice', 'Less Sugar'],
      'date': '2025-06-18',
    },
    {
      'flavor': 'Apple',
      'addons': ['Extra Sugar'],
      'date': '2025-06-17',
    },
    {
      'flavor': 'Mixed Berry',
      'addons': ['No Ice', 'Add Water'],
      'date': '2025-06-15',
    },
  ];

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Duration to cover all animations, e.g. 600ms per item staggered
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600 + dummyOrders.length * 200),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Build each animated item with stagger
  Widget _buildAnimatedItem(BuildContext context, int index) {
    final Animation<double> animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (index / dummyOrders.length),
        1.0,
        curve: Curves.easeOut,
      ),
    );

    final order = dummyOrders[index];

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(animation),
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          child: ListTile(
            leading: const Icon(Icons.local_drink, color: Colors.deepOrange),
            title: Text(order['flavor']),
            subtitle: Text('Add-ons: ${order['addons'].join(', ')}'),
            trailing: Text(order['date']),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyOrders.length,
        itemBuilder: _buildAnimatedItem,
      ),
    );
  }
}
