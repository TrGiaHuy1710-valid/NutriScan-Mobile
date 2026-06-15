import 'package:flutter/material.dart';

import 'core/persistence/app_database.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/usecases/create_account_usecase.dart';
import 'features/auth/application/usecases/get_current_user_usecase.dart';
import 'features/auth/application/usecases/login_usecase.dart';
import 'features/auth/application/usecases/logout_usecase.dart';
import 'features/auth/data/repositories/sqlite_auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/domain/entities/daily_health_stats.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/dashboard/presentation/pages/health_stats_page.dart';
import 'features/food_discover/application/usecases/build_food_recommendations_usecase.dart';
import 'features/food_discover/application/usecases/get_bought_today_usecase.dart';
import 'features/food_discover/application/usecases/save_bought_today_usecase.dart';
import 'features/food_discover/data/mock_food_discover_data.dart';
import 'features/food_discover/data/repositories/sqlite_bought_food_repository.dart';
import 'features/food_discover/domain/bought_food_item.dart';
import 'features/food_discover/domain/food_recommendation.dart';
import 'features/food_discover/domain/scanned_product.dart';
import 'features/food_discover/presentation/pages/foods_discover_page.dart';
import 'features/food_discover/presentation/cubit/food_discover_cubit.dart';
import 'features/food_scan/presentation/pages/scan_barcode_page.dart';
import 'features/food_scan/presentation/pages/scan_food_page.dart';
import 'features/food_scan/presentation/pages/scan_ingredient_page.dart';
import 'features/calendar/application/usecases/get_free_time_slots_usecase.dart';
import 'features/calendar/domain/entities/free_time_slot.dart';
import 'features/calendar/data/repositories/fake_calendar_repository.dart';
import 'features/nutrition/application/usecases/add_meal_log_usecase.dart';
import 'features/nutrition/application/usecases/calculate_today_nutrition_usecase.dart';
import 'features/nutrition/application/usecases/get_today_meals_usecase.dart';
import 'features/nutrition/data/repositories/sqlite_nutrition_repository.dart';
import 'features/nutrition/domain/entities/nutrition_summary.dart';
import 'features/nutrition/presentation/cubit/nutrition_cubit.dart';
import 'features/nutrition/presentation/pages/add_meal_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/onboarding/presentation/pages/splash_screen.dart';
import 'features/profile/data/mock_profile_data.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/workout/application/usecases/complete_workout_usecase.dart';
import 'features/workout/application/usecases/get_scheduled_workout_usecase.dart';
import 'features/workout/application/usecases/get_workout_suggestions_usecase.dart';
import 'features/workout/application/usecases/schedule_workout_usecase.dart';
import 'features/workout/data/repositories/sqlite_workout_repository.dart';
import 'features/workout/domain/entities/workout_plan.dart';
import 'features/workout/presentation/cubit/workout_cubit.dart';
import 'features/workout/presentation/pages/workout_plan_page.dart';

class HealTrackApp extends StatelessWidget {
  const HealTrackApp({this.database, super.key});

  final AppDatabase? database;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealTrack Daily',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: HealTrackHome(database: database),
    );
  }
}

class HealTrackHome extends StatefulWidget {
  const HealTrackHome({this.database, super.key});

  final AppDatabase? database;

  @override
  State<HealTrackHome> createState() => _HealTrackHomeState();
}

class _HealTrackHomeState extends State<HealTrackHome> {
  bool _hasSeenSplash = false;
  bool _hasFinishedOnboarding = false;
  int _selectedIndex = 0;
  late final AppDatabase _database;
  late final AuthCubit _authCubit;
  late final NutritionCubit _nutritionCubit;
  late final WorkoutCubit _workoutCubit;
  late final FoodDiscoverCubit _foodDiscoverCubit;
  final _buildFoodRecommendationsUseCase =
      const BuildFoodRecommendationsUseCase();
  final List<ScannedProduct> _recentlyScannedProducts = [];
  final List<FoodRecommendation> _customFoodRecommendations = [];

