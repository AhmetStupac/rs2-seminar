import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/models/nutrition_plan.dart';
import 'package:personaltrainer_mobile/models/user.dart';
import 'package:personaltrainer_mobile/models/personal_trainer.dart';
import 'package:personaltrainer_mobile/providers/nutrition_plan_provider.dart';
import 'package:personaltrainer_mobile/providers/user_provider.dart';
import 'package:personaltrainer_mobile/providers/personal_trainer_provider.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';

class NutritionPlanMainArea extends StatefulWidget {
  @override
  _NutritionPlanMainAreaState createState() => _NutritionPlanMainAreaState();
}

class _NutritionPlanMainAreaState extends State<NutritionPlanMainArea> {
  final TextEditingController TitleController = TextEditingController();
  final TextEditingController DescriptionController = TextEditingController();
  final TextEditingController TotalCaloriesController = TextEditingController();
  final TextEditingController ProteinController = TextEditingController();
  final TextEditingController CarbsController = TextEditingController();
  final TextEditingController FatsController = TextEditingController();
  final TextEditingController PriceController = TextEditingController();

  late NutritionPlanProvider _nutritionProvider;
  late UserProvider _userProvider;
  late PersonalTrainerProvider _personalTrainerProvider;
  List<NutritionPlan> _availablePlans = [];
  List<User> _users = [];
  List<PersonalTrainer> _personalTrainers = [];
  int? _selectedUserId;
  int? _selectedPersonalTrainerId;
  bool _loadingUsers = false;
  String? _usersError;
  bool _loadingTrainers = false;
  String? _trainersError;
  bool _loadingPlans = false;
  String? _plansError;
  int? _selectedPlanId;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _nutritionProvider = NutritionPlanProvider();
    _userProvider = UserProvider();
    _personalTrainerProvider = PersonalTrainerProvider();
    _fetchAvailablePlans();
    _fetchUsers();
    _fetchPersonalTrainers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _loadingUsers = true;
      _usersError = null;
    });

    try {
      final result = await _userProvider.get();
      print('Fetched users count: ${result.count}');
      setState(() {
        _users = result.result;
        _loadingUsers = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        _usersError = e.toString();
        _loadingUsers = false;
      });
    }
  }

  Future<void> _fetchPersonalTrainers() async {
    setState(() {
      _loadingTrainers = true;
      _trainersError = null;
    });

    try {
      print('🔍 Fetching personal trainers from API...');
      print('🔍 Endpoint: ${_personalTrainerProvider.runtimeType}');
      final result = await _personalTrainerProvider.get();
      print('✅ Fetched personal trainers count: ${result.count}');
      print('✅ Personal trainers list length: ${result.result.length}');
      if (result.result.isNotEmpty) {
      } else {
        print('⚠️ Personal trainers list is empty!');
      }
      setState(() {
        _personalTrainers = result.result;
        _loadingTrainers = false;
      });
    } catch (e, stackTrace) {
      print('❌ Error fetching personal trainers: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Stack trace: $stackTrace');
      setState(() {
        _trainersError = 'Failed to load trainers: ${e.toString()}';
        _loadingTrainers = false;
      });
    }
  }

  @override
  void dispose() {
    TitleController.dispose();
    DescriptionController.dispose();
    TotalCaloriesController.dispose();
    ProteinController.dispose();
    CarbsController.dispose();
    FatsController.dispose();
    PriceController.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailablePlans() async {
    setState(() {
      _loadingPlans = true;
      _plansError = null;
    });
    try {
      final result = await _nutritionProvider.get();
      setState(() {
        _availablePlans = result.result;
        _loadingPlans = false;
      });
    } catch (e) {
      setState(() {
        _plansError = e.toString();
        _loadingPlans = false;
      });
    }
  }

  void _selectPlan(NutritionPlan plan) {
    if (plan.id == null) return;
    setState(() {
      _selectedPlanId = plan.id;
      TitleController.text = plan.title ?? '';
      DescriptionController.text = plan.description ?? '';
      TotalCaloriesController.text = plan.totalCalories ?? '';
      ProteinController.text = plan.protein ?? '';
      CarbsController.text = plan.carbs ?? '';
      FatsController.text = plan.fats?.toString() ?? '';
      PriceController.text = plan.price?.toString() ?? '';
    });
  }

  void posaljiNaAPI() async {
    final title = TitleController.text.trim();
    final desc = DescriptionController.text.trim();
    final totalCalories = TotalCaloriesController.text.trim();
    final protein = ProteinController.text.trim();
    final carbs = CarbsController.text.trim();
    final fatsInt = int.tryParse(FatsController.text.trim());
    final priceDouble = double.tryParse(PriceController.text.trim());

    final double? totalCaloriesNum = double.tryParse(totalCalories);
    final double? proteinNum = double.tryParse(protein);
    final double? carbsNum = double.tryParse(carbs);

    if (title.isEmpty || totalCaloriesNum == null || proteinNum == null || carbsNum == null || fatsInt == null || priceDouble == null) {
      setState(() {
        errorMessage = 'Please fill Title and enter numeric values for Total Calories, Protein, Carbs, Fats and Price.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    print('📋 Creating nutrition plan with personalTrainerId: ${_selectedPersonalTrainerId}');
    print('📋 Current token: ${AuthProvider.token?.substring(0, 20)}...');
    
    final NutritionPlan plan = NutritionPlan(
      title: title,
      description: desc,
      totalCalories: totalCaloriesNum.toString(),
      protein: proteinNum.toString(),
      carbs: carbsNum.toString(),
      fats: fatsInt,
      price: priceDouble,
      createdAt: DateTime.now().toIso8601String(),
      userId: _selectedUserId,
      personalTrainerId: _selectedPersonalTrainerId,
    );

    print('📋 Plan JSON: ${jsonEncode(plan.toJson())}');

    try {
      final inserted = await _nutritionProvider.insert(plan.toJson());
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nutrition plan saved (id: ${inserted.id ?? 0})')),
      );
      _fetchAvailablePlans();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error sending to API: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            SizedBox(height: 8),
            TextField(controller: TitleController, decoration: InputDecoration(border: OutlineInputBorder())),
            SizedBox(height: 12),
            Text('User', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            SizedBox(height: 8),
            if (_loadingUsers)
              SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
            else if (_usersError != null)
              Row(
                children: [
                  Expanded(child: Text('Error loading users', style: TextStyle(color: Colors.red))),
                  TextButton(onPressed: _fetchUsers, child: Text('Retry')),
                ],
              )
            else
              DropdownButtonFormField<int>(
                value: _users.isNotEmpty && _users.any((u) => u.id == _selectedUserId)
                    ? _selectedUserId
                    : null,
                items: _users.map((u) {
                  final label = "${u.firstName ?? ''} ${u.lastName ?? ''}".trim();
                  return DropdownMenuItem<int>(
                    value: u.id,
                    child: Text(label.isNotEmpty ? label : (u.username ?? 'User')),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() => _selectedUserId = v);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select user (optional)',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
            SizedBox(height: 16),
            Text('Personal Trainer', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            SizedBox(height: 8),
            if (_loadingTrainers)
              SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
            else if (_trainersError != null)
              Row(
                children: [
                  Expanded(child: Text(_trainersError!, style: TextStyle(color: Colors.red, fontSize: 12))),
                  TextButton(onPressed: _fetchPersonalTrainers, child: Text('Retry')),
                ],
              )
            else
              DropdownButtonFormField<int>(
                value: () {
                  final trainersWithIds = _personalTrainers.where((t) => t.id != null).toList();
                  if (trainersWithIds.isEmpty) return null;
                  if (_selectedPersonalTrainerId == null) return null;
                  return trainersWithIds.any((t) => t.id == _selectedPersonalTrainerId)
                      ? _selectedPersonalTrainerId
                      : null;
                }(),
                items: _personalTrainers
                    .where((t) => t.id != null)
                    .map((t) {
                      final displayName = t.userFirstName?.isNotEmpty == true
                          ? t.userFirstName!
                          : 'Trainer ${t.id}';
                      return DropdownMenuItem<int>(
                        value: t.id!,
                        child: Text('$displayName (${t.yearsOfExperience ?? 0} years)'),
                      );
                    }).toList(),
                onChanged: (v) {
                  setState(() => _selectedPersonalTrainerId = v);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select personal trainer (optional)',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
            SizedBox(height: 16),
            Text('Description', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            SizedBox(height: 8),
            TextField(controller: DescriptionController, maxLines: 3, decoration: InputDecoration(border: OutlineInputBorder())),
            SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Total Calories', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  SizedBox(height: 8),
                  TextField(controller: TotalCaloriesController, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(border: OutlineInputBorder())),
                ]),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Protein', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  SizedBox(height: 8),
                  TextField(controller: ProteinController, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(border: OutlineInputBorder())),
                ]),
              ),
            ]),
            SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Carbs', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  SizedBox(height: 8),
                  TextField(controller: CarbsController, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(border: OutlineInputBorder())),
                ]),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Fats', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  SizedBox(height: 8),
                  TextField(controller: FatsController, keyboardType: TextInputType.number, decoration: InputDecoration(border: OutlineInputBorder())),
                ]),
              ),
            ]),
            SizedBox(height: 16),
            Text('Price', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            SizedBox(height: 8),
            TextField(controller: PriceController, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(border: OutlineInputBorder())),
            SizedBox(height: 24),
            if (errorMessage != null)
              Container(padding: EdgeInsets.all(12), color: Colors.red[50], child: Text(errorMessage!, style: TextStyle(color: Colors.red))),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : posaljiNaAPI,
                icon: Icon(Icons.send),
                label: Text('Send to API'),
              ),
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
