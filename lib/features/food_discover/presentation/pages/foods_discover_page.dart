import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/nutrition/application/usecases/add_meal_log_usecase.dart';
import '../../../../features/nutrition/domain/entities/meal_log.dart';
import '../../domain/bought_food_item.dart';
import '../../domain/scanned_product.dart';

class MealIngredient {
  MealIngredient({
    required this.name,
    required this.emoji,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
  });

  final String name;
  final String emoji;
  final double quantity;
  final String unit;
  final int calories;
  final int protein;
}

class RequiredIngredient {
  const RequiredIngredient(this.name, this.quantity, this.unit);
  final String name;
  final double quantity;
  final String unit;
}

class MealRecipe {
  const MealRecipe({
    required this.name,
    required this.emoji,
    required this.description,
    required this.nutritionBrief,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.requiredIngredients,
    required this.instructions,
  });

  final String name;
  final String emoji;
  final String description;
  final String nutritionBrief;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<RequiredIngredient> requiredIngredients;
  final String instructions;
}

class FoodsDiscoverPage extends StatefulWidget {
  const FoodsDiscoverPage({
    required this.recentlyScannedProducts,
    required this.boughtToday,
    required this.onAddRecommendedMeal,
    super.key,
  });

  final List<ScannedProduct> recentlyScannedProducts;
  final List<BoughtFoodItem> boughtToday;
  final Future<void> Function(AddMealLogParams params) onAddRecommendedMeal;

  @override
  State<FoodsDiscoverPage> createState() => _FoodsDiscoverPageState();
}

class _FoodsDiscoverPageState extends State<FoodsDiscoverPage> {
  // Refrigerator/Available ingredients state
  final List<MealIngredient> _availableIngredients = [
    MealIngredient(name: 'Ức gà', emoji: '🥩', quantity: 500, unit: 'g', calories: 165, protein: 31),
    MealIngredient(name: 'Bông cải', emoji: '🥦', quantity: 300, unit: 'g', calories: 34, protein: 3),
    MealIngredient(name: 'Sữa tươi', emoji: '🥛', quantity: 400, unit: 'ml', calories: 62, protein: 3),
    MealIngredient(name: 'Yến mạch', emoji: '🌾', quantity: 250, unit: 'g', calories: 380, protein: 13),
    MealIngredient(name: 'Trứng gà', emoji: '🥚', quantity: 6, unit: 'quả', calories: 140, protein: 13),
    MealIngredient(name: 'Quả bơ', emoji: '🥑', quantity: 1, unit: 'quả', calories: 160, protein: 2)
  ];

