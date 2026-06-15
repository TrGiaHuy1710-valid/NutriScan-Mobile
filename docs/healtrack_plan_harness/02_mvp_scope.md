# MVP Scope

## MVP v0: UI-first Prototype

Goal: make the app visible and clickable with mock/local data only.

### Must Have

```text
Onboarding
Dashboard
Foods / Discover
Add Meal hidden/internal flow
Scan Ingredient mock
Scan Barcode mock
Workout Plan
Profile with body/status and goal input
Fake recommendations
Fake bought-today list
Fake recently scanned products
```

### Must Not Have

```text
Backend
Database
Real Google Calendar
Real AI
Real OCR
Real barcode scanner
Real nutrition API
API keys
Medical advice
Automatic supplement recommendations
```

### Definition Of Done

```text
App opens.
Main nav shows Home, Foods, Workout, Profile.
Meal logging works as an internal flow.
Dashboard updates after adding a meal.
Scan mock can confirm a product.
Foods screen can show bought today and scanned products from mock/local state.
Workout suggestions render from fake data.
Profile captures mock preferences and health goal fields.
No real API call is made.
```

---

## MVP v1: First Working Vertical Slices

### Primary Slice: Meal Log + Dashboard

```text
Dashboard
-> Add Meal
-> Save Meal
-> Dashboard updated
```

Includes:
- Add meal manually.
- Choose meal type.
- Calculate total calories/protein/carbs/fat.
- Save in mock/local repository.

### Secondary Slice: Product Scan + Bought Today

```text
Scan Ingredient/Barcode mock
-> Confirm product
-> Add to Bought Today
-> Foods screen updated
```

Includes:
- ScannedProduct.
- IngredientInsight.
- BoughtFoodItem.
- Optional Add as Meal for edible/meal-like products.

### Third Slice: Profile-driven Food Recommendations

```text
Profile goal/preferences
-> Mock recommendation rules
-> Foods / Discover updates recommendations
```

Includes:
- Health goal.
- Activity level.
- Food preferences.
- Allergies or avoid list.
- Daily nutrition status.

### Fourth Slice: Workout Scheduler + Calendar Mock

```text
Workout Plan
-> Fake free slots
-> Schedule workout
-> Dashboard updated
```

Includes:
- FreeTimeSlot.
- WorkoutPlan.
- FakeCalendarRepository.
- FakeWorkoutRepository.

---

## Later MVP

Only after mock flows are stable:

```text
Real backend meal API
Persistent database
Real Google Calendar
Real barcode scanner
Open Food Facts API
OCR ingredient labels
AI food image estimate
Weekly summary
```

## Safety Scope

The MVP must not encourage restrictive eating or aggressive calorie deficits.

If weight goals are present, wording should remain neutral and habit-focused.

For teen or young users, strict weight-loss guidance should be avoided and the app should recommend discussing goals with a trusted adult or qualified professional.
