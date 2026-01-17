// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Image _$ImageFromJson(Map<String, dynamic> json) => Image(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  url: json['url'] as String?,
  size: (json['size'] as num?)?.toInt(),
  isHeader: json['isHeader'] as bool?,
  userId: (json['userId'] as num?)?.toInt(),
);

Map<String, dynamic> _$ImageToJson(Image instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'url': instance.url,
  'size': instance.size,
  'isHeader': instance.isHeader,
  'userId': instance.userId,
};
