import 'package:personaltrainer_mobile/models/exercise_plan.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class ExercisePlanProvider extends BaseProvider<ExercisePlan> {
  ExercisePlanProvider() : super("ExercisePlan");

  //1. korak importovati model.
  //2. dodati u main.dart, provider -> void metoda ChangeNotifierProvider<ExercisePlanProvider>(
  //   create: (_) => ExercisePlanProvider(),
  //),
  //3. ako nesto radim sa providerom, obavezno uraditi hot restart

  @override
  ExercisePlan fromJson(data) {
    return ExercisePlan.fromJson(data);
  }
}
