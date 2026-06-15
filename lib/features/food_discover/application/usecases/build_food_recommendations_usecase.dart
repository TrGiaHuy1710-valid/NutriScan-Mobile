import '../../../nutrition/domain/entities/nutrition_summary.dart';
import '../../../profile/domain/entities/user_health_profile.dart';
import '../../domain/bought_food_item.dart';
import '../../domain/food_recommendation.dart';
import '../../domain/scanned_product.dart';

class FoodRecommendationPlan {
  const FoodRecommendationPlan({
    required this.recommendations,
    required this.activeTags,
    required this.reason,
  });

  final List<FoodRecommendation> recommendations;
  final List<String> activeTags;
  final String reason;
}

class BuildFoodRecommendationsUseCase {
  const BuildFoodRecommendationsUseCase();

  FoodRecommendationPlan call({
    required UserHealthProfile profile,
    required NutritionSummary summary,
    required List<FoodRecommendation> baseRecommendations,
    required List<FoodRecommendation> customRecommendations,
    required List<ScannedProduct> recentlyScannedProducts,
    required List<BoughtFoodItem> boughtToday,
  }) {
    final activeTags = <String>{
      ...profile.recommendationTags,
      ..._goalTags(profile.healthGoal),
      ..._nutritionTags(summary),
      ...boughtToday.expand((item) => item.tags),
      ...recentlyScannedProducts.expand((product) => product.tags),
      ...customRecommendations.expand((recommendation) => recommendation.tags),
    };

    final recommendations = [...customRecommendations, ...baseRecommendations];

    final scoredRecommendations =
        recommendations.map((recommendation) {
          final tagScore = recommendation.tags
              .where(activeTags.contains)
              .length;
          final customScore = recommendation.tags.contains('custom_food')
              ? 2
              : 0;
          final sectionScore = recommendation.section == 'Good for today'
              ? 1
              : 0;

          return _ScoredRecommendation(
            recommendation: recommendation,
            score: tagScore + customScore + sectionScore,
          );
        }).toList()..sort((a, b) {
          final scoreCompare = b.score.compareTo(a.score);
          if (scoreCompare != 0) {
            return scoreCompare;
          }
          return a.recommendation.title.compareTo(b.recommendation.title);
        });

    return FoodRecommendationPlan(
      recommendations: scoredRecommendations
          .map((item) => item.recommendation)
          .toList(),
      activeTags: activeTags.toList()..sort(),
      reason: _reason(summary, boughtToday, recentlyScannedProducts),
    );
  }

  Set<String> _goalTags(String healthGoal) {
    final goal = healthGoal.toLowerCase();
    if (goal.contains('gain')) {
      return {'balanced', 'high_protein', 'home_cooking'};
    }
    if (goal.contains('lose')) {
      return {'balanced', 'light', 'high_fiber'};
    }
    if (goal.contains('maintain')) {
      return {'balanced', 'home_cooking'};
    }
    return {'balanced', 'home_cooking', 'quick_meal'};
  }

  Set<String> _nutritionTags(NutritionSummary summary) {
    final tags = <String>{};
    if (summary.totalProtein < 70) {
      tags.add('high_protein');
    }
    if (summary.totalCalories < 1200) {
      tags.addAll({'balanced', 'quick_meal'});
    }
    if (summary.totalCalories > 1600) {
      tags.add('light');
    }
    if (summary.totalCarbs < 160) {
      tags.add('home_cooking');
    }
    return tags;
  }

  String _reason(
    NutritionSummary summary,
    List<BoughtFoodItem> boughtToday,
    List<ScannedProduct> recentlyScannedProducts,
  ) {
    if (recentlyScannedProducts.isNotEmpty && boughtToday.isNotEmpty) {
      return 'Using today nutrition, confirmed scans, and bought-today foods.';
    }
    if (boughtToday.isNotEmpty) {
      return 'Using today nutrition and bought-today foods.';
    }
    if (recentlyScannedProducts.isNotEmpty) {
      return 'Using today nutrition and recently scanned products.';
    }
    if (summary.mealCount > 0) {
      return 'Using today nutrition and profile preferences.';
    }
    return 'Using profile preferences until more local activity is added.';
  }
}

class _ScoredRecommendation {
  const _ScoredRecommendation({
    required this.recommendation,
    required this.score,
  });

  final FoodRecommendation recommendation;
  final int score;
}
