class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
  });

  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
}