  // Static recipes
  final List<MealRecipe> _allRecipes = const [
    MealRecipe(
      name: 'Yến mạch trộn sữa tươi',
      emoji: '🥣',
      description: 'Bữa sáng siêu nhanh dồi dào chất xơ, hỗ trợ tiêu hóa lành mạnh.',
      nutritionBrief: '🔥314 Kcal | 🥩12g Protein',
      calories: 314,
      protein: 12,
      carbs: 55,
      fat: 5,
      requiredIngredients: [
        RequiredIngredient('Yến mạch', 50, 'g'),
        RequiredIngredient('Sữa tươi', 200, 'ml'),
      ],
      instructions: 'Cho yến mạch vào bát, đổ sữa tươi ngập mặt. Quay lò vi sóng 1 phút hoặc ngâm mềm trong 5 phút. Có thể thêm mật ong hoặc hạt khô nếu thích.',
    ),
    MealRecipe(
      name: 'Ức gà xào bông cải xanh',
      emoji: '🥦',
      description: 'Món ăn kinh điển giàu protein tự nhiên của gymer, đầy đủ đạm và chất xơ.',
      nutritionBrief: '🔥364 Kcal | 🥩65g Protein',
      calories: 364,
      protein: 65,
      carbs: 10,
      fat: 7,
      requiredIngredients: [
        RequiredIngredient('Ức gà', 200, 'g'),
        RequiredIngredient('Bông cải', 100, 'g'),
      ],
      instructions: 'Ức gà thái hạt lựu, áp chảo với chút tỏi và hạt tiêu thơm lừng. Cho bông cải xào cùng với chút nước tương nhạt trong 5-7 phút cho tới khi chín giòn.',
    ),
    MealRecipe(
      name: 'Trứng chiên bông cải xanh',
      emoji: '🍳',
      description: 'Sự kết hợp thơm béo thanh mát, cung cấp năng lượng đa dạng.',
      nutritionBrief: '🔥174 Kcal | 🥩14g Protein',
      calories: 174,
      protein: 14,
      carbs: 4,
      fat: 11,
      requiredIngredients: [
        RequiredIngredient('Trứng gà', 2, 'quả'),
        RequiredIngredient('Bông cải', 50, 'g'),
      ],
      instructions: 'Đánh tan trứng gà cùng chút hạt tiêu. Băm nhỏ bông cải rồi xào qua, sau đó đổ trứng vào chiên vàng đều hai mặt ở lửa vừa.',
    ),
    MealRecipe(
      name: 'Salad gà bơ cà chua',
      emoji: '🥗',
      description: 'Sự béo bùi của bơ chín mọng hoà quyện với ức gà xé phay ngọt thịt.',
      nutritionBrief: '🔥485 Kcal | 🥩50g Protein',
      calories: 485,
      protein: 50,
      carbs: 15,
      fat: 26,
      requiredIngredients: [
        RequiredIngredient('Ức gà', 150, 'g'),
        RequiredIngredient('Quả bơ', 1, 'quả'),
        RequiredIngredient('Cà chua', 1, 'quả'),
      ],
      instructions: 'Luộc chín ức gà rồi xé phay. Thái lát mỏng bơ và cà chua chín. Trộn tất cả cùng chút dấm balsamic, muối hồng và muỗng dầu ô liu.',
    ),
    MealRecipe(
      name: 'Trứng xào cà chua hành tây',
      emoji: '🍅',
      description: 'Nhanh gọn, đầy màu sắc, ngọt vị tự nhiên từ hành tây và xốt cà chua ấm áp.',
      nutritionBrief: '🔥220 Kcal | 🥩15g Protein',
      calories: 220,
      protein: 15,
      carbs: 12,
      fat: 13,
      requiredIngredients: [
        RequiredIngredient('Trứng gà', 2, 'quả'),
        RequiredIngredient('Cà chua', 1, 'quả'),
        RequiredIngredient('Hành tây', 1, 'quả'),
      ],
      instructions: 'Hành tây xào thơm xém cạnh, trút cà chua băm nhỏ vào đảo mềm cho ra xốt sệt. Đổ trứng gà đánh tan vào đảo đều cho tới khi chín mềm mịn màng.',
    ),
    MealRecipe(
      name: 'Bò lúc lắc hành tây cà chua',
      emoji: '🥩',
      description: 'Món ăn giàu sắt và kẽm, thơm dậy hương tỏi cháy xém hấp dẫn dạ dày.',
      nutritionBrief: '🔥520 Kcal | 🥩42g Protein',
      calories: 520,
      protein: 42,
      carbs: 18,
      fat: 32,
      requiredIngredients: [
        RequiredIngredient('Thịt bò', 200, 'g'),
        RequiredIngredient('Hành tây', 1, 'quả'),
        RequiredIngredient('Cà chua', 1, 'quả'),
      ],
      instructions: 'Thịt bò cắt khối vuông ướp tỏi tỏi dầu hào. Bật lửa lớn, áp chảo bò chín tái nhanh chóng rồi trút hành tây, cà chua cắt miếng vuông vào xốc mạnh tay.',
    ),
    MealRecipe(
      name: 'Cá hồi nướng măng tây bơ chanh',
      emoji: '🐟',
      description: 'Nguồn cung dồi dào chất béo omega-3 và chất xơ măng tây thanh mảnh.',
      nutritionBrief: '🔥390 Kcal | 🥩32g Protein',
      calories: 390,
      protein: 32,
      carbs: 8,
      fat: 25,
      requiredIngredients: [
        RequiredIngredient('Cá hồi', 150, 'g'),
        RequiredIngredient('Măng tây', 100, 'g'),
        RequiredIngredient('Quả chanh', 1, 'quả'),
      ],
      instructions: 'Cá hồi áp chảo hoặc nướng lò cùng măng tây rắc muối tiêu nhạt. Tưới lên xốt bơ chanh tươi ấm áp trước khi bầy ra đĩa.',
    )
  ];

