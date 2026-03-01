class TopTrainerReportItem {
  final int trainerId;
  final String trainerFullName;
  final double averageRating;
  final int ratingCount;

  TopTrainerReportItem({
    required this.trainerId,
    required this.trainerFullName,
    required this.averageRating,
    required this.ratingCount,
  });

  factory TopTrainerReportItem.fromJson(Map<String, dynamic> json) {
    return TopTrainerReportItem(
      trainerId: json['trainerId'] as int,
      trainerFullName: json['trainerFullName'] as String? ?? 'Unknown',
      averageRating: (json['averageRating'] as num).toDouble(),
      ratingCount: json['ratingCount'] as int,
    );
  }
}

class DashboardReport {
  final int totalPersonalTrainers;
  final int totalUsers;
  final int totalGyms;
  final List<TopTrainerReportItem> topTrainers;

  DashboardReport({
    required this.totalPersonalTrainers,
    required this.totalUsers,
    required this.totalGyms,
    required this.topTrainers,
  });

  factory DashboardReport.fromJson(Map<String, dynamic> json) {
    final trainersList = (json['topTrainers'] as List<dynamic>? ?? [])
        .map((e) => TopTrainerReportItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return DashboardReport(
      totalPersonalTrainers: json['totalPersonalTrainers'] as int,
      totalUsers: json['totalUsers'] as int,
      totalGyms: json['totalGyms'] as int,
      topTrainers: trainersList,
    );
  }
}
