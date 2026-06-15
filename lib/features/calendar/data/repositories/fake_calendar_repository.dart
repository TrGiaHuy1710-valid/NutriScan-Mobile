import '../../domain/entities/free_time_slot.dart';
import '../../domain/repositories/calendar_repository.dart';

class FakeCalendarRepository implements CalendarRepository {
  @override
  Future<List<FreeTimeSlot>> getFreeTimeSlots() async {
    return [
      FreeTimeSlot(
        startTime: DateTime.now().copyWith(hour: 21, minute: 10),
        endTime: DateTime.now().copyWith(hour: 21, minute: 25),
        durationMinutes: 15,
      ),
      FreeTimeSlot(
        startTime: DateTime.now().copyWith(hour: 17, minute: 30),
        endTime: DateTime.now().copyWith(hour: 18, minute: 0),
        durationMinutes: 30,
      ),
      FreeTimeSlot(
        startTime: DateTime.now().copyWith(hour: 12, minute: 15),
        endTime: DateTime.now().copyWith(hour: 13, minute: 0),
        durationMinutes: 45,
      ),
      FreeTimeSlot(
        startTime: DateTime.now().copyWith(hour: 6, minute: 30),
        endTime: DateTime.now().copyWith(hour: 7, minute: 30),
        durationMinutes: 60,
      ),
      FreeTimeSlot(
        startTime: DateTime.now().copyWith(hour: 19, minute: 0),
        endTime: DateTime.now().copyWith(hour: 20, minute: 30),
        durationMinutes: 90,
      ),
    ];
  }
}
