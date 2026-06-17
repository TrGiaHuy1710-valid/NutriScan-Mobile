package com.example.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

@Dao
interface MealDao {
    @Query("SELECT * FROM meal_logs ORDER BY timestamp DESC")
    fun getAllMealsFlow(): Flow<List<MealLog>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMeal(meal: MealLog)

    @Query("DELETE FROM meal_logs WHERE id = :id")
    suspend fun deleteMealById(id: Int)

    @Query("DELETE FROM meal_logs")
    suspend fun clearMeals()
}

@Dao
interface FoodDao {
    @Query("SELECT * FROM bought_food_items ORDER BY timestamp DESC")
    fun getAllBoughtFoodsFlow(): Flow<List<BoughtFoodItem>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertBoughtFood(food: BoughtFoodItem)

    @Query("DELETE FROM bought_food_items WHERE id = :id")
    suspend fun deleteBoughtFoodById(id: Int)

    @Query("DELETE FROM bought_food_items")
    suspend fun clearBoughtFoods()
}

@Dao
interface WorkoutDao {
    @Query("SELECT * FROM scheduled_workouts ORDER BY timestamp DESC")
    fun getAllWorkoutsFlow(): Flow<List<ScheduledWorkout>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertWorkout(workout: ScheduledWorkout)

    @Query("UPDATE scheduled_workouts SET isCompleted = :isCompleted WHERE id = :id")
    suspend fun updateWorkoutStatus(id: Int, isCompleted: Boolean)

    @Query("DELETE FROM scheduled_workouts WHERE id = :id")
    suspend fun deleteWorkoutById(id: Int)

    @Query("DELETE FROM scheduled_workouts")
    suspend fun clearWorkouts()
}

@Dao
interface ProfileDao {
    @Query("SELECT * FROM user_profile WHERE id = 1 LIMIT 1")
    fun getProfileFlow(): Flow<UserProfile?>

    @Query("SELECT * FROM user_profile WHERE id = 1 LIMIT 1")
    suspend fun getProfileDirect(): UserProfile?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOrUpdateProfile(profile: UserProfile)
}
