# AGENT.md - HealTrack Daily

## Project Goal

Build HealTrack Daily, a simple daily health tracking Flutter app.

The app helps users:
- Track daily meals.
- Estimate calories and macros at a simple, non-medical level.
- Discover food ideas and everyday products that support balanced eating.
- Mock scan food, ingredient labels, and barcodes.
- Track foods/products bought today.
- Suggest short workouts based on fake free time slots.
- Prepare for future Google Calendar, barcode, nutrition API, and AI integrations.

## Current Product Direction

The visible bottom navigation is:

```text
Home
Foods
Workout
Profile
```

Important navigation decision:
- The old visible `Meals` tab is removed.
- Meal logging stays in the app, but it is a hidden/internal flow.
- Users open Add Meal from Dashboard actions, food scan confirmation, or food recommendation actions.
- Foods / Discover becomes the second main screen.

## Foods / Discover Screen

The Foods screen is a health recommendation screen, not a shopping-first screen.

It should show mock sections such as:
- Good for today
- Easy meal ideas
- Products you scanned
- Bought today
- High protein options
- Light meal ideas
- Balanced meal ideas
- Suggested simple ingredients for home cooking

Recommendations should be based on mock profile preferences and daily nutrition status first.

## Hidden/Internal Meal Flow

These screens are internal and should not appear as main bottom navigation tabs:
- AddMealPage
- MealConfirmPage
- MealHistoryPage, optional later

Open meal flows from:
- Dashboard quick action: Add Meal
- Dashboard quick action: Scan Food
- Food scan result: Confirm as meal
- Ingredient/barcode scan result: Add as meal, optional
- Foods screen: Add recommended meal to plan

## Scan Ingredient / Barcode Flow

Use mock data first.

Flow:
```text
Open Scan Ingredient or Scan Barcode
-> Show detected product/food info
-> User reviews result
-> Confirm product
-> Add product to Foods bought today
-> Optional Add as Meal if edible/meal-like
-> Dashboard and Foods update
```

Core entities:
- ScannedProduct
- IngredientInsight
- BoughtFoodItem
- MealLog

## Development Strategy

Follow UI-first and vertical slice development:

1. Read all harness markdown files first.
2. Build UI screens first.
3. Use fake data and mock repositories first.
4. Do not build backend in early MVP tasks.
5. Do not add real Google Calendar integration yet.
6. Do not add real AI food recognition yet.
7. Complete one vertical slice before moving to another.

## Updated MVP Priorities

MVP v0: UI-first with mock data:
- Dashboard
- Foods / Discover
- Add Meal hidden/internal flow
- Scan Ingredient / Barcode mock flow
- Workout Plan
- Profile with body/status and goal input
- Mock recommendations
- No backend
- No real Google Calendar
- No real AI
- No real nutrition API

MVP v1 vertical slices:
1. Dashboard -> Add Meal -> Save -> Dashboard updated
2. Scan Ingredient/Barcode mock -> Confirm product -> Add to Bought Today -> Foods screen updated
3. Profile goal/preferences -> Foods recommendations update using mock rule-based logic
4. Workout mock slots -> Schedule workout -> Dashboard updated

## Architecture

Use Clean Architecture:

```text
UI
-> Bloc / Cubit / ViewModel
-> UseCase
-> Repository Interface
-> Repository Implementation
-> DataSource
```

Feature modules:
- dashboard
- nutrition
- food_discover
- food_scan
- workout
- calendar
- profile
- auth, later optional

Important mapping:
- `nutrition` owns MealLog, NutritionSummary, AddMealPage, MealConfirmPage.
- `food_discover` owns recommendations, bought today, recently scanned products, and food/product discovery.
- `food_scan` owns ingredient/barcode scan, ScannedProduct, IngredientInsight, and confirmation.
- `profile` owns body/status info, health goal, preferences, allergies/avoid list.
- `workout` owns workout suggestions and scheduled workouts.
- `calendar` owns fake free slots in MVP and real Google Calendar later.

## Rules

- Do not call real APIs yet.
- Do not add backend code yet.
- Do not add a real database yet.
- Do not put API keys in Flutter.
- Use mock/local data only until a vertical slice explicitly moves to backend.
- Keep UI simple and clean.
- Do not over-engineer.
- Keep screens readable and beginner-friendly.
- Every screen should have empty/loading/error-friendly layout when reasonable.
- After each task, explain changed files and how to run/test.

## Safety And Tone

- Do not frame the app around body pressure, appearance, or extreme dieting.
- Use neutral wording: health goal, energy, routine, balanced eating, movement.
- Do not generate aggressive calorie deficit plans.
- Do not encourage restrictive eating.
- For teen or young users, avoid strict weight-loss guidance and show a note that goals should be discussed with a trusted adult or qualified professional.
- Do not recommend pills, powders, or medical supplements automatically.
- If "supplementary foods" is used, it means normal foods that support nutrition, such as yogurt, eggs, beans, milk, tofu, fruit, nuts, and similar foods.
- Any real supplement/pill/powder recommendation requires explicit user confirmation and should be marked as: consult a qualified adult, doctor, or pharmacist first.

## UI Style

Use a clean health dashboard style:
- Soft cards.
- Clear primary action buttons.
- Minimal bottom navigation.
- No crowded charts in MVP.
- Friendly language.
- Simple light theme.
- White/off-white backgrounds.
- Soft pastel accents.
- Readable dark text.
- Rounded cards with enough spacing.

## Main Visible Screens

MVP visible screens:
- OnboardingPage
- DashboardPage
- FoodsDiscoverPage
- WorkoutPlanPage
- ProfilePage

Hidden/internal screens:
- AddMealPage
- MealConfirmPage
- ScanIngredientPage
- ScanBarcodePage
- ScanResultPage
- FoodProductDetailPage
- CalendarSlotsPage
- MealHistoryPage, optional later

## Required Harness Files

Before coding, read:
- docs/AGENT.md
- docs/healtrack_plan_harness/00_README.md
- docs/healtrack_plan_harness/01_one_page_plan.md
- docs/healtrack_plan_harness/02_mvp_scope.md
- docs/healtrack_plan_harness/03_main_screens.md
- docs/healtrack_plan_harness/04_development_flow.md
- docs/healtrack_plan_harness/05_solo_project_harness.md
- docs/healtrack_plan_harness/06_clean_architecture.md
- docs/healtrack_plan_harness/07_vertical_slice_backlog.md
- docs/healtrack_plan_harness/08_mock_data_and_api_contracts.md

## Output Format

When done, report:
1. What was implemented or planned.
2. Files changed.
3. How to run or validate.
4. What flow was tested or updated.
5. What remains for the next vertical slice.

Do not edit the baseline harness files repeatedly for every new idea.

When the user gives new UI/logic requirements, first convert them into a new markdown file under:

docs/changes/

Then create or update:

harness/current_task.md

Only update the main harness files when the user explicitly asks to sync the accepted changes back into the baseline plan.