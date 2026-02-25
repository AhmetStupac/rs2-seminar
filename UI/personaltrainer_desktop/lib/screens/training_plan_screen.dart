import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/screens/training_plan_main_area.dart';

class TrainingPlanScreen extends StatefulWidget {
  const TrainingPlanScreen({super.key});

  @override
  _TrainingPlanScreenState createState() => _TrainingPlanScreenState();
}

class _TrainingPlanScreenState extends State<TrainingPlanScreen> {
  String selectedPlan = "Chest - triceps";

  @override
  Widget build(BuildContext context) {
    return NavBar('Trening plan', TrainingPlanMainArea());
  }
}
