import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bikibook/src/core/widgets/biki_logo.dart';
import 'package:bikibook/src/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF001F3F), // Deep Navy
              Color(0xFF000D1A), // Darker Navy
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Elegant Background Ornaments
            Positioned(
              top: -150,
              right: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      kGoldAccent.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Central Branding
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated or Glowing Logo Container
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kGoldAccent.withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const BikiLogo(size: 160, showText: false),
                ),
                const SizedBox(height: 24),
                const Text(
                  'BikiBook',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const Text(
                  'PREMIUM LOTTERY HUB',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: kGoldAccent,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    color: kGoldAccent,
                    minHeight: 2,
                  ),
                ),
              ],
            ),
            
            // Bottom Tagline
            Positioned(
              bottom: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'EXCELLENCE IN LOTTERY'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'BikiBook Gold Edition',
                    style: TextStyle(
                      fontSize: 14,
                      color: kGoldAccent,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
