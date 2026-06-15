# Vertical Slice Backlog

## Slice 1: Meal Log -> Dashboard

### Priority
P0

### Flow

```text
Dashboard
-> Add Meal
-> Save Meal
-> Dashboard Updated
```

### Why

This is the core tracking loop. If users cannot log a meal and see Dashboard update, the app has no daily value.

### Implementation Order

```text
1. AddMealPage as hidden/internal screen
2. MealLog entity
3. NutritionSummary entity
4. NutritionCubit
5. NutritionRepository interface
6. FakeNutritionRepository
7. AddMealLogUseCase
8. GetTodayMealsUseCase
9. CalculateTodayNutritionUseCase
10. Dashboard summary update
11. Validation
```

### Acceptance Criteria

```text
User can add a meal in under 10 seconds.
Dashboard calories update.
Meal appears in today's list.
Meal state is local/mock.
No backend or database.
```

---

## Slice 2: Scan Product -> Bought Today -> Foods

### Priority
P0

### Flow

```text
Scan Ingredient or Scan Barcode
-> Mock detected product
-> User confirms result
-> Add to Bought Today
-> Foods / Discover updated
-> Optional Add as Meal
```

### Why

This connects scanning to a useful daily food-discovery loop.

### Entities

```text
ScannedProduct
IngredientInsight
BoughtFoodItem
MealLog
```

### Implementation Order

```text
1. ScanIngredientPage mock
2. ScanBarcodePage mock
3. ScanResultPage
4. ScannedProduct entity
5. IngredientInsight entity
6. BoughtFoodItem entity
7. FoodScanRepository interface
8. FakeFoodScanRepository
9. FoodDiscoverRepository interface
10. FakeFoodDiscoverRepository
11. ConfirmScannedProductUseCase
12. AddBoughtFoodItemUseCase
13. Foods screen bought today section update
14. Optional Add as Meal through NutritionCubit
```

### Acceptance Criteria

```text
User can open scan mock.
App shows product/food information.
App shows ingredient insights.
User can confirm product.
Confirmed product appears in Bought Today.
Recently scanned products section updates.
If edible/meal-like, user can add as meal optionally.
No real OCR/barcode/API.
```

---

## Slice 3: Profile -> Food Recommendations

### Priority
P0

### Flow

```text
Profile goal/preferences
-> Save local profile
-> Mock recommendation rules
-> Foods / Discover updates
```

### Why

Foods / Discover should feel personalized, not generic.

### Profile Inputs

```text
Name
Age range
Current body/status input
Activity level
Workout level
Food preferences
Allergies or avoid list
Main health goal
Preferred workout duration
Available equipment
Calendar connection status
```

### Recommendation Rules, MVP

```text
If protein is low today -> show normal high-protein foods like eggs, tofu, beans, yogurt.
If calories are high today -> show lighter meal ideas.
If user avoids dairy -> do not recommend milk/yogurt.
If goal is build healthy habits -> show balanced meal ideas.
If teen/young age range and weight loss goal -> show safety note and avoid strict deficit advice.
```

### Acceptance Criteria

```text
Profile can be edited with mock/local state.
Foods recommendations update from profile and nutrition summary.
Avoid list is respected in mock recommendations.
No supplement/pill/powder recommendations are automatic.
Safety note appears for teen/young strict weight goals.
```

---

## Slice 4: Workout Slot -> Schedule

### Priority
P1

### Flow

```text
Dashboard
-> Plan Workout
-> View fake free slots
-> Choose suggestion
-> Schedule
-> Dashboard shows workout
```

### Implementation Order

```text
1. FreeTimeSlot entity
2. WorkoutPlan entity
3. CalendarRepository interface
4. FakeCalendarRepository
5. WorkoutRepository interface
6. FakeWorkoutRepository
7. GetFreeTimeSlotsUseCase
8. GetWorkoutSuggestionsUseCase
9. ScheduleWorkoutUseCase
10. WorkoutCubit
11. Dashboard workout card update
```

### Acceptance Criteria

```text
App shows at least 3 fake free slots.
App suggests 10/15/20 minute workouts.
User can schedule a workout.
Dashboard shows scheduled workout.
No real Google Calendar.
```

---

## Slice 5: Meal History / Weekly Summary

### Priority
P2

### Flow

```text
Dashboard or Profile
-> Meal History
-> Last 7 days summary
```

### Acceptance Criteria

```text
Uses local/mock data first.
Shows simple weekly nutrition trend.
Does not add pressure or strict dieting language.
```

---

## Slice 6: Backend Meal API

### Priority
P2

Only after mock flow is stable.

### API

```text
GET /meals/today
POST /meals
DELETE /meals/{id}
```

### Acceptance Criteria

```text
Flutter can call API.
Meal persists after app restart.
Repository implementation can replace FakeNutritionRepository.
```

---

## Slice 7: Real Barcode / Food Product API

### Priority
P3

Only after mock scan and confirm flow is stable.

### Flow

```text
Scan barcode
-> Fetch product
-> Show product and ingredients
-> Confirm
-> Add to Bought Today
-> Optional Add as Meal
```

### Acceptance Criteria

```text
Scanner works.
Unknown barcode falls back to manual entry.
No automatic unsafe supplement recommendations.
```

---

## Slice 8: AI Food Image Estimate

### Priority
P3

Only after manual and barcode flows are stable.

### Flow

```text
Take food photo
-> AI detects candidates
-> User confirms food and portion
-> Save as meal
```

### Acceptance Criteria

```text
AI result is never saved automatically.
User can edit/confirm.
Confidence is shown.
Fallback manual entry exists.
```
