import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/dashboard/domain/entities/daily_health_stats.dart';
import '../../../../features/nutrition/domain/entities/nutrition_summary.dart';
import '../../../../features/workout/domain/entities/workout_plan.dart';

class HealthStatsPage extends StatefulWidget {
  const HealthStatsPage({
    required this.summary,
    required this.dailyStats,
    required this.workoutToday,
    super.key,
  });

  final NutritionSummary summary;
  final DailyHealthStats dailyStats;
  final WorkoutPlan? workoutToday;

  @override
  State<HealthStatsPage> createState() => _HealthStatsPageState();
}

class _HealthStatsPageState extends State<HealthStatsPage> {
  int _selectedTab = 0; // 0: Ngày, 1: Tuần, 2: Tháng

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Phân Tích 📊'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Segment selector pill strip
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.vibrantBorderMedium),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _segmentPill('Theo Ngày', 0),
                  _segmentPill('Theo Tuần', 1),
                  _segmentPill('Theo Tháng', 2),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tabs views
            if (_selectedTab == 0) _buildDailyView(),
            if (_selectedTab == 1) _buildWeeklyView(),
            if (_selectedTab == 2) _buildMonthlyView(),

            const SizedBox(height: 24),

            // Gold wellness advice card
            Card(
              color: AppTheme.vibrantSecondary,
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.vibrantVolt,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lời khuyên vàng hôm nay từ HealTrack 🌱',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.vibrantVolt,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Duy trì uống đủ 2 lít nước và tập các bài tập rảnh rỗi trên 20 phút mỗi ngày sẽ tăng tỷ lệ tiêu thụ năng lượng cơ bản cơ thể lên 12%!',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
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

  Widget _segmentPill(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.vibrantPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppTheme.vibrantTextMedium,
            ),
          ),
        ),
      ),
    );
  }

  // --- Tab 1: Daily View ---
  Widget _buildDailyView() {
    final summary = widget.summary;
    final stats = widget.dailyStats;

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tóm tắt dinh dưỡng hôm nay',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
            ),
            const SizedBox(height: 16),

            // Macros progress list
            Row(
              children: [
                Expanded(
                  child: _macroRowItem('Đạm (P)', summary.totalProtein, 120, AppTheme.vibrantPrimary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _macroRowItem('Carbs (C)', summary.totalCarbs, 230, AppTheme.vibrantSunburst),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _macroRowItem('Béo (F)', summary.totalFat, 67, AppTheme.vibrantAlertCoral),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Divider(),
            const SizedBox(height: 12),

            const Text(
              'Ghi chép calo ròng:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
            ),
            const SizedBox(height: 8),
            _calorieDetailRow('Calo nạp vào 🍏', '+${stats.intakeCalories} kcal', AppTheme.vibrantPrimary),
            _calorieDetailRow('Calo tiêu thụ ⚡', '-${stats.burnedCalories} kcal', AppTheme.vibrantAlertCoral),
            const Divider(),
            _calorieDetailRow('Calo ròng ⚖️', '${stats.netCalories} kcal', AppTheme.vibrantSecondary, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _macroRowItem(String label, int current, int target, Color color) {
    final ratio = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.vibrantBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.vibrantBorderMedium),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextLight),
          ),
          const SizedBox(height: 4),
          Text(
            '$current / $target',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 4,
              backgroundColor: AppTheme.vibrantBorderMedium,
              color: color,
            ),
          )
        ],
      ),
    );
  }

  Widget _calorieDetailRow(String label, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.vibrantTextMedium)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // --- Tab 2: Weekly View ---
  Widget _buildWeeklyView() {
    final stats = widget.dailyStats;
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lượng Calo Tiêu Thụ Trong Tuần',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                    ),
                    Text(
                      'Biểu đồ cột so sánh Nạp 🟢 vs Đốt 🔴',
                      style: TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight),
                    ),
                  ],
                ),
                Icon(Icons.star, color: AppTheme.vibrantPrimary, size: 24),
              ],
            ),
            const SizedBox(height: 24),

            // Bar chart canvas
            SizedBox(
              height: 180,
              width: double.infinity,
              child: CustomPaint(
                painter: _WeeklyBarChartPainter(
                  todayIntake: stats.intakeCalories.toDouble(),
                  todayBurned: stats.burnedCalories.toDouble(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Brief health stats cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.vibrantLightHighlight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trung bình tiêu thụ', style: TextStyle(fontSize: 10, color: AppTheme.vibrantTextLight, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('1,885 kcal/ngày', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECE6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tổng năng lượng đốt', style: TextStyle(fontSize: 10, color: AppTheme.vibrantTextLight, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('1,650 kcal/tuần', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.vibrantAlertCoral)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Tab 3: Monthly View ---
  Widget _buildMonthlyView() {
    final stats = widget.dailyStats;
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xu Hướng Cân Nặng & Calo Tịnh 30 Ngày',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
            ),
            const Text(
              'Đồ thị lượn dốc thể hiện tính đều đặn trong giữ mục tiêu',
              style: TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight),
            ),
            const SizedBox(height: 24),

            // Spline Canvas Line Curve
            SizedBox(
              height: 160,
              width: double.infinity,
              child: CustomPaint(
                painter: _MonthlySplinePainter(
                  todayIntake: stats.intakeCalories.toDouble(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.vibrantSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.star, color: AppTheme.vibrantVolt, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kết quả tháng 6/2026', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark)),
                      Text('Cân nặng giảm từ 62kg -> 60kg theo kế hoạch đề ra.', style: TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Custom Painters for Charts ---
class _WeeklyBarChartPainter extends CustomPainter {
  _WeeklyBarChartPainter({required this.todayIntake, required this.todayBurned});

  final double todayIntake;
  final double todayBurned;

  @override
  void paint(Canvas canvas, Size size) {
    final totalWidth = size.width;
    final totalHeight = size.height;
    const barWidth = 14.0;
    const maxCalValue = 2800.0;
    final contentHeight = totalHeight - 30.0;

    // Y Gridlines
    final gridPaint = Paint()
      ..color = AppTheme.vibrantBorderMedium.withOpacity(0.5)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = contentHeight - (contentHeight * (i / 3.5));
      canvas.drawLine(Offset(0, y), Offset(totalWidth, y), gridPaint);
    }

    // Weekdays lists
    final weekDays = [
      _WeekdayData('T2', 1750, 200),
      _WeekdayData('T3', todayIntake, todayBurned), // Today live values!
      _WeekdayData('T4', 1900, 300),
      _WeekdayData('T5', 1600, 150),
      _WeekdayData('T6', 2100, 450),
      _WeekdayData('T7', 1850, 200),
      _WeekdayData('CN', 2200, 100)
    ];

    // Compute spacing dynamically
    final calculatedSpacing = (totalWidth - (barWidth * 2 * 7)) / 8;

    for (int idx = 0; idx < weekDays.length; idx++) {
      final data = weekDays[idx];
      final xCenter = calculatedSpacing + idx * (barWidth * 2 + calculatedSpacing) + barWidth;

      final isToday = idx == 1; // Tue is today in mock setup

      // 1. Draw Intake Bar (Green/Sage)
      final intakeHeightRatio = (data.intake / maxCalValue).clamp(0.01, 1.0);
      final intakeBarHeight = contentHeight * intakeHeightRatio;
      final intakeBottomY = contentHeight;
      final intakeTopY = intakeBottomY - intakeBarHeight;

      final intakePaint = Paint()
        ..color = isToday ? AppTheme.vibrantPrimary : AppTheme.vibrantPrimary.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(xCenter - barWidth - 2, intakeTopY, xCenter - 2, intakeBottomY),
          const Radius.circular(6),
        ),
        intakePaint,
      );

      // 2. Draw Burned Bar (Coral/Red)
      final burnedHeightRatio = (data.burned / maxCalValue).clamp(0.01, 1.0);
      final burnedBarHeight = contentHeight * burnedHeightRatio;
      final burnedTopY = intakeBottomY - burnedBarHeight;

      final burnedPaint = Paint()
        ..color = isToday ? AppTheme.vibrantAlertCoral : AppTheme.vibrantAlertCoral.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(xCenter + 2, burnedTopY, xCenter + barWidth + 2, intakeBottomY),
          const Radius.circular(6),
        ),
        burnedPaint,
      );

      // 3. Draw Labels
      final textPainter = TextPainter(
        text: TextSpan(
          text: data.day,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isToday ? FontWeight.w900 : FontWeight.w500,
            color: isToday ? AppTheme.vibrantPrimary : AppTheme.vibrantTextLight,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(xCenter - textPainter.width / 2, totalHeight - 20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _WeekdayData {
  _WeekdayData(this.day, this.intake, this.burned);
  final String day;
  final double intake;
  final double burned;
}

class _MonthlySplinePainter extends CustomPainter {
  _MonthlySplinePainter({required this.todayIntake});

  final double todayIntake;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stepX = w / 6.0;
    const maxVal = 2605.0;
    const targetCal = 2000.0;

    final calMonthlyHistory = [2100.0, 1950.0, 1780.0, 1850.0, todayIntake, 1900.0, 1750.0];

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < calMonthlyHistory.length; i++) {
      final valPoint = calMonthlyHistory[i];
      final x = i * stepX;
      final yRatio = (valPoint / maxVal).clamp(0.1, 0.9);
      final y = h - (h * yRatio);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, h);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevYRatio = (calMonthlyHistory[i - 1] / maxVal).clamp(0.1, 0.9);
        final prevY = h - (h * prevYRatio);

        path.cubicTo(
          (prevX + x) / 2, prevY,
          (prevX + x) / 2, y,
          x, y,
        );
        fillPath.cubicTo(
          (prevX + x) / 2, prevY,
          (prevX + x) / 2, y,
          x, y,
        );
      }

      if (i == calMonthlyHistory.length - 1) {
        fillPath.lineTo(x, h);
        fillPath.close();
      }
    }

    // 1. Draw fill area gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppTheme.vibrantLightHighlight, AppTheme.vibrantLightHighlight.withOpacity(0.01)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 2. Draw line path
    final linePaint = Paint()
      ..color = AppTheme.vibrantPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(path, linePaint);

    // 3. Draw dotted target line
    final targetLineY = h - (h * (targetCal / maxVal));
    final targetPaint = Paint()
      ..color = AppTheme.vibrantAlertCoral
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw manual dotted line
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double startX = 0;
    while (startX < w) {
      canvas.drawLine(
        Offset(startX, targetLineY),
        Offset(startX + dashWidth, targetLineY),
        targetPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // 4. Draw labels bottom
    final labels = ['Tuần 1', 'Tuần 2', 'Tuần 3', 'Tuần 4', 'Hôm nay'];
    final spacing = w / (labels.length - 1);
    for (int i = 0; i < labels.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextLight),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      double posX = i * spacing - textPainter.width / 2;
      if (i == 0) posX = 0;
      if (i == labels.length - 1) posX = w - textPainter.width;

      textPainter.paint(canvas, Offset(posX, h - 14));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
