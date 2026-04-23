import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BookingInvoiceView extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingInvoiceView({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        title: const Text('BOOKING INVOICE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_rounded)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.download_rounded)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  // Header with Circular Logo
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: kNavyPrimary,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('OFFICIAL INVOICE', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.black, letterSpacing: 1)),
                            Text('ID: ${bookingData['id'] ?? 'BK-99824'}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        Container(
                          height: 60,
                          width: 60,
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Image.asset('assets/images/logo.png'),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Verification Stamp Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn('BOOKING DATE', bookingData['date'] ?? 'Apr 23, 2026'),
                            _buildInfoColumn('DRAW NAME', bookingData['draw'] ?? 'DEAR MORNING'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        
                        // Ticket Details Table
                        const Text('TICKET DETAILS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 12),
                        _buildDataRow('Ticket Number', bookingData['number'] ?? '50A 12345'),
                        _buildDataRow('Series Count', '${bookingData['series'] ?? 5} Series'),
                        _buildDataRow('SEM Count', '${bookingData['sem'] ?? 5} SEM'),
                        _buildDataRow('Verified Status', 'SUCCESS', isStatus: true),
                        
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Payment Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Paid Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('₹${bookingData['amount'] ?? 175}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.black, color: kNavyPrimary)),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Signature & Stamps Area
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left Side: Authorized Signature
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Authorized Signature', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    const SizedBox(height: 8),
                                    Image.network(
                                      'https://upload.wikimedia.org/wikipedia/commons/3/3a/Jon_Kirsch%27s_Signature.png',
                                      height: 40,
                                      color: kNavyPrimary,
                                    ),
                                    Container(width: 120, height: 1, color: Colors.grey.shade300),
                                    const SizedBox(height: 4),
                                    const Text('BIKIBOOK ADMIN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                
                                // Right Side: Trust Stamp
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.green.withOpacity(0.5), width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.verified_user_rounded, color: Colors.green, size: 30),
                                      const Text('VERIFIED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.black, fontSize: 10)),
                                      const Text('TRUSTED PLATFORM', style: TextStyle(color: Colors.green, fontSize: 6)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            // Center: E-STAMP Overlay (BikiBook)
                            Opacity(
                              opacity: 0.1,
                              child: Transform.rotate(
                                angle: -0.2,
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: kNavyPrimary, width: 4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text('BIKIBOOK\nOFFICIAL\nSTAMP', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.black, fontSize: 12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Footer Security Text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24))),
                    child: const Text('This is a digitally generated invoice. No physical seal required.', textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: Colors.grey)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('THANK YOU FOR TRUSTING BIKIBOOK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildDataRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(value, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
            )
          else
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
