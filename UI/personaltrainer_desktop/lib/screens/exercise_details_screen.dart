import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/layouts/navBar.dart';
import 'package:personaltrainer_mobile/models/exercise.dart';
import 'package:personaltrainer_mobile/models/muscleGroup.dart';
import 'package:personaltrainer_mobile/models/equipment.dart';
import 'package:personaltrainer_mobile/providers/muscle_group_provider.dart';
import 'package:personaltrainer_mobile/providers/equipment_provider.dart';
import 'package:personaltrainer_mobile/providers/exerciseProvider.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  ExerciseDetailsScreen({super.key});

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  int? _selectedMuscleGroupId;
  int? _selectedEquipmentId;
  List<MuscleGroup> _muscleGroups = [];
  List<Equipment> _equipments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    final mgProvider = MuscleGroupProvider();
    final eqProvider = EquipmentProvider();
    final mgResult = await mgProvider.get();
    final eqResult = await eqProvider.get();
    setState(() {
      _muscleGroups = mgResult.result;
      _equipments = eqResult.result;
      _isLoading = false;
    });
  }

  void _saveExercise() async {
    if (_formKey.currentState?.validate() ?? false) {
      Exercise exercise = Exercise(
        name: _nameController.text,
        muscleGroupId: _selectedMuscleGroupId,
        equipmentId: _selectedEquipmentId,
      );
      final provider = ExerciseProvider();
      await provider.insert(exercise.toJson());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Vježba uspješno spremljena!')));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      "Detalji vježbe",
      _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "Ime vježbe"),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Unesite ime vježbe'
                          : null,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedMuscleGroupId,
                      decoration: InputDecoration(labelText: "Muscle Group"),
                      items: _muscleGroups
                          .map(
                            (mg) => DropdownMenuItem<int>(
                              value: mg.id,
                              child: Text(mg.name ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedMuscleGroupId = val;
                        });
                      },
                      validator: (val) =>
                          val == null ? 'Odaberite muscle group' : null,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedEquipmentId,
                      decoration: InputDecoration(labelText: "Equipment"),
                      items: _equipments
                          .map(
                            (eq) => DropdownMenuItem<int>(
                              value: eq.id,
                              child: Text(eq.name ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedEquipmentId = val;
                        });
                      },
                      validator: (val) =>
                          val == null ? 'Odaberite equipment' : null,
                    ),
                    SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Otkaži'),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _saveExercise,
                          child: Text('Spremi'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
