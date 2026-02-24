import 'package:personaltrainer_desktop/models/training_plan.dart';
import 'package:personaltrainer_desktop/providers/base_provider.dart';

class TrainingPlanProvider extends BaseProvider<TrainingPlan> {
  TrainingPlanProvider() : super("TrainingPlan");

  //1. korak importovati model.
  //2. dodati u main.dart, provider -> void metoda ChangeNotifierProvider<EquipmentProvider>(
  //   create: (_) => EquipmentProvider(),
  //),
  //3. ako nesto radim sa providerom, obavezno uraditi hot restart

  @override
  TrainingPlan fromJson(data) {
    return TrainingPlan.fromJson(data);
  }
}
