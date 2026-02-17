// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutritionPlan _$NutritionPlanFromJson(Map<String, dynamic> json) =>
    NutritionPlan(
      id: (json['id'] as num?)?.toInt(),
      personalTrainerId: (json['personalTrainerId'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      totalCalories: json['totalCalories'] as String?,
      protein: json['protein'] as String?,
      carbs: json['carbs'] as String?,
      fats: (json['fats'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toDouble(),
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$NutritionPlanToJson(NutritionPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'personalTrainerId': instance.personalTrainerId,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'totalCalories': instance.totalCalories,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fats': instance.fats,
      'price': instance.price,
      'createdAt': instance.createdAt,
    };
