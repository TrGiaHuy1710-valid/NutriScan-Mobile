# Current Task: Local Auth Continuity

## Scope

Local SQLite auth continuity only. Do not add backend server, cloud sync, OCR, barcode scanner, Google Calendar, AI, or API keys.

## Acceptance Criteria

- SQLite seeds a fixed local demo account.
- User can log in with `huy@example.com` / `demo123`.
- User can create a new local account from the Login screen.
- Local SQLite schema is ensured on create, upgrade, open, and existing open DB access.
- Android/iOS use `sqflite`; desktop/test use `sqflite_common_ffi`.
- Login status is visible after a successful login or restored session.
- Existing local auth session can continue into the app without requiring onboarding again.
- Existing Dashboard, Foods, Scan, Workout, and Health Stats flows remain unchanged.
- No backend server, OCR, barcode scanner, Google Calendar, or AI integration.

## Verification Note

`dart --version`, `flutter analyze`, and `flutter pub get` currently time out in this workspace because old Dart/Flutter processes are still running. Stop those processes or restart the terminal/IDE before verification.

---

# Current Task: Workout UI Enhancement (Local Mock Data Only)

## Scope
Workout UI enhancement only. Do NOT modify or break the local auth continuity task. Do not add backend services, OCR, barcode scanner, Google Calendar API calls, or AI integrations. Use local mock data only.

## Acceptance Criteria
- Create `WorkoutSuggestionScreen` matching selected free time slots.
- Make Free Time Today section on `WorkoutPlanPage` interactive using chips/cards.
- Implement scheduling validation comparing workout duration with selected free time (with warning dialog/snackbar).
- Enhance Today's Schedule section to support mock Google Calendar events and scheduled workouts, using badges to distinguish them.
- Add multi-day Workout Plan Timeline (horizontal cards/timeline) supporting Today, Tomorrow, Next 3 Days, and Next 7 Days filters.
- Persist scheduled workouts locally using the existing SQLite database or local repository state.
- Ensure consistent UI styling matching the app's clean light theme.

