import 'package:json_annotation/json_annotation.dart';
import 'package:personaltrainer_mobile/models/image.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  int? id;
  String? firstName;
  String? lastName;
  String? username;
  String? email;
  String? phoneNumber;
  String? password;
  String? passwordConfirmation;
  bool? isActive;
  int? profileImageId;
  Image? profileImage;
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
    this.password,
    this.passwordConfirmation,
    this.isActive = true,
    this.profileImageId,
    this.profileImage,
    this.isBanned = false,
    this.bannedAt,
    this.banReason,
    this.banExpiresAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
