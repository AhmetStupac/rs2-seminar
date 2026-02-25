import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/models/personal_trainer.dart';
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
    _loadPersonalTrainers();
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
      print('Error loading personal trainers: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Greška pri učitavanju.')));
      }
    }
  }

  Future<void> _deletePersonalTrainer(PersonalTrainer trainer) async {
    // Nepovratna akcija - prvo prikaži dijalog za potvrdu
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda brisanja'),
        content: Text(
          'Da li ste sigurni da želite da obrišete personalnog trenera "${trainer.userFirstName ?? 'ID: ${trainer.id}'}"?\n\nOva akcija je nepovratna!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Obriši'),
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
              content: Text('Personalni trener je uspješno obrisan!'),
              backgroundColor: Colors.green,
            ),
          );
          // Ponovno učitaj listu
          _loadPersonalTrainers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Greška pri brisanju.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      'Nema personalnih trenera',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kliknite na + dugme da dodate novog trenera',
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
                            'ID',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Ime',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Godine iskustva',
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
                            'Certifikati',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Akcije',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: _trainers.map((trainer) {
                        return DataRow(
                          cells: [
                            DataCell(Text('${trainer.id ?? 'N/A'}')),
                            DataCell(Text(trainer.userFirstName ?? 'N/A')),
                            DataCell(
                              Text('${trainer.yearsOfExperience ?? 0} godina'),
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
                                      ? 'Aktivan'
                                      : 'Neaktivan',
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
                                tooltip: 'Obriši',
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
            // Navigiraj na screen za dodavanje personalnog trenera
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PersonalTrainerScreen(),
              ),
            );
            // Nakon povratka, ponovno učitaj listu
            _loadPersonalTrainers();
          },
          icon: const Icon(Icons.add),
          label: const Text('Dodaj trenera'),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
