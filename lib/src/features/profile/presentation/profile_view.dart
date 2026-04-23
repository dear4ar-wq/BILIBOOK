import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/glass_box.dart';
import '../../admin/data/admin_repository.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final String displayName = user?.email?.split('@')[0].toUpperCase() ?? 'BIKIBOOK USER';
    final String subText = user?.phone != null && user!.phone!.isNotEmpty 
        ? user.phone! 
        : (user?.email ?? 'Sign in for Gold Access');

    return Container(
      color: kIvoryBackground,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 60),
          // Luxury Profile Header with Gold Halo
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 140, width: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kGoldAccent.withOpacity(0.3), width: 2),
                ),
              ),
              Container(
                height: 120, width: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [kNavyPrimary, kNavyDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.person_rounded, size: 60, color: kGoldAccent),
              ),
              Positioned(
                bottom: 5, right: 5,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: kGoldAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded, size: 16, color: Colors.white),
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          Text(
            displayName,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: kNavyPrimary, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text(
            subText,
            style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
          ),
          
          const SizedBox(height: 40),
          
          // Luxury Action List
          _buildProfileItem(context, Icons.security_rounded, 'KYC Verification', 'PENDING', kGoldAccent),
          _buildProfileItem(context, Icons.account_balance_wallet_rounded, 'Gold Wallet', '₹0.00', kNavyPrimary),
          _buildProfileItem(context, Icons.military_tech_rounded, 'Rewards Points', '1,250 PTS', Colors.teal),
          _buildProfileItem(context, Icons.settings_rounded, 'Account Settings', 'MANAGE', Colors.grey),
          
          const SizedBox(height: 12),
          FutureBuilder<bool>(
            future: AdminRepository().isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return GestureDetector(
                  onTap: () => context.push('/admin'),
                  child: _buildProfileItem(
                    context, 
                    Icons.admin_panel_settings_rounded, 
                    'Admin Dashboard', 
                    'CONSOLE', 
                    kNavyPrimary
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          const Spacer(),
          
          // Sign Out Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextButton.icon(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.power_settings_new_rounded),
              label: const Text('SECURE SIGN OUT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                backgroundColor: Colors.redAccent.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, IconData icon, String title, String trailing, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kNavyPrimary.withOpacity(0.03)),
          boxShadow: [
            BoxShadow(color: kNavyPrimary.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title, 
                style: const TextStyle(fontWeight: FontWeight.w800, color: kNavyPrimary, fontSize: 14),
              ),
            ),
            Text(
              trailing, 
              style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
