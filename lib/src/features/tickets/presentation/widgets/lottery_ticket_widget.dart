import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LotteryTicketWidget extends StatelessWidget {
  final String ticketNumber;
  final String drawName;
  final String drawDate;
  final String drawTime;
  final double price;

  const LotteryTicketWidget({
    super.key,
    required this.ticketNumber,
    required this.drawName,
    required this.drawDate,
    required this.drawTime,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7), // Light yellow paper feel
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Background Pattern (Simulated)
            Positioned.fill(
              child: CustomPaint(
                painter: TicketBackgroundPainter(),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Gov Logo Placeholder & Agency Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.account_balance, size: 20, color: Color(0xFFD81B60)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'NAGALAND STATE LOTTERIES',
                            style: GoogleFonts.roboto(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD81B60),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Govt. of Nagaland',
                            style: GoogleFonts.roboto(
                              fontSize: 8,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Main Branding "DEAR"
                  Text(
                    'DEAR',
                    style: GoogleFonts.poppins(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFD81B60),
                      height: 1,
                    ),
                  ),
                  
                  Text(
                    drawName.toUpperCase(),
                    style: GoogleFonts.roboto(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFD81B60),
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Prize & Date Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'First Prize',
                              style: GoogleFonts.roboto(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            Text(
                              '1 CRORE',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.blue.shade900,
                                height: 1,
                              ),
                            ),
                            Text(
                              '(Including Super Prize Amount)',
                              style: GoogleFonts.roboto(
                                fontSize: 6,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFFD81B60),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Price',
                              style: GoogleFonts.roboto(fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '₹${price.toInt()}/-',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(color: Colors.black12, height: 20),
                  
                  // Bottom Row: Ticket Number & QR Placeholder
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TICKET NUMBER',
                            style: GoogleFonts.roboto(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Text(
                              ticketNumber,
                              style: GoogleFonts.courierPrime(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black12),
                        ),
                        child: const Icon(Icons.qr_code, size: 30, color: Colors.black54),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Draw Details
                  Text(
                    'Draw on $drawDate $drawTime onwards',
                    style: GoogleFonts.roboto(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
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

class TicketBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw some diagonal lines/patterns
    for (var i = -size.height; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
    
    final textPaint = Paint()..color = const Color(0xFFD81B60).withOpacity(0.03);
    // Add text watermark would be here, but using circles/dots for now
    for (var x = 0.0; x < size.width; x += 30) {
      for (var y = 0.0; y < size.height; y += 30) {
        canvas.drawCircle(Offset(x, y), 1, textPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
