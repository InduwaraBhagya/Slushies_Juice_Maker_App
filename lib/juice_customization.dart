import 'package:flutter/material.dart';

class JuiceCustomizationPage extends StatefulWidget {
  const JuiceCustomizationPage({super.key});

  @override
  State<JuiceCustomizationPage> createState() => _JuiceCustomizationPageState();
}

class _JuiceCustomizationPageState extends State<JuiceCustomizationPage> {
  List<Map<String, String>> juiceFlavors = [
    {'name': 'Orange', 'image': 'assets/images'},
    {'name': 'Mango', 'image': 'assets/images'},
    {'name': 'Apple', 'image': 'assets/images'},
    {'name': 'Pineapple', 'image': 'assets/images'},
    {'name': 'Mixed Berry', 'image': 'assets/images'},
  ];

  List<String> addons = ['Sugar', 'Salt', 'Water'];
  String? selectedJuice;
  final Set<String> selectedAddons = {};
  bool animateHeader = true;

  void toggleAddOn(String addon) {
    setState(() {
      if (selectedAddons.contains(addon)) {
        selectedAddons.remove(addon);
      } else {
        selectedAddons.add(addon);
      }
    });
  }

  void placeOrder() {
    if (selectedJuice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a juice!')),
      );
      return;
    }

    final orderDetails =
        'Ordered $selectedJuice juice with ${selectedAddons.join(", ")}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(orderDetails)),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void initState() {
    super.initState();
    selectedJuice = juiceFlavors[0]['name'];

    Future.delayed(Duration.zero, () {
      setState(() {
        animateHeader = false;
      });
    });
  }

  Widget buildJuiceCard(Map<String, String> juice) {
    bool selected = juice['name'] == selectedJuice;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedJuice = juice['name'];
        });
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.orange.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.deepOrange : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(juice['image']!, height: 70, fit: BoxFit.contain),
            const SizedBox(height: 8),
            Text(
              juice['name']!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? Colors.deepOrange : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddonsChips() {
    return Wrap(
      spacing: 10,
      children: addons.map((addon) {
        final isSelected = selectedAddons.contains(addon);
        return ChoiceChip(
          label: Text(addon),
          selected: isSelected,
          onSelected: (_) => toggleAddOn(addon),
          selectedColor: Colors.orangeAccent,
          backgroundColor: Colors.grey.shade200,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Widget buildSummaryCard() {
    return Card(
      color: Colors.orange.shade50,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.local_drink, color: Colors.deepOrange),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedJuice != null
                        ? 'Juice: $selectedJuice'
                        : 'No juice selected',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.add_circle, color: Colors.deepOrange),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedAddons.isNotEmpty
                        ? 'Add-ons: ${selectedAddons.join(", ")}'
                        : 'No add-ons selected',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juice Customization'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            AnimatedDefaultTextStyle(
              style: TextStyle(
                fontSize: 24,
                color: animateHeader ? Colors.grey : Colors.deepOrange,
                fontWeight: FontWeight.bold,
              ),
              duration: const Duration(seconds: 1),
              child: const Text("Select Your Juice"),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: juiceFlavors.map(buildJuiceCard).toList(),
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Choose Add-ons",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            buildAddonsChips(),
            const SizedBox(height: 24),
            buildSummaryCard(),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text("Place Order",style: TextStyle(color: Colors.white),),
              onPressed: placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
            //const SizedBox(height: 16),
            //TextButton.icon(
             // onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
             // icon: const Icon(Icons.arrow_back),
              //label: const Text('Back to Home'),
            //),
          ],
        ),
      ),
    );
  }
}
