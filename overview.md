# Tổng Quan Dự Án: HealTrack Daily (NutriScan)

Tài liệu này cung cấp mô tả chi tiết về dự án HealTrack Daily, tập trung làm rõ thiết kế **UX/UI (Trải nghiệm người dùng/Giao diện người dùng)** và **Logic các chức năng chính (Functional Logic & Flows)** của hệ thống.

---

## 1. Giới thiệu chung về Dự án
HealTrack Daily là một ứng dụng di động theo dõi sức khỏe và dinh dưỡng hàng ngày (Flutter/Dart). Ứng dụng hướng tới mục tiêu đơn giản hóa việc quản lý lối sống lành mạnh, giúp người dùng theo dõi thói quen dinh dưỡng, khám phá sản phẩm an toàn và lên lịch luyện tập nhanh mà không tạo áp lực tâm lý hay gò bó về mặt ăn kiêng.

### Mục tiêu cốt lõi:
- **Theo dõi năng lượng và dinh dưỡng đa lượng**: Đo lường calo và các chất dinh dưỡng thiết yếu (Protein, Carbs, Fat) ở mức độ hỗ trợ nâng cao lối sống lành mạnh, phi y tế.
- **Khám phá và Đề xuất Thực phẩm**: Gợi ý các món ăn dinh dưỡng và nguyên liệu chế biến tại nhà dựa trên nhu cầu cơ thể và mục tiêu trong ngày.
- **Giả lập Quét nhãn và Mã vạch**: Cho phép quét thành phần dinh dưỡng từ nhãn hộp hoặc mã vạch của sản phẩm để đưa ra đánh giá nhanh.
- **Gợi ý Luyện tập dựa trên thời gian rảnh**: Tự động gợi ý các bài tập ngắn (5-30 phút) phù hợp với khoảng thời gian trống giả lập từ lịch cá nhân.

---

## 2. Thiết kế UX/UI (User Experience & User Interface Design)

Hệ thống UX/UI của ứng dụng được xây dựng theo triết lý **"Nhẹ nhàng - Lành mạnh - Không áp lực"** (Mindful Health Tracking).

