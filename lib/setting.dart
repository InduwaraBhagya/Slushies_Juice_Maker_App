import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool bluetoothOn = false;
  bool wifiOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Bluetooth'),
              value: bluetoothOn,
              onChanged: (bool value) {
                setState(() {
                  bluetoothOn = value;
                });
              },
              secondary: const Icon(Icons.bluetooth),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Wi-Fi'),
              value: wifiOn,
              onChanged: (bool value) {
                setState(() {
                  wifiOn = value;
                });
              },
              secondary: const Icon(Icons.wifi),
            ),
            const SizedBox(height: 32),
            const Text(
              'Note: These settings are for simulation only. '
              'Implement actual connectivity logic as needed.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
