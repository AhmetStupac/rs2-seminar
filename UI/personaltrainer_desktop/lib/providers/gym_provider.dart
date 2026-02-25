import 'package:personaltrainer_desktop/models/gym.dart';
import 'package:personaltrainer_desktop/providers/base_provider.dart';

class GymProvider extends BaseProvider<Gym> {
  GymProvider() : super("Gym");

  @override
  Gym fromJson(data) {
    return Gym.fromJson(data);
  }
}
