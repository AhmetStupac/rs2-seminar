// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_training_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthlyTrainingStatistics _$MonthlyTrainingStatisticsFromJson(
  Map<String, dynamic> json,
) => MonthlyTrainingStatistics(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['userId'] as num?)?.toInt(),
  userName: json['userName'] as String?,
  year: (json['year'] as num?)?.toInt(),
  month: (json['month'] as num?)?.toInt(),
  monthName: json['monthName'] as String?,
  trainingSessionCount: (json['trainingSessionCount'] as num?)?.toInt(),
  comment: json['comment'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MonthlyTrainingStatisticsToJson(
  MonthlyTrainingStatistics instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'year': instance.year,
  'month': instance.month,
  'monthName': instance.monthName,
  'trainingSessionCount': instance.trainingSessionCount,
  'comment': instance.comment,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

MonthlyCommentUpsertRequest _$MonthlyCommentUpsertRequestFromJson(
  Map<String, dynamic> json,
) => MonthlyCommentUpsertRequest(
  year: (json['year'] as num?)?.toInt(),
  month: (json['month'] as num?)?.toInt(),
  comment: json['comment'] as String?,
);

Map<String, dynamic> _$MonthlyCommentUpsertRequestToJson(
  MonthlyCommentUpsertRequest instance,
) => <String, dynamic>{
  'year': instance.year,
  'month': instance.month,
  'comment': instance.comment,
};
