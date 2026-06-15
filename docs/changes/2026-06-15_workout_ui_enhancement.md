# Workout UI Enhancement Plan

## Overview
Improve the Workout experience by introducing an interactive Free Time selection, suggestions matching that free time, scheduling validation, an enhanced Today's Schedule timeline (including Google Calendar events), and a multi-day Workout Plan Timeline.

## Features to Implement

### 1. Interactive Free Time Today
- Display available time slots as tappable cards or choice chips: `[15m]`, `[30m]`, `[45m]`, `[60m]`, `[90m]`.
- Provide a selected state: highlighted, elevated, primary color.
- When tapped, navigate to `WorkoutSuggestionScreen` passing the selected slot's duration and start/end times.

### 2. Workout Suggestion Screen
- Display a dedicated suggestion screen showing workouts.
- Workouts that match the selected duration will be featured prominently.
- Other workout options of different durations will be browseable to allow validation testing.
- Display workout name, duration, exercises block (Warm Up, Cardio, Stretching with block duration), estimated calories, and difficulty level.
- Actions: **Schedule Workout** and **Back**.

### 3. Schedule Validation
- When "Schedule Workout" is pressed, check: `workout duration <= selected free time`.
- If workout duration is larger, display a warning dialog/snackbar: `"Workout exceeds your available free time."` and do not schedule.
- If it fits, save the scheduled workout in the local database/state, display a success snackbar, and return.

### 4. Today's Schedule Section
- Enhanced timeline view displaying both calendar events and scheduled workouts.
- Mock Google Calendar events:
  - 09:00 - Team Meeting
  - 11:00 - Lunch
- If a workout is scheduled, show it in the timeline (e.g. 17:30 - Gym Session: 30-Min Cardio & Stretch).
- Use badges to visually distinguish item types:
  - Workout = Green Badge
  - Calendar = Blue Badge

### 5. Workout Plan Timeline (Multi-day)
- Segmented filter controls: `Today`, `Tomorrow`, `Next 3 Days`, `Next 7 Days`.
- Show horizontal cards or a vertical list of days and their plan:
  - Monday (Today): Upper Body (reflects scheduled workout if any)
  - Tuesday (Tomorrow): Recovery Walk
  - Wednesday: HIIT
  - Thursday: Core Training
  - Friday: Full Body
  - Saturday: Yoga Flow
  - Sunday: Rest Day

### 6. Persistence
- Persist scheduled workouts using the existing `SqliteWorkoutRepository` (saving to SQLite database) so that it updates the dashboard and health stats seamlessly.
- Allow marking the scheduled workout as completed from either the dashboard or the today's schedule timeline.