### 2.1. Hệ thống Màu sắc (Color Palette)
Được định nghĩa tập trung tại lớp giao diện [AppTheme](file:///E:/MobileApp/nutriscan/lib/core/theme/app_theme.dart):
- **Tông màu chủ đạo (Primary/Seed Color)**: `Color(0xFF1F8A70)` - Màu xanh ngọc lục bảo (Emerald Green) nhẹ dịu. Màu sắc này đại diện cho sự tươi mới, thiên nhiên và thói quen ăn uống lành mạnh tự nhiên.
- **Màu nền (Scaffold Background Color)**: `Color(0xFFF7FAF8)` - Màu off-white pha chút sắc xanh lá cực nhạt. Màu này thay thế cho nền trắng tinh thuần túy để tạo cảm giác dịu mắt và sạch sẽ hơn cho người dùng.
- **Thiết kế Thẻ hiển thị (Card Theme)**: Màu nền trắng thuần (`Colors.white`), độ phẳng tuyệt đối (`elevation: 0`) và bo tròn góc lớn (`borderRadius: BorderRadius.circular(8)`) tạo ra phong cách giao diện tối giản hiện đại (Flat UI/Material 3).
- **Trường nhập liệu (Input Decoration)**: Nền trắng, viền ngoài bo tròn góc 8px với màu viền xám nhạt nhẹ nhàng `Color(0xFFDDE7E1)`.

### 2.2. Triết lý UX & Ngôn ngữ (Safety & Tone Guidelines)
- **Tránh áp lực cân nặng**: Ứng dụng không khuyến khích việc đếm calo cực đoan hay thúc đẩy giảm cân tiêu cực. Ngôn ngữ giao diện hoàn toàn trung tính: thay vì dùng "giảm cân nhanh", "ít mỡ", ứng dụng dùng các từ ngữ như *health goal* (mục tiêu sức khỏe), *energy* (năng lượng nạp vào/tiêu hao), *routine* (thói quen lành mạnh), *balanced eating* (ăn uống cân bằng), *movement* (vận động).
- **Bảo vệ người dùng trẻ tuổi**: Giao diện hiển thị các cảnh báo an toàn cho nhóm tuổi thiếu niên, khuyên họ tham khảo ý kiến cha mẹ hoặc bác sĩ dinh dưỡng trước khi đặt mục tiêu calo.
- **Định hướng Thực phẩm Tự nhiên**: Tránh các khuyến nghị tự động về thuốc giảm cân, bột Whey hay thực phẩm bổ sung tổng hợp. Các "Thực phẩm hỗ trợ" ở đây luôn là thực phẩm tự nhiên tốt cho sức khỏe như sữa chua, trứng, các loại hạt, sữa đậu nành, trái cây.

---

## 3. Bản đồ Giao diện & Hệ thống Điều hướng (Navigation)

Ứng dụng sử dụng bố cục Bottom Navigation Bar bo cong (`CircularNotchedRectangle`) với 4 tab chính và một nút quét nhanh ở trung tâm:
1. **Home (Dashboard)**
2. **Foods (Discover)**
3. **[Nút Quét ở trung tâm]**
4. **Workout (Luyện tập)**
5. **Profile (Hồ sơ cá nhân)**

> [!NOTE]
> Khác với nhiều ứng dụng dinh dưỡng truyền thống, tab Nhật ký Bữa ăn (`Meals`) trực quan đã bị loại bỏ để giảm áp lực ghi chép cho người dùng. Thay vào đó, luồng thêm bữa ăn (`Add Meal`) được thiết kế thành một luồng ẩn/nội bộ (Internal Flow), chỉ mở ra khi người dùng chủ động lựa chọn từ Trang chủ hoặc từ các đề xuất.

---

## 4. Logic Nghiệp vụ & Các chức năng chính (Functional Logic)

### 4.1. Luồng Xác thực (Authentication & Session)
- **Quản lý trạng thái**: Sử dụng Cubit để xử lý đăng nhập, đăng ký và đăng xuất thông qua [LoginPage](file:///E:/MobileApp/nutriscan/lib/features/auth/presentation/pages/login_page.dart).
- **Logic Lưu trữ Cục bộ**: Toàn bộ dữ liệu tài khoản được đồng bộ vào bảng cơ sở dữ liệu SQLite `auth_users` và `auth_session` thông qua [AppDatabase](file:///E:/MobileApp/nutriscan/lib/core/persistence/app_database.dart).
- **Tài khoản Demo**: Để thuận tiện cho việc thử nghiệm, hệ thống tự động khởi tạo (seed) tài khoản demo sẵn có:
  - *Email*: `huy@example.com`
  - *Password*: `demo123`
  - *Display Name*: `Huy Nguyen`

### 4.2. Luồng Onboarding & Khởi tạo (Onboarding Flow)
- Thực hiện qua [OnboardingPage](file:///E:/MobileApp/nutriscan/lib/features/onboarding/presentation/pages/onboarding_page.dart).
- Khi người dùng đăng nhập lần đầu tiên hoặc tạo tài khoản mới, hệ thống hiển thị màn hình Onboarding để khảo sát nhanh: Mục tiêu sức khỏe (Giảm cân, Giữ cân, Tăng cân, Tạo thói quen), Dị ứng/Hạn chế ăn uống, Thể trạng và Mức độ vận động.
- Thông tin thu thập được lưu trữ vào cấu hình hồ sơ và trực tiếp làm đầu vào cho thuật toán gợi ý món ăn sau này.

### 4.3. Trang chủ Dashboard & Thêm Bữa ăn (Dashboard & Add Meal Flow)
- **Quản lý dinh dưỡng**: [DashboardPage](file:///E:/MobileApp/nutriscan/lib/features/dashboard/presentation/pages/dashboard_page.dart) hiển thị thống kê calo tổng hợp trong ngày và các chỉ số dinh dưỡng đa lượng (Carbs, Protein, Fat) nạp vào.
- **Logic Thêm bữa ăn**: 
  1. Người dùng bấm **Add Meal** từ trang chủ hoặc các nút hành động nhanh.
  2. Hệ thống chuyển hướng tới [AddMealPage](file:///E:/MobileApp/nutriscan/lib/features/nutrition/presentation/pages/add_meal_page.dart) để nhập thông tin bữa ăn bao gồm: loại bữa ăn (Sáng, Trưa, Tối, Nhẹ), tên món, khẩu phần, Calo và Macros.
  3. Sau khi Lưu, dữ liệu bữa ăn được ghi vào bảng `meal_logs` trong cơ sở dữ liệu SQLite.
  4. Trạng thái dinh dưỡng hôm nay (`NutritionSummary`) được tính toán lại ngay lập tức và giao diện Dashboard cập nhật chỉ số năng lượng theo thời gian thực.

### 4.4. Trang Khám phá Foods/Discover & Logic Đề xuất (Foods Discovery & Recommendation Engine)
- **Màn hình**: [FoodsDiscoverPage](file:///E:/MobileApp/nutriscan/lib/features/food_discover/presentation/pages/foods_discover_page.dart)
- **Logic thuật toán đề xuất**: 
  - Thuật toán đọc thông tin hồ sơ của người dùng (trong `mockUserHealthProfile`) kết hợp với dữ liệu dinh dưỡng thực tế đã nạp trong ngày từ `NutritionSummary`.
  - Nếu lượng protein tích lũy trong ngày của người dùng còn thiếu so với mục tiêu, thuật toán sẽ tự động ưu tiên đẩy các thực phẩm/món ăn thuộc thẻ `High protein` lên các mục gợi ý ưu tiên.
  - Các phần đề xuất như *Good for today* và *Easy meal ideas* liên kết trực tiếp với chức năng **Thêm bữa ăn nhanh** (`Add recommended meal to plan`). Khi nhấn chọn, món ăn gợi ý với thông tin calo/dinh dưỡng định sẵn sẽ được tự động ghi nhận vào cơ sở dữ liệu của ngày hôm nay mà không cần người dùng tự nhập tay.

### 4.5. Luồng Quét mã giả lập (Mock Scanning Flows)
Khi người dùng bấm nút Quét lớn màu xanh ở giữa Bottom Navigation Bar, một trang Bottom Sheet hiện lên với 3 tuỳ chọn quét:
1. **Quét món ăn (Scan Food - [ScanFoodPage](file:///E:/MobileApp/nutriscan/lib/features/food_scan/presentation/pages/scan_food_page.dart))**: Giả lập camera nhận diện đĩa thức ăn. Hệ thống trả về phân tích dinh dưỡng giả lập của đĩa đồ ăn đó (Ví dụ: Salad ức gà - 320 kcal, Protein: 25g). Người dùng có thể chỉnh sửa và bấm xác nhận để ghi nhận thẳng món ăn này thành một bữa ăn trong ngày.
2. **Quét thành phần nhãn dinh dưỡng (Scan Ingredient - [ScanIngredientPage](file:///E:/MobileApp/nutriscan/lib/features/food_scan/presentation/pages/scan_ingredient_page.dart))**: Giả lập việc nhận diện văn bản từ bảng thành phần của bao bì. Hệ thống phân tích nhanh và đưa ra các "Insight" (Ví dụ: "Hàm lượng đường cao", "Chứa nhiều chất béo bão hòa").
3. **Quét mã vạch (Scan Barcode - [ScanBarcodePage](file:///E:/MobileApp/nutriscan/lib/features/food_scan/presentation/pages/scan_barcode_page.dart))**: Giả lập việc tìm kiếm sản phẩm qua cơ sở dữ liệu mã vạch (ví dụ: quét mã vạch sữa chua Hy Lạp).

**Logic Nghiệp vụ sau quét:**
- Sau khi có kết quả quét, người dùng bấm **Xác nhận sản phẩm** (Confirm product).
- Sản phẩm được thêm vào danh sách **"Đã mua hôm nay"** (`BoughtFoodItem` lưu vào bảng SQLite `bought_food_items`).
- Dữ liệu này ngay lập tức đồng bộ sang tab **Foods / Discover** dưới danh mục *Bought today* và *Products you scanned*, đồng thời Dashboard cũng cập nhật trạng thái mua sắm của người dùng.

### 4.6. Lập kế hoạch Luyện tập từ Lịch trống (Workout Planning Flow)
- **Màn hình**: [WorkoutPlanPage](file:///E:/MobileApp/nutriscan/lib/features/workout/presentation/pages/workout_plan_page.dart)
- **Logic lấy slot trống**: Ứng dụng đọc dữ liệu giả lập từ nguồn lịch biểu (giả định các khoảng thời gian trống của người dùng như `17:30 - 18:00`).
- **Gợi ý & Lên lịch**:
  - Người dùng có thể chọn bộ lọc thời lượng tập (5, 10, 15, 20, 30 phút).
  - Hệ thống gợi ý danh sách bài tập ngắn (Yoga kéo giãn, Cardio nhẹ, Full body...) phù hợp với slot thời gian đã chọn.
  - Khi nhấn **Schedule**, bài tập được ghi nhận vào cơ sở dữ liệu `scheduled_workout`.
  - Thẻ thông tin bài tập sẽ xuất hiện trên trang chủ Dashboard để nhắc nhở người dùng thực hiện.
- **Ghi nhận hoàn thành**:
  - Người dùng bấm **Complete** trên Dashboard hoặc trang Workout.
  - Trạng thái bài tập được cập nhật thành `is_completed = 1`.
  - Calo tiêu thụ giả lập từ bài tập sẽ được cộng vào chỉ số **Burned Calories** (Năng lượng tiêu hao) của ngày hôm nay, cập nhật trực tiếp lên thanh biểu đồ năng lượng ở Dashboard.

---

## 5. Kiến trúc Công nghệ của Dự án
Dự án được xây dựng dựa trên nguyên lý **Clean Architecture** để đảm bảo khả năng mở rộng trong tương lai (khi tích hợp AI thật, API dinh dưỡng bên ngoài và Google Calendar).

```text
lib/
├── core/                       # Các thành phần dùng chung cho toàn bộ app
│   ├── persistence/            # Lớp cơ sở dữ liệu SQLite (AppDatabase)
│   └── theme/                  # Định nghĩa ThemeData và Style (AppTheme)
├── features/                   # Từng tính năng được phát triển độc lập dạng mô-đun
│   ├── auth/                   # Quét, đăng ký, đăng nhập tài khoản cục bộ
│   ├── onboarding/             # Màn hình Splash, màn hình khảo sát ban đầu
│   ├── dashboard/              # Trang chủ và logic tính toán sức khoẻ trong ngày
│   ├── nutrition/              # Nhật ký ăn uống, lượng Calo, Carbs, Fat, Protein nạp vào
│   ├── food_discover/          # Hệ thống gợi ý thực phẩm, thực phẩm đã mua
│   ├── food_scan/              # Chức năng giả lập quét món ăn, nhãn thành phần và barcode
│   ├── workout/                # Quản lý bài tập gợi ý và bài tập đã lên lịch
│   └── calendar/               # Khai thác slot thời gian trống từ lịch biểu giả lập
└── app.dart                    # File điều hướng chính điều phối State và Tab-Routing
```

Mỗi mô-đun tính năng đều bao gồm 3 lớp con tiêu chuẩn:
- **Presentation**: Chứa các widget hiển thị (`pages`, `widgets`) và khối quản lý trạng thái (`cubit`).
- **Domain**: Định nghĩa thực thể dữ liệu (`entities`/`models`) và các ca sử dụng nghiệp vụ (`usecases`).
- **Data**: Cung cấp các hiện thực cụ thể (`repositories`), nguồn cấp dữ liệu (`datasources` - mock hoặc local sqlite database).

---

## 6. Sơ đồ thực thể dữ liệu SQLite (Database Schema)
Dữ liệu cục bộ được quản lý bằng thư viện SQLite thông qua lớp [AppDatabase](file:///E:/MobileApp/nutriscan/lib/core/persistence/app_database.dart):
- Bảng `meal_logs`: Lưu trữ chi tiết các bữa ăn người dùng đã nạp (`id`, `meal_type`, `food_name`, `portion`, `calories`, `protein`, `carbs`, `fat`, `tags`, `created_at`).
- Bảng `bought_food_items`: Lưu các sản phẩm người dùng xác nhận đã mua sau khi quét nhãn hoặc barcode.
- Bảng `scheduled_workout`: Lưu vết các bài tập được lên lịch hoặc đã tập xong cùng lượng calo đốt cháy tương ứng.
- Bảng `auth_users` & `auth_session`: Lưu trữ tài khoản và phiên đăng nhập hiện tại để duy trì trạng thái ứng dụng sau khi khởi động lại.
