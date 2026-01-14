import 'package:personaltrainer_mobile/models/exercise.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class ExerciseProvider extends BaseProvider<Exercise> {
  ExerciseProvider() : super("Exercise");

  @override
  Exercise fromJson(data) {
    return Exercise.fromJson(data);
  }
}
