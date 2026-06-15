# Mock Data and API Contracts

MVP uses mock/local data only. API contracts below are for later.

## 1. Mock Meal Data

```json
[
  {
    "id": "meal_001",
    "mealType": "breakfast",
    "foodName": "Oatmeal with banana",
    "portion": "1 bowl",
    "calories": 320,
    "protein": 10,
    "carbs": 55,
    "fat": 7,
    "createdAt": "2026-06-13T08:00:00Z"
  },
  {
    "id": "meal_002",
    "mealType": "lunch",
    "foodName": "Rice with chicken and vegetables",
    "portion": "1 plate",
    "calories": 620,
    "protein": 35,
    "carbs": 75,
    "fat": 18,
    "createdAt": "2026-06-13T12:30:00Z"
  }
]
```

## 2. Mock Nutrition Summary

```json
{
  "date": "2026-06-13",
  "totalCalories": 940,
  "totalProtein": 45,
  "totalCarbs": 130,
  "totalFat": 25,
  "mealCount": 2
}
```

## 3. Mock Profile

```json
{
  "id": "profile_001",
  "name": "Huy",
  "ageRange": "18-24",
  "bodyStatusNote": "Wants steadier energy during study days",
  "activityLevel": "lightly_active",
  "workoutLevel": "beginner",
  "foodPreferences": ["simple home meals", "high protein options"],
  "avoidList": ["shellfish"],
  "healthGoal": "build_healthy_habits",
  "preferredWorkoutDurationMinutes": 15,
  "availableEquipment": ["none"],
  "calendarConnectionStatus": "not_connected"
}
```

Health goal values:

```text
lose_weight
maintain_weight
gain_weight
build_healthy_habits
```

Safety:
- Do not use aggressive deficit plans.
- If ageRange suggests teen/young user and healthGoal is lose_weight, show a trusted adult/professional note.

## 4. Mock Food Recommendations

```json
[
  {
    "id": "rec_001",
    "section": "good_for_today",
    "title": "Egg and tofu rice bowl",
    "type": "meal_idea",
    "reason": "Balanced meal idea with protein and carbs.",
    "tags": ["balanced", "home cooking"],
    "mealSuggestion": {
      "mealType": "lunch",
      "foodName": "Egg and tofu rice bowl",
      "portion": "1 bowl",
      "calories": 520,
      "protein": 28,
      "carbs": 64,
      "fat": 16
    }
  },
  {
    "id": "rec_002",
    "section": "high_protein_options",
    "title": "Greek yogurt with fruit",
    "type": "food_item",
    "reason": "A normal food option that can support protein intake.",
    "tags": ["protein", "snack"]
  },
  {
    "id": "rec_003",
    "section": "simple_ingredients",
    "title": "Beans, eggs, tofu, bananas",
    "type": "ingredient_list",
    "reason": "Simple everyday ingredients for home cooking.",
    "tags": ["budget friendly", "easy"]
  }
]
```

Do not auto-recommend pills, powders, or medical supplements.

## 5. Mock Scanned Product

```json
{
  "id": "scan_001",
  "source": "ingredient_label",
  "productName": "Chocolate Milk",
  "brandName": "Mock Dairy",
  "barcode": "8930000001234",
  "isMealLike": true,
  "ingredients": ["milk", "sugar", "cocoa powder", "stabilizer", "salt"],
  "estimatedNutrition": {
    "portion": "1 bottle",
    "calories": 210,
    "protein": 8,
    "carbs": 32,
    "fat": 5
  },
  "insights": [
    {
      "type": "sugar",
      "level": "high",
      "message": "This product appears to contain added sugar."
    },
    {
      "type": "protein",
      "level": "medium",
      "message": "Milk may provide some protein."
    }
  ],
  "scannedAt": "2026-06-13T16:20:00Z"
}
```

## 6. Mock Bought Today

