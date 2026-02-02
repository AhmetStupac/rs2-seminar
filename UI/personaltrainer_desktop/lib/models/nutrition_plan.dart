import 'package:json_annotation/json_annotation.dart';

part 'nutrition_plan.g.dart';

@JsonSerializable()
class NutritionPlan {
  int? id;
  int? personalTrainerId;
  int? userId;
  String? title;
  String? description;
  String? totalCalories;
  String? protein;
  String? carbs;
  int? fats;
  double? price;
  String? createdAt;

  NutritionPlan({
    this.id,
    this.personalTrainerId,
    this.userId,
    this.title,
    this.description,
    this.totalCalories,
    this.protein,
    this.carbs,
    this.fats,
    this.price,
    this.createdAt,
  });

  factory NutritionPlan.fromJson(Map<String, dynamic> json) =>
      _$NutritionPlanFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionPlanToJson(this);
}
