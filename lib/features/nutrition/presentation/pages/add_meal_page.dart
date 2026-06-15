import 'package:flutter/material.dart';

import '../../application/usecases/add_meal_log_usecase.dart';
import '../../domain/entities/meal_log.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({required this.onMealSaved, super.key});

  final Future<void> Function(AddMealLogParams params) onMealSaved;

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _portionController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  MealType _mealType = MealType.lunch;
  final Set<String> _selectedTags = {'balanced'};

  static const _availableTags = [
    'high_protein',
    'light',
    'balanced',
    'quick_meal',
    'breakfast',
    'lunch',
    'dinner',
    'snack',
    'vegetarian',
    'low_sugar',
    'high_fiber',
    'custom_food',
  ];

  @override
  void dispose() {
    _foodNameController.dispose();
    _portionController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final params = AddMealLogParams(
      mealType: _mealType,
      foodName: _foodNameController.text.trim(),
      portion: _portionController.text.trim(),
      calories: int.parse(_caloriesController.text),
      protein: int.parse(_proteinController.text),
      carbs: int.parse(_carbsController.text),
      fat: int.parse(_fatController.text),
      tags: _selectedTags.toList(),
    );

    await widget.onMealSaved(params);
    if (!mounted) {
      return;
    }

    _formKey.currentState!.reset();
    _foodNameController.clear();
    _portionController.clear();
    _caloriesController.clear();
    _proteinController.clear();
    _carbsController.clear();
    _fatController.clear();
    setState(() {
      _mealType = MealType.lunch;
      _selectedTags
        ..clear()
        ..add('balanced');
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Meal saved to today.')));

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _requiredNumber(String? value) {
    final text = value?.trim() ?? '';
    final number = int.tryParse(text);
    if (number == null || number < 0) {
      return 'Enter 0 or more';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Meal')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<MealType>(
                key: const Key('mealTypeField'),
                initialValue: _mealType,
                decoration: const InputDecoration(labelText: 'Meal type'),
                items: MealType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _mealType = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('foodNameField'),
                controller: _foodNameController,
                decoration: const InputDecoration(labelText: 'Food name'),
                textInputAction: TextInputAction.next,
                validator: _requiredText,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('portionField'),
                controller: _portionController,
                decoration: const InputDecoration(labelText: 'Portion'),
                textInputAction: TextInputAction.next,
                validator: _requiredText,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('caloriesField'),
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: _requiredNumber,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('proteinField'),
                      controller: _proteinController,
                      decoration: const InputDecoration(labelText: 'Protein'),
                      keyboardType: TextInputType.number,
                      validator: _requiredNumber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      key: const Key('carbsField'),
                      controller: _carbsController,
                      decoration: const InputDecoration(labelText: 'Carbs'),
                      keyboardType: TextInputType.number,
                      validator: _requiredNumber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      key: const Key('fatField'),
                      controller: _fatController,
                      decoration: const InputDecoration(labelText: 'Fat'),
                      keyboardType: TextInputType.number,
                      validator: _requiredNumber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Tags', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTags.map((tag) {
                  final selected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                key: const Key('saveMealButton'),
                onPressed: _saveMeal,
                icon: const Icon(Icons.check),
                label: const Text('Save Meal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
