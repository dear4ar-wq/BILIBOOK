import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/models.dart';
import '../../biki_prize/domain/prize_ticket.dart';

class AdminRepository {
  final _supabase = Supabase.instance.client;

  // --- Auth & Role Check ---
  
  Future<bool> isAdmin() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    try {
      final response = await _supabase
          .from('users')
          .select('is_admin')
          .eq('id', user.id)
          .single();
      
      return response['is_admin'] as bool? ?? false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // --- Draw Management ---

  Stream<List<Draw>> streamAllDraws() {
    return _supabase
        .from('draws')
        .stream(primaryKey: ['id'])
        .order('draw_date', ascending: false)
        .map((data) => data.map((json) => Draw(
          id: json['id'],
          name: json['name'],
          date: DateTime.parse(json['draw_date']),
          ticketPrice: (json['ticket_price'] as num).toInt(),
          result: json['result'],
        )).toList());
  }

  Future<void> createDraw({
    required String name,
    required DateTime date,
    required int price,
  }) async {
    await _supabase.from('draws').insert({
      'name': name,
      'draw_date': date.toIso8601String(),
      'ticket_price': price,
    });
  }

  Future<void> updateDraw({
    required String id,
    String? name,
    DateTime? date,
    int? price,
    String? result,
  }) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (date != null) updates['draw_date'] = date.toIso8601String();
    if (price != null) updates['ticket_price'] = price;
    if (result != null) updates['result'] = result;

    await _supabase.from('draws').update(updates).eq('id', id);
  }

  Future<void> deleteDraw(String id) async {
    await _supabase.from('draws').delete().eq('id', id);
  }

  // --- Prize Management ---

  Stream<List<PrizeTicket>> streamAllPrizeTickets() {
    return _supabase
        .from('prize_tickets')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => PrizeTicket.fromJson(json)).toList());
  }

  Future<void> updatePrizeStatus({
    required String ticketId,
    required PrizeStatus status,
    required double prizeAmount,
    required String userId,
  }) async {
    // 1. Update the ticket status and amount
    await _supabase.from('prize_tickets').update({
      'status': status.name,
      'prize_amount': prizeAmount,
    }).eq('id', ticketId);

    // 2. Create a notification for the user
    String title = '';
    String message = '';

    if (status == PrizeStatus.approved) {
      title = 'Prize Approved! 🎉';
      message = 'Your ticket has been approved for a prize of ₹$prizeAmount. You can now claim it in the BikiPrize section.';
    } else if (status == PrizeStatus.rejected) {
      title = 'Verification Failed';
      message = 'Unfortunately, your ticket verification failed. Please contact support for more details.';
    } else if (status == PrizeStatus.verifying) {
      title = 'Verification Started';
      message = 'Admin has started verifying your ticket. Please wait for the final result.';
    }

    if (title.isNotEmpty) {
      await _supabase.from('prize_notifications').insert({
        'user_id': userId,
        'ticket_id': ticketId,
        'title': title,
        'message': message,
      });
    }
  }

  Stream<List<Map<String, dynamic>>> streamAllTickets() {
    return _supabase
        .from('tickets')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          final List<Map<String, dynamic>> bookings = [];
          for (var item in data) {
            try {
              // Join Draw info
              final drawResp = await _supabase.from('draws').select('name').eq('id', item['draw_id']).single();
              // Join User info
              final userResp = await _supabase.from('users').select('phone_number').eq('id', item['user_id']).single();
              
              bookings.add({
                ...item,
                'draw_name': drawResp['name'],
                'user_phone': userResp['phone_number'],
              });
            } catch (e) {
              print('Error joining data for ticket ${item['id']}: $e');
              bookings.add(item);
            }
          }
          return bookings;
        });
  }

  Future<void> updateTicketStatus(String ticketId, String status) async {
    await _supabase.from('tickets').update({'status': status}).eq('id', ticketId);
  }
}
