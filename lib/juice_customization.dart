import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class JuiceCustomizationPage extends StatefulWidget {
  const JuiceCustomizationPage({super.key});

  @override
  State<JuiceCustomizationPage> createState() => _JuiceCustomizationPageState();
}

class _JuiceCustomizationPageState extends State<JuiceCustomizationPage>
    with SingleTickerProviderStateMixin {
  final List<String> cities = ['Colombo', 'Kandy', 'Galle'];

  final Map<String, List<Map<String, String>>> cityJuices = {
    'Colombo': [
      {'name': 'Orange', 'image': 'assets/Orange.jpeg'},
      {'name': 'Strawberry', 'image': 'assets/Strawberry.jpeg'},
      {'name': 'Mango', 'image': 'assets/Mango.jpeg'},
      {'name': 'Papaya', 'image': 'assets/Papaya.jpeg'},
      {'name': 'Avocado', 'image': 'assets/Avocado.jpeg'},
    ],
    'Kandy': [
      {'name': 'Papaya', 'image': 'assets/Papaya.jpeg'},
      {'name': 'Orange', 'image': 'assets/Orange.jpeg'},
      {'name': 'Avocado', 'image': 'assets/Avocado.jpeg'},
      {'name': 'Mango', 'image': 'assets/Mango.jpeg'},
      {'name': 'Strawberry', 'image': 'assets/Strawberry.jpeg'},
    ],
    'Galle': [
      {'name': 'Strawberry', 'image': 'assets/Strawberry.jpeg'},
      {'name': 'Papaya', 'image': 'assets/Papaya.jpeg'},
      {'name': 'Mango', 'image': 'assets/Mango.jpeg'},
      {'name': 'Avocado', 'image': 'assets/Avocado.jpeg'},
      {'name': 'Orange', 'image': 'assets/Orange.jpeg'},
    ],
  };

  final List<String> addons = ['Sugar',  'Water'];

  String selectedCity = 'Colombo';
  String? selectedJuice;
  List<Map<String, String>> juiceFlavors = [];
  final Set<String> selectedAddons = {};

  late AnimationController _controller;
  late Animation<double> _fade;

  void _updateJuicesForCity(String city) {
    setState(() {
      selectedCity = city;
      juiceFlavors = cityJuices[city]!;
      selectedJuice = juiceFlavors.first['name'];
      selectedAddons.clear();
    });
    _controller.forward(from: 0.0);
  }

  void toggleAddOn(String addon) {
    setState(() {
      selectedAddons.contains(addon)
          ? selectedAddons.remove(addon)
          : selectedAddons.add(addon);
    });
  }

  Future<void> placeOrder() async {
    if (selectedJuice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a juice!')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    try {
      final orderRef = await FirebaseFirestore.instance.collection('orders').add({
        'user_id': user.uid,
        'juice_type': selectedJuice,
        'ingredient_list': selectedAddons.toList(),
        'location': selectedCity,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending_payment',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed! Please complete payment.')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(orderId: orderRef.id),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _updateJuicesForCity(selectedCity);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildJuiceCard(Map<String, String> juice) {
    final isSelected = selectedJuice == juice['name'];
    return GestureDetector(
      onTap: () => setState(() => selectedJuice = juice['name']),
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isSelected
                ? [Colors.orange.shade200, Colors.deepOrange.shade200]
                : [Colors.white, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.deepOrange.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                image: DecorationImage(
                  image: AssetImage(juice['image']!),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              juice['name']!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? Colors.white : Colors.deepOrange,
                shadows: isSelected
                    ? [
                        const Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        )
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCitySelector() {
    return DropdownButtonFormField<String>(
      value: selectedCity,
      decoration: InputDecoration(
        labelText: "Select City",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.location_city, color: Colors.deepOrange),
      dropdownColor: Colors.white,
      items: cities
          .map((city) => DropdownMenuItem(
                value: city,
                child: Text(city),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) _updateJuicesForCity(value);
      },
    );
  }

  Widget buildAddonsChips() {
    return Wrap(
      spacing: 10,
      children: addons.map((addon) {
        final isSelected = selectedAddons.contains(addon);
        return FilterChip(
          label: Text(addon),
          selected: isSelected,
          selectedColor: Colors.deepOrange,
          backgroundColor: Colors.grey.shade200,
          checkmarkColor: Colors.white,
          onSelected: (_) => toggleAddOn(addon),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Widget buildSummaryCard() {
    return FadeTransition(
      opacity: _fade,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.local_cafe, color: Colors.deepOrange),
                  const SizedBox(width: 10),
                  Text(
                    selectedJuice != null
                        ? 'Juice: $selectedJuice'
                        : 'No juice selected',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.add_circle, color: Colors.deepOrange),
                  const SizedBox(width: 10),
                  Text(
                    selectedAddons.isNotEmpty
                        ? 'Add-ons: ${selectedAddons.join(", ")}'
                        : 'No add-ons selected',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        title: const Text('Juice Customizer', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCitySelector(),
            const SizedBox(height: 24),
            const Text(
              "Choose Your Juice",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: juiceFlavors.map(buildJuiceCard).toList(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Select Add-ons",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 10),
            buildAddonsChips(),
            const SizedBox(height: 24),
            buildSummaryCard(),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: placeOrder,
                icon: const Icon(Icons.shopping_bag, color: Colors.white),
                label: const Text(
                  'Place Order',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  final String orderId;
  const PaymentPage({super.key, required this.orderId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  bool isPaying = false;
  String selectedCardType = 'Visa';

  final List<String> cardTypes = ['Visa', 'MasterCard', 'Amex', 'Discover'];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isPaying = true);

    await Future.delayed(const Duration(seconds: 2));

    final cardNumber = _cardNumberController.text.trim();
    final last4 = cardNumber.length >= 4
        ? cardNumber.substring(cardNumber.length - 4)
        : cardNumber;

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'status': 'paid',
        'payment': {
          'type': selectedCardType,
          'last4': last4,
          'name': _nameController.text.trim(),
          'paidAt': DateTime.now().toIso8601String(),
        },
      });
      // Update Realtime Database as well
      final dbRef = FirebaseDatabase.instance.ref('orders/${widget.orderId}');
      await dbRef.update({
        'status': 'paid',
        'payment': {
          'type': selectedCardType,
          'last4': last4,
          'name': _nameController.text.trim(),
          'paidAt': DateTime.now().toIso8601String(),
        },
      });

      setState(() => isPaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const JuiceCustomizationPage()),
        (route) => false,
      );
    } catch (e) {
      setState(() => isPaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    }
  }

  Widget _buildCardTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Card Type',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.deepOrange)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: cardTypes.map((type) {
            return ChoiceChip(
              label: Text(type),
              selected: selectedCardType == type,
              onSelected: (_) => setState(() => selectedCardType = type),
              selectedColor: Colors.deepOrange,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color:
                    selectedCardType == type ? Colors.white : Colors.black,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Card Payment', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCardTypeSelector(),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            const InputDecoration(labelText: 'Name on Card'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cardNumberController,
                        decoration:
                            const InputDecoration(labelText: 'Card Number'),
                        keyboardType: TextInputType.number,
                        maxLength: 16,
                        validator: (v) => v == null || v.length < 12
                            ? 'Enter valid card number'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryController,
                              decoration: const InputDecoration(
                                  labelText: 'MM/YY'),
                              maxLength: 5,
                              validator: (v) =>
                                  v == null ||
                                          !RegExp(r'^(0[1-9]|1[0-2])/\d{2}$')
                                              .hasMatch(v)
                                      ? 'Enter valid MM/YY'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              decoration:
                                  const InputDecoration(labelText: 'CVV'),
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              validator: (v) => v == null || v.length < 3
                                  ? 'Enter valid CVV'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: isPaying ? null : _pay,
                        icon: const Icon(Icons.lock, color: Colors.white),
                        label: isPaying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Pay Now',
                                style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
