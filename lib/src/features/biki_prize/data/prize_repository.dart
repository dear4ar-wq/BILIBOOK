import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../domain/prize_ticket.dart';
import '../../../core/utils/image_utils.dart';

class PrizeRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final _uuid = const Uuid();

  Stream<List<PrizeTicket>> streamUserTickets() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _client
        .from('prize_tickets')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => PrizeTicket.fromJson(json)).toList());
  }

  Stream<List<Map<String, dynamic>>> streamUserNotifications() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _client
        .from('prize_notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  Future<void> uploadTicket({
    required File imageFile,
    required String? ticketNumbers,
    required int semCount,
    required int seriesCount,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception("User not logged in");

    // 1. Image Compression
    final compressedFile = await ImageUtils.compressImage(imageFile);
    if (compressedFile == null) throw Exception("Failed to compress image");

    // 2. Generate Unique IDs
    final ticketId = _uuid.v4();
    final ticketIdDisplay = "BK-${_uuid.v4().substring(0, 8).toUpperCase()}";
    final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    final storagePath = "$userId/$fileName";

    // 3. Upload to Storage
    await _client.storage.from('prize-tickets').upload(
          storagePath,
          compressedFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    // 4. Get Public URL
    final imageUrl = _client.storage.from('prize-tickets').getPublicUrl(storagePath);

    // 5. Insert into Database
    await _client.from('prize_tickets').insert({
      'id': ticketId,
      'user_id': userId,
      'ticket_id_display': ticketIdDisplay,
      'image_url': imageUrl,
      'ticket_numbers': ticketNumbers,
      'sem_count': semCount,
      'series_count': seriesCount,
      'status': 'pending',
    });
  }

  Future<void> claimPrize({
    required String ticketId,
    required double amount,
    required String razorpayId,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception("User not logged in");

    await _client.from('prize_payments').insert({
      'user_id': userId,
      'ticket_id': ticketId,
      'amount': amount,
      'status': 'success',
      'razorpay_payment_id': razorpayId,
    });

    // Optionally update ticket status or just let admin handle it
  }

  Future<void> addNotification({
    required String title,
    required String message,
    required String type, // 'booking', 'victory', 'system'
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('prize_notifications').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Placeholder for duplicate check
  Future<bool> isDuplicate(File imageFile) async {
    // In a real app, you might compare hashes or use AI
    // For now, we'll return false to allow testing
    return false;
  }
}
