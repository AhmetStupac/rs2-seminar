// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  userId: json['userId'] as String?,
  user: json['user'] as String?,
  email: json['email'] as String?,
  message: json['message'] as String?,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
  fromUserId: json['fromUserId'] as String?,
  from: json['from'] as String?,
  toUserId: json['toUserId'] as String?,
  isPrivate: json['isPrivate'] as bool? ?? false,
);

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

OnlineUser _$OnlineUserFromJson(Map<String, dynamic> json) => OnlineUser(
  userId: json['userId'] as String? ?? '',
  email: json['email'] as String?,
  firstName: json['firstName'] as String?,
  connectionId: json['connectionId'] as String?,
);

Map<String, dynamic> _$OnlineUserToJson(OnlineUser instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'firstName': instance.firstName,
      'connectionId': instance.connectionId,
    };
