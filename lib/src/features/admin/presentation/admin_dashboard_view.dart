import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'draw_management_view.dart';
import 'prize_verification_view.dart';
import 'booking_history_view.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kIvoryBackground,
      appBar: AppBar(
        title: const Text('ADMIN CONSOLE', 
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 18)
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kGoldAccent,
          labelColor: kNavyPrimary,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.grid_view_rounded), text: 'DRAWS'),
            Tab(icon: Icon(Icons.history_edu_rounded), text: 'BOOKINGS'),
            Tab(icon: Icon(Icons.verified_user_rounded), text: 'PRIZES'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DrawManagementView(),
          BookingHistoryView(),
          PrizeVerificationView(),
        ],
      ),
    );
  }
}
