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

  factory NutritionPlan.fromJson(Map<String, dynamic> json) {
    final np = _$NutritionPlanFromJson(json);

    // Handle cases where API returns nested personalTrainer object
    try {
      if ((np.personalTrainerId == null || np.personalTrainerId == 0) &&
          json['personalTrainer'] != null) {
        final pt = json['personalTrainer'];
        if (pt is Map && pt['id'] != null) {
          final idVal = pt['id'];
          if (idVal is num) {
            np.personalTrainerId = idVal.toInt();
          } else if (idVal is String) {
            np.personalTrainerId = int.tryParse(idVal);
          }
        }
      }

      // Also handle string numeric values for personalTrainerId
      if ((np.personalTrainerId == null || np.personalTrainerId == 0) &&
          json['personalTrainerId'] != null) {
        final raw = json['personalTrainerId'];
        if (raw is num) {
          np.personalTrainerId = raw.toInt();
        } else if (raw is String) {
          np.personalTrainerId = int.tryParse(raw);
        }
      }
    } catch (e) {
      // ignore parsing errors and keep existing values
    }

    return np;
  }

  Map<String, dynamic> toJson() => _$NutritionPlanToJson(this);
}
