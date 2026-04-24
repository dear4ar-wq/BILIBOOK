import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../domain/prize_ticket.dart';
import '../data/prize_repository.dart';
import '../../../core/theme/app_theme.dart';
import 'upload_ticket_view.dart';
import 'prize_ticket_detail_view.dart';
import 'notification_history_view.dart';

class BikiPrizeView extends StatefulWidget {
  const BikiPrizeView({super.key});

  @override
  State<BikiPrizeView> createState() => _BikiPrizeViewState();
}

class _BikiPrizeViewState extends State<BikiPrizeView> {
  final _repository = PrizeRepository();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kIvoryBackground,
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'BIKIPRIZE',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: kNavyPrimary,
                                letterSpacing: -1),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => context.push('/booking_history'),
                                icon: const Icon(Icons.history_rounded,
                                    color: kNavyPrimary, size: 28),
                              ),
                              IconButton(
                                onPressed: () => context.push('/notification_history'),
                                icon: const Icon(Icons.notifications_active_outlined,
                                    color: kNavyPrimary, size: 28),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Submit your tickets for verification & claim rewards',
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              StreamBuilder<List<PrizeTicket>>(
                stream: _repository.streamUserTickets(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final tickets = snapshot.data ?? [];

                  if (tickets.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined,
                                size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'No tickets submitted yet',
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final ticket = tickets[index];
                          return _buildTicketCard(ticket);
                        },
                        childCount: tickets.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          Positioned(
            bottom: 100,
            left: 24,
            right: 24,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/upload_ticket'),
              icon: const Icon(Icons.add_a_photo_rounded),
              label: const Text('UPLOAD TICKET PHOTO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavyPrimary,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(PrizeTicket ticket) {
    return GestureDetector(
      onTap: () => context.push('/prize_ticket_details', extra: ticket),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: kNavyPrimary.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                ticket.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.ticketIdDisplay,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: kNavyPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ticket.semCount} SEM • ₹${ticket.claimFee.toInt()} Fee',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: ticket.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                ticket.status.displayName.toUpperCase(),
                style: TextStyle(
                  color: ticket.status.color,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
