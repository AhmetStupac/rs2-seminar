// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  imageId: (json['imageId'] as num?)?.toInt(),
  image: json['image'] == null
      ? null
      : Image.fromJson(json['image'] as Map<String, dynamic>),
  equipmentId: (json['equipmentId'] as num?)?.toInt(),
  equipment: json['equipment'] == null
      ? null
      : Equipment.fromJson(json['equipment'] as Map<String, dynamic>),
  muscleGroupId: (json['muscleGroupId'] as num?)?.toInt(),
);

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'imageId': instance.imageId,
  'image': instance.image,
  'equipmentId': instance.equipmentId,
  'equipment': instance.equipment,
  'muscleGroupId': instance.muscleGroupId,
};
