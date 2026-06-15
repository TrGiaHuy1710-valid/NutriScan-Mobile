# Solo Project Harness Plan

This harness helps keep HealTrack Daily small and focused.

## Project Brief

```text
Product:
HealTrack Daily

One-liner:
A simple daily health tracking app for meals, food discovery, scanned products, bought-today foods, and short workouts.

Target user:
Busy beginners who want healthy habits without a complex diet app.

Main navigation:
Home, Foods, Workout, Profile

Hidden flow:
Add Meal / Meal Log

MVP:
Dashboard + Foods Discover + Add Meal internal flow + Scan mock + Workout mock + Profile preferences.

Out of scope:
Backend, database, real Google Calendar, real AI, real OCR, real barcode API, medical advice.
```

## Screen Inventory

| Screen | Visibility | Purpose | Data Source | MVP |
|---|---|---|---|---|
| OnboardingPage | Visible entry | Explain app and get preferences | Local/mock | v0 |
| DashboardPage | Main nav | Today summary and quick actions | Mock/local state | v0 |
| FoodsDiscoverPage | Main nav | Food recommendations, bought today, scanned products | Mock/local state | v0 |
| WorkoutPlanPage | Main nav | Fake free slots and workout suggestions | Fake repos | v0 |
| ProfilePage | Main nav | Body/status, goal, preferences | Local/mock | v0 |
| AddMealPage | Hidden/internal | Add manual meal | FakeNutritionRepository | v1 |
| MealConfirmPage | Hidden/internal | Confirm meal from scan/recommendation | Mock/local | v1 |
| ScanIngredientPage | Hidden/internal | Mock ingredient scan | FakeFoodScanRepository | v1 |
| ScanBarcodePage | Hidden/internal | Mock barcode scan | FakeFoodScanRepository | v1 |
| ScanResultPage | Hidden/internal | Confirm scanned product | FakeFoodScanRepository | v1 |
| FoodProductDetailPage | Hidden/internal | View product and actions | Mock/local | v1 |
| CalendarSlotsPage | Hidden/internal | Choose fake free slot | FakeCalendarRepository | v1 |
| MealHistoryPage | Optional later | History and weekly summary | Local/backend later | later |

## Vertical Slice Packets

### Slice 1: Meal Log -> Dashboard

```text
Dashboard -> Add Meal -> Save -> Dashboard updated
```

### Slice 2: Scan Product -> Bought Today -> Foods

```text
Scan Ingredient/Barcode mock -> Confirm product -> Add to Bought Today -> Foods updated
```

### Slice 3: Profile -> Recommendations

```text
Update profile preferences -> Mock rule engine -> Foods recommendations update
```

### Slice 4: Workout Schedule -> Dashboard

```text
Workout Plan -> Fake slot -> Schedule -> Dashboard updated
```

## Weekly Solo Plan

### Week 1: Navigation + UI

```text
Day 1: Update harness and screen plan
Day 2: Home/Dashboard UI
Day 3: Foods / Discover UI
Day 4: Add Meal hidden flow
Day 5: Scan mock screens
Day 6: Workout/Profile UI
Day 7: Manual validation
```

### Week 2: Mock State + Clean Slices

```text
Day 1: Nutrition slice
Day 2: Food scan + bought today slice
Day 3: Food discovery recommendation slice
Day 4: Profile preference slice
Day 5: Workout scheduler slice
Day 6: Widget tests
Day 7: Light refactor
```

### Week 3: Local Persistence, Optional

```text
Persist local meal logs and bought today if needed.
Do not build backend until mock UX is stable.
```

## Solo Rules

```text
Do one slice at a time.
Do not reintroduce Meals as a visible bottom tab.
Do not build backend early.
Do not add real APIs early.
Do not add supplement recommendation logic automatically.
Keep wording neutral and habit-focused.
```
