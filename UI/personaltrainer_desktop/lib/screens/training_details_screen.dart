import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/layouts/navBar.dart';
import 'package:personaltrainer_mobile/models/training.dart';
import 'package:personaltrainer_mobile/providers/training_provider.dart';
import 'package:personaltrainer_mobile/screens/image_upload_screen.dart';

class TrainingDetailsScreen extends StatefulWidget {
  final Training? training;

  TrainingDetailsScreen({Key? key, this.training}) : super(key: key);

  @override
  State<TrainingDetailsScreen> createState() => _TrainingDetailsScreenState();
}

class _TrainingDetailsScreenState extends State<TrainingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  late TextEditingController _clientController;
  late TextEditingController _personalTrainerController;
  late TrainingProvider _trainingProvider;

  @override
  void initState() {
    super.initState();
    _trainingProvider = TrainingProvider();
    _nameController = TextEditingController(text: widget.training?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.training?.description ?? '',
    );
    _durationController = TextEditingController(
      text: widget.training?.duration?.toString() ?? '',
    );
    _clientController = TextEditingController(
      text: widget.training?.clientId.toString() ?? '',
    );
    _personalTrainerController = TextEditingController(
      text: widget.training?.personalTrainerId.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _clientController.dispose();
    _personalTrainerController.dispose();
    super.dispose();
  }

  void _saveTraining() async {
    if (_formKey.currentState?.validate() ?? false) {
      final training = Training(
        id: widget.training?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        duration: int.tryParse(_durationController.text),
        clientId: int.tryParse(_clientController.text),
        personalTrainerId: int.tryParse(_personalTrainerController.text),
      );
      try {
        await _trainingProvider.insert(training);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Trening spremljen!')));
          Navigator.of(context).pop(training);
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
      'Detalji treninga',
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Naziv treninga'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Unesite naziv' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Opis'),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(labelText: 'Trajanje (min)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Unesite trajanje' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _clientController,
                decoration: InputDecoration(labelText: 'Klijent ID:'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _personalTrainerController,
                decoration: InputDecoration(labelText: 'Personalni trener ID:'),
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
                            trainingId: widget.training?.id,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.image),
                    label: Text('Upload sliku'),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveTraining,
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
