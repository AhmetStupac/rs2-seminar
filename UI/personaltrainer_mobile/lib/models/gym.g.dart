// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gym _$GymFromJson(Map<String, dynamic> json) => Gym(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  address: json['address'] as String?,
  cityId: (json['cityId'] as num?)?.toInt(),
  cityName: json['cityName'] as String?,
  countryName: json['countryName'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  workTime: json['workTime'] as String?,
  imageId: (json['imageId'] as num?)?.toInt(),
  image: json['image'] == null
      ? null
      : Image.fromJson(json['image'] as Map<String, dynamic>),
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$GymToJson(Gym instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'cityId': instance.cityId,
  'cityName': instance.cityName,
  'countryName': instance.countryName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'workTime': instance.workTime,
  'imageId': instance.imageId,
  'image': instance.image,
  'imageUrl': instance.imageUrl,
};
