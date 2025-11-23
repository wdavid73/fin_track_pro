import 'package:flutter/material.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final flavorConfig = FlavorConfig.instance;

    return MaterialApp(
      title: flavorConfig.appName,
      debugShowCheckedModeBanner: flavorConfig.showDebugBanner,
      home: HomePage(flavorConfig: flavorConfig),
    );
  }
}

class HomePage extends StatelessWidget {
  final FlavorConfig flavorConfig;

  const HomePage({super.key, required this.flavorConfig});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(flavorConfig.appName),
        backgroundColor: _getFlavorColor(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to ${flavorConfig.appName}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getFlavorColor().withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Environment: ${flavorConfig.name.toUpperCase()}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getFlavorColor(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'MVP in Progress...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFlavorColor() {
    switch (flavorConfig.flavor) {
      case Flavor.dev:
        return Colors.green;
      case Flavor.staging:
        return Colors.orange;
      case Flavor.prod:
        return Colors.blue;
    }
  }
}
