import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/layouts/navBar.dart';
import 'package:personaltrainer_mobile/models/training.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.training?.name ?? '');
    _descriptionController = TextEditingController(text: widget.training?.description ?? '');
    _durationController = TextEditingController(text: widget.training?.duration?.toString() ?? '');
    _clientController = TextEditingController(text: widget.training?.client ?? '');
    _personalTrainerController = TextEditingController(text: widget.training?.personalTrainer ?? '');
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

  void _saveTraining() {
    if (_formKey.currentState?.validate() ?? false) {
      // Ovdje ide logika za spremanje (API poziv ili Provider)
      final training = Training(
        id: widget.training?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        duration: int.tryParse(_durationController.text),
        client: _clientController.text,
        personalTrainer: _personalTrainerController.text,
      );
      // TODO: Pozovi provider ili API za spremanje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trening spremljen!')),
      );
      Navigator.of(context).pop(training);
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
                validator: (value) => value == null || value.isEmpty ? 'Unesite naziv' : null,
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
                validator: (value) => value == null || value.isEmpty ? 'Unesite trajanje' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _clientController,
                decoration: InputDecoration(labelText: 'Klijent'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _personalTrainerController,
                decoration: InputDecoration(labelText: 'Personalni trener'),
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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