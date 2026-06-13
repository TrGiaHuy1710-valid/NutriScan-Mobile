# Vertical Slice Backlog

## Slice 1: Meal Log -> Dashboard

### Priority
P0

### Why
Đây là lõi của app. Nếu không log meal và dashboard không cập nhật, app chưa có giá trị.

### Flow

```text
Dashboard
→ Add Meal
→ Save Meal
→ Dashboard Updated
```

### Implementation order

```text
1. UI mock
2. MealLog entity
3. NutritionSummary entity
4. NutritionBloc
5. FakeNutritionRepository
6. AddMealLogUseCase
7. GetTodayMealsUseCase
8. Dashboard summary
9. Validation
10. Backend API
```

### Acceptance Criteria

```text
User thêm meal trong dưới 10 giây.
Dashboard cập nhật calories.
Meal lưu trong app session.
Có edit/delete cơ bản sau MVP.
```

---

## Slice 2: Workout Slot -> Schedule

### Priority
P0

### Why
Đây là điểm khác biệt của app: tìm thời gian rảnh để tập.

### Flow

```text
Dashboard
→ Plan Workout
→ View free slots
→ Choose suggestion
→ Schedule
→ Dashboard shows workout
```

### Implementation order

```text
1. Fake free slots
2. Workout suggestion rules
3. WorkoutPlan entity
4. WorkoutBloc
5. FakeWorkoutRepository
6. FakeCalendarRepository
7. ScheduleWorkoutUseCase
8. Dashboard update
```

### Acceptance Criteria

```text
App hiển thị ít nhất 3 slot rảnh fake.
App gợi ý workout theo duration.
User schedule được workout.
Workout xuất hiện ở Dashboard.
```

---

## Slice 3: Ingredient Scan Mock -> Insight

### Priority
P1

### Why
Chuẩn bị cho tính năng scan thật nhưng không làm phức tạp MVP.

### Flow

```text
Dashboard
→ Scan Ingredient
→ Mock Scan
→ Show ingredient insight
→ Save optional
```

### Acceptance Criteria

```text
Mock scan tạo ingredient list.
Insight hiển thị sugar/sodium/protein/fiber.
User có thể confirm hoặc cancel.
```

---

## Slice 4: Backend Meal API

### Priority
P1

### Why
Thay fake data bằng dữ liệu lưu thật.

### API

```text
POST /meals
GET /meals/today
DELETE /meals/{id}
```

### Acceptance Criteria

```text
Flutter gọi API thật.
Database lưu meal.
Reload app vẫn thấy meal.
```

---

## Slice 5: Real Google Calendar

### Priority
P2

### Why
Đây là integration quan trọng nhưng không nên làm quá sớm.

### Flow

```text
Connect Google
→ Read free/busy
→ Show free slots
→ Create workout event
→ Save calendarEventId
```

### Acceptance Criteria

```text
User login Google.
App lấy free slots thật.
App tạo event workout thật.
Nếu permission lỗi thì có fallback mock/local.
```

---

## Slice 6: Barcode / Open Food Facts

### Priority
P2

### Why
Scan barcode dễ làm hơn AI nhận diện ảnh món ăn và có dữ liệu sản phẩm tốt hơn.

### Flow

```text
Scan barcode
→ Fetch product
→ Show nutrition facts
→ Confirm as meal
```

### Acceptance Criteria

```text
Scan barcode được.
Nếu không tìm thấy product thì cho nhập thủ công.
Nutrition facts map được sang MealLog.
```

---

## Slice 7: AI Food Image Estimate

### Priority
P3

### Why
Hấp dẫn nhưng khó chính xác. Chỉ làm sau khi manual/barcode flow ổn.

### Flow

```text
Take food photo
→ AI detects food candidates
→ User confirms portion
→ Save meal
```

### Acceptance Criteria

```text
AI không tự lưu kết quả.
Luôn có confirm/edit.
Có confidence score.
Có fallback nhập thủ công.
```
