import 'package:personaltrainer_desktop/models/muscleGroup.dart';
import 'package:personaltrainer_desktop/providers/base_provider.dart';

class MuscleGroupProvider extends BaseProvider<MuscleGroup> {
  MuscleGroupProvider() : super("MuscleGroup");

  @override
  MuscleGroup fromJson(data) {
    return MuscleGroup.fromJson(data);
  }
}
