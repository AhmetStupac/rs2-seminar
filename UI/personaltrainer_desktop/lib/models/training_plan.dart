import 'package:json_annotation/json_annotation.dart';
import 'package:personaltrainer_mobile/models/exercise_plan.dart';

part 'training_plan.g.dart';

@JsonSerializable(explicitToJson: true)
class TrainingPlan {
  int? id;
  int? personalTrainerId;
  int? userId;
  String? title;
  String? description;
  double? basePrice;
  String? createdAt;
  List<ExercisePlan>? exercises;


  // 1. korak preimenovati part dio, naziv klase, ctor itd.
  //2.  korak popisati prop i dodati u ctor
  //3. korak save projekat pa pokrenuti -> flutter pub run build_runner build
  //4. korak kreirati provider za ovaj model

  TrainingPlan({
    this.id,
    this.personalTrainerId,
    this.userId,
    this.title,
    this.description,
    this.basePrice,
    this.createdAt,
    this.exercises,
  });

  factory TrainingPlan.fromJson(Map<String, dynamic> json) =>
      _$TrainingPlanFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingPlanToJson(this);
}
