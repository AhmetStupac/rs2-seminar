import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/models/training_plan.dart';
import 'package:personaltrainer_desktop/providers/training_plan_provider.dart';
import 'package:personaltrainer_desktop/screens/image_upload_screen.dart';

class TrainingDetailsScreen extends StatefulWidget {
  final TrainingPlan? trainingPlan;

  const TrainingDetailsScreen({super.key, this.trainingPlan});

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
        _plansError = 'Failed to load plans.';
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
          ).showSnackBar(SnackBar(content: Text('Training plan Saved!')));
          Navigator.of(context).pop(trainingPlan);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save training plan.')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      'Training Plan Details',
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
                    decoration: InputDecoration(labelText: 'Plan Title'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter the plan title'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _basePriceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter the price'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _personalTrainerIdController,
                    decoration: InputDecoration(
                      labelText: 'Personal Trainer ID',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter the trainer ID'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _userIdController,
                    decoration: InputDecoration(labelText: 'User ID'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter the user ID'
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
                          labelText: 'Creation Date',
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
                        label: Text('Add New Exercise'),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _saveTrainingPlan,
                        child: Text('Save'),
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
                    'Available Training Plans',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
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
                    ..._availablePlans
                        .map(
                          (plan) => Card(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(plan.title ?? 'No Title'),
                              subtitle: Text(plan.description ?? ''),
                              trailing: Text(
                                '${plan.basePrice?.toStringAsFixed(2) ?? ''} KM',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                        ,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
