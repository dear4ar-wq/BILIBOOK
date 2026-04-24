import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/models.dart';
import 'widgets/checkout_widgets.dart';
import '../../biki_prize/data/prize_repository.dart';

class CheckoutScreen extends StatefulWidget {
  final Draw draw;
  final String ticketNumber;

  const CheckoutScreen({super.key, required this.draw, required this.ticketNumber});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late Razorpay _razorpay;

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
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client.from('payments').insert({
          'user_id': user.id,
          'amount': widget.draw.ticketPrice,
          'payment_method': 'Razorpay',
          'status': 'success',
          'razorpay_payment_id': response.paymentId,
        });

        await Supabase.instance.client.from('tickets').insert({
          'user_id': user.id,
          'draw_id': widget.draw.id,
          'ticket_number': widget.ticketNumber,
          'status': 'active',
        });

        if (user != null) {
          final prizeRepo = PrizeRepository();
          await prizeRepo.addNotification(
            title: 'Ticket Purchased!',
            message: 'Your ticket ${widget.ticketNumber} for ${widget.draw.name} has been successfully booked.',
            type: 'booking',
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ticket Purchased Successfully!"), backgroundColor: Colors.green),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
        }
      }
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
      'amount': (widget.draw.ticketPrice + 1.18) * 100, // Including fees
      'name': 'BikiBook Lottery',
      'description': 'Ticket: ${widget.ticketNumber}',
      'prefill': {'contact': user.phone ?? ''},
      'theme': {'color': '#E91E63'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse ticket number if possible
    String series = "50";
    String group = "A";
    List<String> digits = ["7", "3", "7", "4", "1"];
    
    if (widget.ticketNumber.contains('-')) {
      final parts = widget.ticketNumber.split('-');
      if (parts.length == 2) {
        final prefix = parts[0];
        series = prefix.replaceAll(RegExp(r'[^0-9]'), '');
        group = prefix.replaceAll(RegExp(r'[^A-Z]'), '');
        if (group.isEmpty) group = "A";
        if (series.isEmpty) series = "50";
        
        final numPart = parts[1];
        if (numPart.length == 5) {
          digits = numPart.split('');
        }
      }
    }

    const double platformFee = 1.00;
    const double gst = 0.18;
    final total = widget.draw.ticketPrice + platformFee + gst;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const TicketAppBar(title: "Ticket Details"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Ticket Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Yellow Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC107),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.draw.name.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                              Text(
                                "FRIDAY WEEKLY LOTTERY", // Contextual label
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A1A).withOpacity(0.7),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "14-06-2024", // Hardcoded per image for now or use widget.draw.date
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                              Text(
                                "8:00 P.M. ONWARDS",
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A1A).withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // White Body
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.image_outlined, color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Nagaland State Lotteries",
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1A3B7D),
                                      ),
                                    ),
                                    Text(
                                      "Govt. of Nagaland",
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE91E63),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  "MRP ₹${widget.draw.ticketPrice}/-",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "SELECTED TICKET NUMBER",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFE91E63),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  series,
                                  style: GoogleFonts.outfit(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1A3B7D),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  group,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A3B7D),
                                  ),
                                ),
                                const Spacer(),
                                ...digits.map((d) => Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: const Color(0xFFE91E63),
                                    child: Text(
                                      d,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFFE91E63)),
                                label: const Text("Edit Number", style: TextStyle(color: Color(0xFFE91E63), fontWeight: FontWeight.bold)),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                                label: const Text("Remove", style: TextStyle(color: Colors.grey)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Serrated Edge
                    SizedBox(
                      height: 16,
                      width: double.infinity,
                      child: CustomPaint(painter: SerratedEdgePainter()),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Add Another Ticket
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1A3B7D), style: BorderStyle.none), // Simulated dashed border
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF1A3B7D).withOpacity(0.3), width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle_outline, color: Color(0xFF1A3B7D)),
                        const SizedBox(width: 8),
                        Text(
                          "Add Another Ticket",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A3B7D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Payment Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Payment Summary",
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1A3B7D)),
                    ),
                    const SizedBox(height: 16),
                    _row("Ticket Price (1 x ₹${widget.draw.ticketPrice})", "₹${widget.draw.ticketPrice.toStringAsFixed(2)}"),
                    const SizedBox(height: 8),
                    _row("Platform Fee", "₹${platformFee.toStringAsFixed(2)}"),
                    const SizedBox(height: 8),
                    _row("GST (18%)", "₹${gst.toStringAsFixed(2)}"),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Amount",
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF1A3B7D)),
                        ),
                        Text(
                          "₹${total.toStringAsFixed(2)}",
                          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: const Color(0xFF1A3B7D)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 100), // Space for bottom bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 8),
                Text(
                  "100% Secure Payment",
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _openCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Proceed to Pay ₹${total.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        Text(value, style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w700)),
      ],
    );
  }
}
