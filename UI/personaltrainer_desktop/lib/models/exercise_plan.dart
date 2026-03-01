import 'package:json_annotation/json_annotation.dart';
import 'package:personaltrainer_desktop/models/exercise.dart';

part 'exercise_plan.g.dart';

@JsonSerializable()
class ExercisePlan {
  int? id;
  int? exerciseId;
  int? trainingPlanId;
  @JsonKey(includeToJson: false)
  Exercise? exercise;
  @JsonKey(includeToJson: false)
  String? exerciseName;
  int? sets;
  int? reps;
  int? duration;
  double? customPrice;
  String? note;

  // 1. korak preimenovati part dio, naziv klase, ctor itd.
  //2.  korak popisati prop i dodati u ctor
  //3. korak save projekat pa pokrenuti -> flutter pub run build_runner build
  //4. korak kreirati provider za ovaj model

  ExercisePlan({
    this.id,
    this.exerciseId,
    this.trainingPlanId,
    this.exercise,
    this.exerciseName,
    this.sets,
    this.reps,
    this.duration,
    required this.customPrice,
    this.note,
  });

  factory ExercisePlan.fromJson(Map<String, dynamic> json) =>
      _$ExercisePlanFromJson(json);

  Map<String, dynamic> toJson() => _$ExercisePlanToJson(this);
}