  @override
  void initState() {
    super.initState();

    _database = widget.database ?? AppDatabase();

    final authRepository = SqliteAuthRepository(_database);
    _authCubit = AuthCubit(
      createAccountUseCase: CreateAccountUseCase(authRepository),
      getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
      loginUseCase: LoginUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
    );
    _authCubit.addListener(_syncAuthContinuity);
    _authCubit.loadSession();

    final nutritionRepository = SqliteNutritionRepository(_database);
    _nutritionCubit = NutritionCubit(
      addMealLogUseCase: AddMealLogUseCase(nutritionRepository),
      getTodayMealsUseCase: GetTodayMealsUseCase(nutritionRepository),
      calculateTodayNutritionUseCase: const CalculateTodayNutritionUseCase(),
    )..loadTodayNutrition();

    final calendarRepository = FakeCalendarRepository();
    final workoutRepository = SqliteWorkoutRepository(_database);
    _workoutCubit = WorkoutCubit(
      getFreeTimeSlotsUseCase: GetFreeTimeSlotsUseCase(calendarRepository),
      getWorkoutSuggestionsUseCase: GetWorkoutSuggestionsUseCase(
        workoutRepository,
      ),
      getScheduledWorkoutUseCase: GetScheduledWorkoutUseCase(workoutRepository),
      scheduleWorkoutUseCase: ScheduleWorkoutUseCase(workoutRepository),
      completeWorkoutUseCase: CompleteWorkoutUseCase(workoutRepository),
    )..loadWorkoutPlan();

    final foodDiscoverRepository = SqliteBoughtFoodRepository(_database);
    _foodDiscoverCubit = FoodDiscoverCubit(
      getBoughtTodayUseCase: GetBoughtTodayUseCase(foodDiscoverRepository),
      saveBoughtTodayUseCase: SaveBoughtTodayUseCase(foodDiscoverRepository),
    )..loadBoughtToday();

    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _hasSeenSplash = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _workoutCubit.dispose();
    _nutritionCubit.dispose();
    _foodDiscoverCubit.dispose();
    _authCubit.removeListener(_syncAuthContinuity);
    _authCubit.dispose();
    _database.close();
    super.dispose();
  }

  void _syncAuthContinuity() {
    final isAuthenticated =
        _authCubit.state.status == AuthStatus.authenticated;
    if (!mounted || !isAuthenticated || _hasFinishedOnboarding) {
      return;
    }

    setState(() {
      _hasFinishedOnboarding = true;
    });
  }

  void _finishOnboarding() {
    setState(() {
      _hasFinishedOnboarding = true;
    });
  }

