class TrainerDashboard {
  final int trainerId;
  final String trainerFullName;
  final int totalTrainingPlansCreated;
  final int totalNutritionPlansCreated;
  final int totalClients;
  final int soldTrainingPlans;
  final int soldNutritionPlans;
  final int soldMemberships;
  final double totalEarnedEur;
  final double averageRating;
  final int ratingCount;

  TrainerDashboard({
    required this.trainerId,
    required this.trainerFullName,
    required this.totalTrainingPlansCreated,
    required this.totalNutritionPlansCreated,
    required this.totalClients,
    required this.soldTrainingPlans,
    required this.soldNutritionPlans,
    required this.soldMemberships,
    required this.totalEarnedEur,
    required this.averageRating,
    required this.ratingCount,
  });

  factory TrainerDashboard.fromJson(Map<String, dynamic> json) {
    return TrainerDashboard(
      trainerId: (json['trainerId'] as num?)?.toInt() ?? 0,
      trainerFullName: json['trainerFullName'] as String? ?? 'Unknown',
      totalTrainingPlansCreated: (json['totalTrainingPlansCreated'] as num?)?.toInt() ?? 0,
      totalNutritionPlansCreated: (json['totalNutritionPlansCreated'] as num?)?.toInt() ?? 0,
      totalClients: (json['totalClients'] as num?)?.toInt() ?? 0,
      soldTrainingPlans: (json['soldTrainingPlans'] as num?)?.toInt() ?? 0,
      soldNutritionPlans: (json['soldNutritionPlans'] as num?)?.toInt() ?? 0,
      soldMemberships: (json['soldMemberships'] as num?)?.toInt() ?? 0,
      totalEarnedEur: (json['totalEarnedEur'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
    );
  }
}
