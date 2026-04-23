import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/biki_logo.dart';
import '../../../core/theme/glass_box.dart';

class BikiLoginScreen extends StatefulWidget {
  const BikiLoginScreen({super.key});

  @override
  State<BikiLoginScreen> createState() => _BikiLoginScreenState();
}

class _BikiLoginScreenState extends State<BikiLoginScreen> {
  bool _isLoading = false;
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && mounted) {
        context.go('/home');
      }
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      const webClientId = '42238413084-2bl7folo1bgfdntj2g3gnk1ds7uqguuk.apps.googleusercontent.com';
      
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
        scopes: ['email', 'profile'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) throw 'Login failed: No ID Token found.';

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kIvoryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Luxury Logo
                const BikiLogo(size: 140, showText: true),
                const SizedBox(height: 12),
                Text(
                  'GOLD EDITION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: kGoldAccent.withOpacity(0.8),
                    letterSpacing: 4,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Login Card
                GlassBox(
                  padding: const EdgeInsets.all(32),
                  opacity: 0.8,
                  child: Column(
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kNavyPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please sign in to continue securely',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kNavyPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 8,
                            shadowColor: kNavyPrimary.withOpacity(0.3),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.network(
                                        'https://www.gstatic.com/images/branding/product/1x/googleg_48dp.png',
                                        height: 20,
                                        width: 20,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 20, color: kNavyPrimary),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Flexible(
                                      child: Text(
                                        'Continue with Google',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(
                    'EXPLORE AS GUEST',
                    style: TextStyle(
                      color: kNavyPrimary.withOpacity(0.4),
                      letterSpacing: 2,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Trust Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user_rounded, size: 14, color: kGoldAccent.withOpacity(0.6)),
                    const SizedBox(width: 8),
                    Text(
                      'SECURED & ENCRYPTED',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}
