class DailyHealthStats {
  const DailyHealthStats({
    required this.intakeCalories,
    required this.burnedCalories,
    required this.targetCalories,
  });

  final int intakeCalories;
  final int burnedCalories;
  final int targetCalories;

  int get netCalories => intakeCalories - burnedCalories;

  int get remainingCalories => targetCalories - netCalories;

  double get intakeProgress {
    return (intakeCalories / targetCalories).clamp(0.0, 1.0).toDouble();
  }

  double get burnedProgress {
    return (burnedCalories / targetCalories).clamp(0.0, 1.0).toDouble();
  }
}
