// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num?)?.toInt(),
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  username: json['username'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  profileImageId: (json['profileImageId'] as num?)?.toInt(),
  profileImage: json['profileImage'] == null
      ? null
      : Image.fromJson(json['profileImage'] as Map<String, dynamic>),
  password: json['password'] as String?,
  passwordConfirmation: json['passwordConfirmation'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  isBanned: json['isBanned'] as bool? ?? false,
  bannedAt: json['bannedAt'] == null
      ? null
      : DateTime.parse(json['bannedAt'] as String),
  banReason: json['banReason'] as String?,
  banExpiresAt: json['banExpiresAt'] == null
      ? null
      : DateTime.parse(json['banExpiresAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'username': instance.username,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'profileImageId': instance.profileImageId,
  'profileImage': instance.profileImage?.toJson(),
  'password': instance.password,
  'passwordConfirmation': instance.passwordConfirmation,
  'isActive': instance.isActive,
  'isBanned': instance.isBanned,
  'bannedAt': instance.bannedAt?.toIso8601String(),
  'banReason': instance.banReason,
  'banExpiresAt': instance.banExpiresAt?.toIso8601String(),
};
