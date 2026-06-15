import '../entities/free_time_slot.dart';

abstract class CalendarRepository {
  Future<List<FreeTimeSlot>> getFreeTimeSlots();
}
