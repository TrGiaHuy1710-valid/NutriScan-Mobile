# HealTrack Daily Plan Harness

This harness is the planning source for HealTrack Daily.

## Current Product Direction

HealTrack Daily is a simple daily health tracking app focused on:
- Daily dashboard.
- Manual meal logging as an internal flow.
- Foods / Discover as a visible main screen.
- Mock food, ingredient, and barcode scanning.
- Bought-today food/product tracking.
- Profile-based food recommendations.
- Workout suggestions from fake free time slots.

## Main Navigation

```text
Home / Dashboard
Foods / Discover
Workout
Profile
```

The old visible `Meals` tab is removed.

Meal logging still exists, but it is hidden/internal and opened from:
- Dashboard Add Meal.
- Dashboard Scan Food.
- Scan result Confirm as Meal.
- Foods recommendation actions.

## Recommended Reading Order

```text
01_one_page_plan.md
02_mvp_scope.md
03_main_screens.md
04_development_flow.md
05_solo_project_harness.md
06_clean_architecture.md
07_vertical_slice_backlog.md
08_mock_data_and_api_contracts.md
09_reference_projects.md
```

## Development Rule

Keep the project UI-first and vertical-slice driven.

Do not add backend, database, real Google Calendar, real OCR, real barcode API, real nutrition API, or real AI until the mock flows are stable.

## Safety Rule

The app must focus on healthy habits, energy, balanced eating, consistency, and safe movement.

Avoid body pressure, appearance-focused language, aggressive calorie deficits, restrictive eating, or automatic supplement recommendations.
