import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/layouts/navBar.dart';
import 'package:personaltrainer_mobile/models/training_plan.dart';
import 'package:personaltrainer_mobile/providers/training_plan_provider.dart';
import 'package:personaltrainer_mobile/screens/image_upload_screen.dart';

class TrainingDetailsScreen extends StatefulWidget {
  final TrainingPlan? trainingPlan;

  TrainingDetailsScreen({Key? key, this.trainingPlan}) : super(key: key);

  @override
  State<TrainingDetailsScreen> createState() => _TrainingDetailsScreenState();
}

class _TrainingDetailsScreenState extends State<TrainingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _basePriceController;
  late TextEditingController _personalTrainerIdController;
  late TextEditingController _userIdController;
  late TextEditingController _createdAtController;
  late TrainingPlanProvider _trainingPlanProvider;
  List<TrainingPlan> _availablePlans = [];
  bool _loadingPlans = false;
  String? _plansError;

  @override
  void initState() {
    super.initState();
    _trainingPlanProvider = TrainingPlanProvider();
    _titleController = TextEditingController(
      text: widget.trainingPlan?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.trainingPlan?.description ?? '',
    );
    _basePriceController = TextEditingController(
      text: widget.trainingPlan?.basePrice?.toString() ?? '',
    );
    _personalTrainerIdController = TextEditingController(
      text: widget.trainingPlan?.personalTrainerId?.toString() ?? '',
    );
    _userIdController = TextEditingController(
      text: widget.trainingPlan?.userId?.toString() ?? '',
    );
    _createdAtController = TextEditingController(
      text: widget.trainingPlan?.createdAt ?? '',
    );
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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _personalTrainerIdController.dispose();
    _userIdController.dispose();
    _createdAtController.dispose();
    super.dispose();
  }

  void _saveTrainingPlan() async {
    if (_formKey.currentState?.validate() ?? false) {
      final trainingPlan = TrainingPlan(
        id: widget.trainingPlan?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        basePrice: double.tryParse(_basePriceController.text),
        personalTrainerId: int.tryParse(_personalTrainerIdController.text),
        userId: int.tryParse(_userIdController.text),
        createdAt: _createdAtController.text,
      );
      try {
        await _trainingPlanProvider.insert(trainingPlan);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Trening plan spremljen!')));
          Navigator.of(context).pop(trainingPlan);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Greška: ${e.toString()}')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      'Detalji trening plana',
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Naziv plana'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Unesite naziv plana'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Opis'),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _basePriceController,
                    decoration: InputDecoration(labelText: 'Cijena'),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Unesite cijenu'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _personalTrainerIdController,
                    decoration: InputDecoration(
                      labelText: 'Personalni trener ID',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Unesite ID trenera'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _userIdController,
                    decoration: InputDecoration(labelText: 'Korisnik ID'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Unesite ID korisnika'
                        : null,
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _createdAtController.text.isNotEmpty
                            ? DateTime.tryParse(_createdAtController.text) ??
                                  DateTime.now()
                            : DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _createdAtController.text = picked.toIso8601String();
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _createdAtController,
                        decoration: InputDecoration(
                          labelText: 'Datum kreiranja',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.datetime,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ImageUploadScreen(
                                trainingId: widget.trainingPlan?.id,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.image),
                        label: Text('Dodaj novu vjezbu'),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _saveTrainingPlan,
                        child: Text('Spremi'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                    ..._availablePlans
                        .map(
                          (plan) => Card(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(plan.title ?? 'Bez naziva'),
                              subtitle: Text(plan.description ?? ''),
                              trailing: Text(
                                '${plan.basePrice?.toStringAsFixed(2) ?? ''} KM',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
