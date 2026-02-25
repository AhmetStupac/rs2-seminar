import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/models/personal_trainer.dart';
import 'package:personaltrainer_desktop/models/user.dart';
import 'package:personaltrainer_desktop/providers/personal_trainer_provider.dart';
import 'package:personaltrainer_desktop/providers/user_provider.dart';

class PersonalTrainerScreen extends StatefulWidget {
  const PersonalTrainerScreen({super.key});

  @override
  State<PersonalTrainerScreen> createState() => _PersonalTrainerScreenState();
}

class _PersonalTrainerScreenState extends State<PersonalTrainerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _personalTrainerProvider = PersonalTrainerProvider();
  final _userProvider = UserProvider();

  final TextEditingController _yearsOfExperienceController =
      TextEditingController();
  final TextEditingController _certificationsController =
      TextEditingController();

  List<User> _users = [];
  int? _selectedUserId;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isLoadingUsers = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _yearsOfExperienceController.dispose();
    _certificationsController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      final result = await _userProvider.get();
      setState(() {
        _users = result.result ?? [];
        _isLoadingUsers = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() => _isLoadingUsers = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load users.')));
      }
    }
  }

  Future<void> _savePersonalTrainer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final personalTrainer = PersonalTrainer(
        userId: _selectedUserId,
        // userFirstName: _userFirstNameController.text, // Removed, now only from user
        yearsOfExperience: int.tryParse(_yearsOfExperienceController.text),
        isActive: _isActive,
        certifications: _certificationsController.text.isEmpty
            ? null
            : _certificationsController.text,
      );

      await _personalTrainerProvider.insert(personalTrainer.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal Trainer created successfully!'),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create Personal Trainer.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      "Personal Trainer",
      Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Add Personal Trainer',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: _isLoadingUsers
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Dropdown
                      DropdownButtonFormField<int>(
                        initialValue: _selectedUserId,
                        decoration: const InputDecoration(
                          labelText: 'User *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: _users.map((user) {
                          return DropdownMenuItem<int>(
                            value: user.id,
                            child: Text(
                              '${user.firstName ?? ''} ${user.lastName ?? ''} (${user.email ?? ''})',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUserId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a user';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ...existing code...

                      // Years of Experience Field
                      TextFormField(
                        controller: _yearsOfExperienceController,
                        decoration: const InputDecoration(
                          labelText: 'Years of Experience *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter years of experience';
                          }
                          final years = int.tryParse(value);
                          if (years == null || years < 0) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Is Active Switch
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.grey),
                                SizedBox(width: 12),
                                Text(
                                  'Is Active',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            Switch(
                              value: _isActive,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                              activeThumbColor: Colors.green,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Certifications Field
                      TextFormField(
                        controller: _certificationsController,
                        decoration: const InputDecoration(
                          labelText: 'Certifications (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.card_membership),
                          hintText: 'Enter certifications',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _savePersonalTrainer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Save',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
