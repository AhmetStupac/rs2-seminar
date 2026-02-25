import 'package:personaltrainer_desktop/models/nutrition_plan.dart';
import 'package:personaltrainer_desktop/providers/base_provider.dart';

class NutritionPlanProvider extends BaseProvider<NutritionPlan> {
  NutritionPlanProvider() : super("NutritionPlan");

  @override
  NutritionPlan fromJson(data) {
    return NutritionPlan.fromJson(data);
  }
}
