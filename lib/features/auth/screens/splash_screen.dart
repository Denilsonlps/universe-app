import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/brand/universe_brand.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [c.heroFrom, c.heroTo]),
        ),
        child: const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            UniverseAppIcon(size: 96),
            SizedBox(height: 22),
            UniverseWordmark(height: 30, color: Colors.white),
            SizedBox(height: 28),
            SizedBox(width: 26, height: 26, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.6)),
          ]),
        ),
      ),
    );
  }
}
