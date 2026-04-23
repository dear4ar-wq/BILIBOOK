import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/models.dart';
import '../../../core/theme/app_theme.dart';

class DrawListView extends StatelessWidget {
  const DrawListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kIvoryBackground,
      body: CustomScrollView(
        slivers: [
          // Luxury Premium Header
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: kNavyPrimary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
              title: Text(
                'BikiBook Gold',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white),
              ),
              background: Stack(
                children: [
                  // Abstract Gold Ornaments
                  Positioned(
                    right: -30, bottom: -30,
                    child: Icon(Icons.stars_rounded, size: 200, color: kGoldAccent.withOpacity(0.1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: kGoldAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'SUPREME MODEL 3.0',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'FEATURED DRAWS',
                        style: TextStyle(color: kNavyPrimary, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14),
                      ),
                      Icon(Icons.tune_rounded, color: kNavyPrimary.withOpacity(0.5), size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Supabase Draws List
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: Supabase.instance.client.from('draws').select().order('draw_date'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(color: kGoldAccent),
                        ));
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: kNavyPrimary.withOpacity(0.05)),
                          ),
                          child: const Center(child: Text("No Special Draws Today", style: TextStyle(color: Colors.grey))),
                        );
                      }

                      return Column(
                        children: snapshot.data!.map((data) => _buildDrawCard(context, data)).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 48),
                  const Text(
                    'GOLD DASHBOARD',
                    style: TextStyle(color: kNavyPrimary, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // High-Contrast Action Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: [
                      _buildActionCard(context, 'Wallet', Icons.account_balance_wallet_rounded, kNavyPrimary),
                      _buildActionCard(context, 'History', Icons.history_rounded, kGoldAccent),
                      _buildActionCard(context, 'Win Analysis', Icons.analytics_rounded, Colors.teal),
                      _buildActionCard(context, 'VIP Support', Icons.headset_mic_rounded, Colors.indigo),
                    ],
                  ),
                  
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawCard(BuildContext context, Map<String, dynamic> data) {
    final dateObj = DateTime.parse(data['draw_date']);
    final timeStr = "${dateObj.hour}:${dateObj.minute.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          final draw = Draw(
            id: data['id'],
            name: data['name'],
            date: dateObj,
            ticketPrice: data['ticket_price'].toInt(),
          );
          context.push('/ticket_details', extra: draw);
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: kNavyPrimary.withOpacity(0.08), width: 1.5),
            boxShadow: [
              BoxShadow(color: kNavyPrimary.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 56, width: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kNavyPrimary, kNavyDeep]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.confirmation_number_rounded, color: kGoldAccent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'], 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kNavyPrimary),
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NEXT DRAW AT $timeStr',
                      style: const TextStyle(color: kGoldAccent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   const Text('ENTRY', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900)),
                  Text(
                    '₹${data["ticket_price"]}',
                    style: const TextStyle(color: kNavyPrimary, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kNavyPrimary.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: kNavyPrimary.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: kNavyPrimary, fontWeight: FontWeight.w900, fontSize: 14)),
        ],
      ),
    );
  }
}
