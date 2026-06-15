# Development Flow

## Principle

Build HealTrack Daily with UI-first, mock-data-first, vertical slices.

Do not build backend, database, real Google Calendar, real OCR, real barcode API, real nutrition API, or real AI until the relevant mock slice is stable.

## Updated Flow

```text
1. Keep harness updated.
2. Build visible navigation: Home, Foods, Workout, Profile.
3. Keep Add Meal as hidden/internal flow.
4. Build mock data and simple local state.
5. Complete one vertical slice.
6. Validate with manual test and widget test.
7. Refactor lightly into Clean Architecture.
8. Move to the next vertical slice.
```

## MVP v0 UI Order

```text
1. DashboardPage
2. FoodsDiscoverPage
3. AddMealPage as internal flow
4. ScanIngredientPage and ScanBarcodePage as mock flows
5. WorkoutPlanPage
6. ProfilePage
```

## MVP v1 Vertical Slice Order

```text
1. Dashboard -> Add Meal -> Save -> Dashboard updated
2. Scan Ingredient/Barcode mock -> Confirm product -> Add to Bought Today -> Foods updated
3. Profile goal/preferences -> Foods recommendations update
4. Workout mock slots -> Schedule workout -> Dashboard updated
```

## How To Apply Clean Architecture

For each slice:

```text
UI
-> Cubit / ViewModel
-> UseCase
-> Repository Interface
-> Fake Repository
-> Mock data source
```

Only add real repository implementations after the mock feature is validated.

## Validation Checklist

Every slice should answer:

```text
Can the user complete the flow?
Does local/mock state update correctly?
Does Dashboard or Foods reflect the change?
Are empty/loading/error states acceptable?
Did we avoid real API calls and keys?
Did we avoid unsafe health wording?
```

## Safety Checklist

Before shipping any food/profile recommendation copy:

```text
No body-shaming.
No appearance pressure.
No aggressive calorie deficit.
No restrictive eating instructions.
No automatic pill/powder/supplement recommendation.
Teen/young users get a trusted adult/professional note for weight goals.
```
