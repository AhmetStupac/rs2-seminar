import 'package:json_annotation/json_annotation.dart';

part 'personal_trainer_rating.g.dart';

@JsonSerializable()
class PersonalTrainerRatingResponse {
  int? id;
  int? userId;
  String? userName;
  int? personalTrainerId;
  String? personalTrainerName;
  int? rating;
  String? comment;
  DateTime? createdAt;
  DateTime? updatedAt;

  PersonalTrainerRatingResponse({
    this.id,
    this.userId,
    this.userName,
    this.personalTrainerId,
    this.personalTrainerName,
    this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory PersonalTrainerRatingResponse.fromJson(Map<String, dynamic> json) =>
      _$PersonalTrainerRatingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalTrainerRatingResponseToJson(this);
}

@JsonSerializable()
class PersonalTrainerRatingUpsertRequest {
  int personalTrainerId;
  int rating;
  String? comment;

  PersonalTrainerRatingUpsertRequest({
    required this.personalTrainerId,
    required this.rating,
    this.comment,
  });

  factory PersonalTrainerRatingUpsertRequest.fromJson(Map<String, dynamic> json) =>
      _$PersonalTrainerRatingUpsertRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalTrainerRatingUpsertRequestToJson(this);
}

@JsonSerializable()
class PersonalTrainerRatingStats {
  double averageRating;
  int totalRatings;

  PersonalTrainerRatingStats({
    required this.averageRating,
    required this.totalRatings,
  });

  factory PersonalTrainerRatingStats.fromJson(Map<String, dynamic> json) =>
      _$PersonalTrainerRatingStatsFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalTrainerRatingStatsToJson(this);
}
