// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingPlan _$TrainingPlanFromJson(Map<String, dynamic> json) => TrainingPlan(
  id: (json['id'] as num?)?.toInt(),
  personalTrainerId: (json['personalTrainerId'] as num?)?.toInt(),
  userId: (json['userId'] as num?)?.toInt(),
  title: json['title'] as String?,
  description: json['description'] as String?,
  basePrice: (json['basePrice'] as num?)?.toDouble(),
  createdAt: json['createdAt'] as String?,
  exercises: (json['exercises'] as List<dynamic>?)
      ?.map((e) => ExercisePlan.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TrainingPlanToJson(TrainingPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'personalTrainerId': instance.personalTrainerId,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'basePrice': instance.basePrice,
      'createdAt': instance.createdAt,
      'exercises': instance.exercises?.map((e) => e.toJson()).toList(),
    };
