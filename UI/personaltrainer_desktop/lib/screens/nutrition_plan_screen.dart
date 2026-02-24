import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/screens/nutrition_plan_main_area.dart';

class NutritionPlanScreen extends StatefulWidget {
  const NutritionPlanScreen({super.key});

  @override
  _NutritionPlanScreenState createState() => _NutritionPlanScreenState();
}

class _NutritionPlanScreenState extends State<NutritionPlanScreen> {
  @override
  Widget build(BuildContext context) {
    return NavBar('Plan ishrane', NutritionPlanMainArea());
  }
}
