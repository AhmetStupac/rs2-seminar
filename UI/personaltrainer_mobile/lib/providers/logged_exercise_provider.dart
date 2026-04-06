import 'package:personaltrainer_mobile/models/exercise.dart';
import 'package:personaltrainer_mobile/models/search_result.dart';
import 'package:personaltrainer_mobile/providers/exerciseProvider.dart';

class LoggedExerciseProvider extends ExerciseProvider {
  @override
  Future<SearchResult<Exercise>> get({filter}) {

    return super.get(filter: filter);
  }
}
