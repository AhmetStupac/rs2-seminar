import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/models/personal_trainer.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart';
import 'package:personaltrainer_desktop/providers/personal_trainer_provider.dart';
import 'package:personaltrainer_desktop/screens/personal_trainer_screen.dart';

class PersonalTrainerListScreen extends StatefulWidget {
  const PersonalTrainerListScreen({super.key});

  @override
  State<PersonalTrainerListScreen> createState() =>
      _PersonalTrainerListScreenState();
}

class _PersonalTrainerListScreenState extends State<PersonalTrainerListScreen> {
  final _personalTrainerProvider = PersonalTrainerProvider();
  List<PersonalTrainer> _trainers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (AuthProvider.isSuperAdmin) {
      _loadPersonalTrainers();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPersonalTrainers() async {
    setState(() => _isLoading = true);
    try {
      final result = await _personalTrainerProvider.get();
      setState(() {
        _trainers = result.result ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data.')));
      }
    }
  }

  Future<void> _deletePersonalTrainer(PersonalTrainer trainer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete personal trainer "${trainer.userFirstName ?? 'ID: ${trainer.id}'}"?\n\nThis action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && trainer.id != null) {
      try {
        await _personalTrainerProvider.delete(trainer.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Personal trainer deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadPersonalTrainers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting record.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthProvider.isSuperAdmin) {
      return NavBar(
        "Personal Trainers",
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'This section is only available to SuperAdmins.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return NavBar(
      "Personal Trainers",
      Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Personal Trainers',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _trainers.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No personal trainers found',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click the + button to add a new trainer',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor: WidgetStateProperty.all(
                        Colors.grey[100],
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Years of Experience',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Status',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Certifications',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Actions',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: _trainers.map((trainer) {
                        return DataRow(
                          cells: [
                            DataCell(Text(trainer.userFirstName ?? 'N/A')),
                            DataCell(
                              Text('${trainer.yearsOfExperience ?? 0} years'),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: trainer.isActive == true
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  trainer.isActive == true
                                      ? 'Active'
                                      : 'Inactive',
                                  style: TextStyle(
                                    color: trainer.isActive == true
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                trainer.certifications?.isNotEmpty == true
                                    ? trainer.certifications!
                                    : 'N/A',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: 'Delete',
                                onPressed: () =>
                                    _deletePersonalTrainer(trainer),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PersonalTrainerScreen(),
              ),
            );
            _loadPersonalTrainers();
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Trainer'),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
