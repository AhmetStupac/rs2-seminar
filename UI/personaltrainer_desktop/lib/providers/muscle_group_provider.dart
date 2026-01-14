import 'package:personaltrainer_mobile/models/muscleGroup.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class MuscleGroupProvider extends BaseProvider<MuscleGroup> {
  MuscleGroupProvider() : super("MuscleGroup");

  @override
  MuscleGroup fromJson(data) {
    return MuscleGroup.fromJson(data);
  }
}
