# Main Screens

## 1. Onboarding Screen

Mục tiêu: giải thích app làm gì và lấy preference cơ bản.

### Nội dung

```text
Welcome
Health goal nhẹ
Activity level
Workout preference
Calendar connect optional
```

### Button chính

```text
Get Started
Skip for now
```

---

## 2. Today Dashboard

Màn quan trọng nhất.

### Cards

```text
Today Summary Card
Calories / Macro Card
Meals Today Card
Workout Today Card
Quick Actions
```

### Quick Actions

```text
Scan Food
Add Meal
Plan Workout
Scan Ingredient
```

### UI gợi ý

```text
Good morning, Huy

Today
Calories: 1250 / 2000
Protein: 45g
Water: 4 cups
Workout: Not scheduled

[Add Meal] [Scan Ingredient]
[Plan Workout]
```

---

## 3. Add Meal Screen

Mục tiêu: thêm bữa ăn nhanh nhất có thể.

### Input

```text
Meal type
Food name
Portion
Calories
Protein
Carbs
Fat
```

### Smart default

```text
Buổi sáng -> Breakfast
Buổi trưa -> Lunch
Buổi tối -> Dinner
```

---

## 4. Meal Detail / Confirm Screen

Mục tiêu: xác nhận kết quả trước khi lưu.

### Nội dung

```text
Tên món
Khẩu phần
Calo ước lượng
Macro
Edit button
Confirm button
```

---

## 5. Scan Ingredient Screen

MVP dùng mock trước.

### Flow

```text
Open camera/mock scan
→ OCR/mock ingredient text
→ Show ingredient list
→ Show insight
→ Save optional
```

### Insight examples

```text
High sugar
High sodium
Good protein source
Contains fiber
```

Không dùng ngôn ngữ gây áp lực kiểu "xấu", "cấm ăn".

---

## 6. Workout Plan Screen

Mục tiêu: chọn bài tập dựa trên thời gian rảnh.

### Nội dung

```text
Free slots
Workout suggestions
Duration filter: 5/10/15/20/30 minutes
Difficulty: beginner
Equipment: none
```

### Example

```text
Free slot: 17:30 - 18:00
Suggestion: 15-min full body light workout
[Schedule]
```

---

## 7. Calendar Slots Screen

Mục tiêu: hiển thị slot rảnh từ fake data hoặc Google Calendar.

### MVP

```text
Fake free slots
Choose slot
Schedule workout
```

### Sau MVP

```text
Google Calendar FreeBusy API
Create workout event
Sync event id
```

---

## 8. History Screen

Không cần quá phức tạp trong MVP.

### Có thể có

```text
Last 7 days meals
Workout history
Simple weekly summary
```

---

## 9. Profile / Settings Screen

### Nội dung

```text
Name
Activity level
Workout level
Food preference
Daily reminder
Calendar connection
Data export/delete
```

---

# Bottom Navigation đề xuất

```text
Dashboard
Meals
Workout
Profile
```

Hoặc bản tối giản hơn:

```text
Home
Log
Plan
Profile
```
