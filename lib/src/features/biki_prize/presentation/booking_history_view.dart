import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/prize_ticket.dart';
import '../data/prize_repository.dart';
import '../../../core/theme/app_theme.dart';
import 'prize_ticket_detail_view.dart';
import 'package:intl/intl.dart';

class BookingHistoryView extends StatefulWidget {
  const BookingHistoryView({super.key});

  @override
  State<BookingHistoryView> createState() => _BookingHistoryViewState();
}

class _BookingHistoryViewState extends State<BookingHistoryView> {
  final _repository = PrizeRepository();
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _fetchBookingHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    // Fetch tickets and their corresponding payments
    final response = await _supabase
        .from('prize_tickets')
        .select('*, prize_payments(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kIvoryBackground,
      appBar: AppBar(
        title: const Text('BOOKING HISTORY', 
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchBookingHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kNavyPrimary));
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No booking history found', 
                      style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final ticket = PrizeTicket.fromJson(booking);
              final payments = booking['prize_payments'] as List?;
              final isPaid = payments != null && payments.isNotEmpty;

              return _buildBookingCard(ticket, isPaid);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(PrizeTicket ticket, bool isPaid) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PrizeTicketDetailView(ticket: ticket)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kNavyPrimary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.confirmation_number_outlined, color: kNavyPrimary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ticket.ticketIdDisplay, 
                          style: const TextStyle(fontWeight: FontWeight.w900, color: kNavyPrimary, fontSize: 16)),
                      Text(DateFormat('dd MMM yyyy, hh:mm a').format(ticket.createdAt),
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                _statusBadge(ticket.status),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Status', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(isPaid ? Icons.check_circle : Icons.pending_actions, 
                            size: 14, color: isPaid ? Colors.green : Colors.orange),
                        const SizedBox(width: 4),
                        Text(isPaid ? 'SUCCESS' : 'PENDING', 
                            style: TextStyle(color: isPaid ? Colors.green : Colors.orange, 
                                fontWeight: FontWeight.w900, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Amount Paid', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('₹${ticket.claimFee.toInt()}', 
                        style: const TextStyle(fontWeight: FontWeight.w900, color: kNavyPrimary, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(PrizeStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(color: status.color, fontWeight: FontWeight.w900, fontSize: 10),
      ),
    );
  }
}
