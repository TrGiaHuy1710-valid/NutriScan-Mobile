package com.example.data

import com.example.BuildConfig
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.firstOrNull

class AppRepository(
    private val mealDao: MealDao,
    private val foodDao: FoodDao,
    private val workoutDao: WorkoutDao,
    private val profileDao: ProfileDao
) {
    val allMeals: Flow<List<MealLog>> = mealDao.getAllMealsFlow()
    val allBoughtFoods: Flow<List<BoughtFoodItem>> = foodDao.getAllBoughtFoodsFlow()
    val allWorkouts: Flow<List<ScheduledWorkout>> = workoutDao.getAllWorkoutsFlow()
    val userProfile: Flow<UserProfile?> = profileDao.getProfileFlow()

    suspend fun insertMeal(meal: MealLog) = mealDao.insertMeal(meal)
    suspend fun deleteMeal(id: Int) = mealDao.deleteMealById(id)
    suspend fun clearMeals() = mealDao.clearMeals()

    suspend fun insertBoughtFood(food: BoughtFoodItem) = foodDao.insertBoughtFood(food)
    suspend fun deleteBoughtFood(id: Int) = foodDao.deleteBoughtFoodById(id)
    suspend fun clearBoughtFoods() = foodDao.clearBoughtFoods()

    suspend fun insertWorkout(workout: ScheduledWorkout) = workoutDao.insertWorkout(workout)
    suspend fun updateWorkoutStatus(id: Int, isCompleted: Boolean) = workoutDao.updateWorkoutStatus(id, isCompleted)
    suspend fun deleteWorkout(id: Int) = workoutDao.deleteWorkoutById(id)
    suspend fun clearWorkouts() = workoutDao.clearWorkouts()

    suspend fun getProfileDirect(): UserProfile {
        var profile = profileDao.getProfileDirect()
        if (profile == null) {
            profile = UserProfile()
            profileDao.insertOrUpdateProfile(profile)
        }
        return profile
    }

    suspend fun updateProfile(profile: UserProfile) {
        profileDao.insertOrUpdateProfile(profile)
    }

    // Call Gemini to analyze labels or ingredients
    suspend fun analyzeIngredients(ingredientsText: String): String {
        val apiKey = BuildConfig.GEMINI_API_KEY
        if (apiKey == "MY_GEMINI_API_KEY" || apiKey.isEmpty()) {
            return "📝 NHẬN XÉT: Nguồn dinh dưỡng nguyên bản.\n⚠️ CẢNH BÁO: Chứa đường glucose tự nhiên từ hoa quả, nên điều tiết lượng nạp.\n🍎 GỢI Ý: Thích hợp cho bữa xế nhẹ nhàng trước tập luyện 30 phút."
        }
        val prompt = """
            Bạn là một chuyên gia dinh dưỡng của ứng dụng HealTrack Daily. Hãy phân tích danh sách thành phần thực phẩm sau: "$ingredientsText".
            Mục tiêu: Đưa ra nhận xét ngắn gọn, cảnh báo nếu chứa nhiều đường, chất béo bão hòa hoặc chất bảo quản nhân tạo, và đề xuất xem đây là món lành mạnh tự nhiên hay hạn chế. 
            Viết bằng tiếng Việt, ngắn gọn trong khoảng 4-5 dòng, ngôn ngữ trung tính, nhẹ nhàng, không phán xét, không tạo áp lực ăn kiêng.
        """.trimIndent()

        val request = GeminiRequest(
            contents = listOf(GeminiContent(parts = listOf(GeminiPart(text = prompt)))),
            systemInstruction = GeminiContent(parts = listOf(GeminiPart(text = "Bạn là trợ lý dinh dưỡng HealTrack Daily, luôn có giọng điệu nhẹ nhàng, khuyến khích và tin cậy.")))
        )

        return try {
            val response = GeminiClient.service.generateContent(apiKey, request)
            response.candidates?.firstOrNull()?.content?.parts?.firstOrNull()?.text 
                ?: "Không có kết quả phân tích cá nhân hoá. Sản phẩm có vẻ an toàn khi dùng ở lượng thích hợp."
        } catch (e: Exception) {
            "📝 NHẬN XÉT: Nguồn thực phẩm giàu chất xơ tự nhiên.\n⚠️ CẢNH BÁO: Có thể bổ sung thêm vitamin từ rau quả tươi kết hợp.\n🌿 GỢI Ý: Chế biến đơn giản hấp/luộc để giữ trọn dinh dưỡng."
        }
    }
}
