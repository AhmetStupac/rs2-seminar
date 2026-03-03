import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/models/nutrition_plan.dart';
import 'package:personaltrainer_desktop/models/user.dart';
import 'package:personaltrainer_desktop/models/personal_trainer.dart';
import 'package:personaltrainer_desktop/providers/nutrition_plan_provider.dart';
import 'package:personaltrainer_desktop/providers/user_provider.dart';
import 'package:personaltrainer_desktop/providers/personal_trainer_provider.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart';

class NutritionPlanMainArea extends StatefulWidget {
  const NutritionPlanMainArea({super.key});

  @override
  _NutritionPlanMainAreaState createState() => _NutritionPlanMainAreaState();
}

String _errorReason(Object e) {
  final msg = e.toString();
  if (msg.startsWith('Exception: ')) return msg.replaceFirst('Exception: ', '');
  return msg;
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
        _usersError = _errorReason(e);
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
        _trainersError = _errorReason(e);
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
      print('📋 Fetched ${result.result.length} nutrition plans');
      if (result.result.isNotEmpty) {
        final firstPlan = result.result[0];
        print(
          '📋 First plan personalTrainerId: ${firstPlan.personalTrainerId}',
        );
        print('📋 First plan userId: ${firstPlan.userId}');
      }
      setState(() {
        _availablePlans = result.result;
        _loadingPlans = false;
      });
    } catch (e) {
      setState(() {
        _plansError = _errorReason(e);
        _loadingPlans = false;
      });
    }
  }

  List<NutritionPlan> get nutritionPlans => _availablePlans;

  void _selectPlan(NutritionPlan plan) {
    if (plan.id == null) return;
    print('🔍 Selecting plan: ${plan.title}');
    print('🔍 Plan personalTrainerId: ${plan.personalTrainerId}');
    print('🔍 Plan userId: ${plan.userId}');
    print(
      '🔍 Available trainers: ${_personalTrainers.map((t) => t.id).toList()}',
    );
    setState(() {
      _selectedPlanId = plan.id;
      TitleController.text = plan.title ?? '';
      DescriptionController.text = plan.description ?? '';
      TotalCaloriesController.text = plan.totalCalories ?? '';
      ProteinController.text = plan.protein ?? '';
      CarbsController.text = plan.carbs ?? '';
      FatsController.text = plan.fats?.toString() ?? '';
      PriceController.text = plan.price?.toString() ?? '';
      _selectedUserId = plan.userId;
      _selectedPersonalTrainerId = plan.personalTrainerId;
      print('✅ Set _selectedPersonalTrainerId to: $_selectedPersonalTrainerId');
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

    if (title.isEmpty ||
        totalCaloriesNum == null ||
        proteinNum == null ||
        carbsNum == null ||
        fatsInt == null ||
        priceDouble == null) {
      setState(() {
        errorMessage = 'Please fill all required fields.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    print(
      '📋 Creating nutrition plan with personalTrainerId: $_selectedPersonalTrainerId',
    );
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

    final planJson = plan.toJson();
    print('📋 Plan JSON: ${jsonEncode(planJson)}');

    try {
      if (_selectedPlanId != null) {
        // Update existing plan
        plan.id = _selectedPlanId;
        print('📋 Updating plan with payload: ${jsonEncode(planJson)}');
        final updated = await _nutritionProvider.update(
          _selectedPlanId!,
          planJson,
        );
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nutrition plan updated (id: ${updated.id ?? 0})'),
          ),
        );
      } else {
        // Insert new plan
        print('📋 Inserting plan with payload: ${jsonEncode(planJson)}');
        final inserted = await _nutritionProvider.insert(planJson);
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nutrition plan saved (id: ${inserted.id ?? 0})'),
          ),
        );
      }

      // refresh list and clear selection
      await _fetchAvailablePlans();
      _clearForm();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = _errorReason(e);
      });
    }
  }

  void _clearForm() {
    setState(() {
      _selectedPlanId = null;
      _selectedUserId = null;
      _selectedPersonalTrainerId = null;
      TitleController.clear();
      DescriptionController.clear();
      TotalCaloriesController.clear();
      ProteinController.clear();
      CarbsController.clear();
      FatsController.clear();
      PriceController.clear();
      errorMessage = null;
    });
  }

  Future<void> _deletePlan(NutritionPlan plan) async {
    if (plan.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete nutrition plan'),
        content: Text(
          'Are you sure you want to delete "${plan.title ?? 'Untitled Plan'}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => isLoading = true);
    try {
      await _nutritionProvider.delete(plan.id!);
      if (_selectedPlanId == plan.id) _clearForm();
      await _fetchAvailablePlans();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nutrition plan deleted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${_errorReason(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
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
            Text(
              'Title',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            TextField(
              controller: TitleController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 12),
            Text(
              'User',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            if (_loadingUsers)
              SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_usersError != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _usersError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(onPressed: _fetchUsers, child: Text('Retry')),
                ],
              )
            else
              DropdownButtonFormField<int>(
                initialValue:
                    _users.isNotEmpty &&
                        _users.any((u) => u.id == _selectedUserId)
                    ? _selectedUserId
                    : null,
                items: _users.map((u) {
                  final label = "${u.firstName ?? ''} ${u.lastName ?? ''}"
                      .trim();
                  return DropdownMenuItem<int>(
                    value: u.id,
                    child: Text(
                      label.isNotEmpty ? label : (u.username ?? 'User'),
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() => _selectedUserId = v);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select user (optional)',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
            SizedBox(height: 16),
            Text(
              'Personal Trainer',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            if (_loadingTrainers)
              SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_trainersError != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _trainersError!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _fetchPersonalTrainers,
                    child: Text('Retry'),
                  ),
                ],
              )
            else
              DropdownButtonFormField<int>(
                initialValue: () {
                  final trainersWithIds = _personalTrainers
                      .where((t) => t.id != null)
                      .toList();
                  if (trainersWithIds.isEmpty) return null;
                  if (_selectedPersonalTrainerId == null) return null;
                  return trainersWithIds.any(
                        (t) => t.id == _selectedPersonalTrainerId,
                      )
                      ? _selectedPersonalTrainerId
                      : null;
                }(),
                items: _personalTrainers.where((t) => t.id != null).map((t) {
                  final displayName = t.userFirstName?.isNotEmpty == true
                      ? t.userFirstName!
                      : 'Trainer ${t.id}';
                  return DropdownMenuItem<int>(
                    value: t.id!,
                    child: Text(
                      '$displayName (${t.yearsOfExperience ?? 0} years)',
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() => _selectedPersonalTrainerId = v);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select personal trainer (optional)',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
            SizedBox(height: 16),
            Text(
              'Description',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            TextField(
              controller: DescriptionController,
              maxLines: 3,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Calories',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: TotalCaloriesController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Protein',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: ProteinController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carbs',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: CarbsController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fats',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: FatsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Price (€)',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            TextField(
              controller: PriceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixText: '€ ',
              ),
            ),
            SizedBox(height: 24),
            if (errorMessage != null)
              Container(
                padding: EdgeInsets.all(12),
                color: Colors.red[50],
                child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
              ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_selectedPlanId != null) ...[
                  TextButton(
                    onPressed: isLoading ? null : _clearForm,
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            final match = _availablePlans
                                .where((p) => p.id == _selectedPlanId);
                            if (match.isNotEmpty) _deletePlan(match.first);
                          },
                    icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[700]),
                    label: Text('Delete', style: TextStyle(color: Colors.red[700])),
                  ),
                  SizedBox(width: 8),
                ],
                ElevatedButton.icon(
                  onPressed: isLoading ? null : posaljiNaAPI,
                  icon: Icon(_selectedPlanId != null ? Icons.save : Icons.send),
                  label: Text(
                    _selectedPlanId != null ? 'Update' : 'Send',
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            Divider(thickness: 2),
            SizedBox(height: 16),
            Text(
              'Available Nutrition Plans',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (_loadingPlans)
              Center(child: CircularProgressIndicator())
            else if (_plansError != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Failed to load plans.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: _fetchAvailablePlans,
                    child: Text('Retry'),
                  ),
                ],
              )
            else if (nutritionPlans.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No nutrition plans available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: nutritionPlans.length,
                itemBuilder: (context, index) {
                  final plan = nutritionPlans[index];
                  final isSelected = plan.id == _selectedPlanId;
                  return Card(
                    elevation: isSelected ? 4 : 1,
                    margin: EdgeInsets.only(bottom: 12),
                    color: isSelected ? Colors.blue[50] : null,
                    child: ListTile(
                      onTap: () => _selectPlan(plan),
                      title: Text(
                        plan.title ?? 'Untitled Plan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          if (plan.description?.isNotEmpty == true)
                            Text(
                              plan.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 16,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 4),
                              Text('${plan.totalCalories ?? "0"} cal'),
                              SizedBox(width: 16),
                              Icon(
                                Icons.fitness_center,
                                size: 16,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 4),
                              Text('P:${plan.protein ?? "0"}g'),
                              SizedBox(width: 8),
                              Text('C:${plan.carbs ?? "0"}g'),
                              SizedBox(width: 8),
                              Text('F:${plan.fats ?? 0}g'),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '€ ${plan.price?.toStringAsFixed(2) ?? "0.00"}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, color: Colors.blue),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                            tooltip: 'Delete plan',
                            onPressed: () => _deletePlan(plan),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
