import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../models/models.dart';
import 'widgets/lottery_ticket_widget.dart';

class TicketDetailsScreen extends StatefulWidget {
  final Draw draw;

  const TicketDetailsScreen({super.key, required this.draw});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  final List<String> _availableNumbers = [
    '50A-73741', '96B-98765', '11C-55555', '22D-11111', 
    '33E-22222', '44F-33333', '55G-44444', '66H-55555',
    '77I-66666', '88J-77777',
  ];

  String? _selectedNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          "Select Ticket",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Live Preview Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "LIVE PREVIEW",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE91E63),
                        letterSpacing: 1.5,
                      ),
                    ),
                    if (_selectedNumber == null)
                      Text(
                        "Please select a number",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Opacity(
                  opacity: _selectedNumber == null ? 0.5 : 1.0,
                  child: LotteryTicketWidget(
                    ticketNumber: _selectedNumber ?? '00X-00000',
                    drawName: widget.draw.name,
                    drawDate: "14-06-2024", // Use formatted date in real app
                    drawTime: "8:00 P.M.",
                    price: widget.draw.ticketPrice.toDouble(),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Selection Section
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "AVAILABLE NUMBERS",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _availableNumbers.length,
                      itemBuilder: (context, index) {
                        final number = _availableNumbers[index];
                        final isSelected = _selectedNumber == number;
                        
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                            child: Material(
                              color: isSelected ? const Color(0xFFE91E63) : Colors.white,
                              elevation: isSelected ? 4 : 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                                ),
                              ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedNumber = number;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Center(
                                child: Text(
                                  number,
                                  style: GoogleFonts.courierPrime(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _selectedNumber == null
              ? null
              : () {
                  context.push('/checkout', extra: {
                    'draw': widget.draw,
                    'ticketNumber': _selectedNumber,
                  });
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            disabledBackgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            "Review & Pay ₹${widget.draw.ticketPrice}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
