# One-page Plan: HealTrack Daily

## 1. Project Name

```text
HealTrack Daily
```

## 2. One-sentence Description

HealTrack Daily is a simple daily health tracking app that helps users see today's nutrition, log meals, discover useful everyday foods, track scanned/bought products, and plan short workouts from free time.

## 3. Problem

Users who want healthier routines often struggle with:

```text
1. Logging meals quickly without a complex food diary.
2. Knowing what to cook or buy based on today's nutrition.
3. Understanding scanned products or ingredient labels at a simple level.
4. Remembering what food/products they bought today.
5. Finding short safe workouts that fit their schedule.
```

## 4. Solution

The app provides:

```text
Home dashboard:
- Calories and macros for today.
- Meals logged today.
- Workout today.
- Quick actions: Add Meal, Scan Food, Scan Ingredient, Scan Barcode, Plan Workout.

Foods / Discover:
- Good for today.
- Easy meal ideas.
- Products scanned.
- Bought today.
- Simple ingredients for home cooking.
- Mock recommendations based on profile and nutrition status.

Profile:
- Health goal and preferences.
- Body/status information in neutral wording.
- Allergies and avoid list.
- Workout preference and calendar status.
```

## 5. Target Users

```text
Students, busy workers, beginners, and people who want a simpler alternative to heavy calorie-counting apps.
```

The product should support healthy habits without body-shaming or pressure.

## 6. Core Value

```text
1. Add a meal quickly.
2. See today's nutrition summary.
3. Discover simple foods and meals that fit today's needs.
4. Confirm scanned products and add them to bought today.
5. Plan short workouts from free slots.
```

## 7. Core User Flow

```text
Open app
-> View Dashboard
-> Add Meal or Scan Food/Product
-> Confirm result
-> Dashboard updates nutrition
-> Foods screen updates scanned/bought/recommended food sections
-> Plan workout from fake free slot
-> Dashboard shows scheduled workout
```

## 8. MVP v0

UI-first with mock data:

```text
Dashboard
Foods / Discover
Add Meal hidden/internal flow
Scan Ingredient / Barcode mock flow
Workout Plan
Profile with body/status and goal input
Mock recommendations
No backend
No real Google Calendar
No real AI
No real nutrition API
```

## 9. MVP v1

First working vertical slices:

```text
Primary:
Dashboard -> Add Meal -> Save -> Dashboard updated

Secondary:
Scan Ingredient/Barcode mock -> Confirm product -> Add to Bought Today -> Foods screen updated

Third:
Profile goal/preferences -> Foods recommendations update using mock rule-based logic

Fourth:
Workout mock slots -> Schedule workout -> Dashboard updated
```

## 10. Out Of Scope For Early MVP

```text
Backend
Database
Real Google Calendar
Real OCR
Real barcode scanner/API
Real Open Food Facts API
Real AI food image recognition
Medical recommendations
Supplement/pill/powder recommendations
Payment
Social feed
Extreme diet planning
```

## 11. Safety Positioning

HealTrack Daily is not a medical app.

It should use neutral, supportive language:

```text
health goal
energy
routine
balanced eating
movement
steady habits
```

For teen or young users, strict weight-loss guidance should be avoided and the app should advise discussing goals with a trusted adult or qualified professional.
