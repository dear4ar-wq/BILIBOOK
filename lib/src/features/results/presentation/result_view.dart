import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

class ResultView extends StatelessWidget {
  const ResultView({super.key});

  Future<void> _openPdf(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kIvoryBackground,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          const Text(
            'GOLD RESULTS',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kNavyPrimary, letterSpacing: -1),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep track of your winning moments',
            style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: Supabase.instance.client
                  .from('draws')
                  .select('*')
                  .order('draw_date', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: kGoldAccent));
                }
                
                final rawData = snapshot.data ?? [];
                // Only show draws that have a result OR a pdf_url
                final draws = rawData.where((d) => d['result'] != null || d['pdf_url'] != null).toList();

                if (draws.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hourglass_empty_rounded, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No results published yet', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: draws.length,
                  itemBuilder: (context, index) {
                    final data = draws[index];
                    final dateObj = DateTime.parse(data['draw_date']);
                    final resultPdf = data['pdf_url'];
                    final winningNum = data['result'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: kNavyPrimary.withOpacity(0.05)),
                          boxShadow: [
                            BoxShadow(color: kNavyPrimary.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kGoldAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.stars_rounded, color: kGoldAccent),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['name'] ?? 'Draw Result',
                                    style: const TextStyle(fontWeight: FontWeight.w900, color: kNavyPrimary, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'WINNING NO: ${winningNum ?? 'Checking...'}',
                                    style: const TextStyle(fontSize: 12, color: kNavyPrimary, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${dateObj.day}/${dateObj.month}/${dateObj.year} ${dateObj.hour}:${dateObj.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                ],
                              ),
                            ),
                            if (resultPdf != null)
                              TextButton(
                                onPressed: () => _openPdf(resultPdf),
                                child: const Text(
                                  'VIEW PDF',
                                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
                                ),
                              )
                            else if (winningNum != null)
                              const Text(
                                'PUBLISHED',
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
                              )
                            else
                              const Text(
                                'STAY TUNED',
                                style: TextStyle(color: kGoldAccent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
