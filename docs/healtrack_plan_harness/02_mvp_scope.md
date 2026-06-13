# MVP Scope

## MVP v0: UI-first Prototype

Mục tiêu: nhìn được app, bấm được flow chính, chưa cần backend.

### Có

```text
Onboarding
Dashboard
Add Meal
Scan Ingredient Mock
Workout Plan
Calendar Slots Mock
Profile
Fake Data
```

### Chưa có

```text
Backend thật
Database thật
Google Calendar thật
AI thật
OCR thật
```

### Definition of Done

```text
App mở được.
Đi qua được flow chính.
Data fake hiển thị hợp lý.
Không bị crash khi bấm qua các màn.
```

---

## MVP v1: Meal Log + Daily Dashboard

Mục tiêu: tính năng đầu tiên chạy thật ở local/mock repository.

### Có

```text
Add meal thủ công
Chọn meal type: breakfast/lunch/dinner/snack
Tính tổng calo/protein/carbs/fat hôm nay
Dashboard cập nhật sau khi thêm meal
Lưu tạm local/mock repository
```

### Vertical Slice

```text
AddMealPage
→ NutritionBloc
→ AddMealLogUseCase
→ NutritionRepository
→ FakeNutritionRepository
→ Dashboard update
```

### Definition of Done

```text
Thêm meal xong quay về Dashboard.
Tổng calo hôm nay tăng đúng.
Meal xuất hiện trong list hôm nay.
Có empty/loading/error state cơ bản.
```

---

## MVP v1.1: Ingredient / Barcode Scan Mock

Mục tiêu: chuẩn bị flow scan trước khi dùng OCR/API thật.

### Có

```text
Scan Ingredient page
Mock OCR result
Ingredient insight
Confirm product/meal
Save as meal optional
```

### Chưa cần

```text
Camera OCR thật
Barcode scanner thật
Open Food Facts API thật
AI phân tích ảnh món ăn
```

### Definition of Done

```text
User bấm Scan Mock.
App hiện ingredient list.
App highlight sugar/sodium/protein/fiber ở mức đơn giản.
User có thể Save hoặc Cancel.
```

---

## MVP v1.2: Workout Scheduler + Calendar Mock

Mục tiêu: gợi ý workout theo thời gian rảnh.

### Có

```text
Fake free time slots
Workout suggestion theo duration
Schedule workout
Lưu workout plan
Dashboard hiện workout hôm nay
```

### Vertical Slice

```text
WorkoutPlanPage
→ CalendarBloc lấy fake free slots
→ WorkoutBloc tạo suggestion
→ ScheduleWorkoutUseCase
→ FakeWorkoutRepository
→ Dashboard update
```

### Definition of Done

```text
App hiển thị slot rảnh.
App gợi ý workout 10/15/20 phút.
User schedule được workout.
Dashboard hiện workout đã lên lịch.
```

---

## MVP v1.3: Backend + Database First Slice

Mục tiêu: thay fake repository bằng API thật cho meal log.

### Có

```text
GET /meals/today
POST /meals
SQLite/PostgreSQL/Firebase tùy stack
NutritionRepositoryImpl gọi API thật
```

### Definition of Done

```text
Tắt app mở lại vẫn còn meal.
API test bằng Postman/curl được.
Flutter app thêm meal qua backend thật.
```

---

## MVP v2: Real Integrations

Sau khi MVP v1 ổn mới làm:

```text
Google Calendar thật
Barcode scanner thật
Open Food Facts API
OCR ingredient label
AI food image estimation
Weekly summary
```
