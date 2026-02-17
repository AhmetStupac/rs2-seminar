import 'package:personaltrainer_mobile/models/personal_trainer.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class PersonalTrainerProvider extends BaseProvider<PersonalTrainer> {
  PersonalTrainerProvider() : super("PersonalTrainer");

  @override
  PersonalTrainer fromJson(data) {
    return PersonalTrainer.fromJson(data);
  }
}
