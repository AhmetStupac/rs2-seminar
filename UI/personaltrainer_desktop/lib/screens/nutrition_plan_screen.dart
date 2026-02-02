import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/layouts/navBar.dart';
import 'package:personaltrainer_mobile/screens/nutrition_plan_main_area.dart';

class NutritionPlanScreen extends StatefulWidget {
  @override
  _NutritionPlanScreenState createState() => _NutritionPlanScreenState();
}

class _NutritionPlanScreenState extends State<NutritionPlanScreen> {
  @override
  Widget build(BuildContext context) {
    return NavBar('Nutrition Plan', NutritionPlanMainArea());
  }
}
