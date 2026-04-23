import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bikibook/src/features/auth/presentation/login_screen.dart';
import 'package:bikibook/src/features/auth/presentation/splash_screen.dart';
import 'package:bikibook/src/features/home/presentation/home_screen.dart';
import 'package:bikibook/src/features/tickets/presentation/ticket_details_screen.dart';
import 'package:bikibook/src/features/checkout/presentation/checkout_screen.dart';
import 'package:bikibook/src/features/biki_prize/presentation/biki_prize_view.dart';
import 'package:bikibook/src/features/biki_prize/presentation/upload_ticket_view.dart';
import 'package:bikibook/src/features/biki_prize/presentation/prize_ticket_detail_view.dart';
import 'package:bikibook/src/features/biki_prize/presentation/notification_history_view.dart';
import 'package:bikibook/src/features/biki_prize/domain/prize_ticket.dart';
import 'package:bikibook/src/models/models.dart';
import 'package:bikibook/src/features/admin/presentation/admin_dashboard_view.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const BikiLoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const BikiHomeScreen(),
      ),
      GoRoute(
        path: '/ticket_details',
        builder: (context, state) {
          final draw = state.extra as Draw;
          return TicketDetailsScreen(draw: draw);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final draw = extra['draw'] as Draw;
          final ticketNumber = extra['ticketNumber'] as String;
          return CheckoutScreen(draw: draw, ticketNumber: ticketNumber);
        },
      ),
      GoRoute(
        path: '/biki_prize',
        builder: (context, state) => const BikiPrizeView(),
      ),
      GoRoute(
        path: '/upload_ticket',
        builder: (context, state) => const UploadTicketView(),
      ),
      GoRoute(
        path: '/prize_ticket_details',
        builder: (context, state) {
          final ticket = state.extra as PrizeTicket;
          return PrizeTicketDetailView(ticket: ticket);
        },
      ),
      GoRoute(
        path: '/notification_history',
        builder: (context, state) => const NotificationHistoryView(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardView(),
      ),
      // Future routes can be added here
    ],
  );
});
