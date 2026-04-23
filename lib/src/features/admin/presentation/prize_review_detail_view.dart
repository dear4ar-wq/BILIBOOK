import 'package:flutter/material.dart';
import '../data/admin_repository.dart';
import '../../biki_prize/domain/prize_ticket.dart';
import '../../../core/theme/app_theme.dart';

class PrizeReviewDetailView extends StatefulWidget {
  final PrizeTicket ticket;
  const PrizeReviewDetailView({super.key, required this.ticket});

  @override
  State<PrizeReviewDetailView> createState() => _PrizeReviewDetailViewState();
}

class _PrizeReviewDetailViewState extends State<PrizeReviewDetailView> {
  final _repository = AdminRepository();
  final _prizeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prizeController.text = widget.ticket.prizeAmount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavyPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('VERIFY SUBMISSION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Image.network(widget.ticket.imageUrl, fit: BoxFit.contain),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.ticket.ticketIdDisplay, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kNavyPrimary)),
                        Text('Current Status: ${widget.ticket.status.displayName}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: kGoldAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                      child: Text('${widget.ticket.semCount} SEM', style: const TextStyle(color: kGoldAccent, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('SET PRIZE AMOUNT (INR)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: _prizeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kNavyPrimary),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        label: 'REJECT',
                        color: Colors.redAccent,
                        icon: Icons.close_rounded,
                        onPressed: () => _updateStatus(PrizeStatus.rejected),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        label: 'APPROVE',
                        color: Colors.green,
                        icon: Icons.check_rounded,
                        onPressed: () => _updateStatus(PrizeStatus.approved),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _updateStatus(PrizeStatus.verifying),
                    child: const Text('MARK AS VERIFYING', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String label, required Color color, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Future<void> _updateStatus(PrizeStatus status) async {
    setState(() => _isLoading = true);
    try {
      final amount = double.tryParse(_prizeController.text) ?? 0.0;
      await _repository.updatePrizeStatus(
        ticketId: widget.ticket.id,
        status: status,
        prizeAmount: amount,
        userId: widget.ticket.userId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to ${status.displayName}')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
