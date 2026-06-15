# Change Request: Local Persistence Slice

Date: 2026-06-14

## Goal

Persist the current UI-first mock state locally without adding backend services.

## Scope

- Meal logs.
- Bought Today items.
- Scheduled/completed workout state.
- Local JSON storage only.
- Keep fake repositories and local app state.

## Out Of Scope

- Backend.
- Server database.
- Auth.
- Cloud sync.
- Google Calendar.
- OCR.
- Barcode scanner.
- AI.
- API keys.

## Acceptance

- Meal logs survive repository/app recreation when using the same local store.
- Bought Today items survive app state recreation when using the same local store.
- Completed workout state survives repository/app recreation when using the same local store.
- Existing widget tests remain deterministic through isolated test stores.
