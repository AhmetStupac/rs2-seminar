// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gym _$GymFromJson(Map<String, dynamic> json) => Gym(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      workTime: json['workTime'] as String?,
      imageId: (json['imageId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GymToJson(Gym instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'workTime': instance.workTime,
      'imageId': instance.imageId,
    };
