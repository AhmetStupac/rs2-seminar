// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_trainer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonalTrainer _$PersonalTrainerFromJson(Map<String, dynamic> json) =>
    PersonalTrainer(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      userFirstName: json['userFirstName'] as String?,
      yearsOfExperience: (json['yearsOfExperience'] as num?)?.toInt(),
      isActive: json['isActive'] as bool?,
      certifications: json['certifications'] as String?,
      sport: json['sport'] as String?,
    );

Map<String, dynamic> _$PersonalTrainerToJson(PersonalTrainer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userFirstName': instance.userFirstName,
      'yearsOfExperience': instance.yearsOfExperience,
      'isActive': instance.isActive,
      'certifications': instance.certifications,
      'sport': instance.sport,
    };
