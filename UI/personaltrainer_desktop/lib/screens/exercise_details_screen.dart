import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart';
import 'package:personaltrainer_desktop/screens/equipment_screen.dart';
import 'package:personaltrainer_desktop/screens/image_upload_screen.dart';
import 'package:personaltrainer_desktop/screens/muscle_group_screen.dart';
import 'package:personaltrainer_desktop/screens/personal_trainer_list_screen.dart';
import 'package:personaltrainer_desktop/screens/statistics_screen.dart';
import 'package:personaltrainer_desktop/screens/trainer_dashboard_screen.dart';
import 'package:personaltrainer_desktop/screens/training_plan_admin_screen.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  ExerciseDetailsScreen({super.key});

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return NavBar(
      "Detalji vježbe",
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ImageUploadScreen(),
                  ),
                );
              },
              icon: Icon(Icons.upload_file),
              label: Text('Upload a photo and create a new exercise'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            if (AuthProvider.isSuperAdmin) ...[
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PersonalTrainerListScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.person_outline),
                label: Text('Go to Personal Trainer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EquipmentScreen(),
                  ),
                );
              },
              icon: Icon(Icons.fitness_center),
              label: Text('Equipment Management'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MuscleGroupScreen(),
                  ),
                );
              },
              icon: Icon(Icons.accessibility_new),
              label: Text('Muscle Group Management'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TrainingPlanAdminScreen(),
                  ),
                );
              },
              icon: Icon(Icons.assignment),
              label: Text('Training Plan Management'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
            if (AuthProvider.isAdministrator) ...[
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TrainerDashboardScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.dashboard_outlined),
                label: Text('My Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
            if (AuthProvider.isSuperAdmin) ...[
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StatisticsScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.bar_chart_rounded),
                label: Text('Statistics Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
