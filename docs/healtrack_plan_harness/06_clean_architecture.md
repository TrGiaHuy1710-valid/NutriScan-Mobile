# Clean Architecture for HealTrack Daily

## 1. Kiến trúc tổng quan

```text
UI
  -> Bloc / ViewModel
  -> UseCase
  -> Repository Interface
  -> Repository Implementation
  -> DataSource
  -> API / Database / Google Calendar / AI Service
```

## 2. Cấu trúc thư mục Flutter đề xuất

```text
lib/
  main.dart
  app.dart

  core/
    config/
      app_config.dart
    constants/
      app_constants.dart
    errors/
      failures.dart
      exceptions.dart
    routes/
      app_router.dart
    theme/
      app_theme.dart
    utils/
      date_time_utils.dart
      nutrition_utils.dart
    di/
      injection_container.dart

  features/
    auth/
      presentation/
      application/
      domain/
      data/

    dashboard/
      presentation/
      application/
      domain/
      data/

    nutrition/
      presentation/
      application/
      domain/
      data/

    food_scan/
      presentation/
      application/
      domain/
      data/

    workout/
      presentation/
      application/
      domain/
      data/

    calendar/
      presentation/
      application/
      domain/
      data/

    profile/
      presentation/
      application/
      domain/
      data/
```

---

## 3. Feature: Nutrition

```text
nutrition/
  presentation/
    pages/
      add_meal_page.dart
      meal_log_page.dart
      nutrition_summary_page.dart
    widgets/
      meal_card.dart
      macro_summary_card.dart
    bloc/
      nutrition_bloc.dart
      nutrition_event.dart
      nutrition_state.dart

  application/
    usecases/
      add_meal_log_usecase.dart
      get_today_meals_usecase.dart
      calculate_today_nutrition_usecase.dart
      delete_meal_log_usecase.dart

  domain/
    entities/
      meal_log.dart
      nutrition_fact.dart
      macro.dart
    repositories/
      nutrition_repository.dart

  data/
    models/
      meal_log_model.dart
      nutrition_fact_model.dart
    datasources/
      nutrition_remote_datasource.dart
      nutrition_local_datasource.dart
    repositories/
      nutrition_repository_impl.dart
      fake_nutrition_repository.dart
```

### Luồng Add Meal

```text
AddMealPage
→ NutritionBloc
→ AddMealLogUseCase
→ NutritionRepository
→ FakeNutritionRepository / NutritionRepositoryImpl
→ DataSource
```

---

## 4. Feature: Workout

```text
workout/
  presentation/
    pages/
      workout_plan_page.dart
      workout_detail_page.dart
    widgets/
      workout_suggestion_card.dart
    bloc/
      workout_bloc.dart

  application/
    usecases/
      get_workout_suggestions_usecase.dart
      schedule_workout_usecase.dart
      complete_workout_usecase.dart

  domain/
    entities/
      workout_plan.dart
      workout_exercise.dart
      workout_preference.dart
    repositories/
      workout_repository.dart

  data/
    models/
      workout_plan_model.dart
    datasources/
      workout_local_datasource.dart
      workout_remote_datasource.dart
    repositories/
      workout_repository_impl.dart
      fake_workout_repository.dart
```

---

## 5. Feature: Calendar

```text
calendar/
  presentation/
    pages/
      calendar_slots_page.dart
    bloc/
      calendar_bloc.dart

  application/
    usecases/
      get_free_time_slots_usecase.dart
      create_calendar_event_usecase.dart

  domain/
    entities/
      free_time_slot.dart
      calendar_event.dart
    repositories/
      calendar_repository.dart

  data/
    models/
      free_time_slot_model.dart
      calendar_event_model.dart
    datasources/
      google_calendar_datasource.dart
      fake_calendar_datasource.dart
    repositories/
      calendar_repository_impl.dart
      fake_calendar_repository.dart
```

### Luồng Schedule Workout

```text
WorkoutPlanPage
→ CalendarBloc get free slots
→ WorkoutBloc suggest workout
→ ScheduleWorkoutUseCase
→ WorkoutRepository
→ CalendarRepository
→ Google Calendar / Fake Calendar
```

---

## 6. Feature: Food Scan

```text
food_scan/
  presentation/
    pages/
      scan_ingredient_page.dart
      scan_result_page.dart
    bloc/
      food_scan_bloc.dart

  application/
    usecases/
      scan_ingredient_usecase.dart
      analyze_ingredient_usecase.dart
      confirm_scanned_food_usecase.dart

  domain/
    entities/
      scanned_food.dart
      ingredient_insight.dart
    repositories/
      food_scan_repository.dart

  data/
    models/
      scanned_food_model.dart
      ingredient_insight_model.dart
    datasources/
      ocr_datasource.dart
      barcode_datasource.dart
      open_food_facts_datasource.dart
      ai_food_scan_datasource.dart
    repositories/
      food_scan_repository_impl.dart
      fake_food_scan_repository.dart
```

---

## 7. Dependency Injection

MVP đăng ký fake trước:

```text
NutritionRepository -> FakeNutritionRepository
WorkoutRepository -> FakeWorkoutRepository
CalendarRepository -> FakeCalendarRepository
FoodScanRepository -> FakeFoodScanRepository
```

Sau khi slice ổn thì đổi:

```text
NutritionRepository -> NutritionRepositoryImpl
CalendarRepository -> CalendarRepositoryImpl
FoodScanRepository -> FoodScanRepositoryImpl
```

---

## 8. Rule quan trọng

```text
UI không gọi API trực tiếp.
Bloc không gọi Firebase/Google Calendar trực tiếp.
UseCase chỉ gọi Repository Interface.
RepositoryImpl gọi DataSource.
DataSource mới biết HTTP/Firebase/Google API.
Domain không import Flutter/Firebase/HTTP.
```
