import 'package:personaltrainer_mobile/models/gym.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class GymProvider extends BaseProvider<Gym> {
  GymProvider() : super("Gym");

  @override
  Gym fromJson(data) {
    return Gym.fromJson(data);
  }
}
