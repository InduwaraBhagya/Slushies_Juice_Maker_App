
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


import 'login.dart';
import 'Home.dart';
import 'juice_customization.dart';
import 'package:slushies/order_history.dart';
import 'about.dart';
import 'customer_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juice Mixing Machine',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/customize': (context) => const JuiceCustomizationPage(),
        '/history': (context) => const OrderHistoryPage(),
        '/about': (context) => const AboutPage(),
        '/profile': (context) => const CustomerProfilePage(),
      },
    );
  }
}
