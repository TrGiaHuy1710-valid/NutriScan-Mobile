package com.example.ui

import android.app.Application
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.data.*
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

class AppViewModel(application: Application) : AndroidViewModel(application) {
    private val database = AppDatabase.getDatabase(application)
    private val repository = AppRepository(
        mealDao = database.mealDao(),
        foodDao = database.foodDao(),
        workoutDao = database.workoutDao(),
        profileDao = database.profileDao()
    )

    // Tab Index (0: Home, 1: Discover, 2: Workout, 3: Profile)
    var currentTab by mutableStateOf(0)

    // Flows from database
    val mealsState: StateFlow<List<MealLog>> = repository.allMeals
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val boughtFoodsState: StateFlow<List<BoughtFoodItem>> = repository.allBoughtFoods
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val workoutsState: StateFlow<List<ScheduledWorkout>> = repository.allWorkouts
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val profileState: StateFlow<UserProfile?> = repository.userProfile
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), null)

    // Calculation states computed reactively
    val totalCaloriesIntake = mealsState.map { list ->
        list.sumOf { it.calories }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)

    val totalProteinIntake = mealsState.map { list ->
        list.sumOf { it.protein }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)

    val totalCarbsIntake = mealsState.map { list ->
        list.sumOf { it.carbs }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)

    val totalFatIntake = mealsState.map { list ->
        list.sumOf { it.fat }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)

    val totalCaloriesBurned = workoutsState.map { list ->
        list.filter { it.isCompleted }.sumOf { it.caloriesBurned }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)

    // Loading states for Scanning logic
    var isAnalyzing by mutableStateOf(false)
    var analysisResult by mutableStateOf<String?>(null)

    init {
        // Automatically initialize profile if not existing
        viewModelScope.launch {
            repository.getProfileDirect()
        }
    }

    // --- Profile Operations ---
    fun updateProfile(weight: Float, height: Float, age: Int, goal: String, restrictions: String) {
        viewModelScope.launch {
            // Auto re-calculate calorie/macro targets based on health goal
            val baseline = (10 * weight + 6.25f * height - 5 * age + 5).toInt()
            val targetCal = when (goal) {
                "Giảm cân" -> (baseline * 0.85f).toInt()
                "Tăng cân" -> (baseline * 1.15f).toInt()
                "Giữ cân" -> baseline
                else -> baseline // "Lối sống lành mạnh"
            }
            // Macros estimation
            val targetProtein = (weight * 2.0f).toInt().coerceIn(60, 200)
            val targetFat = (targetCal * 0.25f / 9f).toInt().coerceIn(40, 100)
            val targetCarbs = ((targetCal - (targetProtein * 4) - (targetFat * 9)) / 4).toInt().coerceIn(100, 400)

            val updatedProfile = UserProfile(
                id = 1,
                weight = weight,
                height = height,
                age = age,
                healthGoal = goal,
                dietaryRestrictions = restrictions,
                targetCalories = targetCal,
                targetProtein = targetProtein,
                targetCarbs = targetCarbs,
                targetFat = targetFat
            )
            repository.updateProfile(updatedProfile)
        }
    }

    fun updateCustomTargets(calories: Int, protein: Int, carbs: Int, fat: Int) {
        viewModelScope.launch {
            val current = repository.getProfileDirect()
            val updated = current.copy(
                targetCalories = calories,
                targetProtein = protein,
                targetCarbs = carbs,
                targetFat = fat
            )
            repository.updateProfile(updated)
        }
    }

    // --- Meal Operations ---
    fun logMeal(foodName: String, mealType: String, portion: String, calories: Int, protein: Int, carbs: Int, fat: Int) {
        viewModelScope.launch {
            val meal = MealLog(
                foodName = foodName,
                mealType = mealType,
                portion = portion,
                calories = calories,
                protein = protein,
                carbs = carbs,
                fat = fat
            )
            repository.insertMeal(meal)
        }
    }

    fun deleteMeal(id: Int) {
        viewModelScope.launch {
            repository.deleteMeal(id)
        }
    }

    fun clearAllMeals() {
        viewModelScope.launch {
            repository.clearMeals()
        }
    }

    fun clearAllBoughtFoods() {
        viewModelScope.launch {
            repository.clearBoughtFoods()
        }
    }

    fun clearAllWorkouts() {
        viewModelScope.launch {
            repository.clearWorkouts()
        }
    }

    // --- Scanning & Mock Verification Operations ---
    fun performMockScannedProduct(barcode: String) {
        viewModelScope.launch {
            // Match mock products
            val productResult = when (barcode) {
                "8930001" -> Triple("Sữa tươi hữu cơ TH True Milk", 120, 7) to Pair(10, 5)
                "8930002" -> Triple("Sữa chua Vinamilk ít đường", 110, 4) to Pair(15, 3)
                "8930003" -> Triple("Đậu nành hạt sấy giòn Fami", 160, 12) to Pair(18, 6)
                else -> Triple("Thực phẩm nguyên bản bổ sung", 140, 6) to Pair(12, 5)
            }
            val name = productResult.first.first
            val cal = productResult.first.second
            val pro = productResult.first.third
            val carb = productResult.second.first
            val fat = productResult.second.second

            val product = BoughtFoodItem(
                name = name,
                calories = cal,
                protein = pro,
                carbs = carb,
                fat = fat,
                barcode = barcode,
                scanType = "SCAN_BARCODE"
            )
            repository.insertBoughtFood(product)
        }
    }

    fun performMockScannedDish(dishName: String, cal: Int, pro: Int, carb: Int, fat: Int) {
        viewModelScope.launch {
            val product = BoughtFoodItem(
                name = dishName,
                calories = cal,
                protein = pro,
                carbs = carb,
                fat = fat,
                scanType = "SCAN_FOOD"
            )
            repository.insertBoughtFood(product)
        }
    }

    // Helpers to unpack pairs in moshi logic
    private fun dataPairFirst(pair: Pair<Int, Int>) = pair.first
    private fun dataPairSecond(pair: Pair<Int, Int>) = pair.second

    fun analyzeIngredientsText(text: String) {
        viewModelScope.launch {
            isAnalyzing = true
            analysisResult = null
            val result = repository.analyzeIngredients(text)
            analysisResult = result
            isAnalyzing = false
        }
    }

    fun clearAnalysis() {
        analysisResult = null
    }

    fun logBoughtFoodAsMeal(food: BoughtFoodItem, mealType: String) {
        viewModelScope.launch {
            logMeal(
                foodName = food.name,
                mealType = mealType,
                portion = "1 gói / 1 lon",
                calories = food.calories,
                protein = food.protein,
                carbs = food.carbs,
                fat = food.fat
            )
            // Optionally delete from scanned to avoid confusion, or keep it.
            // Let's keep it to show in lists.
        }
    }

    fun deleteBoughtFood(id: Int) {
        viewModelScope.launch {
            repository.deleteBoughtFood(id)
        }
    }

    // --- Workout Operations ---
    fun scheduleWorkout(name: String, duration: Int, calories: Int, timeSlot: String) {
        viewModelScope.launch {
            val workout = ScheduledWorkout(
                exerciseName = name,
                duration = duration,
                caloriesBurned = calories,
                timeSlot = timeSlot,
                isCompleted = false
            )
            repository.insertWorkout(workout)
        }
    }

    fun completeWorkout(id: Int) {
        viewModelScope.launch {
            repository.updateWorkoutStatus(id, true)
        }
    }

    fun deleteWorkout(id: Int) {
        viewModelScope.launch {
            repository.deleteWorkout(id)
        }
    }
}
