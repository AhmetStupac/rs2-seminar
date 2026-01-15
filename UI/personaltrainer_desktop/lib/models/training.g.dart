// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Training _$TrainingFromJson(Map<String, dynamic> json) => Training(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  description: json['description'] as String?,
  duration: (json['duration'] as num?)?.toInt(),
  clientId: (json['clientId'] as num?)?.toInt(),
  personalTrainerId: (json['personalTrainerId'] as num?)?.toInt(),
);

Map<String, dynamic> _$TrainingToJson(Training instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'duration': instance.duration,
  'clientId': instance.clientId,
  'personalTrainerId': instance.personalTrainerId,
};