  // Filtering states
  int _activeFilterIdx = 0; // 0: Tất cả, 1: Có thể nấu ngay, 2: Thiếu nguyên liệu
  final Set<String> _shoppingList = {};

  // Form input controllers for adding ingredients
  final _addIngKey = GlobalKey<FormState>();
  final _ingNameCtrl = TextEditingController();
  final _ingEmojiCtrl = TextEditingController(text: '🥦');
  final _ingQtyCtrl = TextEditingController();
  final _ingUnitCtrl = TextEditingController(text: 'g');
  final _ingCalCtrl = TextEditingController();
  final _ingProCtrl = TextEditingController();

  @override
  void dispose() {
    _ingNameCtrl.dispose();
    _ingEmojiCtrl.dispose();
    _ingQtyCtrl.dispose();
    _ingUnitCtrl.dispose();
    _ingCalCtrl.dispose();
    _ingProCtrl.dispose();
    super.dispose();
  }

  // Check if all required ingredients of a recipe exist in the refrigerator
  bool _canCookNow(MealRecipe recipe) {
    for (final req in recipe.requiredIngredients) {
      final exists = _availableIngredients.any(
        (avail) => avail.name.toLowerCase() == req.name.toLowerCase() && avail.quantity >= req.quantity,
      );
      if (!exists) return false;
    }
    return true;
  }

  // Get missing ingredients of a recipe
  List<RequiredIngredient> _getMissingIngredients(MealRecipe recipe) {
    List<RequiredIngredient> missing = [];
    for (final req in recipe.requiredIngredients) {
      final availIndex = _availableIngredients.indexWhere(
        (avail) => avail.name.toLowerCase() == req.name.toLowerCase(),
      );
      if (availIndex == -1 || _availableIngredients[availIndex].quantity < req.quantity) {
        missing.add(req);
      }
    }
    return missing;
  }

  // Filter recipes based on tab selection
  List<MealRecipe> get _filteredRecipes {
    if (_activeFilterIdx == 1) {
      return _allRecipes.where((r) => _canCookNow(r)).toList();
    } else if (_activeFilterIdx == 2) {
      return _allRecipes.where((r) => !_canCookNow(r)).toList();
    }
    return _allRecipes;
  }

