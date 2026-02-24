import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/screens/image_upload_screen.dart';
import 'package:personaltrainer_desktop/screens/personal_trainer_list_screen.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  const ExerciseDetailsScreen({super.key});

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
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
