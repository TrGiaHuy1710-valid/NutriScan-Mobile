Bạn lưu nội dung dưới đây thành file:

```text
harness/changes/CR-002-dashboard-health-stats-workout-ui.md
```

````md
# CR-002: Improve Dashboard, Health Stats, Workout Logic, Splash Screen, and Scan UX

## 1. Title

Improve UI and local logic for HealTrack Daily: Splash Screen, Home Dashboard, Health Stats Dashboard, Workout Calories, Center Scan FAB, Foods Recommendation, and Goal-based Notices.

---

## 2. Goal

Refactor the current UI and mock/local logic to make the app feel more complete, friendly, and useful for daily health tracking.

The app should focus on:

- Simple daily dashboard.
- Clear calories intake / burned / net status.
- Bought Today visibility.
- Hidden health analytics dashboard.
- Workout tracking with completed workout logic.
- Center Scan button for all scan actions.
- Foods / Discover recommendation using tags and user profile.
- Safe, neutral health guidance.

This task is still UI + mock/local logic only.

Do not build backend, database, real scan, Google Calendar, OCR, barcode scanner, or AI integration yet.

---

## 3. Current Problem

The current app direction is good, but several parts need to be improved:

1. Home dashboard needs better structure and clearer nutrition/workout summary.
2. Scan actions should not be scattered across Home.
3. All scan features should be inside one prominent center Scan button.
4. Foods screen currently feels confusing if every food card directly shows `Add Meal`.
5. Food tags exist in recommendation ideas but Add Meal does not collect tags yet.
6. Health stats/progress screen needs better visualization.
7. Calories by day should be shown as a vertical bar chart.
8. Workout should affect daily calorie balance after user confirms completion.
9. Profile needs body/status and goal fields to support recommendation logic.
10. Splash screen and app phase flow should be added or improved.

---

## 4. Product Direction

HealTrack Daily is a simple daily health tracking app.

Main visible navigation:

