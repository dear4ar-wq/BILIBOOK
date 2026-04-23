import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/wallet_repository.dart';
import '../domain/withdrawal_request.dart';

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  final _repository = WalletRepository();
  double _balance = 0.0;
  List<WithdrawalRequest> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);
    try {
      final balance = await _repository.getAvailableBalance();
      final history = await _repository.getWithdrawalHistory();
      setState(() {
        _balance = balance;
        _history = history;
      });
    } catch (e) {
      debugPrint('Error loading wallet: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MY WALLET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWalletData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    _buildBalanceCard(),
                    const SizedBox(height: 40),
                    
                    // Transaction History Header
                    const Text('TRANSACTION HISTORY',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
                    const SizedBox(height: 16),
                    
                    if (_history.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: Text('No withdrawals yet', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _history.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _buildHistoryItem(_history[index]),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: kNavyPrimary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: kNavyPrimary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text('₹${_balance.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _balance >= 100 ? () => _showWithdrawDialog() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kGoldAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('WITHDRAW MONEY',
                  style: TextStyle(color: kNavyPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
          if (_balance < 100)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('* Minimum withdrawal: ₹100', style: TextStyle(color: Colors.white54, fontSize: 10)),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(WithdrawalRequest request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Withdrawal Request', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${request.amount}',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: kNavyPrimary, fontSize: 14)),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: request.status.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(request.status.displayName,
                    style: TextStyle(color: request.status.color, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    final upiController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('WITHDRAW TO UPI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 24),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Amount',
                hintText: 'Max: ₹$_balance',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: upiController,
              decoration: InputDecoration(
                labelText: 'Enter UPI ID',
                hintText: 'e.g. user@ybl',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  final upi = upiController.text.trim();
                  if (amount < 100) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimum withdrawal is ₹100')));
                    return;
                  }
                  if (upi.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter UPI ID')));
                    return;
                  }
                  
                  Navigator.pop(context);
                  setState(() => _isLoading = true);
                  try {
                    await _repository.requestWithdrawal(amount: amount, upiId: upi);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdrawal request sent!'), backgroundColor: Colors.green));
                    _loadWalletData();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                    setState(() => _isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNavyPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('CONFIRM WITHDRAWAL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
