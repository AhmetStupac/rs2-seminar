import 'package:json_annotation/json_annotation.dart';

part 'monthly_training_statistics.g.dart';

@JsonSerializable()
class MonthlyTrainingStatistics {
  int? id;
  int? userId;
  String? userName;
  int? year;
  int? month;
  String? monthName;
  int? trainingSessionCount;
  String? comment;
  DateTime? createdAt;
  DateTime? updatedAt;

  MonthlyTrainingStatistics({
    this.id,
    this.userId,
    this.userName,
    this.year,
    this.month,
    this.monthName,
    this.trainingSessionCount,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory MonthlyTrainingStatistics.fromJson(Map<String, dynamic> json) =>
      _$MonthlyTrainingStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyTrainingStatisticsToJson(this);
}

@JsonSerializable()
class MonthlyCommentUpsertRequest {
  int? year;
  int? month;
  String? comment;

  MonthlyCommentUpsertRequest({this.year, this.month, this.comment});

  factory MonthlyCommentUpsertRequest.fromJson(Map<String, dynamic> json) =>
      _$MonthlyCommentUpsertRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyCommentUpsertRequestToJson(this);
}
