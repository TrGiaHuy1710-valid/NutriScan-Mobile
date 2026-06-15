# Backend / Bloc / AI Service Report

Date: 2026-06-14

## 1. Why continuous testing failed

The app code was not the root cause of the latest continuous test failure.

Observed failure:

```text
PathExistsException: Cannot copy file to build/native_assets/windows/sqlite3.dll
OS Error: Cannot create a file when that file already exists
```

Cause:

- `sqflite_common_ffi` uses a native `sqlite3.dll` on Windows.
- Previous `flutter test` runs timed out and left `flutter_tester` / Dart VM processes alive.
- Those processes kept the generated native SQLite asset locked.
- Flutter then crashed while copying `sqlite3.dll` into `build/native_assets/windows`.

What fixes it:

- Stop the stale Flutter/Dart test processes.
- Delete/rebuild the generated native asset.
- Run tests again.

This is an environment/build-artifact lock issue, not a Clean Architecture issue.

## 2. Why backend should not be "inside Bloc"

Bloc/Cubit should not own backend/database implementation.

Correct flow:

```text
UI
-> Cubit / Bloc
-> UseCase
-> Repository Interface
-> Repository Implementation
-> DataSource / SQLite / API / AI client
```

Wrong flow:

```text
UI
-> Bloc
-> raw SQLite / HTTP / AI SDK directly
```

Reason:

- Bloc should manage UI state.
- UseCases hold app actions.
- Repositories hide SQLite/API details.
- Data sources talk to actual storage/services.

Current status after refactor:

- Auth: `AuthCubit -> UseCases -> AuthRepository -> SqliteAuthRepository`
- Nutrition: `NutritionCubit -> UseCases -> NutritionRepository -> SqliteNutritionRepository`
- Workout: `WorkoutCubit -> UseCases -> WorkoutRepository -> SqliteWorkoutRepository`
- Food Discover / Bought Today: `FoodDiscoverCubit -> UseCases -> FoodDiscoverRepository -> SqliteBoughtFoodRepository`

## 3. Backend status

Current "backend" is local-device backend only:

- SQLite local database.
- No server API.
- No Firebase.
- No cloud sync.
- No auth server.
- No real password security.

SQLite tables:

- `auth_users`
- `auth_session`
- `meal_logs`
- `bought_food_items`
- `scheduled_workout`

## 4. AI service backend status

There is no real AI service implemented yet.

Current scan features are mock only:

- `ScanFoodPage`
- `ScanIngredientPage`
- `ScanBarcodePage`
- `mock_food_scan_data.dart`
- `MockScanResultView`

Current AI-related behavior:

- No AI API call.
- No OCR call.
- No model integration.
- No API key.
- No server-side AI proxy.
- No image upload pipeline.

Recommended future AI architecture:

```text
FoodScanCubit
-> ScanFoodImageUseCase
-> FoodScanRepository
-> AiFoodScanRemoteDataSource
-> Backend API endpoint
-> AI provider
```

Important:

- The Flutter app should not store real AI API keys.
- AI calls should go through a backend endpoint later.
- AI results should never auto-save; user confirmation remains required.

## 5. Immediate next steps

1. Clean stale Flutter test processes / native asset lock.
2. Run full `flutter test`.
3. Add real data sources under each repository if the local SQLite slice remains stable.
4. Add AI service as a new vertical slice only after scan mock flow is stable.
