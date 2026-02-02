import 'package:personaltrainer_mobile/models/nutrition_plan.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class NutritionPlanProvider extends BaseProvider<NutritionPlan> {
  NutritionPlanProvider() : super("NutritionPlan");

  @override
  NutritionPlan fromJson(data) {
    return NutritionPlan.fromJson(data);
  }
}
