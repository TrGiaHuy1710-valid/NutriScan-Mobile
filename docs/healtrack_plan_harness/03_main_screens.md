# Main Screens

## Main Bottom Navigation

```text
Home
Foods
Workout
Profile
```

The old visible `Meals` tab is removed.

Meal logging is hidden/internal and opened from actions.

---

## 1. OnboardingPage

Purpose: explain the app and collect basic preferences.

Content:

```text
Welcome
Health goal
Age range, not exact age if possible
Activity level
Workout level
Food preferences
Allergies or avoid list
Calendar connect optional
Safety note for teen/young users
```

Primary actions:

```text
Get Started
Skip for now
```

---

## 2. DashboardPage

Purpose: show today's health snapshot and quick actions.

Cards:

```text
Greeting
Today calories summary
Protein/carbs/fat summary
Meals today list
Workout today card
Bought/scanned prompt, optional
Quick actions
```

Quick actions:

```text
Add Meal
Scan Food
Scan Ingredient
Scan Barcode
Plan Workout
```

Example:

```text
Good morning, Huy

Today
Calories: 1250 / 2000
Protein: 45g
Workout: Not scheduled

[Add Meal] [Scan Food]
[Scan Ingredient] [Scan Barcode]
[Plan Workout]
```

---

## 3. FoodsDiscoverPage

Purpose: show food recommendations and product discovery without feeling like a shopping app.

Sections:

```text
Good for today
Easy meal ideas
Products you scanned
Bought today
High protein options
Light meal ideas
Balanced meal ideas
Simple ingredients for home cooking
```

Data sources in MVP:

```text
Mock recommendations
Mock profile preferences
Daily nutrition summary
Confirmed scanned products
BoughtFoodItem local state
```

Actions:

```text
View food/product detail
Add recommended meal to plan
Add as meal
Mark as bought today
Scan ingredient/barcode
```

Important:
- Do not make the screen feel shopping-first.
- Do not recommend pills, powders, or medical supplements automatically.
- "Supplementary foods" means normal foods that support nutrition, such as yogurt, eggs, beans, milk, tofu, fruit, nuts.

---

## 4. WorkoutPlanPage

Purpose: choose a short workout from fake free time slots.

Content:

```text
Free slots
Workout suggestions
Duration filter: 5/10/15/20/30 minutes
Difficulty: beginner
Equipment: none or available equipment
Schedule button
```

Example:

```text
Free slot: 17:30 - 18:00
Suggestion: 15-min light full body workout
[Schedule]
```

---

## 5. ProfilePage

Purpose: collect user profile, body/status info, safety preferences, and recommendation inputs.

Fields:

```text
Name
Age range
Current body/status input
Activity level
Workout level
Food preferences
Allergies or avoid list
Main health goal:
- lose weight
- maintain weight
- gain weight
- build healthy habits
Preferred workout duration
Available equipment
Calendar connection status
```

Safety:
- Use neutral wording.
- Avoid appearance pressure.
- Avoid strict weight-loss guidance for teen/young users.

---

## Hidden/Internal Screens

These screens are not bottom navigation items.

## AddMealPage

Opened from Dashboard, scan confirmation, or Foods recommendations.

Input:

```text
Meal type
Food name
Portion
Calories
Protein
Carbs
Fat
Save
```

## MealConfirmPage

Purpose: confirm a food/scan/recommendation before saving as MealLog.

Content:

```text
Food name
Portion
Estimated calories
Macros
Edit
Confirm as meal
```

## ScanIngredientPage / ScanBarcodePage

MVP uses mock data.

Flow:

```text
Open mock scan
-> Show detected product
-> Show ingredients and insights
-> Confirm product
-> Add to Bought Today
-> Optional Add as Meal
```

## ScanResultPage

Shows:

```text
ScannedProduct
IngredientInsight list
Confirm product
Add to bought today
Add as meal, optional
```

## FoodProductDetailPage

Shows:

```text
Product details
Ingredients
Insights
Bought today status
Optional add as meal
```

## CalendarSlotsPage

MVP:

```text
Fake free slots
Choose slot
Schedule workout
```

Later:

```text
Google Calendar FreeBusy API
Create workout event
Sync event id
```

## MealHistoryPage

Optional later:

```text
Last 7 days meals
Simple weekly nutrition summary
```
