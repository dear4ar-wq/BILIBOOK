import 'package:flutter/material.dart';

enum PrizeStatus {
  pending,
  verifying,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case PrizeStatus.pending:
        return 'Pending';
      case PrizeStatus.verifying:
        return 'Verifying';
      case PrizeStatus.approved:
        return 'Approved';
      case PrizeStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case PrizeStatus.pending:
        return Colors.orange;
      case PrizeStatus.verifying:
        return Colors.blue;
      case PrizeStatus.approved:
        return Colors.green;
      case PrizeStatus.rejected:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case PrizeStatus.pending:
        return Icons.hourglass_empty_rounded;
      case PrizeStatus.verifying:
        return Icons.verified_user_rounded;
      case PrizeStatus.approved:
        return Icons.check_circle_rounded;
      case PrizeStatus.rejected:
        return Icons.cancel_rounded;
    }
  }
}

class PrizeTicket {
  final String id;
  final String userId;
  final String ticketIdDisplay; // Auto-generated ID like BK-XXXXXX
  final String imageUrl;
  final String? ticketNumbers;
  final int semCount;
  final int seriesCount;
  final PrizeStatus status;
  final double prizeAmount;
  final DateTime createdAt;

  PrizeTicket({
    required this.id,
    required this.userId,
    required this.ticketIdDisplay,
    required this.imageUrl,
    this.ticketNumbers,
    required this.semCount,
    required this.seriesCount,
    required this.status,
    required this.prizeAmount,
    required this.createdAt,
  });

  factory PrizeTicket.fromJson(Map<String, dynamic> json) {
    return PrizeTicket(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      ticketIdDisplay: json['ticket_id_display'] as String,
      imageUrl: json['image_url'] as String,
      ticketNumbers: json['ticket_numbers'] as String?,
      semCount: json['sem_count'] as int,
      seriesCount: json['series_count'] as int? ?? 1,
      status: PrizeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PrizeStatus.pending,
      ),
      prizeAmount: (json['prize_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'ticket_id_display': ticketIdDisplay,
      'image_url': imageUrl,
      'ticket_numbers': ticketNumbers,
      'sem_count': semCount,
      'series_count': seriesCount,
      'status': status.name,
      'prize_amount': prizeAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  double get claimFee {
    return (semCount * 7.0) * seriesCount;
  }
}
