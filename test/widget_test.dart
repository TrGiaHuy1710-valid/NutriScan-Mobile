import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nutriscan/app.dart';
import 'package:nutriscan/core/persistence/app_database.dart';
import 'package:nutriscan/features/auth/data/repositories/sqlite_auth_repository.dart';
import 'package:nutriscan/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:nutriscan/features/dashboard/presentation/pages/health_stats_page.dart';
import 'package:nutriscan/features/calendar/domain/entities/free_time_slot.dart';
import 'package:nutriscan/features/food_discover/domain/bought_food_item.dart';
import 'package:nutriscan/features/food_discover/data/repositories/sqlite_bought_food_repository.dart';
import 'package:nutriscan/features/nutrition/data/repositories/sqlite_nutrition_repository.dart';
import 'package:nutriscan/features/nutrition/domain/entities/meal_log.dart';
import 'package:nutriscan/features/nutrition/presentation/pages/add_meal_page.dart';
import 'package:nutriscan/features/workout/data/repositories/sqlite_workout_repository.dart';

void main() {
  Future<AppDatabase> createTestDatabase() async {
    final directory = await Directory.systemTemp.createTemp(
      'healtrack_daily_sqlite_test_',
    );
    return AppDatabase(
      path: '${directory.path}${Platform.pathSeparator}healtrack.sqlite',
    );
  }

  Future<void> pumpUi(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }

  Future<void> startApp(WidgetTester tester) async {
    await tester.pumpWidget(HealTrackApp(database: await createTestDatabase()));
    expect(find.text('HealTrack Daily'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.tap(find.byKey(const Key('loginButton')));
    await pumpUi(tester);
    final getStartedButton = find.byKey(const Key('getStartedButton'));
    if (getStartedButton.evaluate().isNotEmpty) {
      await tester.tap(getStartedButton);
      await pumpUi(tester);
    }
  }

  Future<void> scrollDashboardDown(WidgetTester tester) async {
    await tester.drag(
      find.descendant(
        of: find.byType(DashboardPage),
        matching: find.byType(ListView),
      ),
      const Offset(0, -420),
    );
    await pumpUi(tester);
  }

  Future<void> scrollDashboardTop(WidgetTester tester) async {
    await tester.drag(
      find.descendant(
        of: find.byType(DashboardPage),
        matching: find.byType(ListView),
      ),
      const Offset(0, 700),
    );
    await pumpUi(tester);
  }

  test(
    'sqlite persists login, meals, bought today, and completed workout',
    () async {
      final database = await createTestDatabase();

      final authRepository = SqliteAuthRepository(database);
      final user = await authRepository.createAccount(
        email: 'persist@example.com',
        password: 'demo123',
        displayName: 'Persisted User',
      );
      final currentUser = await authRepository.getCurrentUser();
      expect(currentUser?.id, user.id);
      final db = await database.database;
      await db.update(
        'auth_users',
        {'mock_password_token': 'stale_token_from_old_local_database'},
        where: 'email = ?',
        whereArgs: [AppDatabase.fixedLocalEmail],
      );
      final fixedUser = await authRepository.login(
        email: AppDatabase.fixedLocalEmail,
        password: AppDatabase.fixedLocalPassword,
        displayName: AppDatabase.fixedLocalDisplayName,
      );
      expect(fixedUser.email, AppDatabase.fixedLocalEmail);
      await expectLater(
        authRepository.login(
          email: 'persist@example.com',
          password: 'wrong-password',
          displayName: 'Persisted User',
        ),
        throwsA(isA<StateError>()),
      );

      final nutritionRepository = SqliteNutritionRepository(database);
      await nutritionRepository.addMealLog(
        mealType: MealType.snack,
        foodName: 'Persisted yogurt',
        portion: '1 cup',
        calories: 150,
        protein: 15,
        carbs: 12,
        fat: 4,
        tags: const ['custom_food'],
      );

      final reloadedNutritionRepository = SqliteNutritionRepository(database);
      final meals = await reloadedNutritionRepository.getTodayMeals();
      expect(meals.any((meal) => meal.foodName == 'Persisted yogurt'), isTrue);

      final boughtItem = BoughtFoodItem(
        id: 'bought_test',
        productName: 'Persisted bananas',
        source: 'manual',
        quantityLabel: '2 pieces',
        addedAt: DateTime.now(),
        canAddAsMeal: false,
        tags: const ['fruit'],
      );
      final boughtRepository = SqliteBoughtFoodRepository(database);
      await boughtRepository.saveBoughtToday([boughtItem]);
      final reloadedBoughtToday = await boughtRepository.getBoughtToday();
      expect(reloadedBoughtToday.first.productName, 'Persisted bananas');

      final workoutRepository = SqliteWorkoutRepository(database);
      final workout = (await workoutRepository.getWorkoutSuggestions()).first;
      final scheduled = await workoutRepository.scheduleWorkout(
        workout: workout,
        slot: FreeTimeSlot(
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(minutes: 30)),
          durationMinutes: 30,
        ),
      );
      await workoutRepository.completeWorkout(scheduled);

      final reloadedWorkoutRepository = SqliteWorkoutRepository(database);
      final reloadedWorkout = await reloadedWorkoutRepository
          .getScheduledWorkoutToday();
      expect(reloadedWorkout?.isCompleted, true);
      expect(reloadedWorkout?.estimatedCaloriesBurned, 35);

      await authRepository.logout();
      expect(await authRepository.getCurrentUser(), isNull);
      await database.close();
    },
  );

  testWidgets('restores local auth session and shows login status', (
    tester,
  ) async {
    final database = await createTestDatabase();
    final authRepository = SqliteAuthRepository(database);
    await authRepository.createAccount(
      email: 'restored@example.com',
      password: 'demo123',
      displayName: 'Restored User',
    );

    await tester.pumpWidget(HealTrackApp(database: database));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(find.text('Good morning, Huy'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);

    await tester.tap(find.byKey(const Key('profileTab')));
    await pumpUi(tester);

    expect(find.text('Account email'), findsOneWidget);
    expect(find.text('restored@example.com'), findsOneWidget);
    expect(find.text('Login status'), findsOneWidget);
    expect(find.text('Session restored'), findsOneWidget);
  });

  testWidgets('meal flow updates dashboard calories and list', (tester) async {
    await startApp(tester);

    expect(find.text('Good morning, Huy'), findsOneWidget);
    expect(find.text('Foods'), findsOneWidget);
    expect(find.text('Meals'), findsNothing);
    expect(find.byKey(const Key('centerScanButton')), findsOneWidget);
    expect(
      find.byKey(const Key('dashboardScanIngredientButton')),
      findsNothing,
    );
    expect(find.text('940 net kcal'), findsOneWidget);
    expect(find.text('Eaten: 940 kcal'), findsOneWidget);
    expect(find.text('Estimated burned: 0 kcal'), findsOneWidget);

    await scrollDashboardDown(tester);
    await tester.tap(find.byKey(const Key('dashboardAddMealButton')));
    await pumpUi(tester);

    await tester.enterText(
      find.byKey(const Key('foodNameField')),
      'Greek yogurt',
    );
    await tester.enterText(find.byKey(const Key('portionField')), '1 cup');
    await tester.enterText(find.byKey(const Key('caloriesField')), '150');
    await tester.enterText(find.byKey(const Key('proteinField')), '15');
    await tester.enterText(find.byKey(const Key('carbsField')), '12');
    await tester.enterText(find.byKey(const Key('fatField')), '4');
    await tester.drag(
      find.descendant(
        of: find.byType(AddMealPage),
        matching: find.byType(ListView),
      ),
      const Offset(0, -600),
    );
    await pumpUi(tester);
    await tester.tap(find.byKey(const Key('saveMealButton')));
    await pumpUi(tester);

    await scrollDashboardTop(tester);
    expect(find.text('1090 net kcal'), findsOneWidget);
    await scrollDashboardDown(tester);
    expect(find.text('Greek yogurt'), findsOneWidget);

    await tester.tap(find.byKey(const Key('foodsTab')));
    await pumpUi(tester);

    expect(
      find.text('Using today nutrition and bought-today foods.'),
      findsOneWidget,
    );
    expect(find.text('custom_food'), findsWidgets);
    expect(find.text('Greek yogurt'), findsOneWidget);
  });

  testWidgets('ingredient scan mock can confirm bought food and save a meal', (
    tester,
  ) async {
    await startApp(tester);

    await tester.tap(find.byKey(const Key('centerScanButton')));
    await pumpUi(tester);
    await tester.tap(find.byKey(const Key('scanIngredientOption')));
    await pumpUi(tester);

    expect(find.text('Scan Ingredient Mock'), findsOneWidget);
    expect(find.text('Chocolate Milk'), findsWidgets);
    expect(find.text('Brand: Mock Dairy'), findsOneWidget);
    expect(find.text('bought_today'), findsOneWidget);
    expect(find.text('milk'), findsOneWidget);
    expect(find.text('sugar'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirmMockScanProductButton')));
    await pumpUi(tester);

    await tester.tap(find.byKey(const Key('foodsTab')));
    await pumpUi(tester);

    expect(find.text('Discover foods'), findsOneWidget);
    expect(
      find.text(
        'Using today nutrition, confirmed scans, and bought-today foods.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('foodsScanIngredientButton')), findsNothing);
    expect(find.byKey(const Key('foodsScanBarcodeButton')), findsNothing);
    await tester.scrollUntilVisible(find.text('Products you scanned'), 300);
    expect(find.text('Products you scanned'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Bought today'), 300);
    expect(find.text('Bought today'), findsOneWidget);
    expect(find.text('Chocolate Milk'), findsWidgets);

    await tester.tap(find.byKey(const Key('homeTab')));
    await pumpUi(tester);

    await tester.tap(find.byKey(const Key('centerScanButton')));
    await pumpUi(tester);
    await tester.tap(find.byKey(const Key('scanIngredientOption')));
    await pumpUi(tester);
    await tester.tap(find.byKey(const Key('saveMockScanMealButton')));
    await pumpUi(tester);

    expect(find.text('1150 net kcal'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Chocolate Milk'), 300);
    expect(find.text('Chocolate Milk'), findsOneWidget);
  });

  testWidgets('health stats page opens from dashboard quick action', (
    tester,
  ) async {
    await startApp(tester);

    await scrollDashboardDown(tester);
    await tester.tap(find.byKey(const Key('dashboardHealthStatsButton')));
    await pumpUi(tester);

    expect(find.text('Health Stats'), findsOneWidget);
    expect(find.text('Daily target'), findsOneWidget);
    expect(find.text('Calories by day'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('This week'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(HealthStatsPage),
            matching: find.byType(Scrollable),
          )
          .last,
    );
    expect(find.text('This week'), findsOneWidget);
  });

  testWidgets('workout scheduler mock updates dashboard', (tester) async {
    await startApp(tester);

    await scrollDashboardDown(tester);
    await tester.tap(find.byKey(const Key('dashboardPlanWorkoutButton')));
    await pumpUi(tester);

    expect(find.text('Workout Plan'), findsOneWidget);
    expect(find.text('17:30 - 18:00'), findsOneWidget);
    expect(find.text('10-min Stretching'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('scheduleWorkoutButton_workout_001')),
      120,
    );
    await tester.ensureVisible(
      find.byKey(const Key('scheduleWorkoutButton_workout_001')),
    );
    await pumpUi(tester);
    await tester.tap(
      find.byKey(const Key('scheduleWorkoutButton_workout_001')),
    );
    await pumpUi(tester);

    await tester.scrollUntilVisible(
      find.text('10-min Stretching - 10 min'),
      300,
    );
    expect(find.text('10-min Stretching - 10 min'), findsOneWidget);

    await tester.tap(find.byKey(const Key('workoutTab')));
    await pumpUi(tester);
    await tester.drag(
      find.byKey(const Key('workoutPlanList')),
      const Offset(0, 700),
    );
    await pumpUi(tester);
    await tester.drag(
      find.byKey(const Key('workoutPlanList')),
      const Offset(0, -100),
    );
    await pumpUi(tester);
    final completeButton = find.byKey(
      const Key('completeWorkoutButton_workout_001'),
    );
    await tester.tapAt(
      tester.getTopLeft(completeButton) + const Offset(80, 20),
    );
    await pumpUi(tester);

    await scrollDashboardTop(tester);
    expect(find.text('905 net kcal'), findsOneWidget);
    expect(find.text('Estimated burned: 35 kcal'), findsOneWidget);
  });
}
