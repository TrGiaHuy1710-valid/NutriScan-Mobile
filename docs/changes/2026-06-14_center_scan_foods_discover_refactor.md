# Change Request: Center Scan + Foods Discover Refactor

Date: 2026-06-14

## Goal

Refactor current UI and local/mock logic so scan actions are centralized and Foods remains a discovery/recommendation screen.

## Required Changes

- Use bottom navigation structure:
  - Home
  - Foods
  - Center Scan button
  - Workout
  - Profile
- Remove visible Meals tab.
- Keep Add Meal as hidden/internal flow.
- Remove separate scan quick action buttons from Home.
- Center Scan opens a bottom sheet with:
  - Scan Food
  - Scan Ingredient Label
  - Scan Barcode
  - Manual Add fallback
- Foods / Discover should show recommendations by tags, bought today, recently scanned, and custom foods.
- Recommended cards should not show confusing direct "Add Meal" buttons.
- Add Meal should include tags.
- New manual foods should be added to local/mock custom food list.
- Add a hidden HealthStatsPage / ProgressDashboardPage with simple local/mock visual cards.

## Out Of Scope

- Backend
- Database
- Google Calendar integration
- Real OCR
- Real barcode scanner
- Real AI scanning
- API keys
- Large architecture rewrite
