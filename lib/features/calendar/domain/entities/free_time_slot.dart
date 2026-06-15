class FreeTimeSlot {
  const FreeTimeSlot({
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
  });

  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
}
