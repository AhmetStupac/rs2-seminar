import 'package:json_annotation/json_annotation.dart';

part 'muscleGroup.g.dart';

@JsonSerializable()
class MuscleGroup {
  int? id;
  String? name;

  MuscleGroup({this.id, this.name});

  factory MuscleGroup.fromJson(Map<String, dynamic> json) =>
      _$MuscleGroupFromJson(json);

  Map<String, dynamic> toJson() => _$MuscleGroupToJson(this);
}
