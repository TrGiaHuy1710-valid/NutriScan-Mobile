import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/user_health_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    required this.profile,
    required this.accountEmail,
    required this.loginStatus,
    required this.onProfileUpdated,
    required this.onCustomTargetsUpdated,
    required this.onClearMeals,
    required this.onClearScanned,
    required this.onClearWorkouts,
    required this.onResetAll,
    required this.onLogout,
    super.key,
  });

  final UserHealthProfile profile;
  final String accountEmail;
  final String loginStatus;
  final Future<void> Function({
    required String name,
    required double weight,
    required double height,
    required int age,
    required String goal,
    required String restrictions,
  }) onProfileUpdated;
  final Future<void> Function({
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) onCustomTargetsUpdated;
  final VoidCallback onClearMeals;
  final VoidCallback onClearScanned;
  final VoidCallback onClearWorkouts;
  final VoidCallback onResetAll;
  final VoidCallback onLogout;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _ageController;
  late TextEditingController _restrictionsController;

  late TextEditingController _calController;
  late TextEditingController _proController;
  late TextEditingController _carbController;
  late TextEditingController _fatController;

  String _selectedGoal = 'Giữ cân';
  final List<String> _goals = ['Giảm cân', 'Giữ cân', 'Tăng cân', 'Lối sống lành mạnh'];

  // Switches
  bool _waterReminder = true;
  bool _aiCompanion = true;
  bool _workoutAlert = true;

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  void _initFields() {
    _nameController = TextEditingController(text: widget.profile.name);
    _weightController = TextEditingController(text: widget.profile.weight.toString());
    _heightController = TextEditingController(text: widget.profile.height.toString());
    _ageController = TextEditingController(text: widget.profile.age.toString());
    _restrictionsController = TextEditingController(text: widget.profile.dietaryRestrictions);

    _calController = TextEditingController(text: widget.profile.targetCalories.toString());
    _proController = TextEditingController(text: widget.profile.targetProtein.toString());
    _carbController = TextEditingController(text: widget.profile.targetCarbs.toString());
    _fatController = TextEditingController(text: widget.profile.targetFat.toString());

    _selectedGoal = widget.profile.healthGoal;
    if (!_goals.contains(_selectedGoal)) {
      _selectedGoal = 'Giữ cân';
    }
  }

  @override
  void didUpdateWidget(ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _initFields();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _restrictionsController.dispose();
    _calController.dispose();
    _proController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  double get _bmi {
    if (widget.profile.height <= 0) return 0;
    final hMeters = widget.profile.height / 100.0;
    return widget.profile.weight / (hMeters * hMeters);
  }

  String get _bmiStatus {
    final val = _bmi;
    if (val < 18.5) return 'Thiếu cân ⚠️';
    if (val < 23) return 'Bình thường ✨';
    if (val < 25) return 'Thừa cân nhẹ ⚠️';
    return 'Béo phì 🚨';
  }

  Color get _bmiColor {
    final val = _bmi;
    if (val >= 18.5 && val < 23) return AppTheme.vibrantPrimary;
    return AppTheme.vibrantAlertCoral;
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      await widget.onProfileUpdated(
        name: _nameController.text,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        age: int.parse(_ageController.text),
        goal: _selectedGoal,
        restrictions: _restrictionsController.text,
      );
      setState(() {
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật hồ sơ thể trạng và tự động tính toán calo! 🌱')),
        );
      }
    }
  }

  Future<void> _saveCustomTargets() async {
    final cal = int.tryParse(_calController.text) ?? widget.profile.targetCalories;
    final pro = int.tryParse(_proController.text) ?? widget.profile.targetProtein;
    final carb = int.tryParse(_carbController.text) ?? widget.profile.targetCarbs;
    final fat = int.tryParse(_fatController.text) ?? widget.profile.targetFat;

    await widget.onCustomTargetsUpdated(
      calories: cal,
      protein: pro,
      carbs: carb,
      fat: fat,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật mục tiêu calo & macros tự chọn! 🎯')),
      );
    }
  }

  void _showDeleteDialog(String title, String content, VoidCallback onConfirm) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Huỷ', style: TextStyle(color: AppTheme.vibrantTextMedium)),
            ),
            ElevatedButton(
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vibrantAlertCoral,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xoá sạch'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTeenager = widget.profile.age < 18;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ Sơ Sức Khoẻ Cá Nhân 👤'),
        actions: [
          IconButton(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout, color: AppTheme.vibrantAlertCoral),
            tooltip: 'Đăng xuất',
          )
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              const Text(
                'Quản lý chỉ số cơ thể, mục tiêu rèn luyện và cá nhân hóa các thiết lập ứng dụng.',
                style: TextStyle(fontSize: 12, color: AppTheme.vibrantTextMedium),
              ),
              const SizedBox(height: 16),

              // Teenager safety banner
              if (isTeenager) ...[
                Card(
                  color: AppTheme.vibrantAlertCoral.withAlpha(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppTheme.vibrantAlertCoral.withAlpha(50)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: AppTheme.vibrantAlertCoral, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Bạn đang ở độ tuổi phát triển (<18 tuổi). Xin hãy tham khảo ý kiến của cha mẹ hoặc bác sĩ dinh dưỡng trước khi thay đổi mục tiêu calo để phát triển an toàn toàn diện.',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.vibrantTextDark,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // BMI card
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _bmiColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _bmi.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: _bmiColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Chỉ số khối cơ thể (BMI)',
                              style: TextStyle(fontSize: 11, color: AppTheme.vibrantTextMedium, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _bmiStatus,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _bmiColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Giữ chỉ số BMI từ 18.5 - 22.9 để có thể trạng tối ưu nhất.',
                              style: TextStyle(fontSize: 10, color: AppTheme.vibrantTextLight),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Form card
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
                            'Thông Tin Thể Trạng Hiện Tại 📊',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                          ),
                          if (!_isEditing)
                            IconButton(
                              onPressed: () => setState(() => _isEditing = true),
                              icon: const Icon(Icons.edit, color: AppTheme.vibrantPrimary, size: 18),
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.vibrantLightHighlight,
                                shape: const CircleBorder(),
                              ),
                            )
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: AppTheme.vibrantBorderMedium),
                      const SizedBox(height: 8),

                      if (!_isEditing) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _readOnlyField('CÂN NẶNG', '${widget.profile.weight} kg'),
                            ),
                            Expanded(
                              child: _readOnlyField('CHIỀU CAO', '${widget.profile.height} cm'),
                            ),
                            Expanded(
                              child: _readOnlyField('TUỔI', '${widget.profile.age} tuổi'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('MỤC TIÊU SỨC KHOẺ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextLight)),
                                  const SizedBox(height: 4),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.vibrantLightHighlight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text(
                                      widget.profile.healthGoal,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('DỊ ỨNG / HẠN CHẾ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextLight)),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.profile.dietaryRestrictions.isEmpty
                                        ? 'Không có dị ứng nào 🎉'
                                        : widget.profile.dietaryRestrictions,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _isEditing = true),
                          icon: const Icon(Icons.edit, size: 14, color: AppTheme.vibrantPrimary),
                          label: const Text('Chỉnh Sửa Chỉ Số Hồ Sơ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.vibrantPrimary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size.fromHeight(40),
                          ),
                        ),
                      ] else ...[
                        // Edit fields
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Họ và tên'),
                          validator: (v) => v == null || v.isEmpty ? 'Hãy nhập họ và tên' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Cân nặng (kg)'),
                                validator: (v) => double.tryParse(v ?? '') == null ? 'Lỗi số' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _heightController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Chiều cao (cm)'),
                                validator: (v) => double.tryParse(v ?? '') == null ? 'Lỗi số' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Tuổi'),
                                validator: (v) => int.tryParse(v ?? '') == null ? 'Lỗi số' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedGoal,
                          decoration: const InputDecoration(labelText: 'Mục tiêu sức khoẻ'),
                          items: _goals.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedGoal = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _restrictionsController,
                          decoration: const InputDecoration(
                            labelText: 'Hạn chế ăn uống / Dị ứng',
                            hintText: 'Ví dụ: Shellfish, Gluten, Peanut...',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => setState(() {
                                  _isEditing = false;
                                  _initFields();
                                }),
                                child: const Text('Huỷ', style: TextStyle(color: AppTheme.vibrantTextMedium)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.vibrantPrimary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Lưu hồ sơ'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Custom Targets configuration
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mục Tiêu Dinh Dưỡng Tự Chọn 🎯',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Điều chỉnh calo và protein/carbs/fat theo chế độ ăn uống chuyên biệt.',
                        style: TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _calController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Calo (kcal)'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _proController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Protein (g)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _carbController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Carbs (g)'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _fatController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Fat (g)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saveCustomTargets,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.vibrantSecondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child: const Text('Cập nhật chỉ số calo & macros'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Settings Card
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cài Đặt Ứng Dụng ⚙️',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        value: _waterReminder,
                        title: const Text('Nhắc nhở uống nước', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Báo thức uống nước đủ 2L mỗi ngày', style: TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight)),
                        activeColor: AppTheme.vibrantPrimary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => setState(() => _waterReminder = v),
                      ),
                      SwitchListTile(
                        value: _aiCompanion,
                        title: const Text('Trợ lý AI Gemini', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Phân tích thành phần nhãn dinh dưỡng', style: TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight)),
                        activeColor: AppTheme.vibrantPrimary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => setState(() => _aiCompanion = v),
                      ),
                      SwitchListTile(
                        value: _workoutAlert,
                        title: const Text('Cảnh báo lịch tập', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Báo trước 10 phút trước giờ tập rảnh', style: TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight)),
                        activeColor: AppTheme.vibrantPrimary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => setState(() => _workoutAlert = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dangerous Zone card
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vùng Nguy Hiểm / Xoá Dữ Liệu 🚨',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.vibrantAlertCoral),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Các hoạt động xoá lịch sử và đặt lại cài đặt này không thể khôi phục.',
                        style: TextStyle(fontSize: 11, color: AppTheme.vibrantTextLight),
                      ),
                      const SizedBox(height: 16),
                      _dangerousButton(
                        'Xoá toàn bộ nhật ký ăn uống',
                        () => _showDeleteDialog(
                          'Xác nhận xoá nhật ký ăn uống',
                          'Bạn có chắc chắn muốn xoá toàn bộ lịch sử các món ăn đã ghi nhận?',
                          widget.onClearMeals,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _dangerousButton(
                        'Xoá lịch sử quét thực phẩm',
                        () => _showDeleteDialog(
                          'Xác nhận xoá lịch sử quét',
                          'Bạn có chắc chắn muốn xoá toàn bộ sản phẩm và nhãn dinh dưỡng đã quét?',
                          widget.onClearScanned,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _dangerousButton(
                        'Xoá lịch trình bài tập',
                        () => _showDeleteDialog(
                          'Xác nhận xoá bài tập',
                          'Bạn có chắc chắn muốn xoá sạch toàn bộ lịch trình các bài luyện tập hôm nay?',
                          widget.onClearWorkouts,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () => _showDeleteDialog(
                          'Khôi phục cài đặt gốc',
                          'Tác vụ này sẽ đặt lại Hồ sơ về mặc định, xoá sạch lịch sử thực đơn, món ăn đã quét và bài tập luyện tập. Hành động này không thể hoàn tác!',
                          widget.onResetAll,
                        ),
                        icon: const Icon(Icons.restore, size: 14),
                        label: const Text('Khôi Phục Cài Đặt Gốc', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          minimumSize: const Size.fromHeight(40),
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
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextLight),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.vibrantTextDark),
        ),
      ],
    );
  }

  Widget _dangerousButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppTheme.vibrantBorderMedium),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size.fromHeight(40),
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.vibrantTextDark, fontWeight: FontWeight.w500)),
          const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.vibrantTextLight),
        ],
      ),
    );
  }
}
