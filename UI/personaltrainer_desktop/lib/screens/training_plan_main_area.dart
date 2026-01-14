import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:personaltrainer_mobile/models/exercise.dart';
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
  List<Exercise> addedExercises = [];


  Exercise? _selectedExercise;
  @override
  void dispose() {
    PlanNameController.dispose(); // Obavezno očisti kada Widget nestane
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
      final result = await exerciseProvider.get(); // Use get() method
      setState(() {
        exercises = result.result; // result. result is List<Exercise>
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

    void _addExerciseToList() {
    if (_selectedExercise != null) {
      setState(() {
        // Check if exercise is already added
        if (!addedExercises.any((ex) => ex.id == _selectedExercise! .id)) {
          addedExercises.add(_selectedExercise!);
        }
        _selectedExercise = null; // Reset dropdown
      });
    }
  }

  void _removeExercise(Exercise exercise) {
    setState(() {
      addedExercises.remove(exercise);
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
          // Plan Name TextField (Polje za unos)
          Row(
            children: [
              Text(
                'Naziv plana:',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(width: 16),

              // TextField umesto DropdownButton
              Expanded(
                child: TextField(
                  controller:
                      PlanNameController, // Povezuje TextField sa controller-om
                  decoration: InputDecoration(
                    hintText: 'Prsa - triceps', // Placeholder tekst
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
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

          //
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
                color: Colors. grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Odabrane vježbe (${addedExercises.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  if (addedExercises.isEmpty)
                    const Center(
                      child:  Padding(
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
                        itemCount: addedExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = addedExercises[index];
                          return _buildExerciseCard(exercise);
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

   Widget _buildExerciseCard(Exercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color:  Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Exercise Image (placeholder for now)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image. network(
                      exercise.imageUrl!,
                      fit:  BoxFit.cover,
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
                    fontWeight: FontWeight. bold,
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
                        value:  exercise.reps > 0 ? exercise.reps : 8,
                        items: List.generate(20, (i) => i + 1).map((reps) {
                          return DropdownMenuItem(
                            value: reps,
                            child: Text('$reps'),
                          );
                        }).toList(),
                        onChanged: (newReps) {
                          setState(() {
                            // Update reps (you might want to create a mutable copy)
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
                        border: Border.all(color: Colors.grey[300]! ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButton<int>(
                        value: exercise.sets > 0 ? exercise.sets : 3,
                        items: List. generate(10, (i) => i + 1).map((sets) {
                          return DropdownMenuItem(
                            value:  sets,
                            child: Text('$sets'),
                          );
                        }).toList(),
                        onChanged: (newSets) {
                          setState(() {
                            // Update sets (you might want to create a mutable copy)
                          });
                        },
                        underline:  const SizedBox(),
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



  void posaljiNaAPI(String nazivPlana) {
    // Ovde će biti tvoj API poziv
    print('Šaljem na API: $nazivPlana');
  }
}
