# Clean Architecture for HealTrack Daily

## Architecture Overview

```text
UI
  -> Cubit / Bloc / ViewModel
  -> UseCase
  -> Repository Interface
  -> Repository Implementation
  -> DataSource
  -> API / Database / Calendar / AI later
```

MVP uses fake repositories and mock/local state.

## Feature Modules

```text
lib/
  main.dart
  app.dart

  core/
    config/
    constants/
    errors/
    routes/
    theme/
    utils/
    di/

  features/
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

    food_discover/
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

    auth/
      presentation/
      application/
      domain/
      data/
      # later optional
```

## Feature: Nutrition

Owns MealLog and NutritionSummary.

Add Meal is internal and not a visible bottom navigation tab.

```text
nutrition/
  presentation/
    pages/
      add_meal_page.dart
      meal_confirm_page.dart
      meal_history_page.dart # optional later
    widgets/
      meal_log_tile.dart
      macro_summary_card.dart
    cubit/
      nutrition_cubit.dart
      nutrition_state.dart

  application/
    usecases/
      add_meal_log_usecase.dart
      get_today_meals_usecase.dart
      calculate_today_nutrition_usecase.dart
      delete_meal_log_usecase.dart # later

  domain/
    entities/
      meal_log.dart
      nutrition_summary.dart
    repositories/
      nutrition_repository.dart

  data/
    repositories/
      fake_nutrition_repository.dart
      nutrition_repository_impl.dart # later
    datasources/
      nutrition_local_datasource.dart # later
      nutrition_remote_datasource.dart # later
```

Flow:

```text
Dashboard/Add action
-> AddMealPage
-> NutritionCubit
-> AddMealLogUseCase
-> NutritionRepository
-> FakeNutritionRepository
-> Dashboard updates
```

## Feature: Food Discover

Owns recommendations, bought today, recently scanned products, and visible Foods screen.

```text
food_discover/
  presentation/
    pages/
      foods_discover_page.dart
      food_product_detail_page.dart
    widgets/
      recommendation_card.dart
      bought_food_item_tile.dart
      scanned_product_tile.dart
    cubit/
      food_discover_cubit.dart
      food_discover_state.dart

  application/
    usecases/
      get_food_recommendations_usecase.dart
      get_bought_today_usecase.dart
      add_bought_food_item_usecase.dart
      get_recently_scanned_products_usecase.dart

  domain/
    entities/
      food_recommendation.dart
      recommended_meal.dart
      recommended_product.dart
      bought_food_item.dart
    repositories/
      food_discover_repository.dart

  data/
    repositories/
      fake_food_discover_repository.dart
    datasources/
      mock_food_recommendation_datasource.dart
```

Reads from:
- Profile preferences.
- Nutrition summary.
- BoughtFoodItem.
- ScannedProduct.

MVP recommendation logic is rule-based and fake.

## Feature: Food Scan

Owns ingredient and barcode scan mock flows.

```text
food_scan/
  presentation/
    pages/
      scan_ingredient_page.dart
      scan_barcode_page.dart
      scan_result_page.dart
    widgets/
      ingredient_insight_card.dart
      scanned_product_card.dart
    cubit/
      food_scan_cubit.dart
      food_scan_state.dart

  application/
    usecases/
      scan_ingredient_mock_usecase.dart
      scan_barcode_mock_usecase.dart
      confirm_scanned_product_usecase.dart

  domain/
    entities/
      scanned_product.dart
      ingredient_insight.dart
    repositories/
      food_scan_repository.dart

  data/
    repositories/
      fake_food_scan_repository.dart
    datasources/
      mock_food_scan_datasource.dart
```

Flow:

```text
Scan Ingredient/Barcode
-> Mock scan result
-> User confirms
-> ScannedProduct saved
-> BoughtFoodItem created
-> Foods screen updates
-> Optional Add as Meal through nutrition slice
```

## Feature: Profile

Owns user preferences and health context.

```text
profile/
  presentation/
    pages/
      profile_page.dart
    cubit/
      profile_cubit.dart
      profile_state.dart

  application/
    usecases/
      get_profile_usecase.dart
      update_profile_usecase.dart

  domain/
    entities/
      user_profile.dart
      health_goal.dart
      activity_level.dart
      workout_level.dart
    repositories/
      profile_repository.dart

  data/
    repositories/
      fake_profile_repository.dart
```

Profile fields:
- Name.
- Age range.
- Current body/status input.
- Activity level.
- Workout level.
- Food preferences.
- Allergies or avoid list.
- Health goal.
- Preferred workout duration.
- Available equipment.
- Calendar connection status.

## Feature: Workout

Owns workout recommendations and scheduled workouts.

```text
workout/
  presentation/
    pages/
      workout_plan_page.dart
    cubit/
      workout_cubit.dart
      workout_state.dart

  application/
    usecases/
      get_workout_suggestions_usecase.dart
      get_scheduled_workout_usecase.dart
      schedule_workout_usecase.dart

  domain/
    entities/
      workout_plan.dart
      workout_exercise.dart
    repositories/
      workout_repository.dart

  data/
    repositories/
      fake_workout_repository.dart
```

## Feature: Calendar

MVP uses fake free slots. Real Google Calendar comes later.

```text
calendar/
  presentation/
    pages/
      calendar_slots_page.dart

  application/
    usecases/
      get_free_time_slots_usecase.dart
      create_calendar_event_usecase.dart # later

  domain/
    entities/
      free_time_slot.dart
      calendar_event.dart
    repositories/
      calendar_repository.dart

  data/
    repositories/
      fake_calendar_repository.dart
      google_calendar_repository.dart # later
```

## Dependency Injection

MVP:

```text
NutritionRepository -> FakeNutritionRepository
FoodDiscoverRepository -> FakeFoodDiscoverRepository
FoodScanRepository -> FakeFoodScanRepository
ProfileRepository -> FakeProfileRepository
WorkoutRepository -> FakeWorkoutRepository
CalendarRepository -> FakeCalendarRepository
```

Later:

```text
Fake repositories can be replaced by API/database implementations without changing UI or use cases.
```

## Rules

```text
UI does not call APIs directly.
Cubit/ViewModel does not call Firebase/Google Calendar directly.
UseCase only calls repository interfaces.
RepositoryImpl calls data sources.
Domain does not import Flutter/Firebase/HTTP.
Food recommendations must respect allergies and avoid lists.
No supplement/pill/powder recommendation should be automatic.
```