```json
[
  {
    "id": "bought_001",
    "productId": "scan_001",
    "productName": "Chocolate Milk",
    "source": "scan_confirmed",
    "quantityLabel": "1 bottle",
    "addedAt": "2026-06-13T16:22:00Z",
    "canAddAsMeal": true
  },
  {
    "id": "bought_002",
    "productName": "Bananas",
    "source": "manual",
    "quantityLabel": "4 pieces",
    "addedAt": "2026-06-13T17:00:00Z",
    "canAddAsMeal": false
  }
]
```

## 7. Mock Free Time Slots

```json
[
  {
    "startTime": "2026-06-13T17:30:00Z",
    "endTime": "2026-06-13T18:00:00Z",
    "durationMinutes": 30
  },
  {
    "startTime": "2026-06-13T20:15:00Z",
    "endTime": "2026-06-13T20:35:00Z",
    "durationMinutes": 20
  },
  {
    "startTime": "2026-06-13T21:10:00Z",
    "endTime": "2026-06-13T21:25:00Z",
    "durationMinutes": 15
  }
]
```

## 8. Mock Workout Suggestions

```json
[
  {
    "id": "workout_001",
    "title": "10-min Stretching",
    "durationMinutes": 10,
    "difficulty": "beginner",
    "equipment": "none",
    "exercises": ["Neck stretch", "Shoulder rolls", "Hamstring stretch", "Deep breathing"]
  },
  {
    "id": "workout_002",
    "title": "15-min Light Full Body",
    "durationMinutes": 15,
    "difficulty": "beginner",
    "equipment": "none",
    "exercises": ["Bodyweight squat", "Wall push-up", "Glute bridge", "March in place"]
  }
]
```

# API Contracts Later

## GET /meals/today

Response:

```json
{
  "date": "2026-06-13",
  "meals": [],
  "summary": {
    "totalCalories": 0,
    "totalProtein": 0,
    "totalCarbs": 0,
    "totalFat": 0
  }
}
```

## POST /meals

Request:

```json
{
  "mealType": "lunch",
  "foodName": "Rice with chicken",
  "portion": "1 plate",
  "calories": 620,
  "protein": 35,
  "carbs": 75,
  "fat": 18
}
```

## POST /food-scan/mock-confirm

Later real version may be split into ingredient scan, barcode scan, OCR, and product lookup.

Request:

```json
{
  "scanId": "scan_001",
  "confirmedProductName": "Chocolate Milk",
  "addToBoughtToday": true,
  "addAsMeal": false
}
```

Response:

```json
{
  "scannedProduct": {
    "id": "scan_001",
    "productName": "Chocolate Milk"
  },
  "boughtFoodItem": {
    "id": "bought_001",
    "productName": "Chocolate Milk",
    "quantityLabel": "1 bottle"
  }
}
```

## GET /foods/discover

Query:

```text
date=2026-06-13
```

Response:

```json
{
  "recommendations": [],
  "recentlyScannedProducts": [],
  "boughtToday": []
}
```

## PUT /profile

Request:

```json
{
  "name": "Huy",
  "ageRange": "18-24",
  "bodyStatusNote": "Wants steadier energy during study days",
  "activityLevel": "lightly_active",
  "workoutLevel": "beginner",
  "foodPreferences": ["simple home meals"],
  "avoidList": ["shellfish"],
  "healthGoal": "build_healthy_habits",
  "preferredWorkoutDurationMinutes": 15,
  "availableEquipment": ["none"]
}
```

## GET /calendar/free-slots

Query:

```text
date=2026-06-13
minDurationMinutes=10
```

Response:

```json
{
  "date": "2026-06-13",
  "slots": []
}
```

## POST /workouts/schedule

Request:

```json
{
  "workoutId": "workout_001",
  "startTime": "2026-06-13T17:30:00Z",
  "endTime": "2026-06-13T17:45:00Z",
  "addToGoogleCalendar": false
}
```

Response:

```json
{
  "id": "plan_001",
  "workoutId": "workout_001",
  "title": "10-min Stretching",
  "status": "scheduled"
}
```
