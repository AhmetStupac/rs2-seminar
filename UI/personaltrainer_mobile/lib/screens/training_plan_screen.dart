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
      final result = await _trainingPlanProvider.get(
        filter: {'userId': AuthProvider.userId.toString()},
      );

      print(
        '📋 Loaded ${result.result.length} training plans for user ${AuthProvider.userId}',
      );
      for (var plan in result.result) {
        print(
          '  - Plan ID: ${plan.id}, Title: ${plan.title}, UserId: ${plan.userId}',
        );
      }

      setState(() {
        _trainingPlans = result.result;
        _isLoadingPlans = false;
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
      var result = await _exercisePlanProvider.get(
        filter: {
          'trainingPlanId': trainingPlanId.toString(),
          'includeProperties': 'Exercise,Exercise.Equipment,Exercise.Image',
        },
      );

      print(
        '📋 Loaded ${result.result.length} exercise plans with includeProperties',
      );

      // If no results, try without includeProperties
      if (result.result.isEmpty) {
        print('🔄 Trying without includeProperties...');
        result = await _exercisePlanProvider.get(
          filter: {'trainingPlanId': trainingPlanId.toString()},
        );
        print(
          '📋 Loaded ${result.result.length} exercise plans without includeProperties',
        );
      }

      // If still no results, try getting ALL exercise plans to debug
      if (result.result.isEmpty) {
        print('🔄 Getting ALL exercise plans to debug...');
        final allPlans = await _exercisePlanProvider.get();
        print('📋 Total exercise plans in system: ${allPlans.result.length}');
        for (var plan in allPlans.result) {
          print(
            '  - Plan ID: ${plan.id}, TrainingPlanId: ${plan.trainingPlanId}, ExerciseId: ${plan.exerciseId}',
          );
        }
      }

      for (var plan in result.result) {
        print(
          '  ✓ Exercise Plan ID: ${plan.id}, Exercise: ${plan.exercise?.name ?? "NULL"}, ExerciseId: ${plan.exerciseId}',
        );
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
            content: Text(
              'Greška pri učitavanju vježbi: ${e.toString().replaceAll('Exception: ', '')}',
            ),
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

    // Show exercise detail view if a plan is selected
    if (_selectedPlan != null) {
      return _buildExerciseListView();
    }

    // Show list of training plans
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trainingPlans.length,
      itemBuilder: (context, index) {
        final plan = _trainingPlans[index];
        return _buildTrainingPlanCard(plan);
      },
    );
  }

  Widget _buildTrainingPlanCard(TrainingPlan plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPlan = plan;
            if (plan.id != null) {
              _loadExercisePlans(plan.id!);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: Colors.orange.shade700,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title ?? 'Bez naziva',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (plan.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        plan.description!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseListView() {
    return Column(
      children: [
        // Custom header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 40, bottom: 16),
          child: Column(
            children: [
              // Header with back button, title, and menu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black87),
                      onPressed: () {
                        setState(() {
                          _selectedPlan = null;
                          _exercisePlans = [];
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        _selectedPlan?.title ?? 'Plan treninga',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.black87),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              // Plan icon
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              // Base price
              if (_selectedPlan?.basePrice != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedPlan?.basePrice?.toStringAsFixed(2)} KM',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        // Exercise list
        Expanded(
          child: Container(
            color: Colors.white,
            child: _isLoadingExercises
                ? const Center(child: CircularProgressIndicator())
                : _exercisePlans.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nema vježbi u ovom planu',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _exercisePlans.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, indent: 72),
                    itemBuilder: (context, index) {
                      final exercisePlan = _exercisePlans[index];
                      return _buildExerciseListItem(exercisePlan);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseListItem(ExercisePlan exercisePlan) {
    return InkWell(
      onTap: () {
        if (exercisePlan.exercise != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ExerciseDetailScreen(exercise: exercisePlan.exercise!),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Exercise icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getExerciseIcon(exercisePlan.exercise?.name),
                color: Colors.black87,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            // Exercise name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercisePlan.exercise?.name ?? 'Bez naziva',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  if (exercisePlan.sets != null ||
                      exercisePlan.reps != null ||
                      exercisePlan.duration != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _buildExerciseSubtitle(exercisePlan),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            // Chevron
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  IconData _getExerciseIcon(String? exerciseName) {
    if (exerciseName == null) return Icons.fitness_center;

    final name = exerciseName.toLowerCase();
    if (name.contains('zgib') || name.contains('pull')) {
      return Icons.accessibility_new;
    } else if (name.contains('vesla') || name.contains('row')) {
      return Icons.rowing;
    } else if (name.contains('bicep') || name.contains('curl')) {
      return Icons.fitness_center;
    } else if (name.contains('preacher')) {
      return Icons.self_improvement;
    } else if (name.contains('dead') || name.contains('mrtv')) {
      return Icons.align_vertical_bottom;
    } else if (name.contains('squat') || name.contains('čučanj')) {
      return Icons.airline_seat_recline_normal;
    } else if (name.contains('bench') || name.contains('klupa')) {
      return Icons.airline_seat_flat;
    } else if (name.contains('chest') || name.contains('prsa')) {
      return Icons.favorite;
    } else if (name.contains('shoulder') || name.contains('rame')) {
      return Icons.man;
    } else {
      return Icons.fitness_center;
    }
  }

  String _buildExerciseSubtitle(ExercisePlan plan) {
    final parts = <String>[];
    if (plan.sets != null) parts.add('${plan.sets}x setova');
    if (plan.reps != null) parts.add('${plan.reps} ponavljanja');
    if (plan.duration != null) parts.add('${plan.duration} min');
    return parts.join(' • ');
  }
}
