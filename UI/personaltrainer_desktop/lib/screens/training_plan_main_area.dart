import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/models/exercise.dart';
import 'package:personaltrainer_desktop/models/exercise_plan.dart';
import 'package:personaltrainer_desktop/providers/exerciseProvider.dart';
import 'package:personaltrainer_desktop/providers/exercise_plan.dart';
import 'package:provider/provider.dart';
import 'package:personaltrainer_desktop/providers/training_plan_provider.dart';
import 'package:personaltrainer_desktop/models/training_plan.dart';

class TrainingPlanMainArea extends StatefulWidget {
  const TrainingPlanMainArea({super.key});

  @override
  _TrainingPlanMainAreaState createState() => _TrainingPlanMainAreaState();
}

class _TrainingPlanMainAreaState extends State<TrainingPlanMainArea> {
  // final TextEditingController PlanNameController = TextEditingController();
  final TextEditingController PriceController = TextEditingController();
  final TextEditingController DurationController = TextEditingController();
  final TextEditingController NoteController = TextEditingController();
  late ExerciseProvider exerciseProvider;
  List<Exercise> exercises = [];
  bool isLoading = false;
  String? errorMessage;
  ExercisePlan? exercisePlan;
  List<ExercisePlan> exercisePlans = [];
  Exercise? _selectedExercise;

  // TrainingPlan related
  late TrainingPlanProvider _trainingPlanProvider;
  List<TrainingPlan> _availablePlans = [];
  bool _loadingPlans = false;
  String? _plansError;
  int? _selectedTrainingPlanId;
  bool _isEditMode = false;
  final Set<int> _originalExercisePlanIds = {};

  @override
  void dispose() {
    // PlanNameController.dispose();
    PriceController.dispose();
    DurationController.dispose();
    NoteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedTrainingPlanId = null;
    _trainingPlanProvider = TrainingPlanProvider();
    _fetchAvailablePlans();
  }

