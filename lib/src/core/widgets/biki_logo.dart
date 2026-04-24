import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BikiLogo extends StatelessWidget {
  final double size;
  final bool showText;
  
  const BikiLogo({
    super.key,
    this.size = 100,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A), // Deep Navy for Logo Background
            borderRadius: BorderRadius.circular(size * 0.3),
            border: Border.all(color: kGoldAccent.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: kGoldAccent.withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: -5,
              ),
            ],
          ),
          padding: EdgeInsets.all(size * 0.15),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'BikiBook',
            style: TextStyle(
              fontSize: size * 0.36,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF003366), // Professional Navy
              letterSpacing: -1,
            ),
          ),
          Text(
            'DEAR LOTTERY HUB',
            style: TextStyle(
              fontSize: size * 0.1,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE91E63), // Magenta accent
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }
}
