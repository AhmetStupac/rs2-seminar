import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:personaltrainer_mobile/models/exercise.dart';
import 'package:personaltrainer_mobile/models/exercise_plan.dart';
import 'package:personaltrainer_mobile/providers/exerciseProvider.dart';
import 'package:provider/provider.dart';

class TrainingPlanMainArea extends StatefulWidget {
  @override
  _TrainingPlanMainAreaState createState() => _TrainingPlanMainAreaState();
}

class _TrainingPlanMainAreaState extends State<TrainingPlanMainArea> {
  final TextEditingController PlanNameController = TextEditingController();
  late ExerciseProvider exerciseProvider;
  List<Exercise> exercises = [];
  bool isLoading = false;
  String? errorMessage;
  ExercisePlan? exercisePlan;
  List<ExercisePlan> exercisePlans = [];
  Exercise? _selectedExercise;

  @override
  void dispose() {
    PlanNameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    exerciseProvider = context.read<ExerciseProvider>();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final result = await exerciseProvider.get();
      setState(() {
        exercises = result.result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _removeExercise(Exercise exercise) {
    setState(() {
      exercisePlans.removeWhere((plan) => plan.exerciseId == exercise.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Naziv plana:',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: PlanNameController,
                  decoration: InputDecoration(
                    hintText: 'Prsa - triceps',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                'Greška: $errorMessage',
                style: TextStyle(color: Colors.red[700]),
              ),
            )
          else if (exercises.isEmpty)
            const Text('Nema dostupnih vježbi')
          else
            DropdownButtonFormField<Exercise>(
              initialValue: _selectedExercise,
              items: exercises.map((ex) {
                return DropdownMenuItem<Exercise>(
                  value: ex,
                  child: Text(ex.name ?? 'Unnamed exercise'),
                );
              }).toList(),
              onChanged: (ex) {
                setState(() {
                  _selectedExercise = ex;
                  if (!exercisePlans.any((plan) => plan.exerciseId == ex?.id)) {
                    exercisePlans.add(
                      ExercisePlan(
                        exerciseId: ex?.id,
                        exercise: ex,
                        sets: 3,
                        reps: 8,
                        customPrice: 100,
                      ),
                    );
                  }
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              hint: const Text('Odaberi vježbu'),
            ),
          SizedBox(height: 16),
          Text(
            'Vježbe',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Odabrane vježbe (${exercisePlans.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (exercisePlans.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Nema dodanih vježbi',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: exercisePlans.length,
                        itemBuilder: (context, index) {
                          final plan = exercisePlans[index];
                          return _buildExerciseCard(plan.exercise!, plan);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, ExercisePlan exercisePlan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Exercise Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: exercise.image?.url != null && exercise.image!.url!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      exercise.image!.url!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.fitness_center,
                        color: Colors.grey[400],
                      ),
                    ),
                  )
                : Icon(
                    Icons.fitness_center,
                    color: Colors.grey[400],
                    size: 30,
                  ),
          ),

          const SizedBox(width: 12),

          // Exercise Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name ?? 'Unnamed Exercise',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Reps Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButton<int>(
                        value: exercisePlan.reps ?? 8,
                        items: List.generate(20, (i) => i + 1).map((reps) {
                          return DropdownMenuItem(
                            value: reps,
                            child: Text('$reps'),
                          );
                        }).toList(),
                        onChanged: (newReps) {
                          setState(() {
                            exercisePlan.reps = newReps;
                          });
                        },
                        underline: const SizedBox(),
                        isDense: true,
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    const Text('Reps'),
                    
                    const SizedBox(width: 16),
                    
                    // Sets Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButton<int>(
                        value: exercisePlan.sets ?? 3,
                        items: List.generate(10, (i) => i + 1).map((sets) {
                          return DropdownMenuItem(
                            value: sets,
                            child: Text('$sets'),
                          );
                        }).toList(),
                        onChanged: (newSets) {
                          setState(() {
                            exercisePlan.sets = newSets;
                          });
                        },
                        underline: const SizedBox(),
                        isDense: true,
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    const Text('Sets'),
                  ],
                ),
              ],
            ),
          ),

          // Remove Button
          IconButton(
            onPressed: () => _removeExercise(exercise),
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void posaljiNaAPI(String nazivPlana) {
    // Ovde će biti tvoj API poziv
    print('Šaljem na API: $nazivPlana');
  }
}