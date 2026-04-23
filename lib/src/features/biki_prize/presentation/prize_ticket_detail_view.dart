import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/prize_ticket.dart';
import '../data/prize_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../booking/presentation/booking_invoice_view.dart';

class PrizeTicketDetailView extends StatefulWidget {
  final PrizeTicket ticket;

  const PrizeTicketDetailView({super.key, required this.ticket});

  @override
  State<PrizeTicketDetailView> createState() => _PrizeTicketDetailViewState();
}

class _PrizeTicketDetailViewState extends State<PrizeTicketDetailView> {
  late Razorpay _razorpay;
  final _repository = PrizeRepository();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isProcessing = true);
    try {
      await _repository.claimPrize(
        ticketId: widget.ticket.id,
        amount: widget.ticket.claimFee,
        razorpayId: response.paymentId ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Prize Claimed Successfully! Processing will take some time."),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Error: ${response.message}"), backgroundColor: Colors.red),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet: ${response.walletName}");
  }

  void _openCheckout() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first!"), backgroundColor: Colors.red),
      );
      return;
    }

    var options = {
      'key': 'rzp_live_Sc2qmYR0dqMuQ3',
      'amount': widget.ticket.claimFee * 100, // Amount in paise
      'name': 'BikiBook Prize Claim',
      'description': 'Ticket: ${widget.ticket.ticketIdDisplay}',
      'prefill': {
        'contact': user.phone ?? '',
        'email': user.email ?? '',
      },
      'theme': {'color': '#10B981'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kIvoryBackground,
      appBar: AppBar(
        title: const Text('TICKET DETAILS',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: _isProcessing 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        child: Column(
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  Icon(widget.ticket.status.icon, size: 64, color: widget.ticket.status.color),
                  const SizedBox(height: 16),
                  Text(
                    widget.ticket.status.displayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: widget.ticket.status.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ticket ID: ${widget.ticket.ticketIdDisplay}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Ticket Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SUBMITTED PHOTO',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        widget.ticket.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey, size: 48),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('SEM Count', '${widget.ticket.semCount} SEM'),
                    const Divider(height: 32),
                    _buildDetailRow('Series Count', '${widget.ticket.seriesCount} Series'),
                    const Divider(height: 32),
                    _buildDetailRow('Submitted On',
                        '${widget.ticket.createdAt.day}/${widget.ticket.createdAt.month}/${widget.ticket.createdAt.year}'),
                    const Divider(height: 32),
                    _buildDetailRow('Prize Amount', '₹${widget.ticket.prizeAmount}',
                        valueColor: kGoldAccent),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // View Invoice Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingInvoiceView(
                        bookingData: {
                          'id': widget.ticket.ticketIdDisplay,
                          'date': '${widget.ticket.createdAt.day}/${widget.ticket.createdAt.month}/${widget.ticket.createdAt.year}',
                          'draw': 'OFFICIAL DRAW', 
                          'number': widget.ticket.ticketNumbers ?? 'As per Image',
                          'series': widget.ticket.seriesCount,
                          'sem': widget.ticket.semCount,
                          'amount': widget.ticket.claimFee,
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long_rounded, color: kNavyPrimary),
                label: const Text('VIEW BOOKING INVOICE', style: TextStyle(color: kNavyPrimary, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: kNavyPrimary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Claim Reward Button (Only if Approved)
            if (widget.ticket.status == PrizeStatus.approved)
              Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                  onPressed: () => _showClaimDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    shadowColor: Colors.green.withOpacity(0.3),
                  ),
                  child: const Text('CLAIM REWARD NOW',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
        Text(value,
            style: TextStyle(
                color: valueColor ?? kNavyPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 16)),
      ],
    );
  }

  void _showClaimDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Confirm Prize Claim',
            style: TextStyle(fontWeight: FontWeight.w900, color: kNavyPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rowInfo('Prize Amount', '₹${widget.ticket.prizeAmount}', color: kGoldAccent),
            const SizedBox(height: 12),
            _rowInfo('Processing Fee', '₹${widget.ticket.claimFee}'),
            const Divider(height: 32),
            Text(
              'By clicking "YES, PAY & CLAIM", you agree to pay the non-refundable processing fee of ₹${widget.ticket.claimFee} to start your prize transfer.',
              style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              _openCheckout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('YES, PAY & CLAIM'),
          ),
        ],
      ),
    );
  }

  Widget _rowInfo(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color ?? kNavyPrimary)),
      ],
    );
  }
}
