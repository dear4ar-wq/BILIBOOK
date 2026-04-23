import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/withdrawal_request.dart';

class WalletRepository {
  final _client = Supabase.instance.client;

  // Calculate current available balance
  Future<double> getAvailableBalance() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0.0;

    // 1. Get total approved prize amounts
    final prizeResponse = await _client
        .from('prize_tickets')
        .select('prize_amount')
        .eq('user_id', userId)
        .eq('status', 'approved');
    
    double totalWinnings = (prizeResponse as List)
        .fold(0.0, (sum, item) => sum + (item['prize_amount'] as num).toDouble());

    // 2. Get total completed withdrawals
    final withdrawalResponse = await _client
        .from('withdrawals')
        .select('amount')
        .eq('user_id', userId)
        .eq('status', 'completed');

    double totalWithdrawn = (withdrawalResponse as List)
        .fold(0.0, (sum, item) => sum + (item['amount'] as num).toDouble());

    return totalWinnings - totalWithdrawn;
  }

  // Request a withdrawal
  Future<void> requestWithdrawal({
    required double amount,
    String? upiId,
    String? bankDetails,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception("User not logged in");

    final balance = await getAvailableBalance();
    if (amount > balance) throw Exception("Insufficient balance");
    if (amount < 100) throw Exception("Minimum withdrawal is ₹100");

    await _client.from('withdrawals').insert({
      'user_id': userId,
      'amount': amount,
      'upi_id': upiId,
      'bank_details': bankDetails,
      'status': 'pending',
    });
  }

  // Get withdrawal history
  Future<List<WithdrawalRequest>> getWithdrawalHistory() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('withdrawals')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => WithdrawalRequest.fromJson(json)).toList();
  }
}