  Future<void> _fetchAvailablePlans() async {
    setState(() {
      _loadingPlans = true;
      _plansError = null;
    });
    try {
      final result = await _trainingPlanProvider.get();
      setState(() {
        _availablePlans = result.result;
        _loadingPlans = false;
      });
    } catch (e) {
      setState(() {
        _plansError = 'Failed to load plans.';
        _loadingPlans = false;
      });
    }
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
        errorMessage = 'Failed to load exercises.';
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Edit mode indicator
            if (_isEditMode && _selectedTrainingPlanId != null)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'EDIT MODE: You are editing an existing training plan. Click "Update Plan" to save changes or "Create New" to start fresh.',
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // ...Naziv plana polje uklonjeno...
            SizedBox(height: 16),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price (€):',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: PriceController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter price',
                      prefixText: '€ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      errorText:
                          (PriceController.text.isNotEmpty &&
                              double.tryParse(PriceController.text) == null)
                          ? 'Price must be a number'
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Duration (min):',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: DurationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter duration',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      errorText:
                          (DurationController.text.isNotEmpty &&
                              int.tryParse(DurationController.text) == null)
                          ? 'Duration must be a number'
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Note:',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: NoteController,
                    decoration: InputDecoration(
                      hintText: 'Enter note',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  '$errorMessage',
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (exercises.isEmpty)
              const Text('No available exercises')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedTrainingPlanId == null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[700],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'First select a training plan from the list at the bottom of the screen',
                              style: TextStyle(color: Colors.orange[900]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  DropdownButtonFormField<Exercise>(
                    initialValue: _selectedExercise,
                    items: exercises.map((ex) {
                      return DropdownMenuItem<Exercise>(
                        value: ex,
                        child: Text(ex.name ?? 'Unnamed exercise'),
                      );
                    }).toList(),
                    onChanged: _selectedTrainingPlanId == null
                        ? null
                        : (ex) {
                            setState(() {
                              _selectedExercise = ex;
                              if (!exercisePlans.any(
                                (plan) => plan.exerciseId == ex?.id,
                              )) {
                                exercisePlans.add(
                                  ExercisePlan(
                                    exerciseId: ex?.id,
                                    trainingPlanId: _selectedTrainingPlanId,
                                    exercise: ex,
                                    sets: 3,
                                    reps: 8,
                                    customPrice: 100,
                                  ),
                                );
                              }
                            });
                          },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      hintText: _selectedTrainingPlanId == null
                          ? 'First select a training plan'
                          : 'Select exercise',
                    ),
                    disabledHint: Text('First select a training plan'),
                  ),
                ],
              ),
            SizedBox(height: 16),
            Text(
              'Exercises',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Container(
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
                    'Selected exercises (${exercisePlans.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (exercisePlans.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No exercises added',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: exercisePlans.length,
                      itemBuilder: (context, index) {
                        final plan = exercisePlans[index];
                        // Only render if exercise is populated
                        if (plan.exercise == null ||
                            plan.exercise!.id == null) {
                          return SizedBox.shrink();
                        }
                        return _buildExerciseCard(plan.exercise!, plan);
                      },
                    ),
                ],
              ),
            ),

            // --- DOSTUPNI TRENING PLANOVI ---
            SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Training Plans',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (_selectedTrainingPlanId != null) ...[
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green[700],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Selected: ${_availablePlans.firstWhere((p) => p.id == _selectedTrainingPlanId, orElse: () => TrainingPlan()).title ?? "Unknown"}',
                              style: TextStyle(
                                color: Colors.green[900],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 16),
                  if (_loadingPlans)
                    Center(child: CircularProgressIndicator())
                  else if (_plansError != null)
                    Text(
                      'Error: $_plansError',
                      style: TextStyle(color: Colors.red),
                    )
                  else if (_availablePlans.isEmpty)
                    Text('No available training plans.')
                  else
                    ..._availablePlans.map((plan) {
                      bool isSelected = _selectedTrainingPlanId == plan.id;
                      return GestureDetector(
                        onTap: () async {
                          print('Plan clicked: ${plan.toJson()}');
                          if (plan.id == null) {
                            print('WARNING: Selected plan has no ID set!');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error: Selected plan has no ID!',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Tapping the already-selected plan deselects it
                          if (isSelected) {
                            _clearForm();
                            return;
                          }

                          // Use the plan data we already have instead of fetching again
                          setState(() {
                            _selectedTrainingPlanId = plan.id;
                            _isEditMode = true;
                            _originalExercisePlanIds.clear();

                            // Populate form fields from training plan
                            if (plan.basePrice != null) {
                              PriceController.text = plan.basePrice.toString();
                            } else {
                              PriceController.clear();
                            }

                            // Clear existing exercise plans and load from selected plan
                            exercisePlans.clear();
                            if (plan.exercises != null &&
                                plan.exercises!.isNotEmpty) {
                              print(
                                'Loading ${plan.exercises!.length} exercises from plan',
                              );
                              print(
                                'Available exercises in memory: ${exercises.length}',
                              );

                              // Load all exercises from the training plan
                              for (var ep in plan.exercises!) {
                                // Update trainingPlanId to current plan
                                ep.trainingPlanId = plan.id;

                                // Find and populate the full Exercise object from the exercises list
                                if (ep.exerciseId != null) {
                                  print(
                                    'Looking for exercise with ID: ${ep.exerciseId}',
                                  );
                                  final matchingExercise = exercises.firstWhere(
                                    (ex) => ex.id == ep.exerciseId,
                                    orElse: () => Exercise(),
                                  );

                                  if (matchingExercise.id != null) {
                                    print(
                                      'Found matching exercise: ${matchingExercise.name} (ID: ${matchingExercise.id})',
                                    );
                                    ep.exercise = matchingExercise;
                                  } else {
                                    print(
                                      'WARNING: No matching exercise found for ID: ${ep.exerciseId}',
                                    );
                                  }
                                }

                                exercisePlans.add(ep);
                                if (ep.id != null) {
                                  _originalExercisePlanIds.add(ep.id!);
                                }
                                print(
                                  'Added exercise plan. Total plans: ${exercisePlans.length}',
                                );
                              }

                              // Optionally populate Duration and Note from first exercise
                              if (plan.exercises!.first.duration != null) {
                                DurationController.text = plan
                                    .exercises!
                                    .first
                                    .duration
                                    .toString();
                              } else {
                                DurationController.clear();
                              }
                              if (plan.exercises!.first.note != null &&
                                  plan.exercises!.first.note!.isNotEmpty) {
                                NoteController.text =
                                    plan.exercises!.first.note!;
                              } else {
                                NoteController.clear();
                              }
                            } else {
                              // Clear fields if no exercises
                              DurationController.clear();
                              NoteController.clear();
                            }
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Training plan "${plan.title}" selected! Loaded ${plan.exercises?.length ?? 0} exercises.',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          color: isSelected ? Colors.green[50] : Colors.white,
                          elevation: isSelected ? 3 : 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.green[700]!
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                if (isSelected)
                                  Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plan.title ?? 'Untitled',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (plan.description != null &&
                                          plan.description!.isNotEmpty)
                                        Padding(
                                          padding: EdgeInsets.only(top: 4),
                                          child: Text(
                                            plan.description!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '€ ${plan.basePrice?.toStringAsFixed(2) ?? ''}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),

            // Buttons for API operations
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_isEditMode) ...[
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : updatePlan,
                    icon: Icon(Icons.edit),
                    label: Text('Update Plan'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ] else
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : posaljiNaAPI,
                    icon: Icon(Icons.send),
                    label: Text('Send plan'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, ExercisePlan exercisePlan) {
    // Debug print za image url
    print(
      'Exercise: "+(exercise.name ?? "")+" | imageId: "+(exercise.imageId?.toString() ?? "null")+" | image.url: "+(exercise.image?.url ?? "null")',
    );

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
            child:
                (exercise.image != null &&
                    exercise.image!.url != null &&
                    exercise.image!.url!.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      exercise.image!.url!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print(
                          'Image load error for url: ${exercise.image!.url!}',
                        );
                        return Icon(
                          Icons.fitness_center,
                          color: Colors.red,
                          size: 30,
                        );
                      },
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        color: Colors.grey[400],
                        size: 30,
                      ),
                      if (exercise.image == null ||
                          exercise.image!.url == null ||
                          exercise.image!.url!.isEmpty)
                        Text(
                          'No image',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  void posaljiNaAPI() async {
    // Prikupi sve podatke iz kontrolera i exercisePlans
    final String cijenaText = PriceController.text.trim();
    final String trajanjeText = DurationController.text.trim();
    final String napomena = NoteController.text.trim();

    double? cijena = double.tryParse(cijenaText);
    int? trajanje = int.tryParse(trajanjeText);

    if (cijena == null || trajanje == null || exercisePlans.isEmpty) {
      setState(() {
        errorMessage =
            'Please fill in all fields and add at least one exercise.';
      });
      return;
    }

    // Check if trainingPlanId is set
    if (_selectedTrainingPlanId == null) {
      setState(() {
        errorMessage =
            'Please select a training plan from the list at the bottom of the screen!';
      });
      return;
    }

    // Pohrani sve atribute u svaki ExercisePlan
    for (var plan in exercisePlans) {
      plan.customPrice = cijena;
      plan.duration = trajanje;
      plan.note = napomena;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Pozovi ExercisePlanProvider za slanje na API
      final provider = Provider.of<ExercisePlanProvider>(
        context,
        listen: false,
      );
      for (var plan in exercisePlans) {
        await provider.insert(plan);
      }

      // Clear all fields and exercises after successful submission
      setState(() {
        PriceController.clear();
        DurationController.clear();
        NoteController.clear();
        exercisePlans.clear();
        _selectedExercise = null;
        _selectedTrainingPlanId = null;
        _isEditMode = false;
        _originalExercisePlanIds.clear();
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plan successfully sent to API! Form cleared.')),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to save plan.';
      });
    }
  }

  void _clearForm() {
    setState(() {
      PriceController.clear();
      DurationController.clear();
      NoteController.clear();
      exercisePlans.clear();
      _selectedExercise = null;
      _selectedTrainingPlanId = null;
      _isEditMode = false;
      _originalExercisePlanIds.clear();
      errorMessage = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Form cleared. Ready to create new plan.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void updatePlan() async {
    // Validate inputs
    final String cijenaText = PriceController.text.trim();
    final String trajanjeText = DurationController.text.trim();
    final String napomena = NoteController.text.trim();

    double? cijena = double.tryParse(cijenaText);
    int? trajanje = int.tryParse(trajanjeText);

    if (cijena == null || trajanje == null || exercisePlans.isEmpty) {
      setState(() {
        errorMessage =
            'Please fill in all fields and add at least one exercise.';
      });
      return;
    }

    if (_selectedTrainingPlanId == null) {
      setState(() {
        errorMessage = 'No training plan selected for update!';
      });
      return;
    }

    // Update all exercise plans with current values
    for (var plan in exercisePlans) {
      plan.customPrice = cijena;
      plan.duration = trajanje;
      plan.note = napomena;
      plan.trainingPlanId = _selectedTrainingPlanId;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final provider = Provider.of<ExercisePlanProvider>(
        context,
        listen: false,
      );

      // Track which exercises to delete (removed from original list)
      Set<int> currentExercisePlanIds = exercisePlans
          .where((ep) => ep.id != null)
          .map((ep) => ep.id!)
          .toSet();
      Set<int> deletedIds = _originalExercisePlanIds.difference(currentExercisePlanIds);

      // Delete removed exercises
      for (var deletedId in deletedIds) {
        print('Deleting exercise plan ID: $deletedId');
        await provider.delete(deletedId);
      }

      // Update existing and insert new exercises
      for (var plan in exercisePlans) {
        if (plan.id != null) {
          // Update existing exercise plan
          print('Updating exercise plan ID: ${plan.id}');
          await provider.update(plan.id!, plan);
        } else {
          // Insert new exercise plan
          print('Inserting new exercise plan for exercise ID: ${plan.exerciseId}');
          await provider.insert(plan);
        }
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Training plan updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the training plans list to show updated data
      await _fetchAvailablePlans();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to update plan.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update plan.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
