import 'package:json_annotation/json_annotation.dart';
import 'package:personaltrainer_mobile/models/equipment.dart';
import 'package:personaltrainer_mobile/models/image.dart';

part 'exercise.g.dart';

@JsonSerializable()
class Exercise {
  int? id;
  String? name;
  int? imageId;
  Image? image;
  int? equipmentId;
  Equipment? equipment;
  int? muscleGroupId;

  Exercise({
    this.id,
    this.name,
    this.imageId,
    this.image,
    this.equipmentId,
    this.equipment,
    this.muscleGroupId,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}
