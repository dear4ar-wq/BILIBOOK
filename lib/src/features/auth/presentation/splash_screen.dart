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
      backgroundColor: kIvoryBackground,
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Elegant Background Ornament
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kGoldAccent.withOpacity(0.05),
                ),
              ),
            ),
            
            // Central Branding
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BikiLogo(size: 140, showText: true),
                const SizedBox(height: 48),
                SizedBox(
                  width: 50,
                  child: LinearProgressIndicator(
                    backgroundColor: kNavyPrimary.withOpacity(0.1),
                    color: kGoldAccent,
                    minHeight: 3,
                  ),
                ),
              ],
            ),
            
            // Bottom Tagline
            Positioned(
              bottom: 60,
              left: 40,
              right: 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'EXCELLENCE IN LOTTERY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: kNavyPrimary,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'BikiBook Gold Edition',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
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
