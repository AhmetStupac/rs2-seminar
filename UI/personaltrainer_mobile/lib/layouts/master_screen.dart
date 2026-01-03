import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/screens/exercise_list.dart';
import 'package:personaltrainer_mobile/screens/user_list_screen.dart';

class MasterScreen extends StatefulWidget {
  MasterScreen(this.title, this.child, {super.key});
  String title;
  Widget child;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text("Back"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Korisnici"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ExerciseListScreen()),
                );
              },
            ),
            ListTile(
              title: Text("Korisnici"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UserListScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: widget.child,
    );
  }
}
