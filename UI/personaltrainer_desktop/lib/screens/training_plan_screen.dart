import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:personaltrainer_mobile/layouts/navBar.dart';
import 'package:personaltrainer_mobile/models/exercise.dart';
import 'package:personaltrainer_mobile/providers/exerciseProvider.dart';
import 'package:personaltrainer_mobile/screens/training_plan_main_area.dart';

class TrainingPlanScreen extends StatefulWidget {
  @override
  _TrainingPlanScreenState createState() => _TrainingPlanScreenState();
}

class _TrainingPlanScreenState extends State<TrainingPlanScreen> {
  String selectedPlan = "Prsa - triceps";
  List<Exercise> exercises = [];

  @override
  Widget build(BuildContext context) {
    return NavBar('Trening plan', TrainingPlanMainArea());
  }
}
