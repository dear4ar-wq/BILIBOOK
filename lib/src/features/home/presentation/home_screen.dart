import 'dart:ui';
import 'package:flutter/material.dart';
import 'draw_list_view.dart';
import '../../tickets/presentation/my_tickets_view.dart';
import '../../results/presentation/result_view.dart';
import '../../profile/presentation/profile_view.dart';
import '../../biki_prize/presentation/biki_prize_view.dart';
import '../../../core/theme/app_theme.dart';

import 'package:go_router/go_router.dart';
import '../../biki_prize/data/prize_repository.dart';

class BikiHomeScreen extends StatefulWidget {
  const BikiHomeScreen({super.key});

  @override
  State<BikiHomeScreen> createState() => _BikiHomeScreenState();
}

class _BikiHomeScreenState extends State<BikiHomeScreen> {
  int _currentIndex = 0;
  final _repository = PrizeRepository();

  final List<Widget> _views = const [
    DrawListView(),
    MyTicketsView(),
    ResultView(),
    BikiPrizeView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: kIvoryBackground,
        elevation: 0,
        title: Image.asset('assets/images/logo.png', height: 40),
        centerTitle: false,
        actions: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _repository.streamUserNotifications(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data?.length ?? 0;
              return Stack(
                children: [
                  IconButton(
                    onPressed: () => context.push('/notification_history'),
                    icon: const Icon(Icons.notifications_active_outlined, color: kNavyPrimary, size: 28),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            }
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: kNavyPrimary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          border: Border.all(color: kNavyPrimary.withOpacity(0.05)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.grid_view_rounded, "DRAWS"),
              _buildNavItem(1, Icons.confirmation_number_rounded, "TICKETS"),
              _buildNavItem(2, Icons.receipt_long_rounded, "RESULTS"),
              _buildNavItem(3, Icons.stars_rounded, "BIKIPRIZE"),
              _buildNavItem(4, Icons.person_rounded, "PROFILE"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? kGoldAccent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? kNavyPrimary : Colors.grey.shade400,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? kNavyPrimary : Colors.grey.shade400,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 4),
              Container(
                width: 4, height: 4,
                decoration: const BoxDecoration(
                  color: kGoldAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
