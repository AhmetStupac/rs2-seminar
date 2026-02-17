// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'userId': instance.userId,
  'user': instance.user,
  'email': instance.email,
  'message': instance.message,
  'timestamp': instance.timestamp?.toIso8601String(),
  'fromUserId': instance.fromUserId,
  'from': instance.from,
  'toUserId': instance.toUserId,
  'isPrivate': instance.isPrivate,
};

Map<String, dynamic> _$OnlineUserToJson(OnlineUser instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'connectionId': instance.connectionId,
    };
