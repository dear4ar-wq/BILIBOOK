import 'package:flutter/material.dart';

enum WithdrawalStatus {
  pending,
  processing,
  completed,
  rejected;

  String get displayName {
    switch (this) {
      case WithdrawalStatus.pending: return 'Pending';
      case WithdrawalStatus.processing: return 'Processing';
      case WithdrawalStatus.completed: return 'Completed';
      case WithdrawalStatus.rejected: return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case WithdrawalStatus.pending: return Colors.orange;
      case WithdrawalStatus.processing: return Colors.blue;
      case WithdrawalStatus.completed: return Colors.green;
      case WithdrawalStatus.rejected: return Colors.red;
    }
  }
}

class WithdrawalRequest {
  final String id;
  final String userId;
  final double amount;
  final String? upiId;
  final String? bankDetails;
  final WithdrawalStatus status;
  final DateTime createdAt;

  WithdrawalRequest({
    required this.id,
    required this.userId,
    required this.amount,
    this.upiId,
    this.bankDetails,
    required this.status,
    required this.createdAt,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      upiId: json['upi_id'] as String?,
      bankDetails: json['bank_details'] as String?,
      status: WithdrawalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WithdrawalStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
