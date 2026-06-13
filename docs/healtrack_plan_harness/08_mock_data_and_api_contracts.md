# Mock Data and API Contracts

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

---

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

---

## 3. Mock Ingredient Scan

```json
{
  "productName": "Chocolate Milk",
  "ingredients": [
    "milk",
    "sugar",
    "cocoa powder",
    "stabilizer",
    "salt"
  ],
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
  ]
}
```

---

## 4. Mock Free Time Slots

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
  }
]
```

---

## 5. Mock Workout Suggestions

```json
[
  {
    "id": "workout_001",
    "title": "10-min Stretching",
    "durationMinutes": 10,
    "difficulty": "beginner",
    "equipment": "none",
    "exercises": [
      "Neck stretch",
      "Shoulder rolls",
      "Hamstring stretch",
      "Deep breathing"
    ]
  },
  {
    "id": "workout_002",
    "title": "15-min Light Full Body",
    "durationMinutes": 15,
    "difficulty": "beginner",
    "equipment": "none",
    "exercises": [
      "Bodyweight squat",
      "Wall push-up",
      "Glute bridge",
      "March in place"
    ]
  }
]
```

---

# API Contracts Later

## 1. GET /meals/today

### Response

```json
{
  "date": "2026-06-13",
  "meals": [
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
    }
  ],
  "summary": {
    "totalCalories": 320,
    "totalProtein": 10,
    "totalCarbs": 55,
    "totalFat": 7
  }
}
```

---

## 2. POST /meals

### Request

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

### Response

```json
{
  "id": "meal_123",
  "mealType": "lunch",
  "foodName": "Rice with chicken",
  "portion": "1 plate",
  "calories": 620,
  "protein": 35,
  "carbs": 75,
  "fat": 18,
  "createdAt": "2026-06-13T12:30:00Z"
}
```

---

## 3. POST /food/scan-ingredient

### Request

```json
{
  "imageUrl": "https://example.com/ingredient-label.jpg"
}
```

### Response

```json
{
  "productName": "Chocolate Milk",
  "ingredients": ["milk", "sugar", "cocoa powder", "salt"],
  "insights": [
    {
      "type": "sugar",
      "level": "high",
      "message": "This product appears to contain added sugar."
    }
  ]
}
```

---

## 4. GET /calendar/free-slots

### Query

```text
date=2026-06-13
minDurationMinutes=10
```

### Response

```json
{
  "date": "2026-06-13",
  "slots": [
    {
      "startTime": "2026-06-13T17:30:00Z",
      "endTime": "2026-06-13T18:00:00Z",
      "durationMinutes": 30
    }
  ]
}
```

---

## 5. POST /workouts/schedule

### Request

```json
{
  "workoutId": "workout_001",
  "startTime": "2026-06-13T17:30:00Z",
  "endTime": "2026-06-13T17:45:00Z",
  "addToGoogleCalendar": true
}
```

### Response

```json
{
  "id": "plan_001",
  "workoutId": "workout_001",
  "title": "10-min Stretching",
  "startTime": "2026-06-13T17:30:00Z",
  "endTime": "2026-06-13T17:45:00Z",
  "calendarEventId": "google_event_123",
  "status": "scheduled"
}
```
