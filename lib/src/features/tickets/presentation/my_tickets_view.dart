import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MyTicketsView extends StatelessWidget {
  const MyTicketsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kIvoryBackground,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          const Text(
            'MY GOLD TICKETS',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kNavyPrimary, letterSpacing: -1),
          ),
          const SizedBox(height: 8),
          Text(
            'Your current active participations',
            style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 2,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: kNavyPrimary.withOpacity(0.08), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: kNavyPrimary.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: kNavyPrimary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'DRAW ID #99283',
                                style: TextStyle(color: kGoldAccent, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.teal.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(color: Colors.teal, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Super Evening Special',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kNavyPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'NUMBERS: 12 - 45 - 67 - 89',
                          style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                        ),
                        const Divider(height: 40, color: kNavyPrimary),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey.shade400),
                            const SizedBox(width: 8),
                            Text(
                              'TOMORROW 8:00 PM',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: kNavyPrimary,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: kNavyPrimary, width: 1.5)),
                              ),
                              child: const Text('VIEW PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
