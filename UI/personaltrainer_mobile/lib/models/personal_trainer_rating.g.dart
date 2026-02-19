// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_trainer_rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonalTrainerRatingResponse _$PersonalTrainerRatingResponseFromJson(
  Map<String, dynamic> json,
) => PersonalTrainerRatingResponse(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['userId'] as num?)?.toInt(),
  userName: json['userName'] as String?,
  personalTrainerId: (json['personalTrainerId'] as num?)?.toInt(),
  personalTrainerName: json['personalTrainerName'] as String?,
  rating: (json['rating'] as num?)?.toInt(),
  comment: json['comment'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PersonalTrainerRatingResponseToJson(
  PersonalTrainerRatingResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'personalTrainerId': instance.personalTrainerId,
  'personalTrainerName': instance.personalTrainerName,
  'rating': instance.rating,
  'comment': instance.comment,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

PersonalTrainerRatingUpsertRequest _$PersonalTrainerRatingUpsertRequestFromJson(
  Map<String, dynamic> json,
) => PersonalTrainerRatingUpsertRequest(
  personalTrainerId: (json['personalTrainerId'] as num).toInt(),
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
);

Map<String, dynamic> _$PersonalTrainerRatingUpsertRequestToJson(
  PersonalTrainerRatingUpsertRequest instance,
) => <String, dynamic>{
  'personalTrainerId': instance.personalTrainerId,
  'rating': instance.rating,
  'comment': instance.comment,
};

PersonalTrainerRatingStats _$PersonalTrainerRatingStatsFromJson(
  Map<String, dynamic> json,
) => PersonalTrainerRatingStats(
  averageRating: (json['averageRating'] as num).toDouble(),
  totalRatings: (json['totalRatings'] as num).toInt(),
);

Map<String, dynamic> _$PersonalTrainerRatingStatsToJson(
  PersonalTrainerRatingStats instance,
) => <String, dynamic>{
  'averageRating': instance.averageRating,
  'totalRatings': instance.totalRatings,
};
