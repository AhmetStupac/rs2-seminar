// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExercisePlan _$ExercisePlanFromJson(Map<String, dynamic> json) => ExercisePlan(
  id: (json['id'] as num?)?.toInt(),
  exerciseId: (json['exerciseId'] as num?)?.toInt(),
  exercise: json['exercise'] == null
      ? null
      : Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
  sets: (json['sets'] as num?)?.toInt(),
  reps: (json['reps'] as num?)?.toInt(),
  duration: (json['duration'] as num?)?.toInt(),
  customPrice: (json['customPrice'] as num?)?.toDouble(),
  note: json['note'] as String?,
);

Map<String, dynamic> _$ExercisePlanToJson(ExercisePlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'exercise': instance.exercise,
      'sets': instance.sets,
      'reps': instance.reps,
      'duration': instance.duration,
      'customPrice': instance.customPrice,
      'note': instance.note,
    };