```text
Home | Foods | Center Scan Button | Workout | Profile
````

Hidden/internal screens:

```text
AddMealPage
HealthStatsPage / ProgressDashboardPage
DailyCalorieDetailPage
ScanResultPage
MealConfirmPage
FoodProductDetailPage
CalendarSlotsPage, placeholder only
```

The app should feel like a friendly daily health companion, not a strict diet app.

---

## 5. Main Navigation Requirement

Update bottom navigation to:

```text
Home
Foods
[Center Scan FAB]
Workout
Profile
```

The center Scan button should be visually prominent.

It can be implemented as:

```text
Prominent Bottom Navigation Button
Floating Action Button integrated into bottom navigation
Center elevated scan button
```

When tapped, it should open a Bottom Sheet or Speed Dial with:

```text
Scan Food
Scan Ingredient Label
Scan Barcode
Manual Add Meal
```

Preferred implementation for this task:

```text
Center FAB -> Bottom Sheet -> scan actions
```

---

## 6. Scan Logic Requirement

All scan actions must be accessed from the center Scan button.

Do not show separate scan quick actions on Home.

### Scan Flow

```text
Tap Center Scan Button
→ Choose Scan Food / Ingredient / Barcode
→ Show mock scan result
→ User confirms
→ Add to Recently Scanned
→ Add to Bought Today if confirmed
→ Optional Add as Meal
→ Update Foods screen and Dashboard
```

### Scan Failure Flow

```text
Scan failed / not recognized
→ Navigate to AddMealPage
→ Prefill known data if available
→ User manually adds food
→ Save as custom food
→ Use it later for recommendations
```

---

## 7. Home Dashboard Requirement

Home should be the “Today Overview” screen.

It should include:

```text
Greeting + current date
Calories Balance Card
Today nutrition summary
Bought Today section
Today Meals summary
Today Workout card
Quick actions
```

### Home Quick Actions

Home quick actions should include only:

```text
Add Meal
Plan Workout
View Health Stats
```

Do not include:

```text
Scan Food
Scan Ingredient
Scan Barcode
```

Those belong inside the center Scan button.

---

## 8. Calories Balance Logic

Do not overwrite or reduce eaten calories directly.

Track these values separately:

```text
intakeCalories
burnedCalories
netCalories = intakeCalories - burnedCalories
targetCalories
remainingCalories = targetCalories - netCalories
```

Dashboard should show:

```text
Calories eaten
Calories burned
Net calories
Target calories
```

Example:

```text
Eaten: 1,450 kcal
Burned: 220 kcal
Net: 1,230 kcal
Target: 2,000 kcal
```

---

## 9. Calories Progress Bar Requirement

Improve the calories progress visualization.

The progress bar should visually represent:

```text
Blue section: calories eaten / intake
White or light gray section: remaining calories
Red or orange section: calories burned by workout
```

Recommended labels:

```text
Eaten
Remaining
Burned
```

Important:

* Keep labels clear.
* Avoid making red feel like danger if it represents workout calories.
* Orange or green can be used for burned calories if red feels too aggressive.
* UI should remain friendly and non-judgmental.

---

## 10. Bought Today Requirement

Home should show a small `Bought Today` section.

Foods / Discover should show a more detailed `Bought Today` section.

Bought Today contains foods/products that were:

```text
Confirmed from scan
Confirmed from barcode
Manually added as bought
Added from product detail
```

Bought Today item should include:

```text
name
source: scan / barcode / manual / recommendation
tags
time added
optional calories/macros
```

---

## 11. Health Stats / Progress Dashboard

Create or improve a hidden internal screen:

```text
HealthStatsPage
```

or:

```text
ProgressDashboardPage
```

It should be opened from Home quick action:

```text
Home -> View Health Stats
```

This screen should not appear in bottom navigation.

### Required Sections

```text
Calories by Day
Calories by Month / Date Range
Workout by Day
Workout Calories Burned
Nutrition Macro Summary
Goal Progress
Health Notices
```

---

## 12. Calories by Day Chart

Calories by day must be shown as a vertical bar chart.

Chart requirements:

```text
X-axis: day / date
Y-axis: calories
Bar value: intake calories
Optional overlay/secondary label: burned calories
```

Example:

```text
Mon  Tue  Wed  Thu  Fri  Sat  Sun
1200 1600 1800 1500 2100 1700 1400
```

If no chart package exists, implement a simple custom bar chart using Flutter widgets.

Do not add heavy dependencies unless necessary.

---

## 13. Monthly / Date Range Stats

Health stats should support mock sections for:

```text
This week
This month
Custom range placeholder
```

For now, use mock/local data.

Stats should include:

```text
Average intake calories
Average burned calories
Total workout minutes
Total workout calories burned
Days logged
Workout completion count
```

---

## 14. Workout Stats Requirement

Health Stats should also summarize workout.

Include:

```text
Workout minutes by day
Workout calories burned by day
Completed workouts
Scheduled workouts
Workout goal progress
```

Workout chart can be simple:

```text
X-axis: day
Y-axis: workout minutes or calories burned
```

---

## 15. Workout Screen Requirement

Workout screen should include:

```text
Workout Library
Workout Suggestions
Mock free time slots
Scheduled workout
Completed workout state
```

Each workout should include:

```text
title
durationMinutes
difficulty
estimatedCaloriesBurned
equipment
tags
exercise list
completed status
```

Example:

```text
10-min Light Stretch
Duration: 10 minutes
Estimated burn: 35 kcal
Difficulty: Beginner
Equipment: None
Tags: light, mobility, beginner
```

---

## 16. Workout Completion Logic

When user confirms a workout as completed:

```text
todayBurnedCalories += workout.estimatedCaloriesBurned
workout.completed = true
dashboard recalculates netCalories
health stats updates workout chart
```

Dashboard should then show:

```text
Workout completed
Calories burned added
Net calories updated
```

Important:

* Calories burned is an estimate.
* Show wording like “Estimated burned”.
* Do not present the number as medically exact.

---

## 17. Foods / Discover Screen Requirement

Foods screen should be a Discover/Recommendation screen, not a meal log screen.

It should include:

```text
Recommended meals to cook
Recommended foods/products
Bought Today
Recently Scanned
Saved Foods
Custom Foods
Ingredient Ideas
Tag-based recommendations
```

### Important UI Fix

Do not show `Add Meal` directly under every food card.

Instead, use actions like:

```text
View
Save
Cook idea
Add to plan
```

Inside detail or confirm screen, allow:

```text
Add as meal
Add to Bought Today
Save to food database
```

---

## 18. Food Tags Requirement

Food recommendation requires tags.

Add tags to:

```text
FoodItem
MealLog
ScannedProduct
RecommendedMeal
BoughtFoodItem
```

Suggested tags:

```text
high_protein
light
balanced
quick_meal
breakfast
lunch
dinner
snack
vegetarian
low_sugar
high_fiber
bought_today
recently_scanned
custom_food
manual_entry
scan_result
barcode_result
```

---

## 19. Add Meal Requirement

AddMealPage remains a hidden/internal flow.

It can be opened from:

```text
Home -> Add Meal
Scan failed -> Add Meal
Scan result -> Add as meal
Food detail -> Add as meal
```

It should include:

```text
Meal type
Food name
Portion
Calories
Protein
Carbs
Fat
Tags
Save button
```

After saving:

```text
Add to meal log
Update Dashboard nutrition summary
If food does not exist, add as custom food
Use custom food for future recommendations
```

Do not expose AddMealPage as a bottom navigation tab.

---

## 20. Profile Requirement

Profile should include:

```text
Name
Age range
Current body/status note
Activity level
Workout level
Food preferences
Allergies / avoid list
Main health goal
Preferred workout duration
Available equipment
Calendar connection placeholder
```

Health goal options:

```text
Build healthy habits
Maintain weight
Lose weight
Gain weight
```

Default should be:

```text
Build healthy habits
```

---

## 21. Goal-based Recommendation Logic

Use simple local/mock rule-based recommendation.

Inputs:

```text
user goal
activity level
workout level
food preferences
avoid list
today nutrition summary
bought today
food tags
workout status
time of day
```

Outputs:

```text
recommended meals
recommended food products
balanced options
light meal ideas
high protein options
quick meal ideas
```

Example rules:

```text
If protein is low -> recommend high_protein foods.
If user has bought eggs/tofu -> recommend simple meal ideas using those items.
If user goal is maintain weight -> recommend balanced meals.
If user wants build healthy habits -> recommend simple consistent meal ideas.
If workout completed -> recommend balanced recovery-style food.
```

Do not recommend strict diet plans.

---

## 22. Health Notice Logic

Add gentle notices, not harsh warnings.

Good examples:

```text
You are slightly above your planned intake today.
You may want a lighter meal later.
You have not scheduled movement today.
Your protein looks lower than usual today.
Your workout goal is almost complete.
```

Avoid:

```text
You ate too much.
Bad progress.
You failed today.
You must lose weight.
```

---

## 23. Splash Screen Requirement

Add or improve SplashScreen.

Flow:

```text
SplashScreen
→ Check local/mock app phase
→ If first launch/profile incomplete -> Onboarding/Profile setup
→ Else -> Home
```

Splash UI should include:

```text
App logo or simple icon
App name
Short subtitle
Light background
Simple loading indicator
```

App phase can be mock/local for now:

```text
firstLaunch
profileIncomplete
ready
```

---

## 24. Onboarding / Profile Setup Requirement

If profile is incomplete, guide user to basic setup.

Minimal setup fields:

```text
Name
Health goal
Activity level
Workout level
Preferred workout duration
Food preference
Avoid/allergy list optional
```

Keep it short.

Do not ask too many questions before user can use the app.

---

## 25. UI Style Requirement

Use a simple, clean, bright UI style.

```text
Light theme only
No dark background
White/off-white background
Soft pastel accent colors
Clear black/dark gray text
Rounded cards
Enough spacing
Large readable font sizes
Avoid crowded layout
Avoid complex animations
Avoid too many colors
```

The app should feel like:

```text
Friendly
Calm
Simple
Daily-use
Beginner-friendly
Non-judgmental
```

---

## 26. Safety Requirements

The app must avoid harmful body/food messaging.

Do not:

```text
Encourage restrictive eating
Create aggressive calorie deficit plans
Shame the user
Use appearance-pressure wording
Treat calories as punishment
Suggest medical supplements/pills/powders
```

Use neutral wording:

```text
Health goal
Balanced meals
Routine
Energy
Movement
Estimated calories
Gentle notice
```

If weight goals are mentioned, keep guidance general and safe.

---

## 27. Data Models Suggested

Use existing models if available.

If not, create simple models:

```text
MealLog
FoodItem
FoodTag
ScannedProduct
IngredientInsight
BoughtFoodItem
NutritionSummary
UserHealthProfile
WorkoutPlan
WorkoutExercise
FreeTimeSlot
DailyHealthStats
MonthlyHealthStats
HealthNotice
AppPhase
```

Keep models simple.

Do not over-engineer.

---

## 28. Implementation Scope

This task may include:

```text
SplashScreen
Center Scan FAB
Bottom Sheet scan actions
Home dashboard update
HealthStatsPage
FoodsDiscoverPage update
Workout completion logic
AddMeal tags
Bought Today
Recently Scanned
Profile goal/status fields
Mock/local state
Simple charts or bar widgets
```

This task must not include:

```text
Backend
Database
Real Google Calendar
Real OCR
Real barcode scanner
Real AI scan
API keys
Authentication
Payment
Cloud sync
```

---

## 29. Acceptance Criteria

After implementation:

1. App starts without errors.
2. SplashScreen exists or is improved.
3. Bottom navigation shows Home, Foods, Center Scan, Workout, Profile.
4. There is no visible Meals tab.
5. Center Scan button opens scan options.
6. Home keeps Add Meal quick action.
7. Home does not show separate scan quick actions.
8. Home shows calories eaten, burned, net, and target.
9. Calories progress bar shows intake, remaining, and burned sections.
10. Home shows Bought Today.
11. AddMealPage is internal and includes tags.
12. Saving a meal updates Dashboard nutrition summary.
13. New manual food can be saved as custom food.
14. Foods screen shows recommendations, bought today, recently scanned, saved/custom foods.
15. Recommended cards do not show confusing Add Meal button under every card.
16. Mock scan result can be confirmed.
17. Confirmed scan result appears in Recently Scanned and/or Bought Today.
18. HealthStatsPage exists as a hidden/internal screen.
19. HealthStatsPage shows calories by day as a vertical bar chart.
20. HealthStatsPage shows workout stats.
21. Workout screen has workout suggestions and completion action.
22. Confirming workout completed updates burned calories.
23. Dashboard net calories updates after workout completion.
24. Profile includes body/status and health goal fields.
25. Goal/profile can influence mock recommendations or notices.
26. UI is light, friendly, simple, and readable.
27. No real external API call is made.
28. No API key is required.
29. `flutter analyze` is run if possible.
30. Any known issues are reported clearly.

---

## 30. Manual Test Checklist

After coding, test:

```text
Open app
Splash appears
Navigate to Home
Tap Add Meal
Add meal with tags
Return Home
Calories summary updates
Open center Scan button
Choose mock scan
Confirm scan result
Check Bought Today
Open Foods
Check Bought Today and Recently Scanned
Check recommendations
Open Workout
Schedule or complete workout
Return Home
Burned calories updates
Open Health Stats
Check calories by day chart
Check workout stats
Open Profile
Update health goal/status
Return Foods
Check mock recommendation changes if implemented
```

---

## 31. Output Required from Agent

After finishing, report:

```text
1. Summary of changes
2. Files created/modified
3. How to run
4. Manual test steps
5. flutter analyze result
6. Known issues
7. Next recommended step
```

---

## 32. Next Recommended Step After This Task

After this UI/local logic task is stable, the next vertical slice should be:

```text
Meal Log + Bought Today + Food Database local persistence
```

Then later:

```text
Real barcode scan
Open Food Facts integration
Google Calendar integration
Backend/database
AI food recognition
```

```
```
