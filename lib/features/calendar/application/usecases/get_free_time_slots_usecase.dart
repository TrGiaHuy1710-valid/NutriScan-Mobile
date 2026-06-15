import '../../domain/entities/free_time_slot.dart';
import '../../domain/repositories/calendar_repository.dart';

class GetFreeTimeSlotsUseCase {
  const GetFreeTimeSlotsUseCase(this._repository);

  final CalendarRepository _repository;

  Future<List<FreeTimeSlot>> call() {
    return _repository.getFreeTimeSlots();
  }
}
