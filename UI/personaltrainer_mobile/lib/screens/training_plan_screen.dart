import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/layouts/mobile_navbar.dart';
import 'package:personaltrainer_mobile/models/training_plan.dart';
import 'package:personaltrainer_mobile/models/exercise_plan.dart';
import 'package:personaltrainer_mobile/providers/training_plan_provider.dart';
import 'package:personaltrainer_mobile/providers/exercise_plan.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
import 'package:personaltrainer_mobile/screens/exercise_detail_screen.dart';

class TrainingPlanScreen extends StatefulWidget {
  const TrainingPlanScreen({super.key});

  @override
  State<TrainingPlanScreen> createState() => _TrainingPlanScreenState();
}

class _TrainingPlanScreenState extends State<TrainingPlanScreen> {
  final _trainingPlanProvider = TrainingPlanProvider();
  final _exercisePlanProvider = ExercisePlanProvider();
  
  List<TrainingPlan> _trainingPlans = [];
  TrainingPlan? _selectedPlan;
  List<ExercisePlan> _exercisePlans = [];
  
  bool _isLoadingPlans = false;
  bool _isLoadingExercises = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrainingPlans();
  }

  Future<void> _loadTrainingPlans() async {
    if (AuthProvider.userId == null) {
      setState(() {
        _errorMessage = 'User not logged in';
      });
      return;
    }

    setState(() {
      _isLoadingPlans = true;
      _errorMessage = null;
    });

    try {
      // Get training plans for the logged-in user
      final result = await _trainingPlanProvider.get(filter: {
        'userId': AuthProvider.userId.toString(),
      });
      
      print('📋 Loaded ${result.result.length} training plans for user ${AuthProvider.userId}');
      for (var plan in result.result) {
        print('  - Plan ID: ${plan.id}, Title: ${plan.title}, UserId: ${plan.userId}');
      }
      
      setState(() {
        _trainingPlans = result.result;
        _isLoadingPlans = false;
        
        // Auto-select first plan if available
        if (_trainingPlans.isNotEmpty && _selectedPlan == null) {
          _selectedPlan = _trainingPlans.first;
          _loadExercisePlans(_selectedPlan!.id!);
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoadingPlans = false;
      });
    }
  }

  Future<void> _loadExercisePlans(int trainingPlanId) async {
    setState(() {
      _isLoadingExercises = true;
    });

    print('🔍 Loading exercise plans for trainingPlanId: $trainingPlanId');

    try {
      // First try with includeProperties
      var result = await _exercisePlanProvider.get(filter: {
        'trainingPlanId': trainingPlanId.toString(),
        'includeProperties': 'Exercise,Exercise.Equipment,Exercise.Image',
      });
      
      print('📋 Loaded ${result.result.length} exercise plans with includeProperties');
      
      // If no results, try without includeProperties
      if (result.result.isEmpty) {
        print('🔄 Trying without includeProperties...');
        result = await _exercisePlanProvider.get(filter: {
          'trainingPlanId': trainingPlanId.toString(),
        });
        print('📋 Loaded ${result.result.length} exercise plans without includeProperties');
      }
      
      // If still no results, try getting ALL exercise plans to debug
      if (result.result.isEmpty) {
        print('🔄 Getting ALL exercise plans to debug...');
        final allPlans = await _exercisePlanProvider.get();
        print('📋 Total exercise plans in system: ${allPlans.result.length}');
        for (var plan in allPlans.result) {
          print('  - Plan ID: ${plan.id}, TrainingPlanId: ${plan.trainingPlanId}, ExerciseId: ${plan.exerciseId}');
        }
      }
      
      for (var plan in result.result) {
        print('  ✓ Exercise Plan ID: ${plan.id}, Exercise: ${plan.exercise?.name ?? "NULL"}, ExerciseId: ${plan.exerciseId}');
      }
      
      setState(() {
        _exercisePlans = result.result;
        _isLoadingExercises = false;
      });
    } catch (e) {
      print('❌ Error loading exercise plans: $e');
      setState(() {
        _exercisePlans = [];
        _isLoadingExercises = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri učitavanju vježbi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Moji planovi treninga',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      drawer: const MobileNavBar(currentRoute: 'training_plan'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingPlans) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTrainingPlans,
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (_trainingPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nemate dodijeljenih planova treninga',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // Left side - Training plans list
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Planovi (${_trainingPlans.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _trainingPlans.length,
                  itemBuilder: (context, index) {
                    final plan = _trainingPlans[index];
                    final isSelected = _selectedPlan?.id == plan.id;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      child: ListTile(
                        title: Text(
                          plan.title ?? 'Bez naziva',
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          plan.description ?? 'Nema opisa',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: plan.basePrice != null
                            ? Text(
                                '${plan.basePrice?.toStringAsFixed(2)} KM',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedPlan = plan;
                          });
                          if (plan.id != null) {
                            _loadExercisePlans(plan.id!);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Right side - Exercise plans
        Expanded(
          child: _buildExercisePlansList(),
        ),
      ],
    );
  }

  Widget _buildExercisePlansList() {
    if (_selectedPlan == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Izaberite plan treninga',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_isLoadingExercises) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_exercisePlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nema vježbi u ovom planu',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'ID plana: ${_selectedPlan?.id}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plan header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedPlan!.title ?? 'Bez naziva',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_selectedPlan!.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  _selectedPlan!.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.fitness_center,
                    '${_exercisePlans.length} vježbi',
                    Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  if (_selectedPlan!.basePrice != null)
                    _buildInfoChip(
                      Icons.attach_money,
                      '${_selectedPlan!.basePrice?.toStringAsFixed(2)} KM',
                      Colors.green,
                    ),
                ],
              ),
            ],
          ),
        ),

        // Exercise list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _exercisePlans.length,
            itemBuilder: (context, index) {
              final exercisePlan = _exercisePlans[index];
              return _buildExerciseCard(exercisePlan, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(ExercisePlan exercisePlan, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (exercisePlan.exercise != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseDetailScreen(
                  exercise: exercisePlan.exercise!,
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Number badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Exercise info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercisePlan.exercise?.name ?? 'Bez naziva',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (exercisePlan.sets != null) ...[
                          _buildDetailTag('${exercisePlan.sets}x setova'),
                          const SizedBox(width: 8),
                        ],
                        if (exercisePlan.reps != null) ...[
                          _buildDetailTag('${exercisePlan.reps} ponavljanja'),
                          const SizedBox(width: 8),
                        ],
                        if (exercisePlan.duration != null)
                          _buildDetailTag('${exercisePlan.duration} min'),
                      ],
                    ),
                    if (exercisePlan.note != null && exercisePlan.note!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        exercisePlan.note!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
