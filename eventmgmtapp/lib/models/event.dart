class Event {
  final int id;
  final String eventTitle;
  final String eventDesc;
  final String eventDate;
  final int userId;
  final String createdAt;
  final String updatedAt;

  Event({
    required this.id,
    required this.eventTitle,
    required this.eventDesc,
    required this.eventDate,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      eventTitle: json['EventTitle'],
      eventDesc: json['EventDesc'],
      eventDate: json['EventDate'],
      userId: json['user_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