  Future<void> _login({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await _authCubit.login(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  Future<void> _createAccount({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await _authCubit.createAccount(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  Future<void> _logout() async {
    await _authCubit.logout();
    setState(() {
      _hasFinishedOnboarding = false;
      _selectedIndex = 0;
    });
  }

  void _goToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openAddMeal() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddMealPage(onMealSaved: _saveMeal)),
    );
  }

  Future<void> _saveMeal(AddMealLogParams params) async {
    await _nutritionCubit.addMeal(params);
    _saveCustomFoodRecommendation(params);
    _goToTab(0);
  }

  Future<void> _addRecommendedMeal(AddMealLogParams params) async {
    await _nutritionCubit.addMeal(params);
    _goToTab(0);
  }

  void _saveCustomFoodRecommendation(AddMealLogParams params) {
    final exists = [...mockFoodRecommendations, ..._customFoodRecommendations]
        .any(
          (recommendation) =>
              recommendation.title.toLowerCase() ==
              params.foodName.toLowerCase(),
        );
    if (exists) {
      return;
    }

    setState(() {
      _customFoodRecommendations.insert(
        0,
        FoodRecommendation(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          section: 'Custom foods',
          title: params.foodName,
          description: 'Saved from your manual meal log for future ideas.',
          tags: {...params.tags, 'custom_food'}.toList(),
          mealSuggestion: params,
        ),
      );
    });
  }

  Future<void> _confirmScannedProduct(ScannedProduct product) async {
    setState(() {
      _recentlyScannedProducts.removeWhere((item) => item.id == product.id);
      _recentlyScannedProducts.insert(0, product);
    });
    await _foodDiscoverCubit.upsertBoughtFood(
      BoughtFoodItem(
        id: 'bought_${DateTime.now().millisecondsSinceEpoch}',
        productId: product.id,
        productName: product.productName,
        source: product.source,
        quantityLabel: product.quantityLabel,
        addedAt: DateTime.now(),
        canAddAsMeal: product.isMealLike,
        tags: product.tags,
      ),
    );
  }

  void _openHealthStats() {
    final nutritionState = _nutritionCubit.state;
    final workoutState = _workoutCubit.state;
    final dailyStats = _buildDailyStats(
      summary: nutritionState.summary,
      workoutToday: workoutState.scheduledWorkout,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HealthStatsPage(
          summary: nutritionState.summary,
          dailyStats: dailyStats,
          workoutToday: workoutState.scheduledWorkout,
        ),
      ),
    );
  }

  void _showScanOptions() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ScanOptionTile(
                    key: const Key('scanFoodOption'),
                    icon: Icons.camera_alt_outlined,
                    title: 'Scan Food',
                    subtitle: 'Mock food estimate',
                    onTap: () {
                      Navigator.of(context).pop();
                      _openScanFood();
                    },
                  ),
                  _ScanOptionTile(
                    key: const Key('scanIngredientOption'),
                    icon: Icons.receipt_long_outlined,
                    title: 'Scan Ingredient Label',
                    subtitle: 'Mock ingredient insights',
                    onTap: () {
                      Navigator.of(context).pop();
                      _openScanIngredient();
                    },
                  ),
                  _ScanOptionTile(
                    key: const Key('scanBarcodeOption'),
                    icon: Icons.qr_code_scanner,
                    title: 'Scan Barcode',
                    subtitle: 'Mock barcode product lookup',
                    onTap: () {
                      Navigator.of(context).pop();
                      _openScanBarcode();
                    },
                  ),
                  _ScanOptionTile(
                    key: const Key('manualAddFallbackOption'),
                    icon: Icons.edit_outlined,
                    title: 'Add manually',
                    subtitle: 'Fallback when scan is unclear',
                    onTap: () {
                      Navigator.of(context).pop();
                      _openAddMeal();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openScanFood() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScanFoodPage(
          onProductConfirmed: _confirmScannedProduct,
          onMealSaved: _saveMeal,
        ),
      ),
    );
  }

  void _openScanIngredient() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScanIngredientPage(
          onProductConfirmed: _confirmScannedProduct,
          onMealSaved: _saveMeal,
        ),
      ),
    );
  }

  void _openScanBarcode() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScanBarcodePage(
          onProductConfirmed: _confirmScannedProduct,
          onMealSaved: _saveMeal,
        ),
      ),
    );
  }

  Future<void> _scheduleWorkout(WorkoutPlan workout) async {
    await _workoutCubit.scheduleWorkout(workout: workout);
    _goToTab(0);
  }

  Future<void> _completeWorkout(WorkoutPlan workout) async {
    await _workoutCubit.completeWorkout(workout);
    _goToTab(0);
  }

  void _selectSlot(FreeTimeSlot? slot) {
    _workoutCubit.selectSlot(slot);
  }

  DailyHealthStats _buildDailyStats({
    required NutritionSummary summary,
    required WorkoutPlan? workoutToday,
  }) {
    return DailyHealthStats(
      intakeCalories: summary.totalCalories,
      burnedCalories: workoutToday?.isCompleted == true
          ? workoutToday!.estimatedCaloriesBurned
          : 0,
      targetCalories: 2000,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasSeenSplash) {
      return const SplashScreen();
    }

    return ListenableBuilder(
      listenable: _authCubit,
      builder: (context, _) {
        final authState = _authCubit.state;
        if (authState.status == AuthStatus.loading ||
            authState.status == AuthStatus.initial) {
          return const SplashScreen();
        }

        if (authState.status != AuthStatus.authenticated) {
          return LoginPage(
            isLoading: authState.status == AuthStatus.loading,
            errorMessage: authState.errorMessage,
            onLogin: _login,
            onCreateAccount: _createAccount,
          );
        }

        return _buildAuthenticatedApp();
      },
    );
  }

  Widget _buildAuthenticatedApp() {
    if (!_hasFinishedOnboarding) {
      return OnboardingPage(onFinish: _finishOnboarding);
    }

    return Scaffold(
      body: ListenableBuilder(
        listenable: Listenable.merge([
          _nutritionCubit,
          _workoutCubit,
          _foodDiscoverCubit,
        ]),
        builder: (context, _) {
          final nutritionState = _nutritionCubit.state;
          final workoutState = _workoutCubit.state;
          final foodDiscoverState = _foodDiscoverCubit.state;
          final authState = _authCubit.state;
          final dailyStats = _buildDailyStats(
            summary: nutritionState.summary,
            workoutToday: workoutState.scheduledWorkout,
          );
          final recommendationPlan = _buildFoodRecommendationsUseCase(
            profile: mockUserHealthProfile,
            summary: nutritionState.summary,
            baseRecommendations: mockFoodRecommendations,
            customRecommendations: _customFoodRecommendations,
            recentlyScannedProducts: _recentlyScannedProducts,
            boughtToday: foodDiscoverState.boughtToday,
          );
          final pages = [
            DashboardPage(
              meals: nutritionState.meals,
              summary: nutritionState.summary,
              dailyStats: dailyStats,
              boughtToday: foodDiscoverState.boughtToday,
              workoutToday: workoutState.scheduledWorkout,
              onAddMeal: _openAddMeal,
              onPlanWorkout: () => _goToTab(2),
              onViewHealthStats: _openHealthStats,
            ),
            FoodsDiscoverPage(
              recentlyScannedProducts: _recentlyScannedProducts,
              boughtToday: foodDiscoverState.boughtToday,
              recommendations: recommendationPlan.recommendations,
              activeTags: recommendationPlan.activeTags,
              recommendationReason: recommendationPlan.reason,
              onAddRecommendedMeal: _addRecommendedMeal,
            ),
            WorkoutPlanPage(
              freeTimeSlots: workoutState.freeTimeSlots,
              workoutSuggestions: workoutState.workoutSuggestions,
              scheduledWorkout: workoutState.scheduledWorkout,
              selectedSlot: workoutState.selectedSlot,
              calendarEvents: workoutState.calendarEvents,
              upcomingPlans: workoutState.upcomingPlans,
              onWorkoutScheduled: _scheduleWorkout,
              onWorkoutCompleted: _completeWorkout,
              onSelectSlot: _selectSlot,
            ),
            ProfilePage(
              profile: mockUserHealthProfile,
              accountEmail: authState.user?.email ?? 'Local account',
              loginStatus:
                  authState.successMessage ?? 'Logged in successfully',
              onLogout: _logout,
            ),
          ];

          return IndexedStack(index: _selectedIndex, children: pages);
        },
      ),
      floatingActionButton: FloatingActionButton.large(
        key: const Key('centerScanButton'),
        onPressed: _showScanOptions,
        child: const Icon(Icons.document_scanner_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          children: [
            Expanded(
              child: _BottomNavItem(
                key: const Key('homeTab'),
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
                selected: _selectedIndex == 0,
                onTap: () => _goToTab(0),
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                key: const Key('foodsTab'),
                icon: Icons.explore_outlined,
                selectedIcon: Icons.explore,
                label: 'Foods',
                selected: _selectedIndex == 1,
                onTap: () => _goToTab(1),
              ),
            ),
            const SizedBox(width: 84),
            Expanded(
              child: _BottomNavItem(
                key: const Key('workoutTab'),
                icon: Icons.fitness_center_outlined,
                selectedIcon: Icons.fitness_center,
                label: 'Workout',
                selected: _selectedIndex == 2,
                onTap: () => _goToTab(2),
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                key: const Key('profileTab'),
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'Profile',
                selected: _selectedIndex == 3,
                onTap: () => _goToTab(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = selected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? selectedIcon : icon, color: color),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanOptionTile extends StatelessWidget {
  const _ScanOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
