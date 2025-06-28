import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconFade;
  late final Animation<Offset> _iconSlide;

  final List<Animation<Offset>> _slideAnimations = [];
  final List<Animation<double>> _fadeAnimations = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _iconFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3)),
    );

    _iconSlide = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3)),
    );

    // Animations for 3 cards
    for (int i = 0; i < 3; i++) {
      _fadeAnimations.add(Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Interval(0.3 + i * 0.2, 0.6 + i * 0.2)),
      ));

      _slideAnimations.add(Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Interval(0.3 + i * 0.2, 0.6 + i * 0.2)),
      ));
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildFeatureItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Slushies',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            FadeTransition(
              opacity: _iconFade,
              child: SlideTransition(
                position: _iconSlide,
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.wine_bar, size: 70, color: Color.fromARGB(255, 228, 61, 10)),
                      SizedBox(height: 12),
                      Text(
                        'Slushies Juice Bartender',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Card 1: About the App
            SlideTransition(
              position: _slideAnimations[0],
              child: FadeTransition(
                opacity: _fadeAnimations[0],
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About the App',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        Text(
                          'Slushies is a smart juice mixing app that lets you customize and remotely order your favorite beverages. '
                          'It connects with the physical Slushies machine via Bluetooth or Wi-Fi, providing a clean, automated juice experience. '
                          'You can select ingredients, add-ons, and even track your orders.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Card 2: Features
            SlideTransition(
              position: _slideAnimations[1],
              child: FadeTransition(
                opacity: _fadeAnimations[1],
                child: Card(
                  color: Colors.orange.shade50,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Features',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildFeatureItem(Icons.local_cafe, 'Customize juice with your favorite add-ons.'),
                        _buildFeatureItem(Icons.history, 'View and manage order history.'),
                        _buildFeatureItem(Icons.settings_bluetooth, 'Control Bluetooth & Wi-Fi connectivity.'),
                        _buildFeatureItem(Icons.info_outline, 'Learn more about the app and its creators.'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Card 3: Developer Info
            SlideTransition(
              position: _slideAnimations[2],
              child: FadeTransition(
                opacity: _fadeAnimations[2],
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}
