import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:personaltrainer_mobile/models/exercise.dart';
import 'package:personaltrainer_mobile/models/exercise_plan.dart';
import 'package:personaltrainer_mobile/providers/exerciseProvider.dart';
import 'package:personaltrainer_mobile/providers/exercise_plan.dart';
import 'package:provider/provider.dart';
import 'package:personaltrainer_mobile/providers/training_plan_provider.dart';
import 'package:personaltrainer_mobile/models/training_plan.dart';

class TrainingPlanMainArea extends StatefulWidget {
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
        _plansError = e.toString();
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ...Naziv plana polje uklonjeno...
            SizedBox(height: 16),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cijena:',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: PriceController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Unesite cijenu',
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
                          ? 'Cijena mora biti broj'
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Trajanje (min):',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: DurationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Unesite trajanje',
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
                          ? 'Trajanje mora biti broj'
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Napomena:',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: NoteController,
                    decoration: InputDecoration(
                      hintText: 'Unesite napomenu',
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
                  'Greška: $errorMessage',
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (exercises.isEmpty)
              const Text('Nema dostupnih vježbi')
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
                              'Prvo odaberite trening plan iz liste na dnu ekrana',
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
                          ? 'Prvo odaberite trening plan'
                          : 'Odaberi vježbu',
                    ),
                    disabledHint: Text('Prvo odaberite trening plan'),
                  ),
                ],
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
                    'Odabrane vježbe (${exercisePlans.length})',
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
                          'Nema dodanih vježbi',
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
                    'Dostupni trening planovi',
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
                              'Odabran: ${_availablePlans.firstWhere((p) => p.id == _selectedTrainingPlanId, orElse: () => TrainingPlan()).title ?? "Nepoznat"}',
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
                      'Greška: $_plansError',
                      style: TextStyle(color: Colors.red),
                    )
                  else if (_availablePlans.isEmpty)
                    Text('Nema dostupnih trening planova.')
                  else
                    ..._availablePlans.map((plan) {
                      if (plan is TrainingPlan) {
                        bool isSelected = _selectedTrainingPlanId == plan.id;
                        return GestureDetector(
                          onTap: () {
                            print('Plan clicked: ${plan.toJson()}');
                            if (plan.id == null) {
                              print(
                                'UPOZORENJE: Odabrani plan nema postavljen id!',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Greška: Odabrani plan nema ID!',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            setState(() {
                              _selectedTrainingPlanId = plan.id;
                              for (var ep in exercisePlans) {
                                ep.trainingPlanId = plan.id;
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Trening plan "${plan.title}" odabran!',
                                ),
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
                                          plan.title ?? 'Bez naziva',
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
                                    '${plan.basePrice?.toStringAsFixed(2) ?? ''} KM',
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
                      } else {
                        return SizedBox.shrink();
                      }
                    }).toList(),
                ],
              ),
            ),

            // Dugme za slanje plana na API
            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : posaljiNaAPI,
                icon: Icon(Icons.send),
                label: Text('Pošalji plan na API'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
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
            child:
                exercise.image?.url != null && exercise.image!.url!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      exercise.image!.url!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.fitness_center, color: Colors.grey[400]),
                    ),
                  )
                : Icon(Icons.fitness_center, color: Colors.grey[400], size: 30),
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
            'Molimo popunite sva polja i dodajte barem jednu vježbu.';
      });
      return;
    }

    // Provjera da li je trainingPlanId postavljen
    if (_selectedTrainingPlanId == null) {
      setState(() {
        errorMessage = 'Molimo odaberite trening plan iz liste na dnu ekrana!';
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
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Plan uspješno poslan na API!')));
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Greška pri slanju na API: ' + e.toString();
      });
    }
  }
}
