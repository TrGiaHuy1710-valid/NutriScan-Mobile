# Change Request: Mock Rule-Based Foods Recommendations

Date: 2026-06-14

## Goal

Make Foods / Discover recommendations respond to local mock context instead of using only a static list.

## Scope

- UI and local/mock logic only.
- Add a mock profile model.
- Add a small local recommendation use case.
- Keep recommendations tag-based and explainable.
- Keep Add Meal hidden/internal.
- Keep Scan centralized in the bottom navigation.

## Recommendation Inputs

- User health goal and food preference tags.
- Daily nutrition summary.
- Bought-today item tags.
- Recently scanned product tags.
- Custom foods saved from manual meal logs.

## Out Of Scope

- Backend.
- Database.
- Real barcode scanner.
- Real OCR.
- Real AI.
- Real nutrition API.
- Google Calendar integration.
- API keys.