  void _showAddIngredientDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm nguyên liệu tủ lạnh 🥦', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: _addIngKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _ingNameCtrl,
                    decoration: const InputDecoration(labelText: 'Tên thực phẩm'),
                    validator: (v) => v == null || v.isEmpty ? 'Nhập tên thực phẩm' : null,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ingEmojiCtrl,
                          decoration: const InputDecoration(labelText: 'Biểu tượng'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _ingUnitCtrl,
                          decoration: const InputDecoration(labelText: 'Đơn vị'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _ingQtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Số lượng'),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Nhập số' : null,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ingCalCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Kcal / 100g'),
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Nhập số' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _ingProCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Protein / 100g'),
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Nhập số' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Huỷ', style: TextStyle(color: AppTheme.vibrantTextMedium)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_addIngKey.currentState!.validate()) {
                  setState(() {
                    _availableIngredients.add(
                      MealIngredient(
                        name: _ingNameCtrl.text,
                        emoji: _ingEmojiCtrl.text,
                        quantity: double.parse(_ingQtyCtrl.text),
                        unit: _ingUnitCtrl.text,
                        calories: int.parse(_ingCalCtrl.text),
                        protein: int.parse(_ingProCtrl.text),
                      ),
                    );
                    _ingNameCtrl.clear();
                    _ingQtyCtrl.clear();
                    _ingCalCtrl.clear();
                    _ingProCtrl.clear();
                  });
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vibrantPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thêm vào'),
            ),
          ],
        );
      },
    );
  }

  void _showRecipeDetails(MealRecipe recipe) {
    final canCook = _canCookNow(recipe);
    final missing = _getMissingIngredients(recipe);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            recipe.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  recipe.nutritionBrief,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.vibrantPrimary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        recipe.description,
                        style: const TextStyle(fontSize: 12, color: AppTheme.vibrantTextMedium, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nguyên liệu yêu cầu:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                      ),
                      const SizedBox(height: 8),

                      Column(
                        children: recipe.requiredIngredients.map((req) {
                          final avail = _availableIngredients.firstWhere(
                            (a) => a.name.toLowerCase() == req.name.toLowerCase(),
                            orElse: () => MealIngredient(name: '', emoji: '', quantity: 0, unit: '', calories: 0, protein: 0),
                          );
                          final hasEnough = avail.name.isNotEmpty && avail.quantity >= req.quantity;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  hasEnough ? Icons.check_circle : Icons.cancel,
                                  color: hasEnough ? AppTheme.vibrantPrimary : AppTheme.vibrantAlertCoral,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${req.name} (${req.quantity} ${req.unit})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: hasEnough ? AppTheme.vibrantTextDark : AppTheme.vibrantTextMedium,
                                  ),
                                ),
                                const Spacer(),
                                if (avail.name.isNotEmpty)
                                  Text(
                                    'Có sẵn: ${avail.quantity} ${avail.unit}',
                                    style: const TextStyle(fontSize: 10, color: AppTheme.vibrantTextLight),
                                  )
                                else
                                  const Text(
                                    'Không có sẵn',
                                    style: TextStyle(fontSize: 10, color: AppTheme.vibrantAlertCoral, fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        'Hướng dẫn chế biến:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recipe.instructions,
                        style: const TextStyle(fontSize: 12, color: AppTheme.vibrantTextMedium, height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          if (!canCook)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    for (final m in missing) {
                                      _shoppingList.add(m.name);
                                    }
                                  });
                                  setModalState(() {});
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đã thêm các nguyên liệu thiếu vào danh sách mua sắm! 🛒')),
                                  );
                                },
                                icon: const Icon(Icons.add_shopping_cart, size: 14, color: AppTheme.vibrantPrimary),
                                label: const Text('Sắm đồ còn thiếu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.vibrantPrimary)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.vibrantPrimary),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  minimumSize: const Size.fromHeight(40),
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  // Deduct ingredients from refrigerator
                                  setState(() {
                                    for (final req in recipe.requiredIngredients) {
                                      final idx = _availableIngredients.indexWhere(
                                        (avail) => avail.name.toLowerCase() == req.name.toLowerCase(),
                                      );
                                      if (idx != -1) {
                                        final current = _availableIngredients[idx];
                                        _availableIngredients[idx] = MealIngredient(
                                          name: current.name,
                                          emoji: current.emoji,
                                          quantity: (current.quantity - req.quantity).clamp(0, 999999),
                                          unit: current.unit,
                                          calories: current.calories,
                                          protein: current.protein,
                                        );
                                      }
                                    }
                                  });

                                  // Log to meals
                                  await widget.onAddRecommendedMeal(
                                    AddMealLogParams(
                                      mealType: MealType.breakfast, // Default
                                      foodName: recipe.name,
                                      portion: '1 phần nấu',
                                      calories: recipe.calories,
                                      protein: recipe.protein,
                                      carbs: recipe.carbs,
                                      fat: recipe.fat,
                                      tags: const ['recommended', 'home_cooking'],
                                    ),
                                  );

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Đã nấu và log món ăn: ${recipe.name}! 🍲')),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.restaurant, size: 14, color: Colors.white),
                                label: const Text('Nấu & Log thành bữa ăn', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.vibrantPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  minimumSize: const Size.fromHeight(40),
                                ),
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Món Ăn Khuyên Dùng 🥗'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            const Text(
              'Cơ chế gợi ý công thức ăn uống lành mạnh tự nhiên dựa trên thể trạng cá nhân và nguyên liệu sẵn có.',
              style: TextStyle(fontSize: 12, color: AppTheme.vibrantTextMedium),
            ),
            const SizedBox(height: 16),

            // Health goals & avoid list banner
            Card(
              color: AppTheme.vibrantLightHighlight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.vibrantBorderLight),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, color: AppTheme.vibrantPrimary, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bản Đồ Nhu Cầu & Dị Ứng Cá Nhân 🥗',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Mục tiêu của bạn là Giữ cân an lành. Hệ thống tự động ẩn hoặc cảnh báo các món có chứa thành phần Shellfish (Hải sản có vỏ) để đảm bảo tối đa an toàn dị ứng cho sức khoẻ của bạn.',
                            style: TextStyle(fontSize: 11, color: AppTheme.vibrantTextMedium, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Refrigerator Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thành phần thực phẩm hiện có 🥦',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                ),
                IconButton(
                  onPressed: _showAddIngredientDialog,
                  icon: const Icon(Icons.add, color: AppTheme.vibrantPrimary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.vibrantLightHighlight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Refrigerator item pills
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIngredients.map((avail) {
                return Chip(
                  avatar: Text(avail.emoji),
                  label: Text('${avail.name} (${avail.quantity.toStringAsFixed(0)} ${avail.unit})'),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppTheme.vibrantBorderMedium),
                  onDeleted: () {
                    setState(() {
                      _availableIngredients.removeWhere((item) => item.name == avail.name);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Filter Tab pills (Tất cả, Có thể nấu ngay, Thiếu nguyên liệu)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.vibrantBorderMedium),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _filterPill('Tất cả', 0),
                  _filterPill('Có thể nấu ngay 🟢', 1),
                  _filterPill('Thiếu đồ 🔴', 2),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recipes List
            const Text(
              'Gợi ý thực đơn cá nhân hoá:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
            ),
            const SizedBox(height: 8),

            if (_filteredRecipes.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text('Không tìm thấy gợi ý phù hợp nào.', style: TextStyle(color: AppTheme.vibrantTextLight)),
                ),
              )
            else
              Column(
                children: _filteredRecipes.map((recipe) {
                  final canCook = _canCookNow(recipe);

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Text(recipe.emoji, style: const TextStyle(fontSize: 28)),
                      title: Text(recipe.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(recipe.description, style: const TextStyle(fontSize: 11, color: AppTheme.vibrantTextMedium), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(recipe.nutritionBrief, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.vibrantPrimary)),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: canCook ? AppTheme.vibrantLightHighlight : AppTheme.vibrantAlertCoral.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                child: Text(
                                  canCook ? 'Có thể nấu' : 'Thiếu đồ',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: canCook ? AppTheme.vibrantPrimary : AppTheme.vibrantAlertCoral,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () => _showRecipeDetails(recipe),
                    ),
                  );
                }).toList(),
              ),

            // Shopping List Section
            if (_shoppingList.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Danh sách sắm đồ cần mua 🛒',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: _shoppingList.map((item) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.shopping_bag_outlined, color: AppTheme.vibrantPrimary),
                        title: Text(item, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark)),
                        trailing: IconButton(
                          icon: const Icon(Icons.check, color: AppTheme.vibrantPrimary),
                          onPressed: () {
                            setState(() {
                              _shoppingList.remove(item);
                              // Add 200g of this item to refrigerator when bought
                              _availableIngredients.add(
                                MealIngredient(name: item, emoji: '🥕', quantity: 200, unit: 'g', calories: 40, protein: 1),
                              );
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _filterPill(String text, int index) {
    final isSelected = _activeFilterIdx == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeFilterIdx = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.vibrantPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppTheme.vibrantTextMedium,
            ),
          ),
        ),
      ),
    );
  }
}
