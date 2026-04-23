class Draw {
  final String id;
  final String name;
  final DateTime date;
  final int ticketPrice;
  final String? result;
  final String? pdfUrl;

  Draw({
    required this.id,
    required this.name,
    required this.date,
    required this.ticketPrice,
    this.result,
    this.pdfUrl,
  });
}

class Ticket {
  final String id;
  final String userId;
  final String ticketNumber;
  final String drawId;
  final String status; // active, won, lost

  Ticket({
    required this.id,
    required this.userId,
    required this.ticketNumber,
    required this.drawId,
    required this.status,
  });
}
