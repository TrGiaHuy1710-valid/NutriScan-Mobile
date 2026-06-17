package com.example.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "meal_logs")
data class MealLog(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val foodName: String,
    val mealType: String, // Sáng, Trưa, Tối, Nhẹ
    val portion: String,
    val calories: Int,
    val protein: Int,
    val carbs: Int,
    val fat: Int,
    val timestamp: Long = System.currentTimeMillis()
)

@Entity(tableName = "bought_food_items")
data class BoughtFoodItem(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val name: String,
    val calories: Int,
    val protein: Int,
    val carbs: Int,
    val fat: Int,
    val barcode: String? = null,
    val scanType: String, // "SCAN_FOOD", "SCAN_INGREDIENT", "SCAN_BARCODE"
    val timestamp: Long = System.currentTimeMillis()
)

@Entity(tableName = "scheduled_workouts")
data class ScheduledWorkout(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val exerciseName: String,
    val duration: Int, // minutes
    val caloriesBurned: Int,
    val isCompleted: Boolean = false,
    val timeSlot: String,
    val timestamp: Long = System.currentTimeMillis()
)

@Entity(tableName = "user_profile")
data class UserProfile(
    @PrimaryKey val id: Int = 1,
    val weight: Float = 60f,
    val height: Float = 165f,
    val age: Int = 22,
    val healthGoal: String = "Giữ cân", // Giảm cân, Giữ cân, Tăng cân, Lối sống lành mạnh
    val dietaryRestrictions: String = "",
    val targetCalories: Int = 2000,
    val targetProtein: Int = 120,
    val targetCarbs: Int = 230,
    val targetFat: Int = 67
)
