import 'package:json_annotation/json_annotation.dart';

import 'image.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  int? id;
  String? firstName;
  String? lastName;
  String? username;
  String? email;
  String? phoneNumber;
  int? profileImageId;
  Image? profileImage;
  String? password;
  String? passwordConfirmation;
  bool? isActive;
  final bool isBanned;
  final DateTime? bannedAt;
  final String? banReason;
  final DateTime? banExpiresAt;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.phoneNumber,
    this.profileImageId,
    this.profileImage,
    this.password,
    this.passwordConfirmation,
    this.isActive = true,
    this.isBanned = false,
    this.bannedAt,
    this.banReason,
    this.banExpiresAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
