# Solo Project Harness Plan

Harness ở đây là bộ quy trình + tài liệu + checklist để bạn làm solo project không bị loạn.

## 1. Cấu trúc thư mục harness

```text
harness/
  00_project_brief.md
  01_mvp_scope.md
  02_screen_inventory.md
  03_mock_data_plan.md
  04_vertical_slice_packet.md
  05_acceptance_criteria.md
  06_validation_log.md
  07_decision_log.md
  08_agent_prompt.md
```

---

## 2. Project Brief Template

```md
# Project Brief

## Product
HealTrack Daily

## One-liner
App theo dõi bữa ăn, ingredient và lịch tập ngắn mỗi ngày.

## Target user
Người bận học/làm, muốn theo dõi sức khỏe đơn giản.

## MVP
Dashboard + Add Meal + Nutrition Summary + Workout Slot Mock.

## Out of scope
AI food recognition, wearable, payment, social feed.

## Success Criteria
Người dùng thêm meal và thấy dashboard cập nhật trong dưới 10 giây.
```

---

## 3. MVP Scope Template

```md
# MVP Scope

## Must-have
- Dashboard
- Add meal
- Daily nutrition summary
- Workout suggestion mock
- Calendar slot mock

## Should-have
- Scan ingredient mock
- History 7 ngày
- Profile preference

## Could-have
- Google Calendar real integration
- Barcode scan real

## Won't-have
- AI image recognition
- Full diet planner
- Medical recommendation
```

---

## 4. Screen Inventory Template

```md
# Screen Inventory

| Screen | Purpose | Main Action | Data Source | MVP |
|---|---|---|---|---|
| Dashboard | Tổng quan hôm nay | Add Meal | Mock/Fake Repo | v1 |
| Add Meal | Nhập bữa ăn | Save Meal | Fake Repo | v1 |
| Workout Plan | Gợi ý tập | Schedule | Fake Calendar Slots | v1 |
| Scan Ingredient | Xem ingredient | Mock Scan | Mock OCR | v1.1 |
| Profile | Cài đặt | Update Preference | Local | v1 |
```

---

## 5. Vertical Slice Packet Template

```md
# Vertical Slice Packet

## Slice name
Meal Log Slice

## User story
Là người dùng, tôi muốn thêm một bữa ăn để dashboard hôm nay cập nhật tổng calo.

## Flow
Dashboard -> Add Meal -> Save -> Dashboard Updated

## Screens involved
- DashboardPage
- AddMealPage

## State involved
- NutritionBloc
- DashboardBloc optional

## Domain
- MealLog
- NutritionSummary

## UseCases
- AddMealLogUseCase
- GetTodayMealsUseCase
- CalculateTodayNutritionUseCase

## Repository
- NutritionRepository
- FakeNutritionRepository first
- NutritionRepositoryImpl later

## API later
- POST /meals
- GET /meals/today

## Acceptance Criteria
- Add meal thành công
- Dashboard cập nhật calories
- Meal xuất hiện trong list
- Không crash khi input thiếu field
```

---

## 6. Validation Log Template

```md
# Validation Log

## Date
YYYY-MM-DD

## Feature
Meal Log Slice

## Tested flow
Dashboard -> Add Meal -> Save -> Dashboard

## Result
Pass / Fail

## Bugs found
- Bug 1
- Bug 2

## Fix plan
- Fix 1
- Fix 2

## Proof
- Screenshot
- Screen recording
- Test output
```

---

## 7. Decision Log Template

```md
# Decision Log

## Decision
Dùng FakeRepository trước Backend API.

## Reason
UI và flow cần ổn trước. Nếu code backend quá sớm sẽ dễ sửa nhiều lần.

## Alternatives
- Code backend trước
- Dùng Firebase ngay

## Final choice
FakeRepository -> API thật sau khi vertical slice ổn.
```

---

## 8. Weekly Solo Plan

## Week 1: UI + Mock Flow

```text
Day 1: One-page plan + MVP scope
Day 2: Screen inventory + wireframe
Day 3: Dashboard UI
Day 4: Add Meal UI
Day 5: Workout Plan UI
Day 6: Fake data + navigation
Day 7: Test flow UI
```

## Week 2: State + Fake Repository

```text
Day 1: Define entities
Day 2: Add NutritionBloc
Day 3: Add FakeNutritionRepository
Day 4: Connect Dashboard + AddMeal
Day 5: Add WorkoutBloc + FakeCalendar
Day 6: Validation log
Day 7: Refactor nhẹ
```

## Week 3: Backend First Slice

```text
Day 1: API contract
Day 2: Create backend project
Day 3: POST /meals
Day 4: GET /meals/today
Day 5: Connect DB
Day 6: Connect Flutter to API
Day 7: E2E test
```

## Week 4: Scan Ingredient Mock + Deploy

```text
Day 1: Scan Ingredient UI
Day 2: Mock OCR result
Day 3: Ingredient insight
Day 4: Save product/meal
Day 5: Deploy backend small
Day 6: Build APK/Web preview
Day 7: Write README + demo video
```

---

## 9. Rule khi làm solo

```text
Không làm nhiều slice cùng lúc.
Không refactor khi feature chưa chạy.
Không thêm AI trước khi manual flow ổn.
Mỗi ngày phải có output nhỏ.
Mỗi feature phải có acceptance criteria.
Mỗi bug phải ghi vào validation log.
```
