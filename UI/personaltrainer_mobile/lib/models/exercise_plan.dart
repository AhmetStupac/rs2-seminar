import 'package:json_annotation/json_annotation.dart';
import 'package:personaltrainer_mobile/models/exercise.dart';

part 'exercise_plan.g.dart';

@JsonSerializable()
class ExercisePlan {
  int? id;
  int? exerciseId;
  int? trainingPlanId;
  @JsonKey(includeToJson: false)
  Exercise? exercise;
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
    this.sets,
    this.reps,
    this.duration,
    required this.customPrice,
    this.note,
  });

  factory ExercisePlan.fromJson(Map<String, dynamic> json) {
    // Handle flattened API response where exercise data comes as exerciseName, etc.
    Exercise? exerciseObj;
    if (json['exercise'] != null) {
      // Nested structure
      exerciseObj = Exercise.fromJson(json['exercise'] as Map<String, dynamic>);
    } else if (json['exerciseName'] != null) {
      // Flattened structure - construct Exercise object
      exerciseObj = Exercise(
        id: json['exerciseId'] as int?,
        name: json['exerciseName'] as String?,
        imageId: json['exerciseImageId'] as int?,
        equipmentId: json['exerciseEquipmentId'] as int?,
        muscleGroupId: json['exerciseMuscleGroupId'] as int?,
      );
    }

    return ExercisePlan(
      id: (json['id'] as num?)?.toInt(),
      exerciseId: (json['exerciseId'] as num?)?.toInt(),
      trainingPlanId: (json['trainingPlanId'] as num?)?.toInt(),
      exercise: exerciseObj,
      sets: (json['sets'] as num?)?.toInt(),
      reps: (json['reps'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      customPrice: (json['customPrice'] as num?)?.toDouble(),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$ExercisePlanToJson(this);
}
