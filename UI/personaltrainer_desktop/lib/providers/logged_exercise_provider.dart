import 'package:personaltrainer_desktop/models/exercise.dart';
import 'package:personaltrainer_desktop/models/search_result.dart';
import 'package:personaltrainer_desktop/providers/exerciseProvider.dart';

class LoggedExerciseProvider extends ExerciseProvider {
  @override
  Future<SearchResult<Exercise>> get({filter}) {
    print("im in Logged Exercise Provider");

    return super.get(filter: filter);
  }
}
