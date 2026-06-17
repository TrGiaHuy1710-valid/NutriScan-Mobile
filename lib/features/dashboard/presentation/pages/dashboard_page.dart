import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/dashboard/domain/entities/daily_health_stats.dart';
import '../../../../features/food_discover/domain/bought_food_item.dart';
import '../../../../features/nutrition/domain/entities/meal_log.dart';
import '../../../../features/nutrition/domain/entities/nutrition_summary.dart';
import '../../../../features/workout/domain/entities/workout_plan.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    required this.meals,
    required this.summary,
    required this.dailyStats,
    required this.boughtToday,
    required this.workoutToday,
    required this.onAddMeal,
    required this.onPlanWorkout,
    required this.onViewHealthStats,
    required this.onDeleteMeal,
    required this.onClearMeals,
    required this.onCompleteWorkout,
    required this.onDeleteBoughtFood,
    required this.onLogBoughtFoodAsMeal,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    super.key,
  });

  final List<MealLog> meals;
  final NutritionSummary summary;
  final DailyHealthStats dailyStats;
  final List<BoughtFoodItem> boughtToday;
  final WorkoutPlan? workoutToday;
  final VoidCallback onAddMeal;
  final VoidCallback onPlanWorkout;
  final VoidCallback onViewHealthStats;
  
  final Function(String id) onDeleteMeal;
  final VoidCallback onClearMeals;
  final Function(WorkoutPlan workout) onCompleteWorkout;
  final Function(String id) onDeleteBoughtFood;
  final Function(BoughtFoodItem item, MealType mealType) onLogBoughtFoodAsMeal;

  final int targetProtein;
  final int targetCarbs;
  final int targetFat;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedDayIdx = 1; // Default Tuesday 13

  final List<Map<String, String>> _weekdayList = const [
    {'day': 'T2', 'date': '12', 'eng': 'Mon'},
    {'day': 'T3', 'date': '13', 'eng': 'Tue'},
    {'day': 'T4', 'date': '14', 'eng': 'Wed'},
    {'day': 'T5', 'date': '15', 'eng': 'Thu'},
    {'day': 'T6', 'date': '16', 'eng': 'Fri'},
  ];

  @override
  Widget build(BuildContext context) {
    final netCal = widget.dailyStats.netCalories;
    final targetCal = widget.dailyStats.targetCalories;
    final intakeCal = widget.dailyStats.intakeCalories;
    final burnedCal = widget.dailyStats.burnedCalories;
    final remainingCal = (targetCal - netCal).clamp(0, 99999);
    final percentage = targetCal > 0 ? (netCal / targetCal).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // --- 1. TOP APP BAR HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDBE6D3),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.person, color: AppTheme.vibrantSecondary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chào buổi sáng, 👋',
                          style: TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Huy Nguyễn',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                        ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hệ thống an lành: Không có thông báo mới! 🔔')),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.vibrantBorderMedium),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.notifications, color: AppTheme.vibrantTextMedium, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- 2. DAY SELECTOR STRIP ---
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_weekdayList.length, (index) {
                      final item = _weekdayList[index];
                      final isSelected = _selectedDayIdx == index;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDayIdx = index;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Xem nhật ký ngày thứ: ${item['eng']} ${item['date']}')),
                            );
                          },
                          child: Container(
                            height: 64,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.vibrantPrimary
                                  : (index == 0 ? const Color(0xFFE8F3DA) : Colors.white),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.vibrantPrimary
                                    : (index == 0 ? const Color(0xFFD2E0BD) : AppTheme.vibrantBorderMedium),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['day']!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white.withOpacity(0.85) : AppTheme.vibrantTextLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['date']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : AppTheme.vibrantTextDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mở Lịch Tháng 📅')),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.vibrantBorderMedium),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.date_range, color: AppTheme.vibrantPrimary, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- 2.5 DYNAMIC ANALYTICS DASHBOARD ENTRY CHIP ---
            Card(
              color: Colors.white,
              child: InkWell(
                onTap: widget.onViewHealthStats,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppTheme.vibrantLightHighlight,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.show_chart, color: AppTheme.vibrantPrimary, size: 16),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xem Phân Tích Xu Hướng 📊',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                              ),
                              Text(
                                'Chỉ số ngày, tuần, tháng tự nhiên',
                                style: TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight),
                              ),
                            ],
                          )
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, color: AppTheme.vibrantPrimary, size: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- 3. DAILY PROGRESS NUTRITION CARD ---
            Card(
              color: AppTheme.vibrantLightHighlight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
                side: const BorderSide(color: AppTheme.vibrantBorderLight),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tiến Trình Dinh Dưỡng',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                            ),
                            Text(
                              'Hôm nay',
                              style: TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.vibrantBorderLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Text(
                            '${(percentage * 100).toInt()}% Mục tiêu',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.vibrantSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        // Circular Gauge Meter
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: percentage,
                                strokeWidth: 10,
                                color: AppTheme.vibrantPrimary,
                                backgroundColor: Colors.white.withOpacity(0.4),
                                strokeCap: StrokeCap.round,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$netCal',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                                  ),
                                  Text(
                                    '/ $targetCal kcal',
                                    style: const TextStyle(fontSize: 10, color: AppTheme.vibrantTextLight, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),

                        // Calculation breakdown
                        Expanded(
                          child: Column(
                            children: [
                              _buildCalRow('Nạp vào 🍏', '+$intakeCal kcal', AppTheme.vibrantSecondary),
                              const Divider(color: Colors.white24),
                              _buildCalRow('Tiêu thụ ⚡', '-$burnedCal kcal', AppTheme.vibrantAlertCoral),
                              const Divider(color: Colors.white24),
                              _buildCalRow('Còn lại', '$remainingCal kcal', AppTheme.vibrantTextDark),
                            ],
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),

                    // Macros Row
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Dinh dưỡng đa lượng (Macros):',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _macroLinearCol('Đạm (P)', widget.summary.totalProtein, widget.targetProtein, AppTheme.vibrantPrimary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _macroLinearCol('Carb (C)', widget.summary.totalCarbs, widget.targetCarbs, AppTheme.vibrantSunburst),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _macroLinearCol('Béo (F)', widget.summary.totalFat, widget.targetFat, AppTheme.vibrantAlertCoral),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- 4. SCHEDULED WORKOUT TODAY ---
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bài Tập Đã Lên Lịch Hôm Nay',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vibrantSecondary),
                        ),
                        if (widget.workoutToday != null)
                          Text(
                            '1 bài',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.vibrantPrimary),
                          )
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (widget.workoutToday == null || !widget.workoutToday!.isScheduled)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            children: [
                              const Icon(Icons.favorite, color: AppTheme.vibrantBorderMedium, size: 36),
                              const SizedBox(height: 4),
                              const Text(
                                'Hôm nay chưa có bài tập nào được lên lịch.\nHãy rà soát slot giờ trống ở Tab Bài tập!',
                                style: TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: widget.onPlanWorkout,
                                child: const Text('Đi tới Lên lịch'),
                              )
                            ],
                          ),
                        ),
                      )
                    else ...[
                      Row(
                        children: [
                          Icon(
                            widget.workoutToday!.isCompleted ? Icons.check_circle : Icons.favorite_border,
                            color: widget.workoutToday!.isCompleted ? AppTheme.vibrantPrimary : AppTheme.vibrantAlertCoral,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.workoutToday!.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.vibrantTextDark,
                                    decoration: widget.workoutToday!.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                Text(
                                  '⏱ ${widget.workoutToday!.durationMinutes}p | 🔥 ${widget.workoutToday!.estimatedCaloriesBurned} kcal',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.vibrantTextMedium),
                                ),
                              ],
                            ),
                          ),
                          if (!widget.workoutToday!.isCompleted)
                            IconButton(
                              onPressed: () => widget.onCompleteWorkout(widget.workoutToday!),
                              icon: const Icon(Icons.check, color: AppTheme.vibrantPrimary),
                              tooltip: 'Hoàn thành',
                            ),
                        ],
                      )
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- 5. TODAY FOOD LOGS ---
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Thực Đơn Đã Ăn Hôm Nay',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vibrantSecondary),
                        ),
                        if (widget.meals.isNotEmpty)
                          TextButton(
                            onPressed: widget.onClearMeals,
                            child: const Text('Xoá tất cả', style: TextStyle(color: Colors.red, fontSize: 11)),
                          )
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (widget.meals.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              Icon(Icons.search, color: AppTheme.vibrantBorderMedium, size: 36),
                              SizedBox(height: 4),
                              Text(
                                'Chưa ghi nhận bữa ăn nào hôm nay.\nHọc đề xuất món nguyên bản ở Tab Món khuyên!',
                                style: TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.meals.length,
                        itemBuilder: (context, idx) {
                          final meal = widget.meals[idx];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.vibrantLightHighlight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    _getMealLetter(meal.mealType),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.vibrantPrimary),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(meal.foodName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark)),
                                      Text(
                                        '🍗 ${meal.portion} | 🔥 ${meal.calories} kcal | P: ${meal.protein}g C: ${meal.carbs}g F: ${meal.fat}g',
                                        style: const TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => widget.onDeleteMeal(meal.id),
                                  icon: const Icon(Icons.close, color: AppTheme.vibrantAlertCoral, size: 18),
                                  tooltip: 'Xoá bữa',
                                )
                              ],
                            ),
                          );
                        },
                      )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- 6. BOUGHT TODAY ITEMS ---
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thực Phẩm Mới Mua Hôm Nay',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vibrantSecondary),
                    ),
                    const SizedBox(height: 12),
                    if (widget.boughtToday.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'Chưa có thực phẩm nào được mua hôm nay.',
                            style: TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.boughtToday.length,
                        itemBuilder: (context, idx) {
                          final item = widget.boughtToday[idx];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.shopping_bag_outlined, color: AppTheme.vibrantPrimary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.productName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark)),
                                      Text(item.quantityLabel, style: const TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight)),
                                    ],
                                  ),
                                ),
                                if (item.canAddAsMeal)
                                  TextButton(
                                    onPressed: () => _showLogBoughtAsMealDialog(item),
                                    child: const Text('Log bữa ăn', style: TextStyle(fontSize: 11)),
                                  ),
                                IconButton(
                                  onPressed: () => widget.onDeleteBoughtFood(item.id),
                                  icon: const Icon(Icons.delete_outline, color: AppTheme.vibrantAlertCoral, size: 18),
                                )
                              ],
                            ),
                          );
                        },
                      )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCalRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.vibrantTextDark, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _macroLinearCol(String label, int actual, int target, Color color) {
    final ratio = target > 0 ? (actual / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            Text('$actual/${target}g', style: const TextStyle(fontSize: 9, color: AppTheme.vibrantTextLight)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            color: color,
            backgroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  String _getMealLetter(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'S';
      case MealType.lunch:
        return 'T';
      case MealType.dinner:
        return 'T';
      case MealType.snack:
        return 'N';
    }
  }

  void _showLogBoughtAsMealDialog(BoughtFoodItem item) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log bữa ăn thực tế 🍏', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Bạn muốn ghi nhận "${item.productName}" vào bữa ăn nào hôm nay?'),
          actions: [
            TextButton(
              onPressed: () {
                widget.onLogBoughtFoodAsMeal(item, MealType.breakfast);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã log ${item.productName} vào Bữa Sáng!')),
                );
              },
              child: const Text('Bữa Sáng'),
            ),
            TextButton(
              onPressed: () {
                widget.onLogBoughtFoodAsMeal(item, MealType.lunch);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã log ${item.productName} vào Bữa Trưa!')),
                );
              },
              child: const Text('Bữa Trưa'),
            ),
            TextButton(
              onPressed: () {
                widget.onLogBoughtFoodAsMeal(item, MealType.dinner);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã log ${item.productName} vào Bữa Tối!')),
                );
              },
              child: const Text('Bữa Tối'),
            ),
          ],
        );
      },
    );
  }
}


