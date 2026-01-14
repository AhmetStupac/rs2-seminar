// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) =>
    Exercise(id: (json['id'] as num?)?.toInt(), name: json['name'] as String?)
      ..picture = json['picture'] as String?;

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'picture': instance.picture,
};
