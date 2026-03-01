import 'package:personaltrainer_desktop/models/exercise.dart';
import 'package:personaltrainer_desktop/providers/base_provider.dart';

class ExerciseProvider extends BaseProvider<Exercise> {
  ExerciseProvider() : super("Exercise");

  @override
  Exercise fromJson(data) {
    return Exercise.fromJson(data);
  }
}
 
