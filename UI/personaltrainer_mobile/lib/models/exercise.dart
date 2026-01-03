
import 'package:json_annotation/json_annotation.dart';

part 'exercise.g.dart';
@JsonSerializable()
class Exercise{
  int? id;
  String? name;


  Exercise({this.id,this.name});

  factory Exercise.fromJson(Map<String,dynamic> json) => _$ExerciseFromJson(json);

  Map<String,dynamic> toJson() => _$ExerciseToJson(this);
}

