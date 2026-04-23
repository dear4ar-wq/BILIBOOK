import 'package:flutter/material.dart';
import '../data/admin_repository.dart';
import '../../biki_prize/domain/prize_ticket.dart';
import '../../../core/theme/app_theme.dart';
import 'prize_review_detail_view.dart';

class PrizeVerificationView extends StatefulWidget {
  const PrizeVerificationView({super.key});

  @override
  State<PrizeVerificationView> createState() => _PrizeVerificationViewState();
}

class _PrizeVerificationViewState extends State<PrizeVerificationView> {
  final _repository = AdminRepository();
  PrizeStatus? _filterStatus = PrizeStatus.pending;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<List<PrizeTicket>>(
              stream: _repository.streamAllPrizeTickets(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var tickets = snapshot.data!;
                if (_filterStatus != null) {
                  tickets = tickets.where((t) => t.status == _filterStatus).toList();
                }

                if (tickets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('Everything Clean!', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                        Text('No pending prizes to verify.', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return _buildTicketCard(ticket);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: PrizeStatus.values.map((status) {
          final isSelected = _filterStatus == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status.displayName.toUpperCase()),
              selected: isSelected,
              onSelected: (val) => setState(() => _filterStatus = val ? status : null),
              selectedColor: kGoldAccent.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? kNavyPrimary : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTicketCard(PrizeTicket ticket) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PrizeReviewDetailView(ticket: ticket)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(ticket.imageUrl, fit: BoxFit.cover),
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${ticket.semCount} SEM', 
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticket.ticketIdDisplay, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(ticket.status.icon, size: 12, color: ticket.status.color),
                      const SizedBox(width: 4),
                      Text(ticket.status.displayName, 
                        style: TextStyle(color: ticket.status.color, fontWeight: FontWeight.bold, fontSize: 10)),
                    ],
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
