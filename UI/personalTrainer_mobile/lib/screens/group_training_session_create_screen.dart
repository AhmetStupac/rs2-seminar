import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/models/group_training_session.dart';
import 'package:personaltrainer_mobile/providers/group_training_session_provider.dart';

class GroupTrainingSessionCreateScreen extends StatefulWidget {
  const GroupTrainingSessionCreateScreen({super.key});

  @override
  State<GroupTrainingSessionCreateScreen> createState() =>
      _GroupTrainingSessionCreateScreenState();
}

class _GroupTrainingSessionCreateScreenState
    extends State<GroupTrainingSessionCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _provider = GroupTrainingSessionProvider();

  final _nameController = TextEditingController();
  final _trainingTypeController = TextEditingController();
  final _placeController = TextEditingController();
  final _notesController = TextEditingController();
  final _durationController = TextEditingController();
  final _kcalController = TextEditingController();

  bool _isLoading = false;

  static const List<String> _trainingTypes = [
    'Running',
    'Cycling',
    'Swimming',
    'Yoga',
    'Bodyweight Training',
    'Weightlifting',
    'Hiking',
    'HIIT',
    'Pilates',
    'CrossFit',
    'Other',
  ];

  String? _selectedType;

  @override
  void dispose() {
    _nameController.dispose();
    _trainingTypeController.dispose();
    _placeController.dispose();
    _notesController.dispose();
    _durationController.dispose();
    _kcalController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = GroupTrainingSession(
        id: 0,
        name: _nameController.text.trim(),
        trainingType: _selectedType ?? _trainingTypeController.text.trim(),
        kcalBurned: int.tryParse(_kcalController.text.trim()) ?? 0,
        durationMinutes: int.tryParse(_durationController.text.trim()) ?? 0,
        place: _placeController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        creatorId: 0,
        creatorName: '',
        createdAt: DateTime.now(),
        participantCount: 0,
        participants: [],
      );

      await _provider.insert(request.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group session created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Group Session',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Session Details', Icons.info_outline),
              const SizedBox(height: 12),
              _buildField(
                controller: _nameController,
                label: 'Session Name',
                hint: 'e.g. Morning Run in the Park',
                icon: Icons.title,
                maxLength: 100,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Name is required.';
                  }
                  if (v.trim().length > 100) {
                    return 'Name must not exceed 100 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTypeDropdown(),
              const SizedBox(height: 24),
              _buildSectionHeader('Training Info', Icons.fitness_center),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _durationController,
                      label: 'Duration (min)',
                      hint: '60',
                      icon: Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required.';
                        }
                        final parsed = int.tryParse(v.trim());
                        if (parsed == null) {
                          return 'Must be a number.';
                        }
                        if (parsed <= 0) {
                          return 'Must be greater than 0.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      controller: _kcalController,
                      label: 'Kcal Burned',
                      hint: '400',
                      icon: Icons.local_fire_department_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required.';
                        }
                        final parsed = int.tryParse(v.trim());
                        if (parsed == null) {
                          return 'Must be a number.';
                        }
                        if (parsed <= 0) {
                          return 'Must be greater than 0.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Location & Notes', Icons.location_on_outlined),
              const SizedBox(height: 12),
              _buildField(
                controller: _placeController,
                label: 'Location / Place',
                hint: 'e.g. Central Park, Gym Hall A',
                icon: Icons.place_outlined,
                maxLength: 200,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Place is required.';
                  }
                  if (v.trim().length > 200) {
                    return 'Place must not exceed 200 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _notesController,
                label: 'Notes (optional)',
                hint: 'Any extra info for participants...',
                icon: Icons.note_alt_outlined,
                maxLines: 3,
                maxLength: 1000,
                validator: (v) {
                  if (v != null && v.trim().length > 1000) {
                    return 'Notes must not exceed 1000 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8B44A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group_add, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Create Session',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFE8B44A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(height: 1, color: Colors.black12),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: Colors.black45),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8B44A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      hint: const Text('Select training type'),
      items: _trainingTypes
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: (val) => setState(() => _selectedType = val),
      validator: (v) =>
          v == null ? 'Training type is required.' : null,
      decoration: InputDecoration(
        labelText: 'Training Type',
        prefixIcon:
            const Icon(Icons.sports, size: 20, color: Colors.black45),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8B44A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
