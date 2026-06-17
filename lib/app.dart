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
import 'features/food_discover/application/usecases/get_bought_today_usecase.dart';
import 'features/food_discover/application/usecases/save_bought_today_usecase.dart';
import 'features/food_discover/data/mock_food_discover_data.dart';
import 'features/food_discover/data/repositories/sqlite_bought_food_repository.dart';
import 'features/food_discover/domain/bought_food_item.dart';
import 'features/food_discover/domain/food_recommendation.dart';
import 'features/food_discover/domain/scanned_product.dart';
import 'features/food_discover/presentation/pages/foods_discover_page.dart';
import 'features/food_discover/presentation/cubit/food_discover_cubit.dart';
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
import 'features/profile/data/repositories/sqlite_profile_repository.dart';
import 'features/profile/application/usecases/get_profile_usecase.dart';
import 'features/profile/application/usecases/update_profile_usecase.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
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
  late final ProfileCubit _profileCubit;


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

    final profileRepository = SqliteProfileRepository(_database);
    _profileCubit = ProfileCubit(
      getProfileUseCase: GetProfileUseCase(profileRepository),
      updateProfileUseCase: UpdateProfileUseCase(profileRepository),
    )..loadProfile();

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
    _profileCubit.dispose();
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
    final profile = _profileCubit.state.profile ?? mockUserHealthProfile;
    final dailyStats = _buildDailyStats(
      summary: nutritionState.summary,
      workoutToday: workoutState.scheduledWorkout,
      targetCalories: profile.targetCalories,
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
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: _ScanBottomSheetContent(
              onProductConfirmed: _confirmScannedProduct,
              onMealSaved: _saveMeal,
            ),
          ),
        );
      },
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
    required int targetCalories,
  }) {
    return DailyHealthStats(
      intakeCalories: summary.totalCalories,
      burnedCalories: workoutToday?.isCompleted == true
          ? workoutToday!.estimatedCaloriesBurned
          : 0,
      targetCalories: targetCalories,
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
          _profileCubit,
        ]),
        builder: (context, _) {
          final nutritionState = _nutritionCubit.state;
          final workoutState = _workoutCubit.state;
          final foodDiscoverState = _foodDiscoverCubit.state;
          final profileState = _profileCubit.state;
          final authState = _authCubit.state;

          final userProfile = profileState.profile ?? mockUserHealthProfile;

          final dailyStats = _buildDailyStats(
            summary: nutritionState.summary,
            workoutToday: workoutState.scheduledWorkout,
            targetCalories: userProfile.targetCalories,
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
              onDeleteMeal: _nutritionCubit.deleteMeal,
              onClearMeals: _nutritionCubit.clearAllMeals,
              onCompleteWorkout: _workoutCubit.completeWorkout,
              onDeleteBoughtFood: _foodDiscoverCubit.deleteBoughtFood,
              onLogBoughtFoodAsMeal: (item, type) {
                _nutritionCubit.addMeal(
                  AddMealLogParams(
                    mealType: type,
                    foodName: item.productName,
                    portion: item.quantityLabel,
                    calories: 150,
                    protein: 8,
                    carbs: 20,
                    fat: 5,
                  ),
                );
              },
              targetProtein: userProfile.targetProtein,
              targetCarbs: userProfile.targetCarbs,
              targetFat: userProfile.targetFat,
            ),
            FoodsDiscoverPage(
              recentlyScannedProducts: _recentlyScannedProducts,
              boughtToday: foodDiscoverState.boughtToday,
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
              profile: userProfile,
              accountEmail: authState.user?.email ?? 'Local account',
              loginStatus: authState.successMessage ?? 'Logged in successfully',
              onProfileUpdated: ({required name, required weight, required height, required age, required goal, required restrictions}) =>
                  _profileCubit.updateProfile(name: name, weight: weight, height: height, age: age, goal: goal, restrictions: restrictions),
              onCustomTargetsUpdated: ({required calories, required protein, required carbs, required fat}) =>
                  _profileCubit.updateCustomTargets(calories: calories, protein: protein, carbs: carbs, fat: fat),
              onClearMeals: _nutritionCubit.clearAllMeals,
              onClearScanned: _foodDiscoverCubit.clearBoughtFoods,
              onClearWorkouts: _workoutCubit.clearAllWorkouts,
              onResetAll: () {
                _profileCubit.updateProfile(name: 'Huy Nguyễn', weight: 60.0, height: 165.0, age: 22, goal: 'Giữ cân', restrictions: '');
                _nutritionCubit.clearAllMeals();
                _foodDiscoverCubit.clearBoughtFoods();
                _workoutCubit.clearAllWorkouts();
              },
              onLogout: _logout,
            ),
          ];

          return IndexedStack(index: _selectedIndex, children: pages);
        },
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppTheme.vibrantPrimary, AppTheme.vibrantSecondary],
          ),
        ),
        child: FloatingActionButton(
          key: const Key('centerScanButton'),
          onPressed: _showScanOptions,
          elevation: 4,
          backgroundColor: Colors.transparent,
          child: const Icon(Icons.star, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: _BottomNavItem(
                key: const Key('homeTab'),
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Trang chủ',
                selected: _selectedIndex == 0,
                onTap: () => _goToTab(0),
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                key: const Key('foodsTab'),
                icon: Icons.search_outlined,
                selectedIcon: Icons.search,
                label: 'Món khuyên',
                selected: _selectedIndex == 1,
                onTap: () => _goToTab(1),
              ),
            ),
            const SizedBox(width: 84),
            Expanded(
              child: _BottomNavItem(
                key: const Key('workoutTab'),
                icon: Icons.favorite_border_outlined,
                selectedIcon: Icons.favorite,
                label: 'Bài tập',
                selected: _selectedIndex == 2,
                onTap: () => _goToTab(2),
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                key: const Key('profileTab'),
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'Hồ sơ',
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
    final color = selected ? AppTheme.vibrantPrimary : AppTheme.vibrantTextLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 28,
              width: 52,
              decoration: BoxDecoration(
                color: selected ? AppTheme.vibrantLightHighlight : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(selected ? selectedIcon : icon, color: color, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanBottomSheetContent extends StatefulWidget {
  const _ScanBottomSheetContent({
    required this.onProductConfirmed,
    required this.onMealSaved,
  });

  final Future<void> Function(ScannedProduct product) onProductConfirmed;
  final Future<void> Function(AddMealLogParams params) onMealSaved;

  @override
  State<_ScanBottomSheetContent> createState() => _ScanBottomSheetContentState();
}

class _ScanBottomSheetContentState extends State<_ScanBottomSheetContent> {
  int _activeScanSubTab = 0; // 0: Ăn uống, 1: Nhãn thành phần, 2: Thực phẩm
  final _ingInputCtrl = TextEditingController();
  bool _isAnalyzing = false;
  String? _analysisResult;

  final List<String> _samples = const [
    'Nước ép táo cô đặc, đường hoá học, chất điều vị, E202',
    'Quả óc sấy, yến mạch nguyên cám, mật ong tự nhiên, muối biển'
  ];

  @override
  void dispose() {
    _ingInputCtrl.dispose();
    super.dispose();
  }

  void _analyze() {
    if (_ingInputCtrl.text.isEmpty) return;
    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          final isHealthy = _ingInputCtrl.text.contains('yến mạch') || _ingInputCtrl.text.contains('hạt') || _ingInputCtrl.text.contains('óc');
          if (isHealthy) {
            _analysisResult = '📝 NHẬN XÉT: Nguồn dinh dưỡng dồi dào chất xơ và chất béo tốt từ các loại hạt.\n⚠️ CẢNH BÁO: Ít chất béo bão hòa và không chứa đường tinh luyện.\n🌿 GỢI Ý: Cực kỳ lành mạnh, thích hợp cho bữa sáng hoặc bữa phụ dinh dưỡng.';
          } else {
            _analysisResult = '📝 NHẬN XÉT: Nguồn thực phẩm chế biến sẵn, chứa đường và chất bảo quản.\n⚠️ CẢNH BÁO: Chứa E202 và đường cô đặc, nên điều tiết lượng nạp để tránh tích mỡ.\n🍎 GỢI Ý: Hạn chế sử dụng thường xuyên. Kết hợp thêm rau quả tươi.';
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Máy Quét HealTrack 🤳',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.vibrantSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Tab Selection Pills
          Container(
            decoration: BoxDecoration(
              color: AppTheme.vibrantBorderMedium.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _subTabPill('Ăn uống', 0),
                _subTabPill('Nhãn thành phần', 1),
                _subTabPill('Thực phẩm', 2),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_activeScanSubTab == 0) _buildDishTab(),
          if (_activeScanSubTab == 1) _buildIngredientsTab(),
          if (_activeScanSubTab == 2) _buildBarcodeTab(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _subTabPill(String title, int idx) {
    final isSel = _activeScanSubTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeScanSubTab = idx),
        child: Container(
          decoration: BoxDecoration(
            color: isSel ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSel
                ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
              color: isSel ? AppTheme.vibrantPrimary : AppTheme.vibrantTextMedium,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDishTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giả Lập Camera Nhận Diện Món Ăn:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
        ),
        const SizedBox(height: 4),
        const Text(
          'Đưa máy ảnh trước đĩa ăn của bạn. Hệ thống sử dụng thị giác máy tính giả lập để trích xuất hàm lượng dinh dưỡng.',
          style: TextStyle(fontSize: 12, color: AppTheme.vibrantTextLight),
        ),
        const SizedBox(height: 16),

        // Finder View Box
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 220,
                height: 130,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.vibrantPrimary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Icon(Icons.search, color: Colors.white24, size: 56),
              const Positioned(
                bottom: 12,
                child: Text(
                  'HealTrack Vision Active',
                  style: TextStyle(color: AppTheme.vibrantPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Chọn món ăn giả lập:',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            _dishMockButton('Bún bò Huế', 420, '1 tô lớn', ['balanced', 'high_protein']),
            const SizedBox(width: 8),
            _dishMockButton('Xôi gà chiên', 530, '1 đĩa', ['high_protein']),
            const SizedBox(width: 8),
            _dishMockButton('Gỏi cuốn tôm', 180, '3 chiếc', ['light', 'balanced']),
          ],
        )
      ],
    );
  }

  Widget _dishMockButton(String name, int cal, String portion, List<String> tags) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          final product = ScannedProduct(
            id: 'dish_${name.hashCode}',
            productName: name,
            source: 'SCAN_FOOD',
            quantityLabel: portion,
            scannedAt: DateTime.now(),
            isMealLike: true,
            tags: tags,
          );
          await widget.onProductConfirmed(product);
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã nhận diện: $name ($cal Kcal)')),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.vibrantLightHighlight,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.vibrantSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text('$cal Kcal', style: const TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phân Tích Thành Phần Bì Sản Phẩm:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
        ),
        const SizedBox(height: 4),
        const Text(
          'Nhập danh sách thành phần thực phẩm để nhận tư vấn cảnh báo dinh dưỡng nguyên bản từ trí tuệ nhân tạo Gemini.',
          style: TextStyle(fontSize: 12, color: AppTheme.vibrantTextLight),
        ),
        const SizedBox(height: 12),

        TextFormField(
          controller: _ingInputCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Đường cát, bột ngọt, chất béo bão hòa, siro ngô fructozơ, protein đậu nành, dầu cọ...',
            hintStyle: TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),

        const Text('Ví dụ gợi ý:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextMedium)),
        const SizedBox(height: 6),

        Row(
          children: _samples.map((sample) {
            return Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: AppTheme.vibrantBorderMedium.withOpacity(0.3),
                child: InkWell(
                  onTap: () => setState(() => _ingInputCtrl.text = sample),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      sample,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: AppTheme.vibrantTextDark),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        ElevatedButton.icon(
          onPressed: _analyze,
          icon: _isAnalyzing
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.info_outline, size: 16),
          label: Text(_isAnalyzing ? 'Trợ lý Gemini đang phân tích...' : 'Phân Tích Bằng Trí Tuệ Nhân Tạo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.vibrantPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size.fromHeight(44),
          ),
        ),

        if (_analysisResult != null) ...[
          const SizedBox(height: 16),
          Card(
            color: AppTheme.vibrantLightHighlight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppTheme.vibrantPrimary.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check, color: AppTheme.vibrantPrimary, size: 16),
                      SizedBox(width: 6),
                      Text('Kết Quả Phân Tích Thực Phẩm:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.vibrantSecondary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(_analysisResult!, style: const TextStyle(fontSize: 12, color: AppTheme.vibrantTextDark, height: 1.4)),
                  const SizedBox(height: 6),
                  const Text('Lời khuyên mang tính tham khảo phi y tế.', style: TextStyle(fontSize: 9, color: AppTheme.vibrantTextLight, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )
        ],
      ],
    );
  }

  Widget _buildBarcodeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giả Lập Quét Mã Vạch Sản Phẩm:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
        ),
        const SizedBox(height: 4),
        const Text(
          'Nhắm mã vạch nằm giữa khung ngắm Laser để xác minh sản phẩm trong cơ sở dữ liệu.',
          style: TextStyle(fontSize: 12, color: AppTheme.vibrantTextLight),
        ),
        const SizedBox(height: 16),

        // Viewfinder
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 180,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 2,
                width: 280,
                color: Colors.red,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text('Ấn mã vạch mẫu để mô phỏng quét thực tế:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark)),
        const SizedBox(height: 8),

        _barcodeMockButton('8930001', 'Sữa tươi hữu cơ TH True Milk', '1 hộp 180ml'),
        const SizedBox(height: 8),
        _barcodeMockButton('8930002', 'Sữa chua Vinamilk ít đường', '1 hộp 100g'),
        const SizedBox(height: 8),
        _barcodeMockButton('8930003', 'Đậu nành hạt sấy giòn Fami', '1 gói 150g'),
      ],
    );
  }

  Widget _barcodeMockButton(String barcode, String name, String qtyLabel) {
    return OutlinedButton(
      onPressed: () async {
        final product = ScannedProduct(
          id: 'barcode_$barcode',
          productName: name,
          source: 'SCAN_BARCODE',
          quantityLabel: qtyLabel,
          scannedAt: DateTime.now(),
          isMealLike: true,
          tags: const ['quick_meal'],
        );
        await widget.onProductConfirmed(product);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã lưu vào danh mục Bought Today!')),
          );
        }
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppTheme.vibrantPrimary.withOpacity(0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 12, color: AppTheme.vibrantTextDark, fontWeight: FontWeight.w500)),
          Text('Barcode #$barcode', style: const TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
