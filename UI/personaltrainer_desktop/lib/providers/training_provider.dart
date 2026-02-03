import 'package:personaltrainer_mobile/models/training.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class TrainingProvider extends BaseProvider<Training> {
  TrainingProvider() : super("Training");

  //1. korak importovati model.
  //2. dodati u main.dart, provider -> void metoda ChangeNotifierProvider<TrainingProvider>(
  //   create: (_) => TrainingProvider(),
  //),
  //3. ako nesto radim sa providerom, obavezno uraditi hot restart
  
  @override
  Training fromJson(data) {
    return Training.fromJson(data);
  }
}
